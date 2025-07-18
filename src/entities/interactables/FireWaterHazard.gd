extends Area2D

enum HazardType { FIRE, WATER }

@export var hazard_type: HazardType = HazardType.FIRE
@export var damage_amount: int = 1

@onready var sprite = $Sprite2D

func _ready():
	_update_sprite()

func _update_sprite():
	# Set sprite based on hazard type
	if hazard_type == HazardType.FIRE:
		# Fire hazard sprite region
		sprite.region_rect = Rect2(250, 150, 64, 64)
		sprite.modulate = Color.ORANGE
	else:
		# Water hazard sprite region  
		sprite.region_rect = Rect2(314, 150, 64, 64)
		sprite.modulate = Color.CYAN

func _on_body_entered(body):
	if body.name == "Echo":
		var echo_form = body.get_current_form()
		
		# Fire hazard damages water form, water hazard damages fire form
		var should_damage = false
		if hazard_type == HazardType.FIRE and echo_form == 1:  # Water form in fire
			should_damage = true
		elif hazard_type == HazardType.WATER and echo_form == 0:  # Fire form in water
			should_damage = true
		
		if should_damage:
			var health_component = body.get_node("HealthComponent")
			if health_component and health_component.has_method("take_damage"):
				health_component.take_damage(damage_amount)
		
		else:
			pass