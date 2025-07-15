extends Area2D

# TextTrigger - Invisible areas that show text when Echo enters

@export var trigger_message: String = "Default message"
@export var cooldown_time: float = 8.0
@export var show_once: bool = false

var text_tag: Control
var has_triggered: bool = false
var on_cooldown: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Create text tag instance (deferred to avoid timing issues)
	call_deferred("_setup_text_tag")

func _setup_text_tag():
	var text_tag_scene = preload("res://scenes/TextTag.tscn")
	text_tag = text_tag_scene.instantiate()
	get_tree().current_scene.add_child(text_tag)

func _on_body_entered(body: Node2D):
	# Only trigger for Echo, and respect cooldown/once rules
	if body.name != "Echo" or on_cooldown or (show_once and has_triggered):
		return
	
	# Show the message
	text_tag.show_text(trigger_message)
	has_triggered = true
	
	# Start cooldown
	if not show_once:
		on_cooldown = true
		var timer = get_tree().create_timer(cooldown_time)
		timer.timeout.connect(func(): on_cooldown = false) 
