extends Control

# StartMenu - Main menu for The Elemental Echo
# Handles navigation to level selection and quick play

@onready var play_button: Button = $UI/VBoxContainer/PlayButton

func _ready() -> void:
	# Connect button signals if not already connected in scene
	if play_button and not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed() -> void:
	# Navigate to level selection menu
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

# Optional: Add methods for future menu options
func _on_settings_button_pressed() -> void:
	# Future: Open settings menu
	pass

func _on_quit_button_pressed() -> void:
	# Quit game
	get_tree().quit() 