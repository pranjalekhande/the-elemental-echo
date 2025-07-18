extends Control
class_name ScoreDisplay

# ScoreDisplay - Modern, real-time score display component
# Shows current score with smooth animations and visual feedback

@onready var score_container: Control = $ScoreContainer
@onready var score_label: Label = $ScoreContainer/VBox/ScoreLabel
@onready var score_value: Label = $ScoreContainer/VBox/ScoreValue
@onready var diamonds_info: Label = $ScoreContainer/VBox/DiamondsInfo
@onready var background: Panel = $ScoreContainer/Background
@onready var glow_effect: Panel = $ScoreContainer/GlowEffect

var current_displayed_score: int = 0
var target_score: int = 0
var score_tween: Tween

func _ready() -> void:
	# Set up the component
	_setup_positioning()
	_setup_styling()
	
	# Defer connection to ensure CollectionManager is fully initialized
	call_deferred("_connect_to_collection_manager")
	
	# Initialize display with current score
	if CollectionManager:
		current_displayed_score = CollectionManager.current_score
		target_score = CollectionManager.current_score
		_update_score_display(current_displayed_score)
		print("ScoreDisplay initialized with score: ", current_displayed_score)
	
	_update_display()

func _setup_positioning() -> void:
	"""Position the score display in the top-right corner"""
	# Anchor to top-right corner
	anchors_preset = Control.PRESET_TOP_RIGHT
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0
	
	# Offset from edge with some padding
	offset_left = -220
	offset_top = 20
	offset_right = -20
	offset_bottom = 120

func _setup_styling() -> void:
	"""Apply modern styling to the score display"""
	if background:
		# Modern semi-transparent background - Panel uses modulate for color
		background.modulate = Color(1.0, 1.0, 1.0, 0.85)
		
	if glow_effect:
		# Subtle glow effect - Panel uses modulate for color
		glow_effect.modulate = Color(0.4, 0.7, 1.0, 0.2)
		glow_effect.visible = false
	
	if score_label:
		# Modern typography
		score_label.add_theme_font_size_override("font_size", 16)
		score_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.9))
		
	if score_value:
		# Larger, bold score value
		score_value.add_theme_font_size_override("font_size", 28)
		score_value.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		
	if diamonds_info:
		# Smaller info text
		diamonds_info.add_theme_font_size_override("font_size", 14)
		diamonds_info.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))

func _connect_to_collection_manager() -> void:
	"""Connect to CollectionManager signals for real-time updates"""
	if not CollectionManager:
		print("ERROR: CollectionManager not found in ScoreDisplay!")
		return
		
	print("ScoreDisplay connecting to CollectionManager signals...")
	
	# Connect to score updates
	if not CollectionManager.score_updated.is_connected(_on_score_updated):
		CollectionManager.score_updated.connect(_on_score_updated)
		print("Connected to score_updated signal")
	
	# Connect to diamond collection for visual feedback
	if not CollectionManager.diamond_collected.is_connected(_on_diamond_collected):
		CollectionManager.diamond_collected.connect(_on_diamond_collected)
		print("Connected to diamond_collected signal")
	
	# Update display with current values
	current_displayed_score = CollectionManager.current_score
	target_score = CollectionManager.current_score
	_update_score_display(current_displayed_score)
	_update_display()

func _on_score_updated(new_score: int) -> void:
	"""Handle score updates with smooth animation"""
	print("ScoreDisplay received score update: ", new_score)
	target_score = new_score
	_animate_score_change()
	_update_display()

func _on_diamond_collected(type: String, total_count: int) -> void:
	"""Handle diamond collection with visual feedback"""
	_show_collection_feedback(type)
	_update_display()

func _animate_score_change() -> void:
	"""Smoothly animate score changes"""
	if score_tween:
		score_tween.kill()
	
	score_tween = create_tween()
	score_tween.set_ease(Tween.EASE_OUT)
	score_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate the displayed score
	var duration = min(abs(target_score - current_displayed_score) * 0.001, 0.5)
	score_tween.tween_method(_update_score_display, current_displayed_score, target_score, duration)
	score_tween.tween_callback(func(): current_displayed_score = target_score)

func _update_score_display(score: int) -> void:
	"""Update the score display with current value"""
	if score_value:
		score_value.text = str(score)

func _show_collection_feedback(diamond_type: String) -> void:
	"""Show visual feedback when diamonds are collected"""
	if not glow_effect:
		return
	
	# Color-code the glow based on diamond type
	var glow_color: Color
	if diamond_type == "fire":
		glow_color = Color(1.0, 0.4, 0.2, 0.4)
	else:  # water
		glow_color = Color(0.2, 0.6, 1.0, 0.4)
	
	glow_effect.modulate = glow_color
	glow_effect.visible = true
	
	# Animate glow effect
	var glow_tween = create_tween()
	glow_tween.set_parallel(true)
	
	# Pulse effect
	glow_tween.tween_property(glow_effect, "modulate:a", 1.0, 0.2)
	glow_tween.tween_property(glow_effect, "modulate:a", 0.0, 0.8)
	glow_tween.tween_callback(func(): glow_effect.visible = false)
	
	# Scale effect on the score container
	var scale_tween = create_tween()
	scale_tween.set_parallel(true)
	scale_tween.tween_property(score_container, "scale", Vector2(1.05, 1.05), 0.1)
	scale_tween.tween_property(score_container, "scale", Vector2(1.0, 1.0), 0.3)

func _update_display() -> void:
	"""Update all display elements with current game state"""
	if not CollectionManager:
		return
	
	# Update diamonds info
	if diamonds_info:
		var fire_collected = CollectionManager.fire_diamonds_collected
		var water_collected = CollectionManager.water_diamonds_collected
		var total_collected = CollectionManager.total_diamonds_collected
		var total_available = CollectionManager.total_fire_diamonds_in_level + CollectionManager.total_water_diamonds_in_level
		
		if total_available > 0:
			diamonds_info.text = "💎 %d/%d (🔥%d 💧%d)" % [total_collected, total_available, fire_collected, water_collected]
		else:
			diamonds_info.text = "💎 %d (🔥%d 💧%d)" % [total_collected, fire_collected, water_collected]

func refresh_display() -> void:
	"""Public method to manually refresh the display"""
	if CollectionManager:
		current_displayed_score = CollectionManager.current_score
		target_score = CollectionManager.current_score
		_update_score_display(current_displayed_score)
		_update_display() 
