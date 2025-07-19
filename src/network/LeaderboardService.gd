extends Node

## LeaderboardService – host-authoritative Top-10 scoreboard (Player-Centric)
# Works in tandem with NetworkManager.
# • Host loads & saves `user://leaderboard.json`.
# • Host updates list when add_score() is called, broadcasts to clients.
# • Clients simply receive leaderboard updates via RPC and emit a signal.
# • NEW: Player-centric scoring with total scores calculated from best level performances

signal leaderboard_updated(board: Array)

const FILE_PATH: String = "user://leaderboard.json"  # Uses same writable location as other save data
const TOP_N: int = 10

# Player-centric leaderboard structure:
# {
#   "player_name": {
#     "total_score": int,
#     "levels": {"level_1": {"best_score": int, "attempts": int}, ...},
#     "levels_completed": int,
#     "last_updated": string
#   }
# }
var player_leaderboard: Dictionary = {}
var leaderboard: Array = [] # Converted array for display compatibility

func _ready() -> void:
	# Load existing data (host or standalone). Clients keep empty list.
	_load_file()


func add_score(player_name: String, points: int, level_id: String = "") -> void:
	"""Host: add a new score, update player total and broadcast."""
	if not _is_host():
		return # Only host should mutate

	print("🎯 Adding score: %s scored %d points on %s" % [player_name, points, level_id])
	
	# Determine level_id if not provided (backward compatibility)
	if level_id == "":
		level_id = _guess_current_level()
		print("⚠️ Level ID not provided, guessed: %s" % level_id)
	else:
		print("✅ Level ID provided: %s" % level_id)
	
	# Get or create player entry
	if not player_leaderboard.has(player_name):
		player_leaderboard[player_name] = _create_new_player_entry(player_name)
		print("✅ Created new player entry for: %s" % player_name)
	else:
		print("📊 Updating existing player: %s" % player_name)
	
	var player_data = player_leaderboard[player_name]
	
	# Update level-specific data
	if not player_data.levels.has(level_id):
		player_data.levels[level_id] = {"best_score": 0, "attempts": 0}
	
	var level_data = player_data.levels[level_id]
	level_data.attempts += 1
	
	# Check if this is a new best score for this level
	var is_new_best = points > level_data.best_score
	if is_new_best:
		print("🏆 New best score for %s on %s: %d (was %d)" % [player_name, level_id, points, level_data.best_score])
		level_data.best_score = points
		
		# Recalculate total score from all level best scores
		_recalculate_player_total(player_name)
	else:
		print("📊 Score %d not better than best %d for %s on %s" % [points, level_data.best_score, player_name, level_id])
	
	# Update metadata
	player_data.last_updated = Time.get_datetime_string_from_system()
	player_data.levels_completed = player_data.levels.size()
	
	# Convert to array format for display compatibility
	_update_display_leaderboard()
	
	_save_file()
	_broadcast_leaderboard()

# Bypass host check for local-only sessions
func add_score_force(player_name: String, points: int, level_id: String = "") -> void:
	"""Force add score without host check - for local play"""
	print("🎯 Force adding score: %s scored %d points on %s" % [player_name, points, level_id])
	
	# Determine level_id if not provided
	if level_id == "":
		level_id = _guess_current_level()
	
	# Get or create player entry
	if not player_leaderboard.has(player_name):
		player_leaderboard[player_name] = _create_new_player_entry(player_name)
		print("✅ Created new player entry for: %s" % player_name)
	
	var player_data = player_leaderboard[player_name]
	
	# Update level-specific data
	if not player_data.levels.has(level_id):
		player_data.levels[level_id] = {"best_score": 0, "attempts": 0}
	
	var level_data = player_data.levels[level_id]
	level_data.attempts += 1
	
	# Check if this is a new best score for this level
	var is_new_best = points > level_data.best_score
	if is_new_best:
		print("🏆 New best score for %s on %s: %d (was %d)" % [player_name, level_id, points, level_data.best_score])
		level_data.best_score = points
		
		# Recalculate total score from all level best scores
		_recalculate_player_total(player_name)
	else:
		print("📊 Score %d not better than best %d for %s on %s" % [points, level_data.best_score, player_name, level_id])
	
	# Update metadata
	player_data.last_updated = Time.get_datetime_string_from_system()
	player_data.levels_completed = player_data.levels.size()
	
	# Convert to array format for display compatibility
	_update_display_leaderboard()
	
	_save_file()
	_broadcast_leaderboard()

