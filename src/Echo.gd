extends CharacterBody2D

# Echo - The player character
# Floats freely with simple 8-direction movement and elemental shifting

enum Form { FIRE, WATER }
var current_form: Form = Form.FIRE

const SPEED := 300.0

@onready var visual: Polygon2D = $Visual

func _ready():
	_update_form_visual()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_toggle_form()

func _toggle_form():
	current_form = Form.WATER if current_form == Form.FIRE else Form.FIRE
	_update_form_visual()

func _update_form_visual():
	visual.color = Color(1,0.6,0.1) if current_form == Form.FIRE else Color(0.1,0.8,1)

func get_current_form() -> Form:
	return current_form

func _physics_process(delta):
	var input_vector := Vector2(
		int(Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_LEFT)),
		int(Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_UP))
	)
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
	velocity = input_vector * SPEED
	move_and_slide() 
