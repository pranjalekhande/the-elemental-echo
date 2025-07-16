extends Control

# StartMenu - Main menu for The Elemental Echo
# Handles navigation to level selection and quick play

@onready var play_button: TextureButton = $UI/PlayButton

func _ready() -> void:
	# Connect button signals if not already connected in scene
	if play_button and not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)
	
	# Enable responsive scaling
	resized.connect(_on_menu_resized)
	# Initial scale setup
	call_deferred("_on_menu_resized")

func _on_play_button_pressed() -> void:
	# Navigate to level selection menu
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

func _on_menu_resized() -> void:
	"""Handle menu resize to scale elements appropriately"""
	var screen_size = get_rect().size
	var base_width = 1920.0  # Base design width
	var base_height = 1080.0  # Base design height
	
	# Calculate scale factors
	var width_scale = screen_size.x / base_width
	var height_scale = screen_size.y / base_height
	var scale_factor = min(width_scale, height_scale)
	
	# Scale button font and minimum size
	if play_button:
		var base_button_size = 20
		var scaled_size = int(base_button_size * scale_factor)
		play_button.add_theme_font_size_override("font_size", max(scaled_size, 14))
		
		# Scale button minimum size
		var base_button_width = 200
		var base_button_height = 55
		var scaled_width = int(base_button_width * scale_factor)
		var scaled_height = int(base_button_height * scale_factor)
		play_button.custom_minimum_size = Vector2(max(scaled_width, 150), max(scaled_height, 40))

# Optional: Add methods for future menu options
func _on_settings_button_pressed() -> void:
	# Future: Open settings menu
	pass

func _on_quit_button_pressed() -> void:
	# Quit game
	get_tree().quit() 
