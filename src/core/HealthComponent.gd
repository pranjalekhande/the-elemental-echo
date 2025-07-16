extends Node
class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal health_depleted
signal healed(amount: int)
signal damaged(amount: int)

@export var max_health: int = 100
@export var current_health: int = 100

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func heal(amount: int) -> void:
	if current_health < max_health:
		var old_health = current_health
		current_health = min(current_health + amount, max_health)
		var actual_heal = current_health - old_health
		if actual_heal > 0:
			healed.emit(actual_heal)
			health_changed.emit(current_health, max_health)

func damage(amount: int) -> void:
	if current_health > 0:
		current_health = max(current_health - amount, 0)
		damaged.emit(amount)
		health_changed.emit(current_health, max_health)
		if current_health <= 0:
			health_depleted.emit()

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func is_low_health() -> bool:
	return get_health_percentage() < 0.25 
