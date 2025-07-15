extends Control

# EndScreen - Victory celebration and navigation options
# Shown when player completes the level

@onready var stats_label: Label = $UI/Stats

var form_switches: int = 0
var completion_time: float = 0.0

func _ready() -> void:
	# Optional: Add celebration animation or effects
	_update_stats_display()

func set_completion_stats(switches: int, time: float) -> void:
	"""Call this from the main level when transitioning to end screen"""
	form_switches = switches
	completion_time = time
	_update_stats_display()

func _update_stats_display() -> void:
	if stats_label:
		var minutes = int(completion_time) / 60
		var seconds = int(completion_time) % 60
		var time_text = "%02d:%02d" % [minutes, seconds]
		
		stats_label.text = "Form switches: %d\nTime: %s" % [form_switches, time_text]

func _on_play_again_button_pressed() -> void:
	# Restart the main level
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_button_pressed() -> void:
	# Return to start menu
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")

# Optional: Add methods for future features
func _show_celebration_animation() -> void:
	# Future: Add sparkles, fade-in effects, etc.
	pass 