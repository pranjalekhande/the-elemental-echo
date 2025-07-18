extends Control

# SettingsMenu - Modern settings interface with audio controls
# Clean, responsive UI for adjusting SFX and Music settings

# Node references
var sfx_toggle: CheckBox
var sfx_slider: HSlider
var sfx_value_label: Label
var music_toggle: CheckBox
var music_slider: HSlider
var music_value_label: Label
var reset_button: Button
var back_button: Button

# Player name references
var name_input: LineEdit
var name_apply_button: Button
var name_status_label: Label

# Settings update tracking
var updating_ui: bool = false

func _ready() -> void:
	# Get node references
	_get_node_references()
	
	# Connect UI signals
	_connect_signals()
	
	# Load current settings into UI
	_update_ui_from_settings()
	
	# Connect to settings changes
	if SettingsManager:
		SettingsManager.settings_changed.connect(_on_settings_changed)
	
	print("⚙️ SettingsMenu ready")
	print("   Current player name: '%s'" % (ProgressManager.get_player_name() if ProgressManager else "N/A"))

func _get_node_references() -> void:
	"""Get references to all UI elements"""
	sfx_toggle = get_node("VBox/AudioSection/SFXContainer/SFXToggle")
	sfx_slider = get_node("VBox/AudioSection/SFXContainer/SFXSlider")
	sfx_value_label = get_node("VBox/AudioSection/SFXContainer/SFXValueLabel")
	
	music_toggle = get_node("VBox/AudioSection/MusicContainer/MusicToggle")
	music_slider = get_node("VBox/AudioSection/MusicContainer/MusicSlider")
	music_value_label = get_node("VBox/AudioSection/MusicContainer/MusicValueLabel")
	
	reset_button = get_node("VBox/ButtonContainer/ResetButton")
	back_button = get_node("VBox/BackButton")
	
	# Player name elements
	name_input = get_node("VBox/PlayerSection/NameContainer/NameInput")
	name_apply_button = get_node("VBox/PlayerSection/NameContainer/NameApplyButton")
	name_status_label = get_node("VBox/PlayerSection/NameStatusLabel")

