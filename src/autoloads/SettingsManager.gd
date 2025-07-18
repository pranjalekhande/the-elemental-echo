extends Node

# SettingsManager - Persistent settings storage and audio control
# Handles SFX and Music volume settings with save/load functionality

signal settings_changed(setting_name: String, value: float)

# Settings constants
const SETTINGS_FILE_PATH = "user://settings.json"
const SETTINGS_VERSION = "1.0"

# Audio settings
var sfx_volume: float = 0.8  # 0.0 to 1.0
var music_volume: float = 0.6  # 0.0 to 1.0
var sfx_enabled: bool = true
var music_enabled: bool = true

# Audio bus indices (Godot's built-in audio buses)
const MASTER_BUS = 0
const SFX_BUS = 1
const MUSIC_BUS = 2

func _ready() -> void:
	# Setup audio buses first
	_setup_audio_buses()
	
	# Load saved settings
	load_settings()
	
	# Apply loaded settings to audio system
	_apply_audio_settings()
	


func _setup_audio_buses() -> void:
	"""Create audio buses for SFX and Music if they don't exist"""
	# Check if we need to create the buses
	var bus_count = AudioServer.get_bus_count()
	
	# Create SFX bus if it doesn't exist
	if bus_count < 2:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "SFX")
		AudioServer.set_bus_send(1, "Master")
	
	# Create Music bus if it doesn't exist
	if bus_count < 3:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "Music")
		AudioServer.set_bus_send(2, "Master")
	


func load_settings() -> void:
	"""Load settings from persistent storage"""
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
	
		save_settings()  # Create default settings file
		return
	
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if not file:
		print("❌ Failed to open settings file")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("❌ Failed to parse settings JSON")
		return
	
	var data = json.data
	
	# Load audio settings with fallbacks
	sfx_volume = data.get("sfx_volume", 0.8)
	music_volume = data.get("music_volume", 0.6)
	sfx_enabled = data.get("sfx_enabled", true)
	music_enabled = data.get("music_enabled", true)
	


func save_settings() -> void:
	"""Save current settings to persistent storage"""
	var settings_data = {
		"version": SETTINGS_VERSION,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"sfx_enabled": sfx_enabled,
		"music_enabled": music_enabled,
		"saved_at": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if not file:
		print("❌ Failed to save settings file")
		return
	
	var json_string = JSON.stringify(settings_data)
	file.store_string(json_string)
	file.close()
	


# Audio Control Methods
func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	_apply_sfx_volume()
	settings_changed.emit("sfx_volume", sfx_volume)
	save_settings()

func set_music_volume(volume: float) -> void:
	"""Set Music volume (0.0 to 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	_apply_music_volume()
	settings_changed.emit("music_volume", music_volume)
	save_settings()

func set_sfx_enabled(enabled: bool) -> void:
	"""Enable/disable SFX"""
	sfx_enabled = enabled
	_apply_sfx_volume()
	settings_changed.emit("sfx_enabled", sfx_enabled)
	save_settings()

func set_music_enabled(enabled: bool) -> void:
	"""Enable/disable Music"""
	music_enabled = enabled
	_apply_music_volume()
	settings_changed.emit("music_enabled", music_enabled)
	save_settings()

func _apply_audio_settings() -> void:
	"""Apply current settings to the audio system"""
	_apply_sfx_volume()
	_apply_music_volume()

func _apply_sfx_volume() -> void:
	"""Apply SFX volume to audio bus"""
	if sfx_enabled and sfx_volume > 0.0:
		var db_volume = linear_to_db(sfx_volume)
		AudioServer.set_bus_volume_db(SFX_BUS, db_volume)
		AudioServer.set_bus_mute(SFX_BUS, false)
	else:
		AudioServer.set_bus_mute(SFX_BUS, true)

func _apply_music_volume() -> void:
	"""Apply Music volume to audio bus"""
	if music_enabled and music_volume > 0.0:
		var db_volume = linear_to_db(music_volume)
		AudioServer.set_bus_volume_db(MUSIC_BUS, db_volume)
		AudioServer.set_bus_mute(MUSIC_BUS, false)
	else:
		AudioServer.set_bus_mute(MUSIC_BUS, true)

# Utility methods
func get_sfx_volume_percent() -> int:
	"""Get SFX volume as percentage (0-100)"""
	return int(sfx_volume * 100)

func get_music_volume_percent() -> int:
	"""Get Music volume as percentage (0-100)"""
	return int(music_volume * 100)

func reset_to_defaults() -> void:
	"""Reset all settings to default values"""
	sfx_volume = 0.8
	music_volume = 0.6
	sfx_enabled = true
	music_enabled = true
	_apply_audio_settings()
	save_settings()


# Player Name Integration (delegates to ProgressManager)
func get_player_name() -> String:
	"""Get player name from ProgressManager"""
	if ProgressManager:
		return ProgressManager.get_player_name()
	return ""

func set_player_name(player_name: String) -> void:
	"""Set player name via ProgressManager"""
	if ProgressManager:
		ProgressManager.set_player_name(player_name)
	

func has_player_name() -> bool:
	"""Check if player has set a name"""
	if ProgressManager:
		return ProgressManager.has_player_name()
	return false 