extends Control

# LevelSelectMenu - Main level selection interface with progress tracking

var title_label: Label
var level_cards_container: GridContainer
var stats_label: Label
var back_button: Button
var reset_button: Button
var scroll_container: ScrollContainer

# Level card scene reference
const LEVEL_CARD_SCENE = preload("res://scenes/ui/menus/LevelCard.tscn")

var level_cards: Array[LevelCard] = []

func _ready() -> void:
	# Get node references manually with better error handling
	title_label = get_node_or_null("VBox/TitleLabel")
	level_cards_container = get_node_or_null("VBox/ScrollContainer/LevelCardsContainer")
	stats_label = get_node_or_null("VBox/StatsContainer/StatsLabel")
	back_button = get_node_or_null("VBox/BackButton")
	reset_button = get_node_or_null("VBox/ButtonContainer/ResetButton")
	scroll_container = get_node_or_null("VBox/ScrollContainer")
	
	# Connect visibility signal to refresh menu when returning to it
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(_on_menu_resized)
	
	# Connect button signals with null checks
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("ERROR: back_button is null!")
	
	if reset_button:
		reset_button.pressed.connect(_on_reset_button_pressed)
	# Reset button is optional in this menu
	
	ProgressManager.level_unlocked.connect(_on_level_unlocked)
	_setup_menu()

func _setup_menu() -> void:
	"""Initialize the level selection menu"""
	if title_label:
		title_label.text = "Select Level"
	else:
		print("ERROR: title_label is null!")
	_create_level_cards()
	_update_global_stats()

func _create_level_cards() -> void:
	"""Create level cards for all available levels"""
	if not level_cards_container:
		print("ERROR: level_cards_container is null!")
		return
		
	# Clear existing cards
	for card in level_cards:
		if is_instance_valid(card):
			card.queue_free()
	level_cards.clear()
	
	# Get available levels from ProgressManager
	var available_levels = ProgressManager.get_available_levels()
	
	# Create cards for each level
	for level_info in available_levels:
		var card_instance = LEVEL_CARD_SCENE.instantiate()
		level_cards_container.add_child(card_instance)
		level_cards.append(card_instance)
		
		# Setup the card
		card_instance.setup_level_card(level_info["id"])
		card_instance.level_selected.connect(_on_level_selected)

func _update_global_stats() -> void:
	"""Update the global statistics display"""
	if not stats_label:
		print("ERROR: stats_label is null!")
		return
		
	var global_stats = ProgressManager.get_global_stats()
	var total_completions = global_stats.get("total_completions", 0)
	var total_play_time = global_stats.get("total_play_time", 0.0)
	
	if total_completions > 0:
		stats_label.text = "Total Completions: %d | Play Time: %.1f minutes" % [
			total_completions,
			total_play_time / 60.0
		]
	else:
		stats_label.text = "Welcome to The Elemental Echo! Select a level to begin your journey."

func _on_level_selected(level_id: String) -> void:
	"""Handle level selection"""
	var level_definitions = ProgressManager.level_definitions
	if level_definitions.has(level_id):
		var level_def = level_definitions[level_id]
		
		# Check if level is implemented
		if not level_def.get("implemented", false):
			_show_coming_soon_notification(level_def.get("name", "Unknown Level"))
			return
		
		# Check if level is unlocked
		if not ProgressManager.is_level_unlocked(level_id):
			print("Level %s is locked!" % level_id)
			return
		
		var scene_path = level_def["scene_path"]
		
		# Record attempt
		ProgressManager.record_attempt(level_id)
		
		# Load the level scene
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Error: Level not found: ", level_id)

func _on_back_button_pressed() -> void:
	"""Return to start menu"""
	get_tree().change_scene_to_file("res://scenes/ui/menus/StartMenu.tscn")

# Stats button temporarily removed - will add back later
# func _on_stats_button_pressed() -> void:
#	"""Open statistics dashboard"""
#	get_tree().change_scene_to_file("res://scenes/ui/menus/StatsDashboard.tscn")

func _on_reset_button_pressed() -> void:
	"""Reset all progress for testing"""
	ProgressManager.reset_all_progress()
	_refresh_level_cards()

func _on_level_unlocked(level_id: String) -> void:
	"""Handle level unlock notifications"""
	_refresh_level_cards()
	_show_unlock_notification(level_id)

func _refresh_level_cards() -> void:
	"""Refresh all level cards with current data"""
	for card in level_cards:
		if is_instance_valid(card):
			card.refresh_display()
	_update_global_stats()

func _show_unlock_notification(level_id: String) -> void:
	"""Show a notification when a new level is unlocked"""
	var level_def = ProgressManager.level_definitions.get(level_id, {})
	var level_name = level_def.get("name", "Unknown Level")
	
	# Create a temporary notification (simple approach)
	var unlock_label = Label.new()
	unlock_label.text = "🎉 %s Unlocked!" % level_name
	unlock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unlock_label.add_theme_color_override("font_color", Color.YELLOW)
	
	add_child(unlock_label)
	unlock_label.position = Vector2(get_rect().size.x / 2 - 100, 100)
	
	# Animate and remove notification
	var tween = create_tween()
	tween.tween_property(unlock_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(unlock_label.queue_free)

func _show_coming_soon_notification(level_name: String) -> void:
	"""Show notification for unimplemented levels"""
	var coming_soon_label = Label.new()
	coming_soon_label.text = "🚧 %s - Coming Soon! 🚧" % level_name
	coming_soon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coming_soon_label.add_theme_color_override("font_color", Color.ORANGE)
	
	add_child(coming_soon_label)
	coming_soon_label.position = Vector2(get_rect().size.x / 2 - 150, 100)
	
	# Animate and remove notification
	var tween = create_tween()
	tween.tween_property(coming_soon_label, "modulate:a", 0.0, 3.0)
	tween.tween_callback(coming_soon_label.queue_free)

func show_menu() -> void:
	"""Public method to refresh and show the menu"""
	_refresh_level_cards()
	show()

func _on_visibility_changed() -> void:
	"""Refresh data when menu becomes visible"""
	if visible:
		_refresh_level_cards()

func _on_menu_resized() -> void:
	"""Handle menu resize to adjust grid layout"""
	if not level_cards_container:
		return
		
	var menu_width = get_rect().size.x
	var min_card_width = 120  # Minimum card width
	var spacing = 20  # Horizontal spacing
	var margins = 160  # Left and right margins
	
	# Calculate how many columns can fit
	var available_width = menu_width - margins
	var columns = max(1, int(available_width / (min_card_width + spacing)))
	columns = min(columns, 6)  # Don't exceed 6 columns for readability
	
	level_cards_container.columns = columns 
