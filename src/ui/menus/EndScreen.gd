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

var pending_score: int = 0  # Store score while waiting for name input

func _ready() -> void:
	# Detect which level was completed
	_detect_current_level()
	
	# Get stats from CollectionManager and save to ProgressManager
	_save_completion_data()
	
	# Update display with clean, modern stats
	_update_clean_stats_display()
	
	# Update button text based on level
	_update_button_text()

	# Submit score to leaderboard (works for both solo and multiplayer)
	_submit_score_to_leaderboard()
	
	# Connect button signals
	if play_again_button and not play_again_button.pressed.is_connected(_on_play_again_button_pressed):
		play_again_button.pressed.connect(_on_play_again_button_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Add leaderboard button
	_add_leaderboard_button()

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

func _submit_score_to_leaderboard() -> void:
	"""Submit the final score to the leaderboard system"""
	print("🎯 Starting leaderboard submission...")
	
	var final_score: int = int(completion_data.get("final_score", 0))
	
	print("🔍 Checking for saved player name...")
	print("   ProgressManager.has_player_name(): ", ProgressManager.has_player_name())
	if ProgressManager.has_player_name():
		var saved_name = ProgressManager.get_player_name()
		print("   Saved name found: '%s'" % saved_name)
	else:
		print("   No saved name found")
	
	# Check if player has a saved name
	if ProgressManager.has_player_name():
		var player_name = ProgressManager.get_player_name()
		print("✅ Using saved player name: '%s'" % player_name)
		_submit_score_with_name(player_name, final_score)
	else:
		print("⚠️ No player name found, prompting for input...")
		_prompt_for_name(final_score)

func _prompt_for_name(score: int) -> void:
	"""Show name input dialog to get player name"""
	print("🚀 _prompt_for_name called with score: %d" % score)
	
	# Store the score for later use
	pending_score = score
	print("💾 Stored pending_score: %d" % pending_score)
	
	# Load and instantiate the name input dialog
	if ResourceLoader.exists("res://scenes/ui/components/NameInputDialog.tscn"):
		print("✅ NameInputDialog scene found, loading...")
		var dialog_scene: PackedScene = load("res://scenes/ui/components/NameInputDialog.tscn")
		var dialog: Control = dialog_scene.instantiate()
		
		print("✅ Dialog instantiated, adding to scene...")
		# Add dialog to scene
		add_child(dialog)
		
		print("🔗 Connecting dialog signals...")
		# Connect signals properly - dialog emits name_confirmed(player_name)
		dialog.name_confirmed.connect(_on_name_confirmed)
		dialog.dialog_canceled.connect(_on_name_canceled)
		
		print("📊 Signal connections:")
		print("   name_confirmed connected: ", dialog.name_confirmed.is_connected(_on_name_confirmed))
		print("   dialog_canceled connected: ", dialog.dialog_canceled.is_connected(_on_name_canceled))
		
		# Show dialog
		print("👀 Showing dialog...")
		dialog.show_dialog()
		print("✅ _prompt_for_name completed")
	else:
		print("❌ NameInputDialog scene not found, using default name")
		_submit_score_with_name("Player", score)

func _on_name_confirmed(player_name: String) -> void:
	"""Handle name confirmation from dialog"""
	print("🎉 _on_name_confirmed called!")
	print("   player_name: '%s'" % player_name)
	print("   using pending_score: %d" % pending_score)
	print("🔍 Before saving - ProgressManager.has_player_name(): ", ProgressManager.has_player_name())
	
	# Save the name for future use
	ProgressManager.set_player_name(player_name)
	
	print("🔍 After saving - ProgressManager.has_player_name(): ", ProgressManager.has_player_name())
	print("🔍 After saving - ProgressManager.get_player_name(): '%s'" % ProgressManager.get_player_name())
	
	print("📤 About to call _submit_score_with_name...")
	# Submit score with the new name
	_submit_score_with_name(player_name, pending_score)
	print("✅ _on_name_confirmed completed")

func _on_name_canceled() -> void:
	"""Handle name dialog cancellation"""
	print("❌ _on_name_canceled called with pending_score: %d" % pending_score)
	print("⚠️ Name input canceled, using default name")
	_submit_score_with_name("Anonymous", pending_score)

func _submit_score_with_name(player_name: String, final_score: int) -> void:
	"""Submit score to leaderboard with specified name"""
	print("📊 Score details:")
	print("   Final score: ", final_score)
	print("   Player name: '%s'" % player_name)
	
	# Try to access NetworkManager directly (alternative to Engine.has_singleton)
	var nm = null
	if Engine.has_singleton("NetworkManager"):
		print("✅ NetworkManager singleton found via Engine.has_singleton")
		nm = Engine.get_singleton("NetworkManager")
	else:
		print("⚠️ NetworkManager not found via Engine.has_singleton, trying direct access...")
		# Try direct access to the autoload
		if get_tree().has_method("get_first_node_in_group"):
			var autoloads = get_tree().get_nodes_in_group("autoload")
			for node in autoloads:
				if node.name == "NetworkManager":
					nm = node
					print("✅ Found NetworkManager via direct access")
					break
		
		# Try accessing via /root/ path
		if not nm:
			var root_nm = get_tree().get_root().get_node_or_null("NetworkManager")
			if root_nm:
				nm = root_nm
				print("✅ Found NetworkManager via /root/ path")
	
	if nm:
		print("📋 NetworkManager found! State:")
		print("   Player name: '", nm.player_name, "'")
		print("   Is host: ", nm.is_host)
		
		# Check if in multiplayer mode
		var has_peer = false
		if nm.has_method("get_multiplayer") or "multiplayer" in nm:
			var mp = nm.multiplayer
			if mp and mp.multiplayer_peer != null:
				has_peer = true
				print("🌐 Multiplayer peer detected - submitting via NetworkManager")
				nm.submit_score(final_score)
			else:
				print("🏠 Solo mode detected - no multiplayer peer")
		else:
			print("⚠️ No multiplayer property found")
	else:
		print("❌ NetworkManager not accessible via any method")
	
	# Try to access LeaderboardService directly
	print("💾 Submitting to LeaderboardService...")
	var lbs = null
	if Engine.has_singleton("LeaderboardService"):
		print("✅ LeaderboardService singleton found via Engine.has_singleton")
		lbs = Engine.get_singleton("LeaderboardService")
	else:
		print("⚠️ LeaderboardService not found via Engine.has_singleton, trying direct access...")
		# Try direct access via /root/ path
		var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
		if root_lbs:
			lbs = root_lbs
			print("✅ Found LeaderboardService via /root/ path")
	
	if lbs:
		print("✅ LeaderboardService found! Calling add_score_force...")
		lbs.add_score_force(player_name, final_score)
		print("📈 Score submitted to leaderboard: %s - %d points" % [player_name, final_score])
	else:
		print("❌ LeaderboardService not accessible via any method")

func _add_leaderboard_button() -> void:
	"""Add a leaderboard button to the button container"""
	var button_container = get_node_or_null("UI/CenterContainer/VBox/ButtonContainer")
	if button_container:
		# Create leaderboard button
		var leaderboard_button = Button.new()
		leaderboard_button.text = "🏆 Leaderboard"
		leaderboard_button.custom_minimum_size = Vector2(160, 45)
		
		# Apply the same styling as other buttons
		var button_style = button_container.get_child(0).get_theme_stylebox("normal")
		var button_hover_style = button_container.get_child(0).get_theme_stylebox("hover")
		if button_style:
			leaderboard_button.add_theme_stylebox_override("normal", button_style)
		if button_hover_style:
			leaderboard_button.add_theme_stylebox_override("hover", button_hover_style)
		
		# Add font styling
		leaderboard_button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		leaderboard_button.add_theme_font_size_override("font_size", 16)
		
		# Connect signal
		leaderboard_button.pressed.connect(_on_leaderboard_button_pressed)
		
		# Add spacer before the button
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(20, 0)
		button_container.add_child(spacer)
		
		# Add the button
		button_container.add_child(leaderboard_button)
		
		print("✅ Leaderboard button added to EndScreen")

func _on_leaderboard_button_pressed() -> void:
	"""Handle leaderboard button press"""
	print("🏆 Opening leaderboard from EndScreen...")
	get_tree().change_scene_to_file("res://scenes/ui/menus/LeaderboardMenu.tscn")
