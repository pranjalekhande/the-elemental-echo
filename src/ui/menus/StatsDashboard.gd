extends Control

# StatsDashboard - Comprehensive player statistics and progress overview

@onready var title_label: Label = $VBox/TitleLabel
@onready var global_stats_container: VBoxContainer = $VBox/ScrollContainer/StatsContent/GlobalStatsContainer
@onready var level_stats_container: VBoxContainer = $VBox/ScrollContainer/StatsContent/LevelStatsContainer
@onready var achievements_container: VBoxContainer = $VBox/ScrollContainer/StatsContent/AchievementsContainer
@onready var back_button: Button = $VBox/BackButton
@onready var export_button: Button = $VBox/ButtonContainer/ExportButton
@onready var reset_button: Button = $VBox/ButtonContainer/ResetButton

var global_stats: Dictionary = {}
var level_stats: Array = []

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	export_button.pressed.connect(_on_export_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	_load_and_display_stats()

func _load_and_display_stats() -> void:
	"""Load and display all statistics"""
	global_stats = ProgressManager.get_global_stats()
	_create_global_stats_display()
	_create_level_stats_display()
	_create_achievements_display()

func _create_global_stats_display() -> void:
	"""Create global statistics overview"""
	_clear_container(global_stats_container)
	
	var section_title = Label.new()
	section_title.text = "🌍 Global Statistics"
	section_title.add_theme_font_size_override("font_size", 24)
	global_stats_container.add_child(section_title)
	
	# Total play time
	var play_time_minutes = global_stats.get("total_play_time", 0.0) / 60.0
	_add_stat_row(global_stats_container, "⏱️ Total Play Time", "%.1f minutes" % play_time_minutes)
	
	# Completion statistics
	_add_stat_row(global_stats_container, "🎯 Total Attempts", str(global_stats.get("total_attempts", 0)))
	_add_stat_row(global_stats_container, "✅ Total Completions", str(global_stats.get("total_completions", 0)))
	
	# Calculate success rate
	var attempts = global_stats.get("total_attempts", 0)
	var completions = global_stats.get("total_completions", 0)
	var success_rate = 0.0
	if attempts > 0:
		success_rate = (float(completions) / float(attempts)) * 100.0
	_add_stat_row(global_stats_container, "📊 Success Rate", "%.1f%%" % success_rate)
	
	# Form switching and efficiency
	_add_stat_row(global_stats_container, "🔄 Total Form Switches", str(global_stats.get("total_form_switches", 0)))
	_add_stat_row(global_stats_container, "💎 Total Diamonds Collected", str(global_stats.get("total_diamonds_collected", 0)))
	
	# Average efficiency
	if completions > 0:
		var avg_switches = float(global_stats.get("total_form_switches", 0)) / float(completions)
		_add_stat_row(global_stats_container, "⚡ Avg. Form Switches per Completion", "%.1f" % avg_switches)

func _create_level_stats_display() -> void:
	"""Create detailed level-by-level statistics"""
	_clear_container(level_stats_container)
	
	var section_title = Label.new()
	section_title.text = "📊 Level Statistics"
	section_title.add_theme_font_size_override("font_size", 24)
	level_stats_container.add_child(section_title)
	
	# Get all available levels
	var available_levels = ProgressManager.get_available_levels()
	
	for level_info in available_levels:
		var level_id = level_info["id"]
		var level_progress = ProgressManager.get_level_progress(level_id)
		var level_def = level_progress.get("level_definition", {})
		
		# Create level section
		var level_section = VBoxContainer.new()
		level_stats_container.add_child(level_section)
		
		# Level title
		var level_title = Label.new()
		level_title.text = "🏛️ %s - %s" % [level_def.get("name", "Unknown"), level_def.get("theme", "")]
		level_title.add_theme_font_size_override("font_size", 18)
		level_section.add_child(level_title)
		
		# Status
		var status = level_progress.get("status", "locked")
		var status_text = _get_status_display_text(status)
		_add_stat_row(level_section, "Status", status_text)
		
		if ProgressManager.is_level_unlocked(level_id):
			# Performance stats
			if level_progress.get("total_completions", 0) > 0:
				_add_stat_row(level_section, "Best Time", "%.1fs" % level_progress.get("best_time", 0.0))
				_add_stat_row(level_section, "Best Score", str(level_progress.get("best_score", 0)))
				_add_stat_row(level_section, "Best Completion", "%.0f%%" % level_progress.get("best_completion_percentage", 0.0))
				_add_stat_row(level_section, "Fewest Form Switches", str(level_progress.get("best_form_switches", 0)))
			
			# Attempt statistics
			_add_stat_row(level_section, "Total Attempts", str(level_progress.get("total_attempts", 0)))
			_add_stat_row(level_section, "Total Completions", str(level_progress.get("total_completions", 0)))
			_add_stat_row(level_section, "Success Rate", "%.1f%%" % level_progress.get("completion_rate", 0.0))
			
			# Last played
			var last_played = level_progress.get("last_played", "")
			if last_played != "":
				_add_stat_row(level_section, "Last Played", last_played.substr(0, 16))  # Just date and time
		
		# Add separator
		var separator = HSeparator.new()
		level_section.add_child(separator)

func _create_achievements_display() -> void:
	"""Create achievements and milestones display"""
	_clear_container(achievements_container)
	
	var section_title = Label.new()
	section_title.text = "🏆 Achievements & Milestones"
	section_title.add_theme_font_size_override("font_size", 24)
	achievements_container.add_child(section_title)
	
	# Calculate achievements
	var achievements = _calculate_achievements()
	
	for achievement in achievements:
		var achievement_row = HBoxContainer.new()
		achievements_container.add_child(achievement_row)
		
		var icon_label = Label.new()
		icon_label.text = achievement["icon"]
		achievement_row.add_child(icon_label)
		
		var desc_label = Label.new()
		desc_label.text = achievement["description"]
		desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		achievement_row.add_child(desc_label)
		
		var status_label = Label.new()
		status_label.text = "✅" if achievement["unlocked"] else "🔒"
		achievement_row.add_child(status_label)

func _calculate_achievements() -> Array:
	"""Calculate which achievements have been unlocked"""
	var achievements = []
	
	# First steps
	achievements.append({
		"icon": "👶",
		"description": "First Steps - Complete your first level",
		"unlocked": global_stats.get("total_completions", 0) > 0
	})
	
	# Persistence
	achievements.append({
		"icon": "💪",
		"description": "Persistent Explorer - Complete 10 level attempts",
		"unlocked": global_stats.get("total_attempts", 0) >= 10
	})
	
	# Mastery
	achievements.append({
		"icon": "🎯",
		"description": "Echo Master - Complete both levels",
		"unlocked": ProgressManager.has_completed_level("level_1") and ProgressManager.has_completed_level("level_2")
	})
	
	# Efficiency
	var avg_switches = 0.0
	if global_stats.get("total_completions", 0) > 0:
		avg_switches = float(global_stats.get("total_form_switches", 0)) / float(global_stats.get("total_completions", 0))
	
	achievements.append({
		"icon": "⚡",
		"description": "Efficiency Expert - Average under 4 form switches per completion",
		"unlocked": avg_switches < 4.0 and global_stats.get("total_completions", 0) > 0
	})
	
	# Time investment
	achievements.append({
		"icon": "⏰",
		"description": "Dedicated Player - Play for over 30 minutes total",
		"unlocked": global_stats.get("total_play_time", 0.0) > 1800.0  # 30 minutes
	})
	
	return achievements

func _get_status_display_text(status: String) -> String:
	"""Convert status to display text"""
	match status:
		"locked": return "🔒 Locked"
		"never_played": return "🆕 Never Played"
		"in_progress": return "⏳ In Progress"
		"completed": return "✅ Completed"
		_: return "❓ Unknown"

func _add_stat_row(container: Node, label_text: String, value_text: String) -> void:
	"""Add a stat row with label and value"""
	var row = HBoxContainer.new()
	container.add_child(row)
	
	var label = Label.new()
	label.text = label_text + ":"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	
	var value = Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)

