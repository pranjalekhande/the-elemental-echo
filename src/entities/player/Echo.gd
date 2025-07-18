extends CharacterBody2D

# Echo - The player character
# Platformer character with gravity-based movement and elemental shifting

const SPEED := 200.0
const GRAVITY := 980.0  # Standard gravity (pixels per second²)
const JUMP_SPEED := 600.0  # Upward velocity when jumping (scaled for level)
var current_form: int = 0  # 0 = FIRE, 1 = WATER (ElementalForms.Form.FIRE/WATER)
var last_position := Vector2.ZERO
var is_changing_form := false
var overlapping_ice_walls: Array[Node] = []

# Dynamic scaling system
var base_scale: float = 0.55  # Default scale factor (increased for better visibility)
var current_scale: float = 0.55  # Current applied scale
var base_resolution: Vector2 = Vector2(1920, 1080)  # Design base resolution
var min_scale: float = 0.2  # Minimum scale for small screens
var max_scale: float = 0.5  # Maximum scale for large screens

# Form positioning adjustments
var water_form_offset: float = 15.0  # Y offset for water form to fix gap issue

@onready var animated_sprite: AnimatedSprite2D = $EchoAnimatedSprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar_bg: ColorRect = $UI/HealthBar/Background
@onready var health_bar_fg: ColorRect = $UI/HealthBar/ForegroundBar
@onready var health_label: Label = $UI/HealthBar/Label

# Animation state tracking
var last_animation_name: String = ""
var last_horizontal_input: float = 0.0

# Walking sound system
var walking_sound_timer: Timer
var is_walking_sound_playing: bool = false
var walking_sound_interval: float = 0.4  # Time between footstep sounds

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
	
	# Setup responsive scaling
	_setup_responsive_scaling()
	
	# Apply initial form positioning
	call_deferred("_apply_form_position_adjustment")
	
	# Setup walking sound timer
	walking_sound_timer = Timer.new()
	walking_sound_timer.wait_time = walking_sound_interval
	walking_sound_timer.timeout.connect(_play_walking_sound)
	add_child(walking_sound_timer)

func _setup_responsive_scaling() -> void:
	"""Setup dynamic scaling based on viewport and platform"""
	# Connect to viewport size changes
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Apply initial scaling
	call_deferred("_update_dynamic_scale")

func _on_viewport_resized() -> void:
	"""Handle viewport resize to update Echo's scale"""
	_update_dynamic_scale()

func _update_dynamic_scale() -> void:
	"""Calculate and apply appropriate scale based on screen size and platform"""
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate scale factors
	var width_scale = viewport_size.x / base_resolution.x
	var height_scale = viewport_size.y / base_resolution.y
	var viewport_scale = min(width_scale, height_scale)
	
	# Platform-specific scaling adjustments
	var platform_multiplier = _get_platform_scale_multiplier()
	var aspect_ratio = viewport_size.x / viewport_size.y
	var aspect_multiplier = _get_aspect_ratio_multiplier(aspect_ratio)
	
	# Calculate final scale
	var new_scale = base_scale * viewport_scale * platform_multiplier * aspect_multiplier
	new_scale = clamp(new_scale, min_scale, max_scale)
	
	# Only update if scale changed significantly (avoid unnecessary updates)
	if abs(new_scale - current_scale) > 0.01:
		current_scale = new_scale
		_apply_scale_with_transition()
	
	# Only apply scale when it changes significantly
	if abs(new_scale - current_scale) > 0.01:
		pass

func _apply_scale_with_transition() -> void:
	"""Apply the current scale with smooth transition to sprite and collision"""
	if not animated_sprite:
		return
	
	# Smooth transition for sprite scale
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE * current_scale, 0.3)
	
	# Maintain form-specific positioning after scaling
	call_deferred("_apply_form_position_adjustment")
	
	# Proportionally scale collision shapes for accurate physics
	_scale_collision_shapes()

func _apply_form_position_adjustment() -> void:
	"""Apply form-specific position adjustments to fix sprite alignment differences"""
	if not animated_sprite:
		return
	
	var base_position = Vector2(0, -50)  # Base sprite position
	var form_offset = Vector2.ZERO
	
	# Water form sprites are positioned differently in their frames
	# Apply offset to align water form properly with platforms
	if current_form == 1:  # WATER form (ElementalForms.Form.WATER)
		form_offset = Vector2(0, water_form_offset)  # Move water form down by offset
	else:  # FIRE form (ElementalForms.Form.FIRE = 0)
		form_offset = Vector2.ZERO  # Fire form uses base position
	
	var final_position = base_position + form_offset
	
	# Apply position smoothly to avoid jarring transitions
	var tween = create_tween()
	tween.tween_property(animated_sprite, "position", final_position, 0.2)

