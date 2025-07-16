extends StaticBody2D

@onready var sprite = $DoorSprite
@onready var collision = $DoorCollision

var is_open = false

func _on_button_pressed():
	open_door()

func _on_button_released():
	close_door()

func open_door():
	if not is_open:
		is_open = true
		# Make door transparent and disable collision
		sprite.modulate = Color(0.5, 0.3, 0.2, 0.3)
		collision.disabled = true
		print("Door opened!")

func close_door():
	if is_open:
		is_open = false
		# Restore door appearance and enable collision
		sprite.modulate = Color(0.5, 0.3, 0.2, 1.0)
		collision.disabled = false
		print("Door closed!") 