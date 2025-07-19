extends Diamond
class_name FireDiamond

# FireDiamond - Collectible only by Fire form Echo
# Glowing red/orange crystal with fire particle effects

func _ready() -> void:
	# Set fire-specific properties
	diamond_type = "fire"
	required_form = "fire"
	points_value = 10
	
	# Call parent ready
	super._ready()
	
	# Set up fire-specific visuals
	_setup_fire_visuals()

func _setup_fire_visuals() -> void:
	# Configure the animated sprite
	if sprite and sprite is AnimatedSprite2D:
		sprite.animation = "red_idle"
		sprite.play()

func get_diamond_color() -> Color:
	# Bright orange-red fire color
	return Color(1.0, 0.4, 0.1, 0.9)

func get_particle_color() -> Color:
	# Warm fire particle color
	return Color(1.0, 0.6, 0.2, 0.8)

func _update_visual_state() -> void:
	"""Update visual appearance based on compatibility and collection state"""
	if is_collected:
		return
		
	if sprite and sprite is AnimatedSprite2D:
		# Store current scale to preserve level scaling
		var current_scale = sprite.scale
		
		if echo_in_range and compatible_form:
			# Bright, active state - play sparkle animation
			sprite.animation = "red_sparkle"
			sprite.modulate = Color.WHITE
			# Maintain scale but add slight interaction feedback
			sprite.scale = current_scale * 1.1
		elif echo_in_range and not compatible_form:
			# Dimmed, incompatible state
			sprite.animation = "red_idle"
			sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)
			sprite.scale = current_scale
		else:
			# Normal state
			sprite.animation = "red_idle"
			sprite.modulate = Color.WHITE
			sprite.scale = current_scale

func _play_collection_animation() -> void:
	"""Enhanced fire-specific collection animation with multi-stage effects"""
	if sprite and sprite is AnimatedSprite2D:
		# Multi-stage fire burst animation
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Stage 1: Quick flash to bright white
		tween.tween_property(sprite, "modulate", Color.WHITE * 1.5, 0.1)
		tween.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.1)
		
		# Stage 2: Fire burst with rotation
		tween.tween_property(sprite, "rotation", TAU * 2, 0.4)
		
		# Stage 3: Fade with expanding scale
		tween.tween_interval(0.1)
		tween.tween_property(sprite, "modulate", Color(1.0, 0.4, 0.1, 0.0), 0.3)
		tween.tween_property(sprite, "scale", Vector2(3.0, 3.0), 0.3)
		
		# Enhanced glow effects
		_animate_glow_effects()

func _animate_glow_effects() -> void:
	"""Animate the glow effects during collection"""
	var outer_glow = get_node_or_null("OuterGlow")
	var inner_glow = get_node_or_null("Sprite/InnerGlow")
	
	if outer_glow:
		var glow_tween = create_tween()
		glow_tween.set_parallel(true)
		glow_tween.tween_property(outer_glow, "modulate:a", 1.0, 0.1)
		glow_tween.tween_property(outer_glow, "scale", Vector2(3.0, 3.0), 0.4)
		glow_tween.tween_interval(0.1)
		glow_tween.tween_property(outer_glow, "modulate:a", 0.0, 0.3)
	
	if inner_glow:
		var inner_tween = create_tween()
		inner_tween.set_parallel(true)
		inner_tween.tween_property(inner_glow, "modulate:a", 0.8, 0.1)
		inner_tween.tween_property(inner_glow, "scale", Vector2(2.0, 2.0), 0.4)
		inner_tween.tween_interval(0.1)
		inner_tween.tween_property(inner_glow, "modulate:a", 0.0, 0.3) 