func _scale_collision_shapes() -> void:
	"""Scale collision shapes proportionally to maintain accurate physics"""
	# Note: We don't scale collision shapes as it can break physics
	# Instead, we maintain base collision size for consistent gameplay
	# The visual appearance scales, but physics remains reliable
	pass

func get_visual_scale() -> float:
	"""Get the current visual scale factor for other systems that need it"""
	return current_scale

func get_scaling_info() -> Dictionary:
	"""Get comprehensive scaling information for other systems"""
	var viewport_size = get_viewport().get_visible_rect().size
	var aspect_ratio = viewport_size.x / viewport_size.y
	
	return {
		"visual_scale": current_scale,
		"base_scale": base_scale,
		"viewport_size": viewport_size,
		"aspect_ratio": aspect_ratio,
		"platform_multiplier": _get_platform_scale_multiplier(),
		"aspect_multiplier": _get_aspect_ratio_multiplier(aspect_ratio)
	}

# Static method for other objects to calculate appropriate scaling
static func calculate_responsive_scale(base_scale_value: float = 0.55) -> float:
	"""Calculate responsive scale for other game objects"""
	var viewport = Engine.get_main_loop().current_scene.get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var base_resolution = Vector2(1920, 1080)
	
	var width_scale = viewport_size.x / base_resolution.x
	var height_scale = viewport_size.y / base_resolution.y
	var viewport_scale = min(width_scale, height_scale)
	
	var platform_multiplier = 1.2 if OS.has_feature("mobile") else 1.0
	var aspect_ratio = viewport_size.x / viewport_size.y
	var aspect_multiplier = 1.3 if aspect_ratio < 1.3 else 1.0
	
	return clamp(base_scale_value * viewport_scale * platform_multiplier * aspect_multiplier, 0.2, 0.5)

func _get_platform_scale_multiplier() -> float:
	"""Get platform-specific scale multiplier"""
	# Check if running on mobile platform
	if OS.has_feature("mobile"):
		return 1.2  # Slightly larger on mobile for better touch interaction
	elif OS.has_feature("web"):
		return 1.1  # Slightly larger on web for visibility
	else:
		return 1.0  # Standard scale for desktop

func _get_aspect_ratio_multiplier(aspect_ratio: float) -> float:
	"""Adjust scale based on screen aspect ratio"""
	var standard_aspect = 16.0 / 9.0  # 1.778
	
	if aspect_ratio < 1.3:  # Portrait or square (mobile portrait)
		return 1.3  # Larger for portrait orientation
	elif aspect_ratio > 2.1:  # Ultra-wide screens
		return 0.9  # Slightly smaller for ultra-wide
	elif aspect_ratio < standard_aspect:  # More square-ish (4:3, etc.)
		return 1.1  # Slightly larger for more square screens
	else:
		return 1.0  # Standard for 16:9 and similar

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q and not is_changing_form:
		_toggle_form()
	
	# Development scaling controls (only in debug builds)
	if OS.is_debug_build() and event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD:  # + key
			_adjust_base_scale(0.05)
		elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:  # - key
			_adjust_base_scale(-0.05)
		elif event.keycode == KEY_0:  # Reset to default
			_reset_scale_to_default()
		elif event.keycode == KEY_BRACKETLEFT:  # [ key - adjust water form up
			_adjust_water_form_offset(-2)
		elif event.keycode == KEY_BRACKETRIGHT:  # ] key - adjust water form down
			_adjust_water_form_offset(2)
	
	# Test controls for health system
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:  # Test damage
			damage(10)
		elif event.keycode == KEY_H:  # Test healing
			heal(15)
		elif event.keycode == KEY_1:  # Test form switch sound
			if AudioManager:
				AudioManager.debug_play_sound("form_switch")
		elif event.keycode == KEY_2:  # Test coin sound
			if AudioManager:
				AudioManager.debug_play_sound("coin")
		elif event.keycode == KEY_3:  # Test completion sound
			if AudioManager:
				AudioManager.debug_play_sound("complete")
		elif event.keycode == KEY_4:  # Test walking sound
			if AudioManager:
				AudioManager.debug_play_sound("walking")
		elif event.keycode == KEY_M:  # Toggle background music
			if AudioManager:
				if AudioManager.is_music_playing:
					AudioManager.stop_background_music()
				else:
					AudioManager.play_background_music()

