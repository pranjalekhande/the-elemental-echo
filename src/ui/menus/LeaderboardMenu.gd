extends Control

# LeaderboardMenu - Dedicated full-screen leaderboard view
# Shows top 10 scores with navigation back to main menu

@onready var title_label: Label = $VBox/Title
@onready var leaderboard_container: VBoxContainer = $VBox/LeaderboardContainer

const MAX_DISPLAY_ENTRIES = 10
var leaderboard_data: Array = []

func _ready() -> void:
	# Add navigation buttons at bottom
	_add_bottom_buttons()
	
	# Add clear button for testing
	_add_clear_button()
	
	# Load and display leaderboard
	_load_leaderboard()
	
	# Connect to leaderboard updates
	_connect_to_leaderboard_service()

func _load_leaderboard() -> void:
	"""Load leaderboard data from LeaderboardService"""
	print("📊 LeaderboardMenu loading data...")
	
	var lbs = null
	if Engine.has_singleton("LeaderboardService"):
		lbs = Engine.get_singleton("LeaderboardService")
	else:
		# Try direct access via /root/ path
		var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
		if root_lbs:
			lbs = root_lbs
	
	if lbs:
		leaderboard_data = lbs.leaderboard.duplicate()
		print("✅ Loaded %d leaderboard entries" % leaderboard_data.size())
		_display_leaderboard()
	else:
		print("❌ Could not access LeaderboardService")
		_display_empty_leaderboard()

func _connect_to_leaderboard_service() -> void:
	"""Connect to leaderboard updates"""
	var lbs = null
	if Engine.has_singleton("LeaderboardService"):
		lbs = Engine.get_singleton("LeaderboardService")
	else:
		var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
		if root_lbs:
			lbs = root_lbs
	
	if lbs:
		lbs.leaderboard_updated.connect(_on_leaderboard_updated)

func _display_leaderboard() -> void:
	"""Create and display leaderboard entries"""
	# Clear existing entries
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	if leaderboard_data.size() == 0:
		_display_empty_leaderboard()
		return
	
	# Create header
	var header = _create_header()
	leaderboard_container.add_child(header)
	
	# Add separator
	var separator = HSeparator.new()
	leaderboard_container.add_child(separator)
	
	# Create entries
	for i in range(min(leaderboard_data.size(), MAX_DISPLAY_ENTRIES)):
		var entry = leaderboard_data[i]
		var entry_row = _create_leaderboard_entry(i + 1, entry)
		leaderboard_container.add_child(entry_row)

func _create_header() -> Control:
	"""Create the leaderboard header row"""
	var header_container = HBoxContainer.new()
	
	var rank_label = Label.new()
	rank_label.text = "RANK"
	rank_label.custom_minimum_size.x = 80
	rank_label.add_theme_font_size_override("font_size", 18)
	rank_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_container.add_child(rank_label)
	
	var name_label = Label.new()
	name_label.text = "PLAYER"
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_container.add_child(name_label)
	
	var score_label = Label.new()
	score_label.text = "SCORE"
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_container.add_child(score_label)
	
	var date_label = Label.new()
	date_label.text = "DATE"
	date_label.custom_minimum_size.x = 120
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	date_label.add_theme_font_size_override("font_size", 18)
	date_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_container.add_child(date_label)
	
	return header_container

func _create_leaderboard_entry(rank: int, entry: Dictionary) -> Control:
	"""Create a single leaderboard entry row"""
	var entry_container = HBoxContainer.new()
	
	# Rank with medal emojis for top 3
	var rank_text = str(rank)
	if rank == 1:
		rank_text = "🥇 1st"
	elif rank == 2:
		rank_text = "🥈 2nd"
	elif rank == 3:
		rank_text = "🥉 3rd"
	else:
		rank_text = "#%d" % rank
	
	var rank_label = Label.new()
	rank_label.text = rank_text
	rank_label.custom_minimum_size.x = 80
	rank_label.add_theme_font_size_override("font_size", 16)
	rank_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	entry_container.add_child(rank_label)
	
	# Player name
	var name_label = Label.new()
	name_label.text = entry.get("name", "Unknown")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	entry_container.add_child(name_label)
	
	# Score
	var score_label = Label.new()
	score_label.text = str(entry.get("points", 0))
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	entry_container.add_child(score_label)
	
	# Date (formatted)
	var date_label = Label.new()
	var date_string = entry.get("date", "")
	var formatted_date = _format_date(date_string)
	date_label.text = formatted_date
	date_label.custom_minimum_size.x = 120
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	date_label.add_theme_font_size_override("font_size", 14)
	date_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	entry_container.add_child(date_label)
	
	return entry_container

