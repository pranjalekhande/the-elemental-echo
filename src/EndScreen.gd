extends Control

# EndScreen - Victory celebration and navigation options
# Shown when player completes the level

@onready var stats_label: Label = $UI/Stats

var form_switches: int = 0
var completion_time: float = 0.0

func _ready() -> void:
	# Get stats from CollectionManager and update display
	_update_comprehensive_stats_display()
	
	# Optional: Add celebration animation or effects
	_show_celebration_based_on_performance()

func set_completion_stats(_switches: int, _time: float) -> void:
	"""Legacy method - stats now come from CollectionManager"""
	_update_comprehensive_stats_display()

func _update_comprehensive_stats_display() -> void:
	if not CollectionManager:
		return
		
	var stats = CollectionManager.get_session_stats()
	
	# Update stats label with comprehensive information
	if stats_label:
		var minutes = int(stats.session_time) / 60
		var seconds = int(stats.session_time) % 60
		var time_text = "%02d:%02d" % [minutes, seconds]
		
		var stats_text = ""
		stats_text += "💎 Diamonds: %d/%d (%.1f%%)\n" % [stats.total_collected, stats.total_available, stats.completion_percent]
		stats_text += "🔥 Fire: %d/%d  💧 Water: %d/%d\n" % [stats.fire_collected, stats.fire_total, stats.water_collected, stats.water_total]
		stats_text += "⚡ Form switches: %d\n" % stats.form_switches
		stats_text += "⏱️ Time: %s\n" % time_text
		stats_text += "\n📊 Score Breakdown:\n"
		stats_text += "Base: %d pts\n" % stats.base_score
		if stats.speed_bonus > 0:
			stats_text += "Speed bonus: +%d pts\n" % stats.speed_bonus
		if stats.efficiency_bonus > 0:
			stats_text += "Efficiency bonus: +%d pts\n" % stats.efficiency_bonus
		if stats.completion_bonus > 0:
			stats_text += "Perfect collection: +%d pts\n" % stats.completion_bonus
		stats_text += "FINAL SCORE: %d pts" % stats.final_score
		
		stats_label.text = stats_text
	
	# Update victory message based on performance
	_update_victory_message(stats)

func _update_victory_message(stats: Dictionary) -> void:
	var victory_message = $UI/VBoxContainer/VictoryMessage
	var celebration = $UI/VBoxContainer/Celebration
	
	if victory_message and celebration:
		if stats.completion_percent >= 100.0:
			victory_message.text = "Echo mastered both elements perfectly!\nEvery crystal found, every heartspring awakened!"
			celebration.text = "✨🏆 PERFECT MASTERY! 🏆✨"
		elif stats.completion_percent >= 75.0:
			victory_message.text = "Echo's elemental harmony grows stronger.\nMost ancient crystals have been gathered!"
			celebration.text = "✨ Excellent Exploration! ✨"
		elif stats.completion_percent >= 50.0:
			victory_message.text = "Echo's journey progresses well.\nThe elements begin to respond to your call."
			celebration.text = "✨ Good Progress! ✨"
		else:
			victory_message.text = "Echo's first steps into elemental mastery.\nMany crystals await discovery on future journeys."
			celebration.text = "✨ Journey Begun! ✨"

func _show_celebration_based_on_performance() -> void:
	"""Future: Add different celebration animations based on performance"""
	pass

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