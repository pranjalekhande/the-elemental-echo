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
	
	# Add spacing after header
	var header_spacer = Control.new()
	header_spacer.custom_minimum_size.y = 30
	leaderboard_container.add_child(header_spacer)
	
	# Create centered container for the grid
	var center_container = HBoxContainer.new()
	center_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Create grid container for entries
	var grid_container = GridContainer.new()
	grid_container.columns = 2
	grid_container.add_theme_constant_override("h_separation", 20)
	grid_container.add_theme_constant_override("v_separation", 15)
	
	# Create entries
	for i in range(min(leaderboard_data.size(), MAX_DISPLAY_ENTRIES)):
		var entry = leaderboard_data[i]
		var entry_card = _create_leaderboard_entry(i + 1, entry)
		grid_container.add_child(entry_card)
	
	# Add grid to centered container, then to main container
	center_container.add_child(grid_container)
	leaderboard_container.add_child(center_container)

func _create_header() -> Control:
	"""Create the leaderboard header row"""
	var header_container = VBoxContainer.new()
	header_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var header_label = Label.new()
	header_label.text = "TOP PLAYERS - TOTAL SCORES"
	header_label.add_theme_font_size_override("font_size", 24)
	header_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(header_label)
	
	# Add subtitle explaining the scoring
	var subtitle_label = Label.new()
	subtitle_label.text = "Best scores from all completed levels combined"
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(subtitle_label)
	
	return header_container

func _create_leaderboard_entry(rank: int, entry: Dictionary) -> Control:
	"""Create a single leaderboard entry card"""
	# Main card container
	var card = Panel.new()
	card.custom_minimum_size = Vector2(420, 100)  # Made wider to accommodate content
	
	# Card background styling
	var style_box = StyleBoxFlat.new()
	if rank == 1:
		style_box.bg_color = Color(0.25, 0.2, 0.1, 0.9)  # Richer gold tint for winner
		style_box.border_color = Color(1.0, 0.84, 0.0, 0.8)  # Brighter gold border
		style_box.border_width_left = 3
		style_box.border_width_right = 3
		style_box.border_width_top = 3
		style_box.border_width_bottom = 3
	elif rank <= 3:
		style_box.bg_color = Color(0.18, 0.22, 0.26, 0.9)  # Slightly lighter for top 3
		style_box.border_color = Color(0.8, 0.7, 0.4, 0.5)  # Subtle golden border
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
	else:
		style_box.bg_color = Color(0.15, 0.18, 0.22, 0.85)  # Standard dark
		style_box.border_color = Color(0.3, 0.35, 0.4, 0.3)  # Subtle border
		style_box.border_width_left = 1
		style_box.border_width_right = 1
		style_box.border_width_top = 1
		style_box.border_width_bottom = 1
	
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	card.add_theme_stylebox_override("panel", style_box)
	
	# Content container with margins
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 16)
	margin_container.add_theme_constant_override("margin_bottom", 16)
	
	# Main content layout
	var content_container = HBoxContainer.new()
	content_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Rank section (fixed width)
	var rank_container = VBoxContainer.new()
	rank_container.custom_minimum_size.x = 80  # Fixed width for rank
	rank_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var rank_label = Label.new()
	if rank <= 3:
		match rank:
			1:
				rank_label.text = "🥇"
				rank_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))  # Brighter gold
			2:
				rank_label.text = "🥈"
				rank_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))  # Bright silver
			3:
				rank_label.text = "🥉"
				rank_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))  # Brighter bronze
	else:
		rank_label.text = str(rank)
		rank_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))  # Golden tint for all ranks
	
	rank_label.add_theme_font_size_override("font_size", 32)  # Bigger font
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_container.add_child(rank_label)
	
	# Add rank suffix for visual appeal (for all ranks)
	var suffix_label = Label.new()
	match rank:
		1:
			suffix_label.text = "ST"
		2:
			suffix_label.text = "ND"
		3:
			suffix_label.text = "RD"
		_:
			suffix_label.text = "TH"
	
	suffix_label.add_theme_font_size_override("font_size", 12)
	suffix_label.add_theme_color_override("font_color", Color(0.7, 0.6, 0.3))
	suffix_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_container.add_child(suffix_label)
	
	content_container.add_child(rank_container)
	
	# Add explicit spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.x = 25
	content_container.add_child(spacer)
	
	# Player name section (fixed width to prevent overflow)
	var name_label = Label.new()
	name_label.text = entry.get("name", "Unknown Player")
	name_label.add_theme_font_size_override("font_size", 22)  # Bigger font
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size.x = 200  # Fixed width for name section
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_contents = true  # Prevent text overflow
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS  # Add ellipsis for long names
	if rank == 1:
		name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))  # Golden white for winner
	elif rank <= 3:
		name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))  # Warm white for top 3
	else:
		name_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))  # Slightly golden tint
	
	content_container.add_child(name_label)
	
	# Add another spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.x = 15
	content_container.add_child(spacer2)
	
	# Score section (fixed width, right-aligned) - Enhanced for player-centric display
	var score_container = VBoxContainer.new()
	score_container.custom_minimum_size.x = 120
	score_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Total score label
	var score_label = Label.new()
	var total_score = int(entry.get("points", 0))
	score_label.text = str(total_score) + " pts   "  # Added extra spaces for better alignment
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if rank == 1:
		score_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))  # Golden for winner
	else:
		score_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))  # Warm tone
	
	score_container.add_child(score_label)
	
	# Levels completed info
	var levels_label = Label.new()
	var levels_completed = int(entry.get("levels_completed", 1))
	if levels_completed == 1:
		levels_label.text = "1 level"
	else:
		levels_label.text = str(levels_completed) + " levels"
	levels_label.add_theme_font_size_override("font_size", 12)
	levels_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	levels_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	
	score_container.add_child(levels_label)
	
	content_container.add_child(score_container)
	
	# Assemble the card
	margin_container.add_child(content_container)
	card.add_child(margin_container)
	
	# Set up anchors
	margin_container.anchors_preset = Control.PRESET_FULL_RECT
	
	return card

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
