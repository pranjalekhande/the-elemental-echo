extends Control

# PauseMenu - Overlay menu that appears when the game is paused
# Provides Resume and Exit to Main Menu options

signal resume_requested
signal exit_requested

@onready var resume_button: Button = $PausePanel/VBox/ResumeButton
@onready var settings_button: Button = $PausePanel/VBox/SettingsButton
@onready var exit_button: Button = $PausePanel/VBox/ExitButton

func _ready() -> void:
	# Set process mode to continue running when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Initially hidden
	visible = false
	
	# Connect button signals if not already connected in scene
	if resume_button and not resume_button.pressed.is_connected(_on_resume_button_pressed):
		resume_button.pressed.connect(_on_resume_button_pressed)
	
	if settings_button and not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
	
	if exit_button and not exit_button.pressed.is_connected(_on_exit_button_pressed):
		exit_button.pressed.connect(_on_exit_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Handle ESC key to resume (only when visible)
	if visible and event.is_action_pressed("ui_cancel"):
		_on_resume_button_pressed()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	"""Show the pause menu and pause the game"""
	visible = true
	get_tree().paused = true
	
	# Center the menu on camera viewport center
	_center_on_camera_view()
	
	# Focus the resume button for keyboard navigation
	if resume_button:
		resume_button.grab_focus()

func _center_on_camera_view() -> void:
	"""Center the pause menu directly over Echo's position"""
	var pause_panel = get_node("PausePanel")
	if pause_panel:
		# Find Echo in the scene using the player group
		var echo = get_tree().get_first_node_in_group("player")
		if echo:
			# Use Godot's proper coordinate conversion
			# Convert Echo's global position to canvas/screen coordinates
			var canvas_transform = get_canvas_transform()
			var echo_screen_pos = canvas_transform * echo.global_position
			
			# Position pause panel directly over Echo (accounting for panel size)
			# Subtract half panel size to center it on Echo
			var panel_center_offset = Vector2(120, 90)  # Half of our 240x180 panel
			pause_panel.position = echo_screen_pos - panel_center_offset
		
		pause_panel.visible = true

func hide_pause_menu() -> void:
	"""Hide the pause menu and resume the game"""
	visible = false
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	"""Handle resume button press"""
	hide_pause_menu()
	resume_requested.emit()

func _on_settings_button_pressed() -> void:
	"""Handle settings button press"""
	print("⚙️ Settings button clicked from PauseMenu!")
	# Unpause before changing scenes to avoid issues
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menus/SettingsMenu.tscn")

func _on_exit_button_pressed() -> void:
	"""Handle exit button press"""
	# Unpause before changing scenes to avoid issues
	get_tree().paused = false
	exit_requested.emit()
	
	# Go directly to level select menu
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn") 