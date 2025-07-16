extends StaticBody2D

signal button_pressed
signal button_released

@onready var sprite = $Sprite2D
@onready var area = $Area2D

var is_pressed = false
var bodies_on_button = 0

func _on_body_entered(body):
	if body.name == "Echo":
		bodies_on_button += 1
		if not is_pressed:
			_press_button()

func _on_body_exited(body):
	if body.name == "Echo":
		bodies_on_button -= 1
		if bodies_on_button <= 0 and is_pressed:
			_release_button()

func _press_button():
	is_pressed = true
	# Change sprite to pressed state (adjust region_rect for pressed button sprite)
	sprite.region_rect = Rect2(148, 100, 48, 48)  # Pressed button sprite
	button_pressed.emit()
	print("Button pressed!")

func _release_button():
	is_pressed = false
	# Change sprite back to unpressed state
	sprite.region_rect = Rect2(100, 100, 48, 48)  # Unpressed button sprite
	button_released.emit()
	print("Button released!")

func get_is_pressed() -> bool:
	return is_pressed 