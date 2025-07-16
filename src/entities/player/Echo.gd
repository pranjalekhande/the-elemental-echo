extends CharacterBody2D

# Echo - The player character
# Platformer character with gravity-based movement and elemental shifting

const SPEED := 300.0
const GRAVITY := 980.0  # Standard gravity (pixels per second²)
const JUMP_SPEED := 600.0  # Upward velocity when jumping (increased for higher jumps)
var current_form: int = 0  # 0 = FIRE, 1 = WATER (ElementalForms.Form.FIRE/WATER)
var last_position := Vector2.ZERO
var is_changing_form := false
var overlapping_ice_walls: Array[Node] = []

@onready var visual: Polygon2D = $Visual
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar_bg: ColorRect = $UI/HealthBar/Background
@onready var health_bar_fg: ColorRect = $UI/HealthBar/ForegroundBar
@onready var health_label: Label = $UI/HealthBar/Label

func _ready() -> void:
	last_position = position
	_update_form_visual()
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)
	
	# Connect health signals
	health_component.health_changed.connect(_on_health_changed)
	health_component.healed.connect(_on_healed)
	health_component.damaged.connect(_on_damaged)
	
	# Initialize health bar
	_update_health_bar_color()
	_on_health_changed(health_component.current_health, health_component.max_health)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q and not is_changing_form:
		_toggle_form()
	
	# Test controls for health system
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:  # Test damage
			damage(10)
		elif event.keycode == KEY_H:  # Test healing
			heal(15)

func _toggle_form() -> void:
	is_changing_form = true
	current_form = 1 if current_form == 0 else 0  # Toggle between FIRE (0) and WATER (1)
	_update_form_visual()
	
	# Track form switch for collection manager
	if CollectionManager:
		CollectionManager.track_form_switch()
	
	# If changing to fire form, check all overlapping ice walls
	if current_form == 0:  # FIRE
		for wall in overlapping_ice_walls:
			if is_instance_valid(wall) and wall.has_method("handle_fire_form"):
				wall.handle_fire_form(self)
	
	# Use a timer to ensure physics state is updated
	var timer := get_tree().create_timer(0.2)  # Increased timer for better reliability
	timer.timeout.connect(func():
		is_changing_form = false
	)

func get_current_form() -> String:
	"""Return current form as string for diamond compatibility checking"""
	match current_form:
		0:  # FIRE
			return "fire"
		1:  # WATER
			return "water"
		_:
			return "unknown"

func get_current_form_enum() -> int:
	"""Return current form as integer for internal use"""
	return current_form

func _update_form_visual() -> void:
	visual.color = ElementalForms.get_form_color(current_form)
	_update_health_bar_color()

func _physics_process(delta: float) -> void:
	# Store position before move
	last_position = position
	
	# Apply gravity constantly (always pulling downward)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle horizontal movement (left/right input)
	var horizontal_input := Input.get_axis("ui_left", "ui_right")
	if horizontal_input != 0:
		velocity.x = horizontal_input * SPEED
	else:
		velocity.x = 0  # Stop when no input
	
	# Handle jumping (only when on ground)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -JUMP_SPEED  # Negative = upward
	
	# Move the character
	move_and_slide()
		
	# Handle ice wall melting when moving into them
	if current_form == 0:  # FIRE
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.has_method("handle_fire_form"):
				collider.handle_fire_form(self)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.has_method("handle_fire_form"):
		overlapping_ice_walls.append(parent)
		if current_form == 0 and not is_changing_form:  # FIRE
			parent.handle_fire_form(self)

func _on_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	overlapping_ice_walls.erase(parent)

# Health system methods
func _on_health_changed(current_health: int, max_health: int) -> void:
	# Update health bar fill
	var health_percentage = float(current_health) / float(max_health)
	var tween = create_tween()
	tween.tween_property(health_bar_fg, "scale:x", health_percentage, 0.3)
	
	# Update label
	health_label.text = "%d/%d" % [current_health, max_health]
	
	# Low health warning effect
	if health_component.is_low_health():
		_show_low_health_warning()
	else:
		_hide_low_health_warning()

func _update_health_bar_color() -> void:
	if health_bar_fg:
		health_bar_fg.color = ElementalForms.get_form_color(current_form)

func _on_healed(_amount: int) -> void:
	# Create healing particle effect
	_show_healing_effect()

func _on_damaged(_amount: int) -> void:
	# Create damage flash effect
	_show_damage_effect()

func _show_healing_effect() -> void:
	# Blue sparkle effect
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "modulate", Color.CYAN, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.tween_property(visual, "modulate", Color.WHITE, 0.3)
	).set_delay(0.1)

func _show_damage_effect() -> void:
	# Red flash effect
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "modulate", Color.RED, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.tween_property(visual, "modulate", Color.WHITE, 0.2)
	).set_delay(0.1)

func _show_low_health_warning() -> void:
	# Pulsing effect for low health
	if not health_bar_bg.has_method("get_tween") or health_bar_bg.get("_warning_tween") == null:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(health_bar_bg, "modulate", Color(1, 0.5, 0.5, 1), 0.5)
		tween.tween_property(health_bar_bg, "modulate", Color.WHITE, 0.5)
		health_bar_bg.set("_warning_tween", tween)

func _hide_low_health_warning() -> void:
	if health_bar_bg.has_method("get") and health_bar_bg.get("_warning_tween") != null:
		health_bar_bg.get("_warning_tween").kill()
		health_bar_bg.set("_warning_tween", null)
		health_bar_bg.modulate = Color.WHITE

# Public methods for external damage/healing
func heal(amount: int) -> void:
	health_component.heal(amount)

func damage(amount: int) -> void:
	health_component.damage(amount)
