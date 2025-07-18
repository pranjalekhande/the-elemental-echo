extends Control

# NameInputDialog - Simple dialog for capturing player names
# Emits signals when name is confirmed or dialog is canceled

signal name_confirmed(player_name: String)
signal dialog_canceled

@onready var name_input: LineEdit = $DialogPanel/VBox/NameInput
@onready var confirm_button: Button = $DialogPanel/VBox/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $DialogPanel/VBox/ButtonContainer/CancelButton

var default_name: String = ""

func _ready() -> void:
	# Set process mode to continue when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	
	# Connect input signals
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.text_changed.connect(_on_text_changed)
	
	# Focus the input field
	call_deferred("_focus_input")
	
	# Set default name if provided
	if default_name != "":
		name_input.text = default_name
		name_input.select_all()

func _focus_input() -> void:
	"""Focus the name input field"""
	name_input.grab_focus()

func show_dialog(current_name: String = "") -> void:
	"""Show the dialog with optional current name"""
	default_name = current_name
	if current_name != "":
		name_input.text = current_name
		name_input.select_all()
	visible = true
	call_deferred("_focus_input")

func _on_confirm_button_pressed() -> void:
	"""Handle confirm button press"""
	_submit_name()

func _on_cancel_button_pressed() -> void:
	"""Handle cancel button press"""
	visible = false
	dialog_canceled.emit()

func _on_name_submitted(text: String) -> void:
	"""Handle Enter key press in input field"""
	_submit_name()

func _on_text_changed(new_text: String) -> void:
	"""Handle text changes to update button state"""
	var cleaned_text = new_text.strip_edges()
	confirm_button.disabled = cleaned_text.length() < 1
	
	# Optional: Show character count or validation feedback
	if cleaned_text.length() > 15:
		confirm_button.text = "Too Long!"
		confirm_button.disabled = true
	else:
		confirm_button.text = "Confirm"

func _submit_name() -> void:
	"""Validate and submit the entered name"""
	var player_name = name_input.text.strip_edges()
	
	# Validation
	if player_name.length() < 1:
		_show_validation_error("Please enter a name")
		return
	
	if player_name.length() > 20:
		_show_validation_error("Name too long (max 20 characters)")
		return
	
	# Filter out inappropriate content (basic)
	if _contains_inappropriate_content(player_name):
		_show_validation_error("Please choose a different name")
		return
	
	# Submit the name
	visible = false
	name_confirmed.emit(player_name)

func _show_validation_error(message: String) -> void:
	"""Show validation error feedback"""
	confirm_button.text = message
	confirm_button.disabled = true
	
	# Reset button after delay
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		confirm_button.text = "Confirm"
		_on_text_changed(name_input.text)
	)

func _contains_inappropriate_content(text: String) -> bool:
	"""Basic content filtering"""
	var lowercase_text = text.to_lower()
	
	# Simple forbidden words list (extend as needed)
	var forbidden_words = ["admin", "moderator", "system", "bot"]
	
	for word in forbidden_words:
		if lowercase_text.contains(word):
			return true
	
	return false

func _unhandled_input(event: InputEvent) -> void:
	"""Handle ESC key to cancel dialog"""
	if visible and event.is_action_pressed("ui_cancel"):
		_on_cancel_button_pressed()
		get_viewport().set_input_as_handled() 