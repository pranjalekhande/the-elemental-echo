extends Control

# EndScreen - Victory celebration and navigation options with progress tracking
# Shown when player completes the level

@onready var title_label: Label = $UI/CenterContainer/VBox/Title
@onready var score_value: Label = $UI/CenterContainer/VBox/ScorePanel/ScoreContent/ScoreValue
@onready var diamond_stats: Label = $UI/CenterContainer/VBox/ScorePanel/ScoreContent/Stats/DiamondStats
@onready var time_stats: Label = $UI/CenterContainer/VBox/ScorePanel/ScoreContent/Stats/TimeStats
@onready var performance_stats: Label = $UI/CenterContainer/VBox/ScorePanel/ScoreContent/Stats/PerformanceStats
@onready var play_again_button: Button = $UI/CenterContainer/VBox/ButtonContainer/PlayAgainButton
@onready var main_menu_button: Button = $UI/CenterContainer/VBox/ButtonContainer/MainMenuButton

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
	
	# Update display with clean, modern stats
	_update_clean_stats_display()
	
	# Update button text based on level
	_update_button_text()
	
	# Connect button signals
	if play_again_button and not play_again_button.pressed.is_connected(_on_play_again_button_pressed):
		play_again_button.pressed.connect(_on_play_again_button_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)

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
		print("ERROR: CollectionManager not found!")
		return
	
	# Log CollectionManager state before getting stats
	print("📊 EndScreen loading - CollectionManager current_score: ", CollectionManager.current_score)
	
	completion_data = CollectionManager.get_session_stats()
	
	# Confirm we got the stats correctly
	print("📊 EndScreen loaded - Final Score: %d" % completion_data.get("final_score", 0))
	
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
	_update_clean_stats_display()

func _update_clean_stats_display() -> void:
	if not CollectionManager:
		return
		
	var stats = completion_data
	
	# Update title based on level
	if title_label:
		if current_level == "level_2":
			title_label.text = "LEVEL 2 COMPLETE"
		else:
			title_label.text = "LEVEL 1 COMPLETE"
		
		# Add new record indicator
		if is_new_record:
			title_label.text += " 🏆"
	
	# Update final score display
	if score_value:
		score_value.text = str(stats.final_score)
	
	# Update diamond collection stats
	if diamond_stats:
		diamond_stats.text = "💎 %d/%d Diamonds Collected" % [stats.total_collected, stats.total_available]
		if stats.completion_percent >= 100.0:
			diamond_stats.text += " ✨"
	
	# Update time stats
	if time_stats:
		var minutes = int(stats.session_time) / 60
		var seconds = int(stats.session_time) % 60
		var time_text = "%02d:%02d" % [minutes, seconds]
		time_stats.text = "⏱️ Time: %s" % time_text
		
		# Add speed indicator for fast completion
		if stats.speed_bonus > 0:
			time_stats.text += " ⚡"
	
	# Update performance stats
	if performance_stats:
		performance_stats.text = "🔄 %d Form Switches" % stats.form_switches
		
		# Add efficiency indicator
		if stats.efficiency_bonus > 0:
			performance_stats.text += " 🎯"

func _on_play_again_button_pressed() -> void:
	"""Handle play again button press"""
	var level_definitions = ProgressManager.level_definitions
	if level_definitions.has(current_level):
		var level_def = level_definitions[current_level]
		var scene_path = level_def["scene_path"]
		
		# Check if this was level 1 and level 2 is unlocked
		if current_level == "level_1" and ProgressManager.is_level_unlocked("level_2"):
			# Go to level 2
			var level_2_def = level_definitions.get("level_2", {})
			if level_2_def.get("implemented", false):
				scene_path = level_2_def["scene_path"]
		
		# Record attempt for the target level
		var target_level = "level_2" if (current_level == "level_1" and ProgressManager.is_level_unlocked("level_2")) else current_level
		ProgressManager.record_attempt(target_level)
		
		# Load the level scene
		get_tree().change_scene_to_file(scene_path)

func _on_main_menu_button_pressed() -> void:
	"""Return to level select menu"""
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

# Legacy method for compatibility - moved to prevent duplication
