extends Node

# ProgressManager - Singleton for anonymous device-based progress tracking
# Handles persistent level completion data, unlocks, and statistics

signal level_unlocked(level_id: String)
signal new_record_achieved(level_id: String, record_type: String, value)
signal progress_saved()

# Save file configuration
const SAVE_FILE_PATH = "user://save_data.json"
const SAVE_VERSION = "1.0"

# Progress data structure
var save_data: Dictionary = {}
var device_id: String = ""

# Level configuration
var level_definitions: Dictionary = {
	"level_1": {
		"name": "First Steps",
		"scene_path": "res://scenes/levels/Main.tscn",
		"unlock_requirements": [],
		"theme": "Tutorial Chamber",
		"implemented": true
	},
	"level_2": {
		"name": "Ascending Echoes", 
		"scene_path": "res://scenes/levels/Level2.tscn",
		"unlock_requirements": ["level_1"],
		"theme": "Vertical Chamber",
		"implemented": true
	},
	"level_3": {
		"name": "Crystal Depths",
		"scene_path": "res://scenes/levels/Level3.tscn",
		"unlock_requirements": ["level_2"],
		"theme": "Underground Crystal Caverns",
		"implemented": false
	},
	"level_4": {
		"name": "Flowing Rivers",
		"scene_path": "res://scenes/levels/Level4.tscn", 
		"unlock_requirements": ["level_3"],
		"theme": "Water Temple Rapids",
		"implemented": false
	},
	"level_5": {
		"name": "Sky Sanctuary",
		"scene_path": "res://scenes/levels/Level5.tscn",
		"unlock_requirements": ["level_4"],
		"theme": "Floating Sky Platforms",
		"implemented": false
	},
	"level_6": {
		"name": "Final Convergence",
		"scene_path": "res://scenes/levels/Level6.tscn",
		"unlock_requirements": ["level_5"],
		"theme": "The Ultimate Trial",
		"implemented": false
	}
}

func _ready() -> void:
	load_progress()

func load_progress() -> void:
	"""Load progress data from device storage"""
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				save_data = json.data
				device_id = save_data.get("device_id", "")
	
			else:
				print("Failed to parse save data, creating new save")
				_create_new_save()
		else:
			print("Failed to open save file, creating new save")
			_create_new_save()
	else:
		print("No save file found, creating new save")
		_create_new_save()
	
	# Ensure device ID exists
	if device_id.is_empty():
		device_id = _generate_device_id()
		save_data["device_id"] = device_id
		save_progress()

