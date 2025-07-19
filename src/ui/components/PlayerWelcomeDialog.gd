extends Control

# PlayerWelcomeDialog - Welcome screen with optional name input for new and returning users
# Handles the player identification flow after StartMenu play button

signal welcome_completed(player_name: String)
signal dialog_skipped()

@onready var dialog_panel: Panel = $DialogPanel
@onready var title_label: Label = $DialogPanel/VBox/TitleLabel
@onready var message_label: Label = $DialogPanel/VBox/MessageLabel
@onready var name_input: LineEdit = $DialogPanel/VBox/NameInputContainer/NameInput
@onready var continue_button: Button = $DialogPanel/VBox/ButtonContainer/ContinueButton
@onready var skip_button: Button = $DialogPanel/VBox/ButtonContainer/SkipButton
@onready var change_button: Button = $DialogPanel/VBox/ButtonContainer/ChangeButton

# Dialog state
var dialog_mode: String = "new_user"  # "new_user" or "returning_user"
var original_name: String = ""
var is_editing_name: bool = false

func _ready() -> void:
	# Set process mode to continue when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	continue_button.pressed.connect(_on_continue_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	change_button.pressed.connect(_on_change_pressed)
	
	# Connect input signals
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.text_changed.connect(_on_text_changed)
	
	# Initially hidden
	visible = false
	
	# Focus handling
	call_deferred("_setup_initial_focus")

func _setup_initial_focus() -> void:
	"""Setup initial focus based on dialog mode"""
	if dialog_mode == "new_user":
		name_input.grab_focus()
	else:
		continue_button.grab_focus()

func show_welcome_dialog() -> void:
	"""Show the welcome dialog with appropriate content for user state"""
	_determine_dialog_mode()
	_setup_dialog_content()
	visible = true
	call_deferred("_setup_initial_focus")

func _determine_dialog_mode() -> void:
	"""Determine if this is a new user or returning user"""
	if ProgressManager and ProgressManager.has_player_name():
		dialog_mode = "returning_user"
		original_name = ProgressManager.get_player_name()
	else:
		dialog_mode = "new_user"
		original_name = ""

func _setup_dialog_content() -> void:
	"""Setup dialog content based on user state"""
	match dialog_mode:
		"new_user":
			_setup_for_new_user()
		"returning_user":
			_setup_for_returning_user()

func _setup_for_new_user() -> void:
	"""Setup dialog for new users"""
	title_label.text = "Welcome to The Elemental Echo!"
	message_label.text = "Enter your name to personalize your adventure"
	name_input.text = ""
	name_input.placeholder_text = "Your name (optional)..."
	
	# Button configuration
	continue_button.text = "Start Playing"
	
	# Update skip button to show next guest name
	var next_guest = _get_next_guest_name()
	skip_button.text = "Play as " + next_guest
	change_button.visible = false
	
	# Enable name input
	name_input.editable = true
	is_editing_name = true

func _setup_for_returning_user() -> void:
	"""Setup dialog for returning users"""
	title_label.text = "Welcome back!"
	message_label.text = "Continue with your saved progress?"
	name_input.text = original_name
	name_input.placeholder_text = ""
	
	# Button configuration
	continue_button.text = "Continue as " + original_name
	
	# Update skip button to show next guest name
	var next_guest = _get_next_guest_name()
	skip_button.text = "Play as " + next_guest
	
	change_button.text = "Change Name"
	change_button.visible = true
	
	# Disable name input initially
	name_input.editable = false
	is_editing_name = false

func _on_continue_pressed() -> void:
	"""Handle continue button press"""
	var player_name = name_input.text.strip_edges()
	
	if dialog_mode == "new_user" or is_editing_name:
		# Validate name if provided
		if player_name.length() > 0:
			var validation = _validate_name(player_name)
			if not validation.valid:
				_show_validation_error(validation.error)
				return
		
		# Save name if provided (don't overwrite with empty)
		if player_name.length() > 0:
			if ProgressManager:
				ProgressManager.set_player_name(player_name)
				print("✅ Player name saved: '%s'" % player_name)
	else:
		# Returning user continuing with existing name
		player_name = original_name
	
	# Complete the welcome flow
	_complete_welcome(player_name)

func _on_skip_pressed() -> void:
	"""Handle skip button press - play as guest"""
	print("⚠️ User chose to play as guest")
	var guest_name = _get_next_guest_name()
	print("🎮 Assigned guest name: %s" % guest_name)
	_complete_welcome(guest_name)

func _on_change_pressed() -> void:
	"""Handle change name button press for returning users"""
	is_editing_name = true
	name_input.editable = true
	name_input.grab_focus()
	name_input.select_all()
	
	# Update button text
	continue_button.text = "Save & Continue"
	change_button.visible = false

func _on_name_submitted(text: String) -> void:
	"""Handle Enter key press in name input"""
	_on_continue_pressed()

func _on_text_changed(new_text: String) -> void:
	"""Handle text changes for validation feedback"""
	var cleaned_text = new_text.strip_edges()
	
	if dialog_mode == "new_user":
		if cleaned_text.length() == 0:
			continue_button.text = "Start Playing"
		else:
			continue_button.text = "Start as " + cleaned_text
	elif is_editing_name:
		if cleaned_text.length() > 0:
			continue_button.text = "Save & Continue"
		else:
			continue_button.text = "Continue"
	
	# Basic length validation
	if cleaned_text.length() > 20:
		continue_button.disabled = true
		_show_validation_error("Name too long (max 20 characters)")
	else:
		continue_button.disabled = false
		_clear_validation_error()

func _validate_name(player_name: String) -> Dictionary:
	"""Validate player name input - returns {valid: bool, error: String}"""
	var cleaned_name = player_name.strip_edges()
	
	if cleaned_name.length() > 20:
		return {"valid": false, "error": "Name too long (max 20 characters)"}
	
	# Prevent users from manually entering guest names
	if cleaned_name.to_lower().begins_with("guest "):
		return {"valid": false, "error": "Guest names are auto-assigned. Use the 'Play as Guest' button."}
	
	# Check for inappropriate content (basic filter)
	var banned_words = ["admin", "system", "null", "undefined", "bot"]
	var lower_name = cleaned_name.to_lower()
	for word in banned_words:
		if lower_name.contains(word):
			return {"valid": false, "error": "Please choose a different name"}
	
	return {"valid": true, "error": ""}

func _show_validation_error(error_message: String) -> void:
	"""Show validation error feedback"""
	message_label.text = "❌ " + error_message
	message_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))

func _clear_validation_error() -> void:
	"""Clear validation error and restore normal message"""
	message_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	if dialog_mode == "new_user":
		message_label.text = "Enter your name to personalize your adventure"
	else:
		message_label.text = "Continue with your saved progress?"

func _complete_welcome(player_name: String) -> void:
	"""Complete the welcome flow and emit completion signal"""
	visible = false
	welcome_completed.emit(player_name)
	print("✅ Welcome flow completed for: '%s'" % player_name)

func _get_next_guest_name() -> String:
	"""Get the next available guest name from LeaderboardService"""
	var lbs = null
	if Engine.has_singleton("LeaderboardService"):
		lbs = Engine.get_singleton("LeaderboardService")
	else:
		lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
	
	if lbs and lbs.has_method("get_next_guest_name"):
		return lbs.get_next_guest_name()
	else:
		print("⚠️ LeaderboardService not found, using default guest name")
		return "Guest 1"

func _unhandled_input(event: InputEvent) -> void:
	"""Handle ESC key to skip dialog"""
	if visible and event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
		get_viewport().set_input_as_handled() 