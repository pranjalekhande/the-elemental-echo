extends AspectRatioContainer
class_name LevelCard

# LevelCard - Reusable component for displaying level information and progress

signal level_selected(level_id: String)

@onready var level_graphic: Label = $VBox/LevelGraphic
@onready var level_name_label: Label = $VBox/LevelName
@onready var lock_overlay: Control = $LockOverlay

var level_id: String = ""
var level_data: Dictionary = {}

func _ready() -> void:
	# Set minimum size for responsiveness
	custom_minimum_size = Vector2(100, 120)
	
	# Make the whole card clickable
	gui_input.connect(_on_card_clicked)
	# Enable resizing notification
	resized.connect(_on_card_resized)

func setup_level_card(id: String) -> void:
	"""Initialize card with level data"""
	level_id = id
	level_data = ProgressManager.get_level_progress(level_id)
	_update_display()

func _update_display() -> void:
	"""Update all visual elements based on level data"""
	var level_def = level_data.get("level_definition", {})
	
	# Simple level naming
	var level_number = level_id.get_slice("_", 1)
	level_name_label.text = "Level %s" % level_number
	
	# Set graphics based on level and status
	var is_unlocked = ProgressManager.is_level_unlocked(level_id)
	var is_implemented = level_def.get("implemented", false)
	var is_completed = level_data.get("total_completions", 0) > 0
	
	_update_graphics(level_number, is_unlocked, is_implemented, is_completed)
	_update_lock_overlay(is_unlocked, is_implemented)

func _update_graphics(level_number: String, is_unlocked: bool, is_implemented: bool, is_completed: bool) -> void:
	"""Update the level graphic based on state"""
	var graphics = ["🔮", "⚡", "❄️", "🌱", "🌟", "💎"]  # Different graphic for each level
	var level_num = int(level_number) - 1
	
	if level_num >= 0 and level_num < graphics.size():
		if not is_implemented:
			level_graphic.text = "🚧"  # Construction for coming soon
			level_graphic.modulate = Color.ORANGE
		elif not is_unlocked:
			level_graphic.text = "🔒"  # Lock for locked levels
			level_graphic.modulate = Color.GRAY
		elif is_completed:
			level_graphic.text = graphics[level_num]
			level_graphic.modulate = Color.GREEN  # Green tint for completed
		else:
			level_graphic.text = graphics[level_num]
			level_graphic.modulate = Color.WHITE  # Normal for available
	else:
		level_graphic.text = "❓"

func _update_lock_overlay(is_unlocked: bool, is_implemented: bool) -> void:
	"""Update lock overlay visibility"""
	lock_overlay.visible = not is_unlocked or not is_implemented

func _on_card_clicked(event: InputEvent) -> void:
	"""Handle card click"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var level_def = level_data.get("level_definition", {})
		var is_unlocked = ProgressManager.is_level_unlocked(level_id)
		var is_implemented = level_def.get("implemented", false)
		
		if is_unlocked and is_implemented:
			level_selected.emit(level_id)

func _on_card_resized() -> void:
	"""Handle card resize to scale fonts appropriately"""
	var card_size = get_rect().size
	var scale_factor = card_size.x / 150.0  # Base width scaling
	
	# Scale the graphic (emoji) font size
	if level_graphic:
		var base_graphic_size = 40
		var scaled_size = int(base_graphic_size * scale_factor)
		level_graphic.add_theme_font_size_override("font_size", max(scaled_size, 20))
	
	# Scale the level name font size
	if level_name_label:
		var base_name_size = 14
		var scaled_size = int(base_name_size * scale_factor)
		level_name_label.add_theme_font_size_override("font_size", max(scaled_size, 10))

func refresh_display() -> void:
	"""Refresh the card display with current data"""
	if level_id != "":
		setup_level_card(level_id) 
