extends StaticBody2D
class_name MovingPlatform

# MovingPlatform - Reusable moving platform component with smooth player carrying
# State machine: Moving_Up → Pause_Top → Moving_Down → Pause_Bottom

@export var move_distance: float = 200.0
@export var move_speed: float = 100.0
@export var pause_duration: float = 2.0

enum State { MOVING_UP, PAUSE_TOP, MOVING_DOWN, PAUSE_BOTTOM }
var current_state: State = State.PAUSE_BOTTOM
var initial_position: Vector2
var target_position: Vector2
var carried_bodies: Array[CharacterBody2D] = []
var state_timer: float = 0.0
var movement_tween: Tween

# Store initial state for reset functionality
var initial_state_data: Dictionary = {}

func _ready() -> void:
	# Store initial position for movement calculations and reset
	initial_position = global_position
	target_position = initial_position
	
	# Store initial state for reset system
	_store_initial_state()
	
	# Connect to area detection for carrying players
	var detection_area = get_node_or_null("CarryDetection")
	if detection_area and detection_area.has_signal("body_entered"):
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	
	# Start the platform movement cycle after a brief delay
	await get_tree().process_frame
	_start_movement_cycle()

func _store_initial_state() -> void:
	"""Store initial state for reset functionality"""
	initial_state_data = {
		"position": global_position,
		"state": State.PAUSE_BOTTOM,
		"timer": 0.0
	}

func reset_platform() -> void:
	"""Reset platform to initial state - called by level reset system"""
	# Stop current movement
	if movement_tween:
		movement_tween.kill()
	
	# Reset position and state
	global_position = initial_state_data.position
	current_state = initial_state_data.state
	state_timer = initial_state_data.timer
	target_position = initial_position
	
	# Clear carried bodies
	carried_bodies.clear()
	
	# Restart movement cycle
	_start_movement_cycle()
	
	print("MovingPlatform reset to initial state")

func _start_movement_cycle() -> void:
	"""Start the movement state machine cycle"""
	_update_state_machine()

func _update_state_machine() -> void:
	"""Handle state transitions and movement"""
	match current_state:
		State.PAUSE_BOTTOM:
			_handle_pause_state(State.MOVING_UP)
		
		State.MOVING_UP:
			target_position = initial_position + Vector2(0, -move_distance)
			_move_to_target(State.PAUSE_TOP)
		
		State.PAUSE_TOP:
			_handle_pause_state(State.MOVING_DOWN)
		
		State.MOVING_DOWN:
			target_position = initial_position
			_move_to_target(State.PAUSE_BOTTOM)

func _handle_pause_state(next_state: State) -> void:
	"""Handle pause states with timer"""
	var pause_tween = create_tween()
	pause_tween.tween_interval(pause_duration)
	await pause_tween.finished
	
	current_state = next_state
	_update_state_machine()

func _move_to_target(next_state: State) -> void:
	"""Move platform to target position smoothly"""
	var distance = global_position.distance_to(target_position)
	var duration = distance / move_speed
	
	# Move platform and carry players
	var move_tween = create_tween()
	move_tween.tween_method(_move_platform_and_players, global_position, target_position, duration)
	move_tween.tween_callback(_on_movement_complete.bind(next_state))

func _move_platform_and_players(new_position: Vector2) -> void:
	"""Move platform and carry any players smoothly"""
	var movement_delta = new_position - global_position
	
	# Move the platform
	global_position = new_position
	
	# Move carried players with the platform
	for body in carried_bodies:
		if is_instance_valid(body):
			body.global_position += movement_delta

func _on_movement_complete(next_state: State) -> void:
	"""Called when movement tween completes"""
	current_state = next_state
	_update_state_machine()

func _on_body_entered(body: Node2D) -> void:
	"""Player or other body entered the carry detection area"""
	if body is CharacterBody2D and not body in carried_bodies:
		carried_bodies.append(body)
		print("MovingPlatform: Carrying ", body.name)

func _on_body_exited(body: Node2D) -> void:
	"""Player or other body exited the carry detection area"""
	if body in carried_bodies:
		carried_bodies.erase(body)
		print("MovingPlatform: Released ", body.name)

# Public interface for getting platform state (useful for debugging/testing)
func get_current_state() -> State:
	return current_state

func get_progress() -> float:
	"""Get movement progress between 0.0 and 1.0"""
	if current_state == State.MOVING_UP or current_state == State.MOVING_DOWN:
		var total_distance = initial_position.distance_to(initial_position + Vector2(0, -move_distance))
		var current_distance = initial_position.distance_to(global_position)
		return clamp(current_distance / total_distance, 0.0, 1.0)
	return 0.0 