func _create_new_player_entry(player_name: String) -> Dictionary:
	"""Create a new player entry with default values"""
	return {
		"name": player_name,
		"total_score": 0,
		"levels": {},
		"levels_completed": 0,
		"last_updated": Time.get_datetime_string_from_system()
	}

func _guess_current_level() -> String:
	"""Attempt to determine current level for backward compatibility"""
	# Check current scene to guess level
	var current_scene = Engine.get_main_loop().current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		if "Level2" in scene_path:
			return "level_2"
		elif "Main" in scene_path:
			return "level_1"
	
	# Default fallback
	return "level_1"

func _recalculate_player_total(player_name: String) -> void:
	"""Recalculate player's total score from all level best scores"""
	if not player_leaderboard.has(player_name):
		return
	
	var player_data = player_leaderboard[player_name]
	var total = 0
	
	print("📊 Recalculating total for %s:" % player_name)
	for level_id in player_data.levels:
		var level_data = player_data.levels[level_id]
		total += level_data.best_score
		print("  %s: %d points (from %d attempts)" % [level_id, level_data.best_score, level_data.attempts])
	
	var old_total = player_data.total_score
	player_data.total_score = total
	
	print("📊 %s total score updated: %d → %d" % [player_name, old_total, total])

func _update_display_leaderboard() -> void:
	"""Convert player-centric data to array format for display compatibility"""
	leaderboard.clear()
	
	# Convert player data to display format
	for player_name in player_leaderboard:
		var player_data = player_leaderboard[player_name]
		leaderboard.append({
			"name": player_name,
			"points": player_data.total_score,
			"levels_completed": player_data.levels_completed,
			"date": player_data.last_updated
		})
	
	# Sort by total score (descending)
	leaderboard.sort_custom(func(a, b): return a["points"] > b["points"])
	
	# Trim to top N
	if leaderboard.size() > TOP_N:
		leaderboard = leaderboard.slice(0, TOP_N)
	
	print("📊 Display leaderboard updated with %d players" % leaderboard.size())

func clear_leaderboard() -> void:
	"""Debug method to clear all leaderboard entries"""
	player_leaderboard.clear()
	leaderboard.clear()
	_save_file()
	_broadcast_leaderboard()

func _broadcast_leaderboard() -> void:
	leaderboard_updated.emit(leaderboard)
	if _is_host():
		rpc("_rpc_receive_leaderboard", leaderboard)

@rpc("authority", "reliable")
func _rpc_receive_leaderboard(board: Array) -> void:
	"""Clients: receive new leaderboard from host."""
	leaderboard = board.duplicate(true)
	leaderboard_updated.emit(leaderboard)

func _load_file() -> void:
	if not _is_host():
		return # Clients wait for RPC

	if FileAccess.file_exists(FILE_PATH):
		var f := FileAccess.open(FILE_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var json := JSON.new()
			if json.parse(txt) == OK:
				var data = json.data
				
				# Check if data is in old Array format or new Dictionary format
				if data is Array:
					print("🔄 Migrating old leaderboard format to player-centric format...")
					_migrate_old_leaderboard(data)
				elif data is Dictionary and data.has("players"):
					# New format
					player_leaderboard = data.players
					print("✅ Loaded player-centric leaderboard with %d players" % player_leaderboard.size())
					_update_display_leaderboard()
				else:
					print("⚠️ Unknown leaderboard format, starting fresh")
					player_leaderboard.clear()
	else:
		print("ℹ️ No existing leaderboard file found, starting fresh")

func _save_file() -> void:
	# Ensure directory exists (only needed in editor/runtime, won't work in exported pck)
	var dir_path := FILE_PATH.get_base_dir()
	var global_dir := ProjectSettings.globalize_path(dir_path)
	if not DirAccess.dir_exists_absolute(global_dir):
		DirAccess.make_dir_recursive_absolute(global_dir)

	# Save in new player-centric format
	var save_data = {
		"version": "2.0",
		"format": "player_centric",
		"players": player_leaderboard,
		"last_updated": Time.get_datetime_string_from_system()
	}

	var f := FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(save_data))
		f.close()
		var absolute_path = ProjectSettings.globalize_path(FILE_PATH)
		print("💾 Saved player-centric leaderboard with %d players to: %s" % [player_leaderboard.size(), absolute_path])

		
		# Verify the file was actually written
		if FileAccess.file_exists(FILE_PATH):
			var file_size = FileAccess.get_file_as_bytes(FILE_PATH).size()
	
			
			# Read back and verify content
			var verify_file = FileAccess.open(FILE_PATH, FileAccess.READ)
			if verify_file:
				var content = verify_file.get_as_text()
				verify_file.close()
		
			else:
				pass
		
		else:
			pass
	
	else:
		var error = FileAccess.get_open_error()
		print("❌ Failed to save leaderboard file: ", error)
		print("   Attempted path: ", ProjectSettings.globalize_path(FILE_PATH))

