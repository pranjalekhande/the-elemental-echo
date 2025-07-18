# This script is an autoload, that can be accessed from any other script!

extends Node

@onready var form_switch_sfx = $FormSwitchSfx
@onready var coin_pickup_sfx = $CoinPickupSfx
@onready var walking_sfx = $WalkingSfx
@onready var level_complete_sfx = $LevelCompleteSfx
@onready var background_music = $BackgroundMusic

# Music control
var is_music_playing: bool = false

func _ready() -> void:
	print("🎵 AudioManager loaded with sounds + background music!")
	print("🔍 Available audio nodes:")
	print("   Form Switch SFX (Magic Whoosh): ", form_switch_sfx)
	print("   Coin pickup SFX (Original): ", coin_pickup_sfx)
	print("   Walking SFX (Stone Footstep): ", walking_sfx)
	print("   Level complete SFX (Level Success): ", level_complete_sfx)
	print("   Background Music (Ambient Mystical): ", background_music)
	
	# Test if audio streams are loaded
	print("🎵 Audio stream status:")
	print("   Magic Whoosh: ", form_switch_sfx.stream if form_switch_sfx else "MISSING NODE")
	print("   Coin Pickup: ", coin_pickup_sfx.stream if coin_pickup_sfx else "MISSING NODE")
	print("   Stone Footstep: ", walking_sfx.stream if walking_sfx else "MISSING NODE")
	print("   Level Success: ", level_complete_sfx.stream if level_complete_sfx else "MISSING NODE")
	print("   Ambient Music: ", background_music.stream if background_music else "MISSING NODE")
	
	# Check audio system status
	print("🔊 Audio system status:")
	print("   Master volume: ", AudioServer.get_bus_volume_db(0))
	print("   Audio driver: ", AudioServer.get_driver_name())
	
	# Auto test a sound after 2 seconds
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(_auto_test_sound)



func debug_play_sound(sound_name: String) -> void:
	print("🎵 Attempting to play sound: ", sound_name)
	match sound_name:
		"form_switch":
			if form_switch_sfx:
				print("   Playing Magic Whoosh...")
				form_switch_sfx.play()
			else:
				print("   ❌ Magic Whoosh SFX node not found!")
		"coin":
			if coin_pickup_sfx:
				print("   Playing coin pickup sound...")
				coin_pickup_sfx.play()
			else:
				print("   ❌ Coin pickup SFX node not found!")
		"walking":
			if walking_sfx:
				print("   Playing Stone Footstep...")
				walking_sfx.play()
			else:
				print("   ❌ Stone Footstep SFX node not found!")
		"complete":
			if level_complete_sfx:
				print("   Playing Level Success...")
				level_complete_sfx.play()
			else:
				print("   ❌ Level Success SFX node not found!")
		_:
			print("   ❌ Unknown sound: ", sound_name)

func _auto_test_sound() -> void:
	print("🔧 AUTO TEST: Playing automatic test sound...")
	debug_play_sound("form_switch")

# Background Music Control
func play_background_music() -> void:
	"""Start playing background music with looping"""
	if background_music and not is_music_playing:
		background_music.stream.loop = true  # Enable looping
		background_music.play()
		is_music_playing = true
		print("🎵 Background music started (looping)")
	elif is_music_playing:
		print("🎵 Background music already playing")

func stop_background_music() -> void:
	"""Stop background music"""
	if background_music and is_music_playing:
		background_music.stop()
		is_music_playing = false
		print("🎵 Background music stopped")

func fade_out_music(duration: float = 2.0) -> void:
	"""Fade out background music over specified duration"""
	if background_music and is_music_playing:
		var tween = get_tree().create_tween()
		tween.tween_property(background_music, "volume_db", -40.0, duration)
		tween.tween_callback(stop_background_music)

func pause_music() -> void:
	"""Pause background music (for pause menus)"""
	if background_music and is_music_playing:
		background_music.stream_paused = true
		print("🎵 Background music paused")

func resume_music() -> void:
	"""Resume paused background music"""
	if background_music and is_music_playing:
		background_music.stream_paused = false
		print("🎵 Background music resumed") 