func _adjust_base_scale(adjustment: float) -> void:
	"""Adjust base scale for testing (debug only)"""
	base_scale = clamp(base_scale + adjustment, 0.1, 1.0)

	_update_dynamic_scale()

func _reset_scale_to_default() -> void:
	"""Reset scale to default values (debug only)"""
	base_scale = 0.55

	_update_dynamic_scale()

func _adjust_water_form_offset(adjustment: float) -> void:
	"""Adjust water form vertical offset for testing (debug only)"""
	water_form_offset = clamp(water_form_offset + adjustment, -50.0, 50.0)

	if current_form == ElementalForms.Form.WATER:
		_apply_form_position_adjustment()

func _toggle_form() -> void:
	is_changing_form = true
	current_form = 1 if current_form == 0 else 0  # Toggle between FIRE (0) and WATER (1)
	
	# Play form switching sound effect
	if AudioManager:
		AudioManager.form_switch_sfx.play()
	
	_update_form_visual()
	
	# Track form switch for collection manager
	if CollectionManager:
		CollectionManager.track_form_switch()
	
	# If changing to fire form, check all overlapping ice walls
	if current_form == 0:  # FIRE
		# Create a copy of the array to avoid modification during iteration
		var walls_to_check = overlapping_ice_walls.duplicate()
		for wall in walls_to_check:
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
	
	# Apply form-specific position adjustments to fix sprite alignment differences
	_apply_form_position_adjustment()

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
	
	# Handle walking sound
	_handle_walking_sound()
	
	# Clean up invalid ice wall references periodically
	_cleanup_ice_wall_references()
		
	# Handle ice wall melting when moving into them
	if current_form == 0:  # FIRE
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if is_instance_valid(collider) and collider.has_method("handle_fire_form"):
				collider.handle_fire_form(self)

func _on_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	var parent = area.get_parent()
	if is_instance_valid(parent) and parent.has_method("handle_fire_form"):
		overlapping_ice_walls.append(parent)
		if current_form == 0 and not is_changing_form:  # FIRE
			parent.handle_fire_form(self)

func _on_area_exited(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	var parent = area.get_parent()
	if is_instance_valid(parent):
		overlapping_ice_walls.erase(parent)

func _cleanup_ice_wall_references() -> void:
	"""Remove invalid ice wall references from the array"""
	for i in range(overlapping_ice_walls.size() - 1, -1, -1):
		if not is_instance_valid(overlapping_ice_walls[i]):
			overlapping_ice_walls.remove_at(i)

func _handle_walking_sound() -> void:
	"""Handle walking sound effects based on movement state"""
	var is_moving_on_ground = is_on_floor() and abs(last_horizontal_input) > 0.1
	
	if is_moving_on_ground and not is_walking_sound_playing:
		# Start playing walking sounds
		is_walking_sound_playing = true
		walking_sound_timer.start()
		_play_walking_sound()  # Play first sound immediately
	elif not is_moving_on_ground and is_walking_sound_playing:
		# Stop playing walking sounds
		is_walking_sound_playing = false
		walking_sound_timer.stop()

func _play_walking_sound() -> void:
	"""Play a single footstep sound"""
	if is_walking_sound_playing and AudioManager:
		# Use walking sound (already configured in AudioManager)
		AudioManager.walking_sfx.play()

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
	if not animated_sprite:
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
		
		last_animation_name = animation_name
	
	# Handle sprite direction for walking animations
	_handle_sprite_direction()

func _handle_sprite_direction() -> void:
	"""Manage sprite flipping based on movement direction"""
	if not animated_sprite:
		return
		
	# Only flip for horizontal movement to avoid flipping during jumps/falls
	if abs(last_horizontal_input) > 0.1 and is_on_floor():
		var should_flip = last_horizontal_input < 0
		animated_sprite.flip_h = should_flip



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
	if not animated_sprite:
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)
	).set_delay(0.1)

func _show_damage_effect() -> void:
	# Red flash effect
	if not animated_sprite:
		return
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_callback(func(): 
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)
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
