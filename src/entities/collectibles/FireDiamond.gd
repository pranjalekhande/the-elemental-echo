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
	# Configure the sprite appearance
	if sprite:
		if sprite.has_method("set_color"):
			sprite.color = get_diamond_color()
		
		# Add a subtle glow effect
		var glow_material = CanvasItemMaterial.new()
		glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		sprite.material = glow_material

func get_diamond_color() -> Color:
	# Bright orange-red fire color
	return Color(1.0, 0.4, 0.1, 0.9)

func get_particle_color() -> Color:
	# Warm fire particle color
	return Color(1.0, 0.6, 0.2, 0.8)

func _play_collection_animation() -> void:
	"""Fire-specific collection animation with flame effects"""
	if sprite:
		# Fire burst animation
		var tween = create_tween()
		
		# Quick flash to bright white, then fade
		tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)
		tween.parallel().tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1)
		
		tween.tween_interval(0.1)
		
		tween.parallel().tween_property(sprite, "modulate", Color(1.0, 0.4, 0.1, 0.0), 0.3)
		tween.parallel().tween_property(sprite, "scale", Vector2(2.5, 2.5), 0.3)

func _update_visual_state() -> void:
	"""Fire diamond specific visual updates"""
	super._update_visual_state()
	
	if is_collected:
		return
		
	# Add pulsing fire effect when Echo is nearby
	if sprite and echo_in_range:
		if compatible_form:
			# Pulse brighter for compatible form
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(sprite, "modulate:a", 1.2, 0.5)
			tween.tween_property(sprite, "modulate:a", 0.8, 0.5)
		elif not compatible_form:
			# Show incompatibility with water form
			sprite.modulate = Color(0.3, 0.1, 0.1, 0.5)  # Very dim red 