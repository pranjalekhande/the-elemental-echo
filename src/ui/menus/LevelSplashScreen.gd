extends Control

# LevelSplashScreen - Clean, light UI splash screen for level introductions
# Shows level-specific content with smooth animations before transitioning to gameplay

signal splash_completed(level_scene_path: String)

# UI Node References
@onready var level_title: Label = $MainContent/ContentPanel/VBox/LevelTitle
@onready var level_subtitle: Label = $MainContent/ContentPanel/VBox/LevelSubtitle
@onready var orb_background: ColorRect = $MainContent/ContentPanel/VBox/EchoOrb/OrbBackground
@onready var orb_glow: ColorRect = $MainContent/ContentPanel/VBox/EchoOrb/OrbGlow
@onready var loading_dots: Label = $MainContent/ContentPanel/VBox/LoadingContainer/LoadingDots
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var splash_timer: Timer = $SplashTimer
@onready var content_panel: Panel = $MainContent/ContentPanel

# Level Data
var current_level_id: String = ""
var target_scene_path: String = ""

# Level-specific content database
var level_data: Dictionary = {
	"level_1": {
		"title": "First Steps",
		"subtitle": "Ancient chambers stir with forgotten whispers...",
		"orb_color": Color(0.4, 0.7, 1, 0.8),  # Mystical blue
		"title_color": Color(0.9, 0.95, 1, 1),
		"theme": "awakening"
	},
	"level_2": {
		"title": "Ascending Echoes",
		"subtitle": "Vertical paths lead to greater mysteries...",
		"orb_color": Color(0.8, 0.4, 1, 0.8),  # Mystical purple
		"title_color": Color(0.95, 0.9, 1, 1),
		"theme": "ascension"
	},
	"level_3": {
		"title": "Crystal Depths",
		"subtitle": "Deep caverns sparkle with elemental energy...",
		"orb_color": Color(0.4, 1, 0.6, 0.8),  # Mystical green
		"title_color": Color(0.9, 1, 0.95, 1),
		"theme": "crystalline"
	},
	"level_4": {
		"title": "Flowing Rivers",
		"subtitle": "Water finds its path through ancient stone...",
		"orb_color": Color(0.3, 0.8, 1, 0.8),  # Flowing cyan
		"title_color": Color(0.9, 0.98, 1, 1),
		"theme": "flowing"
	},
	"level_5": {
		"title": "Sky Sanctuary",
		"subtitle": "Where earth meets the endless heavens...",
		"orb_color": Color(1, 0.8, 0.4, 0.8),  # Golden sky
		"title_color": Color(1, 0.98, 0.9, 1),
		"theme": "celestial"
	},
	"level_6": {
		"title": "Final Convergence",
		"subtitle": "All elements unite in perfect harmony...",
		"orb_color": Color(0.9, 0.7, 1, 0.8),  # Unified energy
		"title_color": Color(1, 0.96, 0.98, 1),
		"theme": "convergence"
	}
}

func _ready() -> void:
	# Connect timer signal
	splash_timer.timeout.connect(_on_splash_timer_timeout)
	
	# Setup initial state
	_setup_initial_state()

func show_splash(level_id: String, scene_path: String) -> void:
	"""Display splash screen for the specified level"""
	current_level_id = level_id
	target_scene_path = scene_path
	
	print("🌟 Showing splash for level: %s" % level_id)
	
	# Setup level-specific content
	_setup_level_content()
	
	# Start animations
	_start_splash_animations()
	
	# Start timer
	splash_timer.start()

func _setup_initial_state() -> void:
	"""Setup initial visual state before animations"""
	# Make elements initially transparent
	content_panel.modulate.a = 0.0
	orb_glow.modulate.a = 0.0

func _setup_level_content() -> void:
	"""Configure content based on the selected level"""
	var data = level_data.get(current_level_id, level_data["level_1"])
	
	# Set text content
	level_title.text = data["title"]
	level_subtitle.text = data["subtitle"]
	
	# Set colors
	level_title.add_theme_color_override("font_color", data["title_color"])
	orb_glow.color = data["orb_color"]
	
	print("✅ Level content configured for: %s" % data["title"])

