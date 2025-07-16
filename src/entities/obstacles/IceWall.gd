extends StaticBody2D

signal melting_started
signal melting_finished

@export var melt_time: float = 1.0
@export var melt_delay: float = 0.3
var is_melting := false
var active_tween: Tween

@onready var sprite: CanvasItem = $ColorRect
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# Ensure collision is enabled at start
	collision_shape.set_deferred("disabled", false)

func handle_fire_form(body: Node2D) -> void:
	if is_melting or not is_instance_valid(body):
		return
		
	is_melting = true
	emit_signal("melting_started")
	
	# Add delay before melting starts
	await get_tree().create_timer(melt_delay).timeout
	
	# Check if still valid after delay
	if not is_instance_valid(self):
		return
	
	# Disable collision to allow passage
	collision_shape.set_deferred("disabled", true)
	
	# Create fade effect that continues after wall is gone
	var fade := ColorRect.new()
	fade.size = sprite.size
	fade.position = global_position + sprite.position
	fade.color = sprite.color
	get_parent().add_child(fade)
	
	# Start fade on new rect and store the tween
	active_tween = create_tween()
	active_tween.tween_property(fade, "modulate:a", 0.0, melt_time)
	active_tween.tween_callback(func():
		fade.queue_free()
		emit_signal("melting_finished")
		queue_free()  # Remove wall after fade completes
	)
	
	# Make original sprite invisible immediately
	sprite.visible = false

func _on_body_entered(body: Node) -> void:
	if not is_melting and body is CharacterBody2D and body.has_method("get_current_form"):
		var form = body.get_current_form()
		if form == "fire":
			handle_fire_form(body)
		# Water form should not pass through - collision stays enabled

func _on_body_exited(_body: Node) -> void:
	pass

func _exit_tree() -> void:
	# Cleanup active tween if it exists
	if active_tween and active_tween.is_valid():
		active_tween.kill() 
