extends Area2D

# Heartspring - The goal that Echo must reach and activate
# Represents the First Fading Heartspring from the story

signal activated
@export var healing_amount: int = 25
@export var activation_cooldown: float = 2.0

var is_activated = false
var can_activate = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Echo" and can_activate and not is_activated:
		activate(body)

func activate(echo: Node2D = null) -> void:
	if is_activated or not can_activate:
		return
		
	is_activated = true
	can_activate = false
	
	# Heal the Echo if it has a heal method
	if echo and echo.has_method("heal"):
		echo.heal(healing_amount)
	
	# Emit activation signal for other systems
	activated.emit()
	
	# Visual/audio feedback would go here
	print("Heartspring activated! Healing provided.")
	
	# Transition to end screen after brief delay
	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(func():
		_go_to_end_screen()
	)

func _go_to_end_screen() -> void:
	# TODO: Pass stats from Echo/Level if available
	get_tree().change_scene_to_file("res://scenes/EndScreen.tscn") 