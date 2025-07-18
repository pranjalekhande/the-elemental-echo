extends Node

# CollectionManager - Singleton for tracking diamond collection and scoring
# Handles stats across level sessions and provides data to UI

signal diamond_collected(type: String, total_count: int)
signal score_updated(new_score: int)

# Current session stats
var fire_diamonds_collected: int = 0
var water_diamonds_collected: int = 0
var total_diamonds_collected: int = 0
var current_score: int = 0

# Level tracking
var total_fire_diamonds_in_level: int = 0
var total_water_diamonds_in_level: int = 0
var form_switches: int = 0
var session_start_time: float = 0.0

# Scoring configuration
var points_per_diamond: int = 10
var speed_bonus_max: int = 500
var efficiency_bonus_max: int = 200
var completion_bonus_multiplier: float = 2.0

func _ready() -> void:
	# Initialize session start time but don't reset score
	# Score should only be reset when explicitly starting a new level
	session_start_time = Time.get_unix_time_from_system()
	print("📋 CollectionManager initialized - preserving existing score: ", current_score)
	
	# Emit initial score to update any existing UI components
	if current_score > 0:
		score_updated.emit(current_score)

func reset_session() -> void:
	"""Reset all collection stats for a new level attempt"""
	print("🔄 Starting new level - resetting score from ", current_score, " to 0")
	
	fire_diamonds_collected = 0
	water_diamonds_collected = 0
	total_diamonds_collected = 0
	current_score = 0
	form_switches = 0
	session_start_time = Time.get_unix_time_from_system()
	
	# Emit reset signals
	score_updated.emit(current_score)

func set_level_diamond_counts(fire_count: int, water_count: int) -> void:
	"""Call this when level starts to set total available diamonds"""
	total_fire_diamonds_in_level = fire_count
	total_water_diamonds_in_level = water_count

func collect_diamond(type: String, points: int) -> void:
	"""Called when Echo collects a diamond"""
	match type:
		"fire":
			fire_diamonds_collected += 1
		"water":
			water_diamonds_collected += 1
		_:
			print("Unknown diamond type: ", type)
			return
	
	total_diamonds_collected += 1
	current_score += points
	
	# Emit signals for UI updates
	diamond_collected.emit(type, total_diamonds_collected)
	score_updated.emit(current_score)
	
	print("Collected %s diamond! Total: %d, Score: %d" % [type, total_diamonds_collected, current_score])

func track_form_switch() -> void:
	"""Call this whenever Echo switches forms"""
	form_switches += 1

func get_session_stats() -> Dictionary:
	"""Get comprehensive stats for end screen display"""
	var session_time = Time.get_unix_time_from_system() - session_start_time
	var total_diamonds_available = total_fire_diamonds_in_level + total_water_diamonds_in_level
	
	# Calculate bonuses
	var speed_bonus = _calculate_speed_bonus(session_time)
	var efficiency_bonus = _calculate_efficiency_bonus()
	var completion_bonus = _calculate_completion_bonus()
	
	var final_score = current_score + speed_bonus + efficiency_bonus + completion_bonus
	
	print("🎯 Level completed! Base: %d, Bonuses: +%d, Final: %d" % [current_score, (speed_bonus + efficiency_bonus + completion_bonus), final_score])
	
	return {
		"fire_collected": fire_diamonds_collected,
		"fire_total": total_fire_diamonds_in_level,
		"water_collected": water_diamonds_collected,
		"water_total": total_water_diamonds_in_level,
		"total_collected": total_diamonds_collected,
		"total_available": total_diamonds_available,
		"completion_percent": (float(total_diamonds_collected) / max(total_diamonds_available, 1)) * 100.0,
		"form_switches": form_switches,
		"session_time": session_time,
		"base_score": current_score,
		"speed_bonus": speed_bonus,
		"efficiency_bonus": efficiency_bonus,
		"completion_bonus": completion_bonus,
		"final_score": final_score
	}

func _calculate_speed_bonus(time_seconds: float) -> int:
	"""Calculate bonus points based on completion speed"""
	# Max bonus for under 30 seconds, decreasing to 0 at 180 seconds
	var bonus_time_threshold = 30.0
	var max_time = 180.0
	
	if time_seconds <= bonus_time_threshold:
		return speed_bonus_max
	elif time_seconds >= max_time:
		return 0
	else:
		var time_factor = 1.0 - ((time_seconds - bonus_time_threshold) / (max_time - bonus_time_threshold))
		return int(speed_bonus_max * time_factor)

func _calculate_efficiency_bonus() -> int:
	"""Calculate bonus based on minimal form switching"""
	# Reward for efficient form usage (fewer unnecessary switches)
	var optimal_switches = 3  # Estimated minimum needed switches
	var excessive_switches = max(0, form_switches - optimal_switches)
	
	if excessive_switches == 0:
		return efficiency_bonus_max
	elif excessive_switches <= 3:
		return int(efficiency_bonus_max / 2.0)  # Convert to int
	else:
		return 0

func _calculate_completion_bonus() -> int:
	"""Calculate bonus for collecting all diamonds"""
	var total_available = total_fire_diamonds_in_level + total_water_diamonds_in_level
	if total_available > 0 and total_diamonds_collected == total_available:
		return int(current_score * (completion_bonus_multiplier - 1.0))
	return 0

func get_collection_percentage(type: String) -> float:
	"""Get collection percentage for specific diamond type"""
	match type:
		"fire":
			return (float(fire_diamonds_collected) / max(total_fire_diamonds_in_level, 1)) * 100.0
		"water":
			return (float(water_diamonds_collected) / max(total_water_diamonds_in_level, 1)) * 100.0
		_:
			return 0.0

func is_perfect_collection() -> bool:
	"""Check if player collected all diamonds"""
	var total_available = total_fire_diamonds_in_level + total_water_diamonds_in_level
	return total_available > 0 and total_diamonds_collected == total_available 
