extends Node

## LeaderboardService – host-authoritative Top-10 scoreboard
# Works in tandem with NetworkManager.
# • Host loads & saves `user://leaderboard.json`.
# • Host updates list when add_score() is called, broadcasts to clients.
# • Clients simply receive leaderboard updates via RPC and emit a signal.

signal leaderboard_updated(board: Array)

const FILE_PATH: String = "user://leaderboard.json"  # Uses same writable location as other save data
const TOP_N: int = 10

var leaderboard: Array = [] # Array of {"name": String, "points": int, "date": String}

func _ready() -> void:
	# Load existing data (host or standalone). Clients keep empty list.
	_load_file()


func add_score(player_name: String, points: int) -> void:
	"""Host: add a new score, update file & broadcast."""
	if not _is_host():
		return # Only host should mutate

	leaderboard.append({
		"name": player_name,
		"points": points,
		"date": Time.get_datetime_string_from_system()
	})
	# Sort descending by points
	leaderboard.sort_custom(func(a, b): return a["points"] > b["points"])
	# Trim to top N
	if leaderboard.size() > TOP_N:
		leaderboard = leaderboard.slice(0, TOP_N)

	_save_file()
	_broadcast_leaderboard()

# Bypass host check for local-only sessions
func add_score_force(player_name: String, points: int) -> void:
	leaderboard.append({
		"name": player_name,
		"points": points,
		"date": Time.get_datetime_string_from_system()
	})
	
	# Sort descending by points
	leaderboard.sort_custom(func(a, b): return a["points"] > b["points"])
	
	# Trim to top N
	if leaderboard.size() > TOP_N:
		leaderboard = leaderboard.slice(0, TOP_N)
	
	_save_file()
	_broadcast_leaderboard()

func clear_leaderboard() -> void:
	"""Debug method to clear all leaderboard entries"""
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
				leaderboard = json.data

func _save_file() -> void:
	# Ensure directory exists (only needed in editor/runtime, won't work in exported pck)
	var dir_path := FILE_PATH.get_base_dir()
	var global_dir := ProjectSettings.globalize_path(dir_path)
	if not DirAccess.dir_exists_absolute(global_dir):
		DirAccess.make_dir_recursive_absolute(global_dir)

	var f := FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(leaderboard))
		f.close()
		var absolute_path = ProjectSettings.globalize_path(FILE_PATH)

		
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

func _print_file_location_debug() -> void:
	"""Print debug information about where the leaderboard file is stored"""
	var absolute_path = ProjectSettings.globalize_path(FILE_PATH)
 
