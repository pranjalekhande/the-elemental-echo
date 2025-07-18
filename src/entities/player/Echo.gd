extends CharacterBody2D

# Echo - The player character
# Platformer character with gravity-based movement and elemental shifting

const SPEED := 300.0
const GRAVITY := 980.0  # Standard gravity (pixels per second²)
const JUMP_SPEED := 800.0  # Upward velocity when jumping (scaled for level)
var current_form: int = 0  # 0 = FIRE, 1 = WATER (ElementalForms.Form.FIRE/WATER)
var last_position := Vector2.ZERO
var is_changing_form := false
var overlapping_ice_walls: Array[Node] = []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animated_sprite_body: AnimatedSprite2D = $AnimatedSpriteBody
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar_bg: ColorRect = $UI/HealthBar/Background
@onready var health_bar_fg: ColorRect = $UI/HealthBar/ForegroundBar
@onready var health_label: Label = $UI/HealthBar/Label

# Animation state tracking
var last_animation_name: String = ""
var last_horizontal_input: float = 0.0

# Step separation system
var step_timer: float = 0.0
var step_alternate: bool = false
var fire_body_position: Vector2 = Vector2(0, 35)  # Fire form - more separation
var water_body_position: Vector2 = Vector2(0, 35)  # Water form - normal separation
var fire_head_position: Vector2 = Vector2(0, -10)  # Fire form - head position
var water_head_position: Vector2 = Vector2(0, 5)    # Water form - head lower for alignment
var step_offset_vertical: float = 4.0  # Reduced vertical movement during steps
var step_offset_horizontal: float = 15.0  # Horizontal lean during walking
var current_step_tween: Tween  # Track current tween to avoid conflicts

func _ready() -> void:
	# Add Echo to player group for easy finding
	add_to_group("player")
	
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
	_update_health_bar_color()
	# Force animation update when form changes
	last_animation_name = ""
	_update_movement_animation()
	
	# Reset body position when changing forms to new form-specific position
	if animated_sprite_body:
		animated_sprite_body.position = _get_base_body_position()
	
	# Reset head position when changing forms to new form-specific position
	if animated_sprite:
		animated_sprite.position = _get_base_head_position()

func _physics_process(delta: float) -> void:
	# Store position before move
	last_position = position
	
	# Apply gravity constantly (always pulling downward)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle horizontal movement (left/right input)
	var horizontal_input := Input.get_axis("ui_left", "ui_right")
	last_horizontal_input = horizontal_input  # Track for animation system
	
	if horizontal_input != 0:
		velocity.x = horizontal_input * SPEED
	else:
		velocity.x = 0  # Stop when no input
	
	# Handle jumping (only when on ground)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -JUMP_SPEED  # Negative = upward
	
	# Move the character
	move_and_slide()
	
	# Update animations based on current state
	_update_movement_animation()
	
	# Update step separation effect
	_update_step_separation(delta)
		
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

# Animation System Methods
func _get_animation_name(base_animation: String) -> String:
	"""Get form-aware animation name"""
	if current_form == ElementalForms.Form.WATER:
		return "water_" + base_animation
	return base_animation

func _get_current_movement_state() -> String:
	"""Determine current movement state from physics"""
	# Priority: jump > fall > walk > idle
	if velocity.y < -50:  # Going up with threshold for small fluctuations
		return "jump"
	elif velocity.y > 50 and not is_on_floor():  # Going down and not on ground
		return "fall"
	elif abs(last_horizontal_input) > 0.1 and is_on_floor():  # Moving horizontally on ground
		return "walk_right" if last_horizontal_input > 0 else "walk_left"
	else:
		return "idle"

func _update_movement_animation() -> void:
	"""Update animation based on current movement and form"""
	if not animated_sprite or not animated_sprite_body:
		return
		
	var movement_state = _get_current_movement_state()
	var animation_name = _get_animation_name(movement_state)
	
	# Only update if animation changed (performance optimization)
	if animation_name != last_animation_name:
		# Update head animation
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			push_warning("Head animation not found: " + animation_name)
		
		# Update body animation (same name, different sprite frames)
		if animated_sprite_body.sprite_frames and animated_sprite_body.sprite_frames.has_animation(animation_name):
			animated_sprite_body.play(animation_name)
		else:
			push_warning("Body animation not found: " + animation_name)
		
		last_animation_name = animation_name
	
	# Handle sprite direction for walking animations
	_handle_sprite_direction()

func _handle_sprite_direction() -> void:
	"""Manage sprite flipping based on movement direction"""
	if not animated_sprite or not animated_sprite_body:
		return
		
	# Only flip for horizontal movement to avoid flipping during jumps/falls
	if abs(last_horizontal_input) > 0.1 and is_on_floor():
		var should_flip = last_horizontal_input < 0
		animated_sprite.flip_h = should_flip
		animated_sprite_body.flip_h = should_flip

func _get_base_body_position() -> Vector2:
	"""Get form-specific body position"""
	if current_form == ElementalForms.Form.FIRE:
		return fire_body_position
	else:
		return water_body_position

func _get_base_head_position() -> Vector2:
	"""Get form-specific head position"""
	if current_form == ElementalForms.Form.FIRE:
		return fire_head_position
	else:
		return water_head_position

func _update_step_separation(delta: float) -> void:
	"""Create step separation effect during walking"""
	if not animated_sprite_body:
		return
	
	var is_walking = abs(last_horizontal_input) > 0.1 and is_on_floor()
	var base_position = _get_base_body_position()
	
	if is_walking:
		# Update step timer (controls rhythm of steps)
		step_timer += delta * 12.0  # Speed of step alternation
		
		# Check if we should alternate step (roughly every 0.25 seconds)
		if step_timer >= 3.0:
			step_alternate = !step_alternate
			step_timer = 0.0
		
		# Apply alternating vertical offset (reduced for subtlety)
		var offset_y = step_offset_vertical if step_alternate else -step_offset_vertical
		
		# Apply horizontal lean based on walking direction
		var offset_x = 0.0
		if last_horizontal_input < 0:  # Walking left
			offset_x = -step_offset_horizontal
		elif last_horizontal_input > 0:  # Walking right
			offset_x = step_offset_horizontal
		
		var target_position = base_position + Vector2(offset_x, offset_y)
		
		# Smooth transition to new position (avoid creating multiple tweens)
		if current_step_tween:
			current_step_tween.kill()
		current_step_tween = create_tween()
		current_step_tween.tween_property(animated_sprite_body, "position", target_position, 0.1)
		
	else:
		# Reset to base position when not walking
		if current_step_tween:
			current_step_tween.kill()
		current_step_tween = create_tween()
		current_step_tween.tween_property(animated_sprite_body, "position", base_position, 0.2)
		step_timer = 0.0

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
	if not animated_sprite or not animated_sprite_body:
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_property(animated_sprite_body, "modulate", Color.CYAN, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)
		fade_tween.tween_property(animated_sprite_body, "modulate", Color.WHITE, 0.3)
	).set_delay(0.1)

func _show_damage_effect() -> void:
	# Red flash effect
	if not animated_sprite or not animated_sprite_body:
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite_body, "modulate", Color.RED, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)
		fade_tween.tween_property(animated_sprite_body, "modulate", Color.WHITE, 0.2)
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