func save_progress() -> void:
	"""Save progress data to device storage"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
		progress_saved.emit()

	else:
		print("Failed to save progress data")

func _create_new_save() -> void:
	"""Initialize new save data structure"""
	save_data = {
		"version": SAVE_VERSION,
		"device_id": _generate_device_id(),
		"created_at": Time.get_datetime_string_from_system(),
		"player_name": "",  # Add player name storage
		"levels": {},
		"global_stats": {
			"total_play_time": 0.0,
			"total_form_switches": 0,
			"total_diamonds_collected": 0,
			"total_attempts": 0,
			"total_completions": 0,
			"favorite_level": ""
		}
	}
	device_id = save_data["device_id"]

func _generate_device_id() -> String:
	"""Generate unique anonymous device identifier"""
	var time_stamp = Time.get_unix_time_from_system()
	var random_part = int(randf_range(100000, 999999))
	return "device_%d_%d" % [time_stamp, random_part]

func save_level_completion(level_id: String, completion_data: Dictionary) -> void:
	"""Save completion data for a level"""
	if not save_data.has("levels"):
		save_data["levels"] = {}
	
	if not save_data["levels"].has(level_id):
		save_data["levels"][level_id] = _create_new_level_data()
	
	var level_data = save_data["levels"][level_id]
	var was_first_completion = level_data["total_completions"] == 0
	
	# Update level-specific stats
	level_data["total_attempts"] += 1
	level_data["total_completions"] += 1
	level_data["last_played"] = Time.get_datetime_string_from_system()
	
	# Set first completion if this is the first time
	if was_first_completion:
		level_data["first_completion"] = level_data["last_played"]
	
	# Update best records if improved
	var session_time = completion_data.get("session_time", 0.0)
	var final_score = completion_data.get("final_score", 0)
	var completion_percent = completion_data.get("completion_percent", 0.0)
	var form_switches = completion_data.get("form_switches", 0)
	
	_update_best_record(level_data, "best_time", session_time, true)  # Lower is better
	_update_best_record(level_data, "best_score", final_score, false) # Higher is better
	_update_best_record(level_data, "best_completion_percentage", completion_percent, false)
	_update_best_record(level_data, "best_form_switches", form_switches, true)
	
	# Update global stats
	save_data["global_stats"]["total_play_time"] += session_time
	save_data["global_stats"]["total_form_switches"] += form_switches
	save_data["global_stats"]["total_diamonds_collected"] += completion_data.get("total_collected", 0)
	save_data["global_stats"]["total_attempts"] += 1
	save_data["global_stats"]["total_completions"] += 1
	
	# Check for level unlocks
	_check_level_unlocks(level_id)
	
	save_progress()

func _create_new_level_data() -> Dictionary:
	"""Create new level data structure"""
	return {
		"unlocked": false,
		"first_completion": "",
		"total_attempts": 0,
		"total_completions": 0,
		"best_time": 999999.0,
		"best_score": 0,
		"best_completion_percentage": 0.0,
		"best_form_switches": 999999,
		"last_played": ""
	}

func _update_best_record(level_data: Dictionary, key: String, new_value, lower_is_better: bool) -> void:
	"""Update best record if new value is better"""
	var current_best
	if lower_is_better:
		current_best = level_data.get(key, 999999.0)
	else:
		current_best = level_data.get(key, 0.0)
	
	var is_better: bool
	if lower_is_better:
		is_better = new_value < current_best
	else:
		is_better = new_value > current_best
	
	if is_better:
		level_data[key] = new_value
		new_record_achieved.emit(key.get_slice("_", 1), key, new_value)

func _check_level_unlocks(_completed_level: String) -> void:
	"""Check if completing this level unlocks others"""
	for level_id in level_definitions.keys():
		if not is_level_unlocked(level_id):
			var requirements = level_definitions[level_id]["unlock_requirements"]
			var all_met = true
			
			for req_level in requirements:
				if not has_completed_level(req_level):
					all_met = false
					break
			
			if all_met:
				unlock_level(level_id)

func unlock_level(level_id: String) -> void:
	"""Unlock a specific level"""
	if not save_data.has("levels"):
		save_data["levels"] = {}
	
	if not save_data["levels"].has(level_id):
		save_data["levels"][level_id] = _create_new_level_data()
	
	save_data["levels"][level_id]["unlocked"] = true
	level_unlocked.emit(level_id)
	save_progress()

func is_level_unlocked(level_id: String) -> bool:
	"""Check if a level is unlocked"""
	# Level 1 is always unlocked
	if level_id == "level_1":
		return true
	
	return save_data.get("levels", {}).get(level_id, {}).get("unlocked", false)

func has_completed_level(level_id: String) -> bool:
	"""Check if a level has been completed at least once"""
	return save_data.get("levels", {}).get(level_id, {}).get("total_completions", 0) > 0

func get_level_progress(level_id: String) -> Dictionary:
	"""Get comprehensive progress data for a level"""
	var default_data = _create_new_level_data()
	var level_data = save_data.get("levels", {}).get(level_id, default_data)
	
	# Add computed fields
	var result = level_data.duplicate()
	result["completion_rate"] = 0.0
	if level_data["total_attempts"] > 0:
		result["completion_rate"] = float(level_data["total_completions"]) / float(level_data["total_attempts"]) * 100.0
	
	result["status"] = _get_level_status(level_id, level_data)
	result["level_definition"] = level_definitions.get(level_id, {})
	
	return result

func _get_level_status(level_id: String, level_data: Dictionary) -> String:
	"""Determine the display status of a level"""
	var completions = level_data.get("total_completions", 0)
	var attempts = level_data.get("total_attempts", 0)
	
	if not is_level_unlocked(level_id):
		return "locked"
	elif completions == 0:
		if attempts > 0:
			return "in_progress"
		else:
			return "never_played"
	else:
		return "completed"

func get_best_stats(level_id: String) -> Dictionary:
	"""Get best performance stats for a level"""
	var level_data = save_data.get("levels", {}).get(level_id, {})
	return {
		"best_time": level_data.get("best_time", 0.0),
		"best_score": level_data.get("best_score", 0),
		"best_completion_percentage": level_data.get("best_completion_percentage", 0.0),
		"best_form_switches": level_data.get("best_form_switches", 0),
		"total_completions": level_data.get("total_completions", 0)
	}

func get_global_stats() -> Dictionary:
	"""Get overall player statistics"""
	return save_data.get("global_stats", {})

func record_attempt(level_id: String) -> void:
	"""Record that a level attempt was started"""
	if not save_data.has("levels"):
		save_data["levels"] = {}
	
	if not save_data["levels"].has(level_id):
		save_data["levels"][level_id] = _create_new_level_data()
	
	save_data["levels"][level_id]["total_attempts"] += 1
	save_data["global_stats"]["total_attempts"] += 1
	save_progress()

func get_available_levels() -> Array:
	"""Get list of all available levels with basic info"""
	var levels = []
	# Sort level IDs to ensure proper order (level_1, level_2, etc.)
	var sorted_level_ids = level_definitions.keys()
	sorted_level_ids.sort()
	
	for level_id in sorted_level_ids:
		var level_info = level_definitions[level_id].duplicate()
		level_info["id"] = level_id
		level_info["unlocked"] = is_level_unlocked(level_id)
		level_info["completed"] = has_completed_level(level_id)
		levels.append(level_info)
	
	return levels

func reset_all_progress() -> void:
	"""Reset all progress data - useful for testing"""

	_create_new_save()
	save_progress()
 

func get_player_name() -> String:
	"""Get the stored player name"""
	return save_data.get("player_name", "")

func set_player_name(player_name: String) -> void:
	"""Set and save the player name"""
	var cleaned_name = player_name.strip_edges()
	save_data["player_name"] = cleaned_name
	save_progress()


func has_player_name() -> bool:
	"""Check if a player name has been set"""
	var name = get_player_name()
	return name != "" and name.length() > 0 
