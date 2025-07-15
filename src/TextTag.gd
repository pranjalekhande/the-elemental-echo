extends Control

# TextTag - Contextual text system
# Shows Echo's internal voice and environmental observations

@onready var label: Label = $Label
var display_tween: Tween

func _ready():
	modulate.a = 0.0  # Start invisible
	
func show_text(message: String, duration: float = 4.0):
	if not label:
		return
		
	label.text = message
	
	# Stop any existing tween
	if display_tween:
		display_tween.kill()
	
	# Fade in
	display_tween = create_tween()
	display_tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Wait, then fade out
	display_tween.tween_interval(duration - 1.0)
	display_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	display_tween.tween_callback(hide)

func hide_text():
	if display_tween:
		display_tween.kill()
	hide() 