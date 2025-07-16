extends Area2D
class_name Diamond

# Base Diamond class - handles form-specific collection mechanics
# Extended by FireDiamond and WaterDiamond

signal collected(diamond_type: String, points: int)

@export var diamond_type: String = "neutral"  # "fire", "water", "neutral"
@export var points_value: int = 10
@export var required_form: String = "any"  # Form required to collect this diamond

@onready var sprite: CanvasItem = $Sprite  # Will be ColorRect or Sprite2D
@onready var particles: Node2D = $Particles  # Particle effects
@onready var collection_area: CollisionShape2D = $CollisionShape2D

var is_collected: bool = false
var echo_in_range: Node2D = null
var compatible_form: bool = false
var form_check_timer: Timer

func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up timer for continuous form checking
	form_check_timer = Timer.new()
	form_check_timer.timeout.connect(_check_form_compatibility)
	form_check_timer.wait_time = 0.1  # Check every 100ms
	add_child(form_check_timer)
	
	# Set up initial appearance
	_update_visual_state()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Echo" and not is_collected:
		echo_in_range = body
		# Start continuous form checking
		form_check_timer.start()
		_check_form_compatibility()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Echo":
		echo_in_range = null
		compatible_form = false
		# Stop continuous form checking
		form_check_timer.stop()
		_update_visual_state()

func _check_form_compatibility() -> void:
	if not echo_in_range or is_collected:
		compatible_form = false
		return
		
	# Check if Echo has the required form
	if echo_in_range.has_method("get_current_form"):
		var current_form = echo_in_range.get_current_form()
		compatible_form = (required_form == "any") or (current_form == required_form)
	else:
		compatible_form = true  # Fallback for testing
	
	_update_visual_state()
	
	# Auto-collect if compatible
	if compatible_form and not is_collected:
		_collect_diamond()

func _collect_diamond() -> void:
	if is_collected:
		return
		
	is_collected = true
	
	# Stop form checking timer
	form_check_timer.stop()
	
	# Emit collection signal
	collected.emit(diamond_type, points_value)
	
	# Visual feedback
	_play_collection_animation()
	
	# Notify collection manager
	if CollectionManager:
		CollectionManager.collect_diamond(diamond_type, points_value)
	
	# Remove from scene after animation
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(queue_free)

func _update_visual_state() -> void:
	"""Update visual appearance based on compatibility and collection state"""
	if is_collected:
		return
		
	if sprite:
		if echo_in_range and compatible_form:
			# Bright, active state
			sprite.modulate = Color.WHITE
			sprite.scale = Vector2(1.2, 1.2)
		elif echo_in_range and not compatible_form:
			# Dimmed, incompatible state
			sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)
			sprite.scale = Vector2(1.0, 1.0)
		else:
			# Normal state
			sprite.modulate = Color.WHITE
			sprite.scale = Vector2(1.0, 1.0)

func _play_collection_animation() -> void:
	"""Override in subclasses for specific visual effects"""
	if sprite:
		# Simple scale-up and fade out
		var tween = create_tween()
		tween.parallel().tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.3)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3)

# Virtual methods for subclasses to override
func get_diamond_color() -> Color:
	return Color.WHITE

func get_particle_color() -> Color:
	return Color.WHITE

func reset_diamond() -> void:
	"""Reset diamond to uncollected state - used for level resets"""
	is_collected = false
	echo_in_range = null
	compatible_form = false
	
	# Stop form checking timer
	if form_check_timer:
		form_check_timer.stop()
	
	# Restore visibility and collision
	if sprite:
		sprite.visible = true
		sprite.modulate = Color.WHITE
		sprite.scale = Vector2(1.0, 1.0)
	
	if collection_area:
		collection_area.disabled = false 