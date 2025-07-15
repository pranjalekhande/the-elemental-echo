extends StaticBody2D

@export var melt_time: float = 1.0
@onready var sprite: CanvasItem = $ColorRect
@onready var area: Area2D = $Area2D

func _ready():
    area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.has_method("get_current_form"):
        return
    if body.get_current_form() != body.Form.FIRE:
        return
    # Prevent double trigger
    area.monitoring = false
    # Fade out sprite over melt_time then remove collision and free
    var tween := create_tween()
    tween.tween_property(sprite, "modulate:a", 0.0, melt_time)
    tween.tween_callback(self._finish_melt)

func _finish_melt() -> void:
    queue_free() 