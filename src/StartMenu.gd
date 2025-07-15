extends Control

# StartMenu - Main menu for The Elemental Echo
# Handles navigation to main game scene

func _ready() -> void:
	# Optional: Add fade-in animation or intro effects
	pass

func _on_play_button_pressed() -> void:
	# Transition to main game scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# Optional: Add methods for future menu options
func _on_settings_button_pressed() -> void:
	# Future: Open settings menu
	pass

func _on_quit_button_pressed() -> void:
	# Future: Quit game
	get_tree().quit() 