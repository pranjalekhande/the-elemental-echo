extends Diamond
class_name WaterDiamond

# WaterDiamond - Collectible only by Water form Echo
# Glowing blue/cyan crystal with water particle effects

func _ready() -> void:
	# Set water-specific properties
	diamond_type = "water"
	required_form = "water"
	points_value = 10
	
	# Call parent ready
	super._ready()
	
	# Set up water-specific visuals
	_setup_water_visuals()

func _setup_water_visuals() -> void:
	# Configure the animated sprite
	if sprite and sprite is AnimatedSprite2D:
		sprite.animation = "blue_idle"
		sprite.play()

func get_diamond_color() -> Color:
	# Cool blue-cyan water color
	return Color(0.1, 0.6, 1.0, 0.9)

func get_particle_color() -> Color:
	# Cool water particle color
	return Color(0.3, 0.8, 1.0, 0.8)

func _update_visual_state() -> void:
	"""Update visual appearance based on compatibility and collection state"""
	if is_collected:
		return
		
	if sprite and sprite is AnimatedSprite2D:
		# Store current scale to preserve level scaling
		var current_scale = sprite.scale
		
		if echo_in_range and compatible_form:
			# Bright, active state - play sparkle animation
			sprite.animation = "blue_sparkle"
			sprite.modulate = Color.WHITE
			# Maintain scale but add slight interaction feedback
			sprite.scale = current_scale * 1.1
		elif echo_in_range and not compatible_form:
			# Dimmed, incompatible state
			sprite.animation = "blue_idle"
			sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)
			sprite.scale = current_scale
		else:
			# Normal state
			sprite.animation = "blue_idle"
			sprite.modulate = Color.WHITE
			sprite.scale = current_scale

func _play_collection_animation() -> void:
	"""Enhanced water-specific collection animation with flowing effects"""
	if sprite and sprite is AnimatedSprite2D:
		# Multi-stage water ripple animation
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Stage 1: Quick flash to bright cyan
		tween.tween_property(sprite, "modulate", Color(0.5, 1.0, 1.0, 1.0) * 1.3, 0.1)
		tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
		
		# Stage 2: Gentle ripple effect with oscillation
		var ripple_tween = create_tween()
		ripple_tween.set_loops(3)
		ripple_tween.tween_property(sprite, "scale", Vector2(1.4, 1.2), 0.1)
		ripple_tween.tween_property(sprite, "scale", Vector2(1.2, 1.4), 0.1)
		
		# Stage 3: Gentle fade like water dissolving
		tween.tween_interval(0.1)
		tween.tween_property(sprite, "modulate", Color(0.1, 0.6, 1.0, 0.0), 0.4)
		tween.tween_property(sprite, "scale", Vector2(2.5, 2.5), 0.4)
		
		# Enhanced shimmer effects
		_animate_shimmer_effects()

func _animate_shimmer_effects() -> void:
	"""Animate the shimmer effects during collection"""
	var outer_glow = get_node_or_null("OuterGlow")
	var inner_glow = get_node_or_null("Sprite/InnerGlow")
	
	if outer_glow:
		var shimmer_tween = create_tween()
		shimmer_tween.set_parallel(true)
		shimmer_tween.tween_property(outer_glow, "modulate:a", 0.8, 0.1)
		shimmer_tween.tween_property(outer_glow, "scale", Vector2(2.5, 2.5), 0.5)
		shimmer_tween.tween_interval(0.1)
		shimmer_tween.tween_property(outer_glow, "modulate:a", 0.0, 0.4)
	
	if inner_glow:
		var inner_tween = create_tween()
		inner_tween.set_parallel(true)
		inner_tween.tween_property(inner_glow, "modulate:a", 0.6, 0.1)
		inner_tween.tween_property(inner_glow, "scale", Vector2(1.8, 1.8), 0.5)
		inner_tween.tween_interval(0.1)
		inner_tween.tween_property(inner_glow, "modulate:a", 0.0, 0.4) 
