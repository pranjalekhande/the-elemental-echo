extends Button

# PauseButton - Simple pause button that can be added to level UI
# Triggers pause when clicked

signal pause_requested

func _ready() -> void:
	# Make sure button works during normal gameplay
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Connect signal if not already connected in scene
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	"""Handle pause button press"""
	pause_requested.emit()
	print("Pause button pressed") 