func _display_empty_leaderboard() -> void:
	"""Display message when leaderboard is empty"""
	# Clear existing entries
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	var empty_label = Label.new()
	empty_label.text = "🎮 No scores yet!\nComplete a level to see your score here."
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 24)
	empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	leaderboard_container.add_child(empty_label)

func _format_date(date_string: String) -> String:
	"""Format date string for display"""
	if date_string.length() >= 10:
		# Extract date part (YYYY-MM-DD)
		return date_string.substr(0, 10)
	return date_string

func _on_leaderboard_updated(board: Array) -> void:
	"""Handle leaderboard updates"""
	print("🔄 LeaderboardMenu received leaderboard update: %d entries" % board.size())
	leaderboard_data = board.duplicate()
	_display_leaderboard()

func _on_back_button_pressed() -> void:
	"""Handle back button press"""
	# Go back to level select menu (or start menu if called from there)
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn") 

func _add_clear_button() -> void:
	"""Add a clear leaderboard button for testing"""
	var vbox = get_node_or_null("VBox")
	if vbox:
		# Create a horizontal container for the button
		var button_container = HBoxContainer.new()
		button_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Create clear button
		var clear_button = Button.new()
		clear_button.text = "🗑️ Clear All"
		clear_button.custom_minimum_size = Vector2(120, 40)
		clear_button.pressed.connect(_on_clear_button_pressed)
		
		# Style the button
		clear_button.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 1))
		clear_button.add_theme_font_size_override("font_size", 14)
		
		button_container.add_child(clear_button)
		vbox.add_child(button_container)
		print("✅ Clear button added to LeaderboardMenu")
	else:
		print("❌ Could not find VBox to add clear button")

func _on_clear_button_pressed() -> void:
	"""Handle clear button press"""
	print("🗑️ Clearing leaderboard...")
	
	# Access LeaderboardService and clear
	var lbs = null
	if Engine.has_singleton("LeaderboardService"):
		lbs = Engine.get_singleton("LeaderboardService")
	else:
		var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
		if root_lbs:
			lbs = root_lbs
	
	if lbs:
		lbs.clear_leaderboard()
		print("✅ Leaderboard cleared successfully")
		# Refresh display
		_load_leaderboard()
	else:
		print("❌ Could not access LeaderboardService to clear") 

func _add_bottom_buttons() -> void:
	"""Add back and settings buttons at the bottom of the VBox"""
	var vbox = get_node_or_null("VBox")
	if vbox:
		# Create button container
		var button_container = HBoxContainer.new()
		button_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Create back button
		var back_btn = Button.new()
		back_btn.text = "← Back"
		back_btn.custom_minimum_size = Vector2(120, 45)
		back_btn.add_theme_font_size_override("font_size", 18)
		back_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		back_btn.pressed.connect(_on_back_button_pressed)
		
		# Add spacer between buttons
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(40, 0)
		
		# Create settings button
		var settings_btn = Button.new()
		settings_btn.text = "⚙️ Settings"
		settings_btn.custom_minimum_size = Vector2(140, 45)
		settings_btn.add_theme_font_size_override("font_size", 18)
		settings_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		settings_btn.pressed.connect(_on_settings_button_pressed)
		
		# Add buttons to container
		button_container.add_child(back_btn)
		button_container.add_child(spacer)
		button_container.add_child(settings_btn)
		
		# Add container to VBox
		vbox.add_child(button_container)
		print("✅ Bottom navigation buttons added")
	else:
		print("❌ Could not find VBox to add navigation buttons")

func _on_settings_button_pressed() -> void:
	"""Handle settings button press"""
	print("⚙️ Settings button clicked from LeaderboardMenu!")
	get_tree().change_scene_to_file("res://scenes/ui/menus/SettingsMenu.tscn")