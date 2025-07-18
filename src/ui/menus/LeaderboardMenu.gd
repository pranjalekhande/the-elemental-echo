extends Control

# LeaderboardMenu - Dedicated full-screen leaderboard view
# Shows top 10 scores with navigation back to main menu

@onready var title_label: Label = $VBox/Title
@onready var leaderboard_container: VBoxContainer = $VBox/LeaderboardContainer
@onready var back_button: Button = $BackArrowButton
@onready var settings_button: Button = $SettingsIconButton

const MAX_DISPLAY_ENTRIES = 10
var leaderboard_data: Array = []

func _ready() -> void:
	# Connect button signals
	back_button.pressed.connect(_on_back_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
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
	"""Create and display leaderboard entries with modern card design"""
	# Clear existing entries
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	if leaderboard_data.size() == 0:
		_display_empty_leaderboard()
		return
	
	# Create entries with card design - no separate header needed
	for i in range(min(leaderboard_data.size(), MAX_DISPLAY_ENTRIES)):
		var entry = leaderboard_data[i]
		var entry_card = _create_modern_leaderboard_card(i + 1, entry)
		leaderboard_container.add_child(entry_card)
		
		# Add spacing between cards
		if i < min(leaderboard_data.size(), MAX_DISPLAY_ENTRIES) - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size.y = 8
			leaderboard_container.add_child(spacer)


func _create_modern_leaderboard_card(rank: int, entry: Dictionary) -> Control:
	"""Create a modern, professional leaderboard card entry"""
	# Main card container with background panel
	var card_container = PanelContainer.new()
	
	# Create card background style
	var style_box = StyleBoxFlat.new()
	if rank <= 3:
		# Special styling for top 3
		if rank == 1:
			style_box.bg_color = Color(1.0, 0.9, 0.4, 0.15)  # Gold tint
			style_box.border_color = Color(1.0, 0.9, 0.4, 0.4)
		elif rank == 2:
			style_box.bg_color = Color(0.8, 0.8, 0.9, 0.15)  # Silver tint
			style_box.border_color = Color(0.8, 0.8, 0.9, 0.4)
		else:  # rank == 3
			style_box.bg_color = Color(0.9, 0.6, 0.4, 0.15)  # Bronze tint
			style_box.border_color = Color(0.9, 0.6, 0.4, 0.4)
		style_box.border_width_left = 3
		style_box.border_width_right = 3
		style_box.border_width_top = 3
		style_box.border_width_bottom = 3
	else:
		# Regular entries
		style_box.bg_color = Color(0.2, 0.25, 0.3, 0.6)
		style_box.border_color = Color(0.4, 0.45, 0.5, 0.3)
		style_box.border_width_left = 1
		style_box.border_width_right = 1
		style_box.border_width_top = 1
		style_box.border_width_bottom = 1
	
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	card_container.add_theme_stylebox_override("panel", style_box)
	card_container.custom_minimum_size.y = 60
	
	# Inner horizontal layout
	var h_box = HBoxContainer.new()
	h_box.add_theme_constant_override("separation", 20)
	card_container.add_child(h_box)
	
	# Left section: Rank with icon
	var rank_section = VBoxContainer.new()
	rank_section.custom_minimum_size.x = 80
	rank_section.add_theme_constant_override("separation", 2)
	
	var rank_icon = Label.new()
	var rank_text = Label.new()
	
	# Set rank icon and text based on position
	if rank == 1:
		rank_icon.text = "👑"
		rank_text.text = "1ST"
		rank_text.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1))
	elif rank == 2:
		rank_icon.text = "🥈"
		rank_text.text = "2ND"
		rank_text.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 1))
	elif rank == 3:
		rank_icon.text = "🥉"
		rank_text.text = "3RD"
		rank_text.add_theme_color_override("font_color", Color(0.9, 0.6, 0.4, 1))
	else:
		rank_icon.text = "🏆"
		rank_text.text = "#%d" % rank
		rank_text.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 1))
	
	rank_icon.add_theme_font_size_override("font_size", 24)
	rank_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	rank_text.add_theme_font_size_override("font_size", 14)
	rank_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	rank_section.add_child(rank_icon)
	rank_section.add_child(rank_text)
	h_box.add_child(rank_section)
	
	# Center section: Player info
	var player_section = VBoxContainer.new()
	player_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_section.add_theme_constant_override("separation", 4)
	
	var player_name = Label.new()
	player_name.text = entry.get("name", "Unknown Player")
	player_name.add_theme_font_size_override("font_size", 18)
	player_name.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	
	var play_date = Label.new()
	var date_string = entry.get("date", "")
	var formatted_date = _format_date(date_string)
	play_date.text = "Played: %s" % formatted_date
	play_date.add_theme_font_size_override("font_size", 12)
	play_date.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	
	player_section.add_child(player_name)
	player_section.add_child(play_date)
	h_box.add_child(player_section)
	
	# Right section: Score
	var score_section = VBoxContainer.new()
	score_section.custom_minimum_size.x = 120
	score_section.add_theme_constant_override("separation", 2)
	
	var score_label = Label.new()
	score_label.text = "SCORE"
	score_label.add_theme_font_size_override("font_size", 11)
	score_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	var score_value = Label.new()
	score_value.text = str(entry.get("points", 0))
	score_value.add_theme_font_size_override("font_size", 20)
	score_value.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 1))
	score_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	score_section.add_child(score_label)
	score_section.add_child(score_value)
	h_box.add_child(score_section)
	
	return card_container

func _display_empty_leaderboard() -> void:
	"""Display modern empty state message when leaderboard is empty"""
	# Clear existing entries
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	# Create modern empty state card
	var empty_card = PanelContainer.new()
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.25, 0.3, 0.4)
	style_box.border_color = Color(0.4, 0.45, 0.5, 0.3)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	empty_card.add_theme_stylebox_override("panel", style_box)
	empty_card.custom_minimum_size.y = 120
	
	var empty_vbox = VBoxContainer.new()
	empty_vbox.add_theme_constant_override("separation", 12)
	empty_card.add_child(empty_vbox)
	
	var empty_icon = Label.new()
	empty_icon.text = "🏆"
	empty_icon.add_theme_font_size_override("font_size", 48)
	empty_icon.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.7))
	empty_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_vbox.add_child(empty_icon)
	
	var empty_title = Label.new()
	empty_title.text = "No Scores Yet"
	empty_title.add_theme_font_size_override("font_size", 24)
	empty_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	empty_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_vbox.add_child(empty_title)
	
	var empty_subtitle = Label.new()
	empty_subtitle.text = "Complete a level to get your first score!"
	empty_subtitle.add_theme_font_size_override("font_size", 16)
	empty_subtitle.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.8))
	empty_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_vbox.add_child(empty_subtitle)
	
	leaderboard_container.add_child(empty_card)

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
	var button_container = get_node_or_null("VBox/ButtonContainer")
	if button_container:
		# Add spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(20, 0)
		button_container.add_child(spacer)
		
		# Create clear button
		var clear_button = Button.new()
		clear_button.text = "🗑️ Clear All"
		clear_button.custom_minimum_size = Vector2(120, 40)
		clear_button.pressed.connect(_on_clear_button_pressed)
		
		# Style the button
		clear_button.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 1))
		
		button_container.add_child(clear_button)
		print("✅ Clear button added to LeaderboardMenu")

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

func _on_settings_button_pressed() -> void:
	"""Handle settings button press"""
	print("⚙️ Settings button clicked from LeaderboardMenu!")
	get_tree().change_scene_to_file("res://scenes/ui/menus/SettingsMenu.tscn")