func _is_host() -> bool:
	# In solo mode (which is the default), always act as host
	# Only check NetworkManager if we're actually in multiplayer mode
	if Engine.has_singleton("NetworkManager"):
		var nm = Engine.get_singleton("NetworkManager")
		# If NetworkManager has an active multiplayer peer, use its host status
		if nm.multiplayer.multiplayer_peer != null:
			return nm.is_host
	
	# Default: solo mode = always host
	return true

func _migrate_old_leaderboard(old_data: Array) -> void:
	"""Migrate old Array-based leaderboard to player-centric format"""
	print("📊 Migrating %d old leaderboard entries..." % old_data.size())
	
	player_leaderboard.clear()
	
	# Process each old entry
	for entry in old_data:
		var player_name = entry.get("name", "Unknown")
		var points = int(entry.get("points", 0))
		var date = entry.get("date", Time.get_datetime_string_from_system())
		
		# Assume old entries are from level_1 (most likely scenario)
		var level_id = "level_1"
		
		# Get or create player entry
		if not player_leaderboard.has(player_name):
			player_leaderboard[player_name] = _create_new_player_entry(player_name)
		
		var player_data = player_leaderboard[player_name]
		
		# Initialize level data if needed
		if not player_data.levels.has(level_id):
			player_data.levels[level_id] = {"best_score": 0, "attempts": 0}
		
		var level_data = player_data.levels[level_id]
		level_data.attempts += 1
		
		# Keep the best score for this level
		if points > level_data.best_score:
			level_data.best_score = points
			print("  📈 %s: best score on %s = %d" % [player_name, level_id, points])
		
		# Update last updated time (use the latest date)
		if date > player_data.last_updated:
			player_data.last_updated = date
	
	# Recalculate totals for all migrated players
	for player_name in player_leaderboard:
		_recalculate_player_total(player_name)
		var player_data = player_leaderboard[player_name]
		player_data.levels_completed = player_data.levels.size()
	
	# Update display and save in new format
	_update_display_leaderboard()
	print("✅ Migration complete! %d players migrated" % player_leaderboard.size())

func get_next_guest_name() -> String:
	"""Get the next available guest number (Guest 1, Guest 2, etc.)"""
	var guest_number = 1
	var max_search = 100  # Prevent infinite loop, max 100 guests
	
	while guest_number <= max_search:
		var guest_name = "Guest " + str(guest_number)
		if not player_leaderboard.has(guest_name):
			print("🎮 Next available guest name: %s" % guest_name)
			return guest_name
		guest_number += 1
	
	# Fallback if somehow we have 100+ guests
	print("⚠️ Maximum guest limit reached, using random number")
	return "Guest " + str(randi_range(1000, 9999))

func get_total_guest_count() -> int:
	"""Get the total number of guest players"""
	var count = 0
	for player_name in player_leaderboard:
		if player_name.begins_with("Guest "):
			count += 1
	return count

func is_guest_name(player_name: String) -> bool:
	"""Check if a player name is a guest name"""
	return player_name.begins_with("Guest ")

func _print_file_location_debug() -> void:
	"""Print debug information about where the leaderboard file is stored"""
	var absolute_path = ProjectSettings.globalize_path(FILE_PATH)
 
