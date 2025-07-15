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
	# Configure the sprite appearance
	if sprite:
		if sprite.has_method("set_color"):
			sprite.color = get_diamond_color()
		
		# Add a subtle shimmer effect
		var shimmer_material = CanvasItemMaterial.new()
		shimmer_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		sprite.material = shimmer_material

func get_diamond_color() -> Color:
	# Cool blue-cyan water color
	return Color(0.1, 0.6, 1.0, 0.9)

func get_particle_color() -> Color:
	# Cool water particle color
	return Color(0.3, 0.8, 1.0, 0.8)

func _play_collection_animation() -> void:
	"""Water-specific collection animation with flowing effects"""
	if sprite:
		# Water ripple animation
		var tween = create_tween()
		
		# Quick flash to bright cyan, then fade with ripple effect
		tween.parallel().tween_property(sprite, "modulate", Color(0.5, 1.0, 1.0, 1.0), 0.1)
		tween.parallel().tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
		
		tween.tween_interval(0.1)
		
		# Gentle fade like water dissolving
		tween.parallel().tween_property(sprite, "modulate", Color(0.1, 0.6, 1.0, 0.0), 0.4)
		tween.parallel().tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.4)

func _update_visual_state() -> void:
	"""Water diamond specific visual updates"""
	super._update_visual_state()
	
	if is_collected:
		return
		
	# Add gentle flowing effect when Echo is nearby
	if sprite and echo_in_range:
		if compatible_form:
			# Gentle pulse for compatible form
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(sprite, "modulate:a", 1.1, 0.8)
			tween.tween_property(sprite, "modulate:a", 0.7, 0.8)
		elif not compatible_form:
			# Show incompatibility with fire form
			sprite.modulate = Color(0.1, 0.2, 0.3, 0.5)  # Very dim blue 