func _connect_signals() -> void:
	"""Connect all UI signals to their handlers"""
	# SFX controls
	if sfx_toggle:
		sfx_toggle.toggled.connect(_on_sfx_toggle_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Music controls
	if music_toggle:
		music_toggle.toggled.connect(_on_music_toggle_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	
	# Action buttons
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Player name controls
	if name_apply_button:
		name_apply_button.pressed.connect(_on_name_apply_pressed)
	if name_input:
		name_input.text_submitted.connect(_on_name_text_submitted)

func _update_ui_from_settings() -> void:
	"""Update UI elements to reflect current settings"""
	if not SettingsManager:
		return
	
	updating_ui = true
	
	# Update SFX controls
	if sfx_toggle:
		sfx_toggle.button_pressed = SettingsManager.sfx_enabled
	if sfx_slider:
		sfx_slider.value = SettingsManager.get_sfx_volume_percent()
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % SettingsManager.get_sfx_volume_percent()
	
	# Update Music controls
	if music_toggle:
		music_toggle.button_pressed = SettingsManager.music_enabled
	if music_slider:
		music_slider.value = SettingsManager.get_music_volume_percent()
	if music_value_label:
		music_value_label.text = "%d%%" % SettingsManager.get_music_volume_percent()
	
	# Update slider states based on toggle states
	_update_slider_states()
	
	# Update player name
	_update_name_display()
	
	updating_ui = false

func _update_slider_states() -> void:
	"""Enable/disable sliders based on toggle states"""
	if sfx_slider:
		sfx_slider.editable = SettingsManager.sfx_enabled if SettingsManager else true
	if music_slider:
		music_slider.editable = SettingsManager.music_enabled if SettingsManager else true

# Signal handlers
func _on_sfx_toggle_changed(enabled: bool) -> void:
	"""Handle SFX toggle change"""
	if updating_ui or not SettingsManager:
		return
	
	SettingsManager.set_sfx_enabled(enabled)
	_update_slider_states()
	print("🔊 SFX %s" % ("enabled" if enabled else "disabled"))

func _on_sfx_volume_changed(value: float) -> void:
	"""Handle SFX volume slider change"""
	if updating_ui or not SettingsManager:
		return
	
	var volume = value / 100.0
	SettingsManager.set_sfx_volume(volume)
	
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % int(value)
	
	print("🔊 SFX volume: %d%%" % int(value))

func _on_music_toggle_changed(enabled: bool) -> void:
	"""Handle Music toggle change"""
	if updating_ui or not SettingsManager:
		return
	
	SettingsManager.set_music_enabled(enabled)
	_update_slider_states()
	print("🎵 Music %s" % ("enabled" if enabled else "disabled"))

func _on_music_volume_changed(value: float) -> void:
	"""Handle Music volume slider change"""
	if updating_ui or not SettingsManager:
		return
	
	var volume = value / 100.0
	SettingsManager.set_music_volume(volume)
	
	if music_value_label:
		music_value_label.text = "%d%%" % int(value)
	
	print("🎵 Music volume: %d%%" % int(value))

func _on_reset_pressed() -> void:
	"""Reset all settings to default values"""
	if SettingsManager:
		SettingsManager.reset_to_defaults()
		_update_ui_from_settings()
		print("🔄 Settings reset to defaults")

func _on_back_pressed() -> void:
	"""Return to previous menu"""
	# Try to determine where we came from and return there
	# For now, go back to StartMenu (can be enhanced later)
	get_tree().change_scene_to_file("res://scenes/ui/menus/StartMenu.tscn")

func _on_settings_changed(setting_name: String, value: float) -> void:
	"""Handle settings changes from external sources"""
	if updating_ui:
		return
	
	# Refresh UI to reflect external changes
	_update_ui_from_settings()
	print("⚙️ Settings updated externally: %s = %.2f" % [setting_name, value])

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

# Player Name Functions
func _update_name_display() -> void:
	"""Update the name input field and status label"""
	if not ProgressManager:
		return
	
	var current_name = ProgressManager.get_player_name()
	
	if name_input:
		name_input.text = current_name
	
	if name_status_label:
		if current_name != "":
			name_status_label.text = "Current: %s" % current_name
			name_status_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7, 1))  # Green tint
		else:
			name_status_label.text = "Current: No name set"
			name_status_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.7, 1))  # Red tint

func _validate_name(player_name: String) -> Dictionary:
	"""Validate player name input - returns {valid: bool, error: String}"""
	var cleaned_name = player_name.strip_edges()
	
	if cleaned_name.length() < 1:
		return {"valid": false, "error": "Name cannot be empty"}
	
	if cleaned_name.length() > 20:
		return {"valid": false, "error": "Name too long (max 20 characters)"}
	
	# Check for inappropriate content (basic filter)
	var banned_words = ["admin", "system", "null", "undefined", "bot"]
	var lower_name = cleaned_name.to_lower()
	for word in banned_words:
		if lower_name.contains(word):
			return {"valid": false, "error": "Name contains restricted words"}
	
	return {"valid": true, "error": "", "name": cleaned_name}

func _apply_name_change(new_name: String) -> void:
	"""Apply the name change and update all relevant systems"""
	if not ProgressManager:
		print("❌ ProgressManager not available")
		return
	
	var old_name = ProgressManager.get_player_name()
	ProgressManager.set_player_name(new_name)
	
	# Update display
	_update_name_display()
	
	print("✅ Player name changed from '%s' to '%s'" % [old_name, new_name])
	
	# Show success feedback
	if name_status_label:
		name_status_label.text = "✅ Name saved: %s" % new_name
		name_status_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7, 1))

func _show_name_error(error_message: String) -> void:
	"""Show name validation error"""
	if name_status_label:
		name_status_label.text = "❌ %s" % error_message
		name_status_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.7, 1))
	print("❌ Name validation error: %s" % error_message)

# Player Name Signal Handlers
func _on_name_apply_pressed() -> void:
	"""Handle Apply button press for name change"""
	if not name_input:
		return
	
	var input_name = name_input.text
	var validation = _validate_name(input_name)
	
	if validation.valid:
		_apply_name_change(validation.name)
	else:
		_show_name_error(validation.error)

func _on_name_text_submitted(new_text: String) -> void:
	"""Handle Enter key press in name input field"""
	_on_name_apply_pressed() 