extends Control
class_name LevelCard

# LevelCard - Reusable component for displaying level information and progress

signal level_selected(level_id: String)

@onready var level_name_label: Label = $VBox/LevelName
@onready var theme_label: Label = $VBox/Theme
@onready var status_label: Label = $VBox/StatusContainer/StatusLabel
@onready var best_time_label: Label = $VBox/StatsContainer/BestTimeLabel
@onready var completion_label: Label = $VBox/StatsContainer/CompletionLabel
@onready var play_button: Button = $VBox/PlayButton
@onready var lock_overlay: Control = $LockOverlay
@onready var progress_bar: ProgressBar = $VBox/ProgressBar

var level_id: String = ""
var level_data: Dictionary = {}

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)

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
	theme_label.text = level_def.get("name", "Unknown Level")
	
	# Status and availability
	var status = level_data.get("status", "locked")
	var is_unlocked = ProgressManager.is_level_unlocked(level_id)
	var is_implemented = level_def.get("implemented", false)
	
	_update_status_display(status, is_unlocked, is_implemented)
	_update_stats_display()
	_update_progress_display()
	_update_button_display(status, is_unlocked, is_implemented)

func _update_status_display(status: String, is_unlocked: bool, is_implemented: bool) -> void:
	"""Update status label and lock overlay"""
	lock_overlay.visible = not is_unlocked or not is_implemented
	
	if not is_implemented:
		status_label.text = "🚧 Coming Soon"
		status_label.modulate = Color.ORANGE
	elif not is_unlocked:
		# Find which level needs to be completed to unlock this one
		var level_def = level_data.get("level_definition", {})
		var requirements = level_def.get("unlock_requirements", [])
		if requirements.size() > 0:
			var req_level = requirements[0]
			var req_number = req_level.get_slice("_", 1)
			status_label.text = "🔒 Complete Level %s" % req_number
		else:
			status_label.text = "🔒 Locked"
		status_label.modulate = Color.GRAY
	else:
		match status:
			"never_played":
				status_label.text = "🆕 New"
				status_label.modulate = Color.CYAN
			"in_progress":
				status_label.text = "⏳ In Progress"
				status_label.modulate = Color.YELLOW
			"completed":
				status_label.text = "✅ Completed"
				status_label.modulate = Color.GREEN
			_:
				status_label.text = "🆕 New"
				status_label.modulate = Color.CYAN

func _update_stats_display() -> void:
	"""Update best time and completion statistics"""
	if level_data.get("total_completions", 0) > 0:
		var best_time = level_data.get("best_time", 0.0)
		best_time_label.text = "Best: %.1fs" % best_time
		best_time_label.visible = true
		
		var completion_rate = level_data.get("completion_rate", 0.0)
		completion_label.text = "Success: %.0f%%" % completion_rate
		completion_label.visible = true
	else:
		best_time_label.visible = false
		completion_label.visible = false

func _update_progress_display() -> void:
	"""Update progress bar based on completion percentage"""
	var completion_rate = level_data.get("completion_rate", 0.0)
	progress_bar.value = completion_rate
	progress_bar.visible = level_data.get("total_attempts", 0) > 0

func _update_button_display(_status: String, is_unlocked: bool, is_implemented: bool) -> void:
	"""Update play button text and state"""
	play_button.disabled = not is_unlocked or not is_implemented
	
	if not is_implemented:
		play_button.text = "Coming Soon"
	elif not is_unlocked:
		play_button.text = "Locked"
	elif level_data.get("total_completions", 0) == 0:
		play_button.text = "Play"
	else:
		play_button.text = "Replay"

func _on_play_button_pressed() -> void:
	"""Handle play button click"""
	if ProgressManager.is_level_unlocked(level_id):
		level_selected.emit(level_id)

func refresh_display() -> void:
	"""Refresh the card display with current data"""
	if level_id != "":
		setup_level_card(level_id) 