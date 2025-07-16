extends Control

# EndScreen - Victory celebration and navigation options with progress tracking
# Shown when player completes the level

@onready var stats_label: Label = $UI/Stats
@onready var play_again_button: Button = $UI/VBoxContainer/ButtonContainer/PlayAgainButton
@onready var main_menu_button: Button = $UI/VBoxContainer/ButtonContainer/MainMenuButton

var form_switches: int = 0
var completion_time: float = 0.0
var current_level: String = "level_1"  # Track which level was completed
var completion_data: Dictionary = {}
var is_new_record: bool = false

func _ready() -> void:
	# Detect which level was completed
	_detect_current_level()
	
	# Get stats from CollectionManager and save to ProgressManager
	_save_completion_data()
	
	# Update display with stats and record information
	_update_comprehensive_stats_display()
	
	# Update button text based on level
	_update_button_text()
	
	# Show celebration based on performance
	_show_celebration_based_on_performance()

func _detect_current_level() -> void:
	"""Detect which level was just completed"""
	var scene_path = get_tree().current_scene.scene_file_path
	if scene_path.contains("Level2"):
		current_level = "level_2"
	else:
		current_level = "level_1"

func set_completed_level(level: String) -> void:
	"""Manually set which level was completed"""
	current_level = level
	_update_button_text()

func _save_completion_data() -> void:
	"""Save completion data to ProgressManager and check for records"""
	if not CollectionManager:
		return
	
	completion_data = CollectionManager.get_session_stats()
	
	# Get previous best stats to check for records
	var previous_best = ProgressManager.get_best_stats(current_level)
	
	# Check for new records
	var session_time = completion_data.get("session_time", 0.0)
	var final_score = completion_data.get("final_score", 0)
	
	if previous_best.get("total_completions", 0) == 0 or session_time < previous_best.get("best_time", 999999.0):
		is_new_record = true
	elif final_score > previous_best.get("best_score", 0):
		is_new_record = true
	
	# Save to ProgressManager
	ProgressManager.save_level_completion(current_level, completion_data)

func _update_button_text() -> void:
	"""Update button text based on completed level and available levels"""
	if not play_again_button:
		return
	
	# Check if Level 2 is unlocked for progression
	if current_level == "level_1" and ProgressManager.is_level_unlocked("level_2"):
		play_again_button.text = "Next Level"
	elif current_level == "level_1":
		play_again_button.text = "Replay Level"
	else:
		play_again_button.text = "Replay Level"
	
	# Update main menu button text
	if main_menu_button:
		main_menu_button.text = "Level Select"

func set_completion_stats(_switches: int, _time: float) -> void:
	"""Legacy method - stats now come from CollectionManager"""
	_update_comprehensive_stats_display()

func _update_comprehensive_stats_display() -> void:
	if not CollectionManager:
		return
		
	var stats = completion_data
	
	# Update stats label with comprehensive information
	if stats_label:
		var minutes = int(stats.session_time) / 60
		var seconds = int(stats.session_time) % 60
		var time_text = "%02d:%02d" % [minutes, seconds]
		
		var stats_text = ""
		
		# Add new record notification
		if is_new_record:
			stats_text += "🏆 NEW RECORD! 🏆\n\n"
		
		stats_text += "💎 Diamonds: %d/%d (%.1f%%)\n" % [stats.total_collected, stats.total_available, stats.completion_percent]
		stats_text += "🔥 Fire: %d/%d  💧 Water: %d/%d\n" % [stats.fire_collected, stats.fire_total, stats.water_collected, stats.water_total]
		stats_text += "⚡ Form switches: %d\n" % stats.form_switches
		stats_text += "⏱️ Time: %s\n" % time_text
		
		# Show level unlock notification
		if current_level == "level_1" and ProgressManager.is_level_unlocked("level_2"):
			var level_2_progress = ProgressManager.get_level_progress("level_2")
			if level_2_progress.get("total_completions", 0) == 0:
				stats_text += "\n🎉 LEVEL 2 UNLOCKED! 🎉\n"
		
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
	var victory_title = $UI/VBoxContainer/VictoryTitle
	
	if victory_message and celebration and victory_title:
		# Update title based on level
		if current_level == "level_2":
			victory_title.text = "Ascending Chamber Mastered!"
		else:
			victory_title.text = "Heartspring Restored!"
		
		# Update messages based on performance
		if stats.completion_percent >= 100.0:
			if current_level == "level_2":
				victory_message.text = "Echo conquered the moving platforms!\nEvery crystal collected with perfect timing!"
			else:
				victory_message.text = "Echo mastered both elements perfectly!\nEvery crystal found, every heartspring awakened!"
			celebration.text = "✨🏆 PERFECT MASTERY! 🏆✨"
		elif stats.completion_percent >= 75.0:
			if current_level == "level_2":
				victory_message.text = "Echo's timing skills are impressive!\nMost crystals gathered from the ascending chamber!"
			else:
				victory_message.text = "Echo's elemental harmony grows stronger.\nMost ancient crystals have been gathered!"
			celebration.text = "✨ Excellent Exploration! ✨"
		elif stats.completion_percent >= 50.0:
			if current_level == "level_2":
				victory_message.text = "Echo learns the rhythm of moving platforms.\nThe ascending path reveals its secrets!"
			else:
				victory_message.text = "Echo's journey progresses well.\nThe elements begin to respond to your call."
			celebration.text = "✨ Good Progress! ✨"
		else:
			if current_level == "level_2":
				victory_message.text = "Echo's first ascent into timing mastery.\nThe moving platforms await further practice!"
			else:
				victory_message.text = "Echo's first steps into elemental mastery.\nMany crystals await discovery on future journeys."
			celebration.text = "✨ Journey Begun! ✨"

func _show_celebration_based_on_performance() -> void:
	"""Future: Add different celebration animations based on performance"""
	pass

func _on_play_again_button_pressed() -> void:
	"""Handle level progression or replay with proper progress tracking"""
	if current_level == "level_1" and ProgressManager.is_level_unlocked("level_2"):
		# Progress to Level 2
		ProgressManager.record_attempt("level_2")
		get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")
	elif current_level == "level_1":
		# Replay Level 1
		ProgressManager.record_attempt("level_1")
		get_tree().change_scene_to_file("res://scenes/levels/Main.tscn")
	elif current_level == "level_2":
		# Replay Level 2
		ProgressManager.record_attempt("level_2")
		get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")
	else:
		# Fallback to Level 1
		ProgressManager.record_attempt("level_1")
		get_tree().change_scene_to_file("res://scenes/levels/Main.tscn")

func _on_main_menu_button_pressed() -> void:
	"""Return to level select menu"""
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

# Optional: Add methods for future features
func _show_celebration_animation() -> void:
	# Future: Add sparkles, fade-in effects, etc.
	pass 