func _start_splash_animations() -> void:
	"""Start the mystical entrance animations"""
	# Create main content fade-in tween with magical feel
	var content_tween = create_tween()
	content_tween.set_parallel(true)
	
	# Panel materializes like ancient magic awakening
	content_panel.scale = Vector2(0.9, 0.9)
	content_panel.modulate.a = 0.0
	content_tween.tween_property(content_panel, "modulate:a", 1.0, 0.8)
	content_tween.tween_property(content_panel, "scale", Vector2(1.0, 1.0), 0.8)
	content_tween.set_ease(Tween.EASE_OUT)
	content_tween.set_trans(Tween.TRANS_BACK)
	
	# Title appears with mystical glow
	level_title.modulate.a = 0.0
	level_subtitle.modulate.a = 0.0
	var text_tween = create_tween()
	text_tween.set_parallel(true)
	text_tween.tween_interval(0.4)
	text_tween.tween_property(level_title, "modulate:a", 1.0, 0.6)
	text_tween.tween_interval(0.6)
	text_tween.tween_property(level_subtitle, "modulate:a", 1.0, 0.5)
	
	# Start orb pulsing animation
	_start_orb_pulsing()
	
	# Start loading dots animation
	_start_loading_animation()
	
	# Echo's orb awakens with elemental energy
	var orb_tween = create_tween()
	orb_tween.tween_interval(0.2)
	orb_tween.tween_property(orb_glow, "modulate:a", 1.0, 0.8)
	orb_tween.set_ease(Tween.EASE_OUT)
	orb_tween.set_trans(Tween.TRANS_EXPO)

func _start_orb_pulsing() -> void:
	"""Create a mystical pulsing effect for Echo's orb"""
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_parallel(true)
	
	# Mystical scale pulsing - like a heartbeat of elemental energy
	pulse_tween.tween_property(orb_glow, "scale", Vector2(1.15, 1.15), 1.2)
	pulse_tween.tween_property(orb_glow, "scale", Vector2(0.95, 0.95), 1.2)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	
	# Mystical alpha pulsing - like breathing energy
	pulse_tween.tween_property(orb_glow, "modulate:a", 1.0, 1.2)
	pulse_tween.tween_property(orb_glow, "modulate:a", 0.7, 1.2)
	
	# Add background orb glow pulsing for extra mysticism
	var bg_pulse_tween = create_tween()
	bg_pulse_tween.set_loops()
	bg_pulse_tween.set_parallel(true)
	
	bg_pulse_tween.tween_property(orb_background, "modulate:a", 0.5, 1.5)
	bg_pulse_tween.tween_property(orb_background, "modulate:a", 0.2, 1.5)
	bg_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	bg_pulse_tween.set_trans(Tween.TRANS_QUAD)

func _start_loading_animation() -> void:
	"""Animate the loading dots with a subtle effect"""
	var dots_tween = create_tween()
	dots_tween.set_loops()
	
	# Cycle through different dot states
	var dot_states = [".", "..", "...", "....", "...", "..", "."]
	
	for state in dot_states:
		dots_tween.tween_callback(func(): loading_dots.text = state)
		dots_tween.tween_interval(0.3)

func _on_splash_timer_timeout() -> void:
	"""Handle splash timer completion"""
	print("⏰ Splash timer completed, transitioning to level...")
	_start_exit_animation()

func _start_exit_animation() -> void:
	"""Mystical exit animation - Echo's essence fades into the cave"""
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	
	# Panel dissolves like ancient magic fading
	exit_tween.tween_property(content_panel, "modulate:a", 0.0, 0.6)
	exit_tween.tween_property(content_panel, "scale", Vector2(1.1, 1.1), 0.6)
	exit_tween.set_ease(Tween.EASE_IN)
	exit_tween.set_trans(Tween.TRANS_EXPO)
	
	# Orb energy disperses first, like Echo departing
	var orb_exit_tween = create_tween()
	orb_exit_tween.set_parallel(true)
	orb_exit_tween.tween_property(orb_glow, "modulate:a", 0.0, 0.4)
	orb_exit_tween.tween_property(orb_glow, "scale", Vector2(1.5, 1.5), 0.4)
	orb_exit_tween.set_ease(Tween.EASE_IN)
	orb_exit_tween.set_trans(Tween.TRANS_QUART)
	
	# Wait for mystical transition to complete
	exit_tween.tween_interval(0.6)
	exit_tween.tween_callback(_emit_completion_signal)

func _emit_completion_signal() -> void:
	"""Emit completion signal to trigger level loading"""
	print("✅ Splash screen completed, loading level: %s" % target_scene_path)
	splash_completed.emit(target_scene_path)

func _input(event: InputEvent) -> void:
	"""Allow skipping splash with any input"""
	if event.is_pressed() and not event.is_echo():
		if event is InputEventKey or event is InputEventMouseButton:
			print("⚡ Splash screen skipped by user input")
			_skip_splash()

func _skip_splash() -> void:
	"""Skip splash screen immediately"""
	# Stop all tweens
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
	
	# Stop timer
	splash_timer.stop()
	
	# Emit completion immediately
	_emit_completion_signal()

func get_level_preview_text(level_id: String) -> String:
	"""Get preview text for a level (useful for tooltips)"""
	var data = level_data.get(level_id, {})
	return data.get("subtitle", "Prepare for your next challenge...")

# Debug method for testing different levels
func _debug_cycle_levels() -> void:
	"""Debug method to cycle through level previews"""
	var levels = ["level_1", "level_2", "level_3"]
	for level in levels:
		show_splash(level, "res://scenes/levels/Main.tscn")
		await splash_completed
		await get_tree().create_timer(1.0).timeout 