func _clear_container(container: Node) -> void:
	"""Clear all children from a container"""
	for child in container.get_children():
		child.queue_free()

func _on_back_button_pressed() -> void:
	"""Return to level select menu"""
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

func _on_export_button_pressed() -> void:
	"""Export statistics to a text file"""
	var export_text = _generate_export_text()
	var file = FileAccess.open("user://statistics_export.txt", FileAccess.WRITE)
	if file:
		file.store_string(export_text)
		file.close()
		print("Statistics exported to user://statistics_export.txt")
		# Show confirmation (simple approach)
		_show_export_confirmation()

func _on_reset_button_pressed() -> void:
	"""Reset all statistics (with confirmation)"""
	# Simple confirmation dialog using AcceptDialog
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to reset all statistics? This cannot be undone."
	dialog.title = "Reset Statistics"
	add_child(dialog)
	dialog.popup_centered()
	
	# Connect to confirmed signal
	dialog.confirmed.connect(_perform_reset)
	dialog.tree_exited.connect(dialog.queue_free)

func _perform_reset() -> void:
	"""Actually perform the statistics reset"""
	# This would need to be implemented in ProgressManager
	print("Statistics reset requested - would implement in ProgressManager")

func _generate_export_text() -> String:
	"""Generate formatted text for statistics export"""
	var text = "THE ELEMENTAL ECHO - STATISTICS EXPORT\n"
	text += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	
	text += "GLOBAL STATISTICS:\n"
	text += "Total Play Time: %.1f minutes\n" % (global_stats.get("total_play_time", 0.0) / 60.0)
	text += "Total Attempts: %d\n" % global_stats.get("total_attempts", 0)
	text += "Total Completions: %d\n" % global_stats.get("total_completions", 0)
	text += "Total Form Switches: %d\n" % global_stats.get("total_form_switches", 0)
	text += "Total Diamonds Collected: %d\n\n" % global_stats.get("total_diamonds_collected", 0)
	
	text += "LEVEL STATISTICS:\n"
	var available_levels = ProgressManager.get_available_levels()
	for level_info in available_levels:
		var level_id = level_info["id"]
		var level_progress = ProgressManager.get_level_progress(level_id)
		var level_def = level_progress.get("level_definition", {})
		
		text += "\n%s - %s:\n" % [level_def.get("name", "Unknown"), level_def.get("theme", "")]
		text += "  Status: %s\n" % _get_status_display_text(level_progress.get("status", "locked"))
		if level_progress.get("total_completions", 0) > 0:
			text += "  Best Time: %.1fs\n" % level_progress.get("best_time", 0.0)
			text += "  Best Score: %d\n" % level_progress.get("best_score", 0)
			text += "  Success Rate: %.1f%%\n" % level_progress.get("completion_rate", 0.0)
	
	return text

func _show_export_confirmation() -> void:
	"""Show export confirmation"""
	var export_label = Label.new()
	export_label.text = "📊 Statistics exported!"
	export_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	export_label.add_theme_color_override("font_color", Color.GREEN)
	
	add_child(export_label)
	export_label.position = Vector2(get_rect().size.x / 2 - 100, 100)
	
	# Animate and remove notification
	var tween = create_tween()
	tween.tween_property(export_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(export_label.queue_free) 