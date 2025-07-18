extends Node2D

# Main Level - Complete game level with diamond collection and reset system
# Initializes CollectionManager, handles level setup, and manages respawn resets

# Store initial level state for reset functionality
var initial_diamond_data: Array = []
var initial_ice_wall_data: Dictionary = {}
var echo_node: Node2D
var level_boundaries: Node2D

# Pause system
var pause_menu: Control
var pause_button: Button
var is_paused: bool = false

func _ready() -> void:
	# Script initialization
	
	# Start background music for level
	if AudioManager:
		AudioManager.play_background_music()
	
	# Get reference to key nodes
	echo_node = get_node("Echo")
	level_boundaries = get_node("LevelBoundaries")
	

	
	# Setup pause menu
	_setup_pause_menu()
	
	# Store initial level state before anything can be collected/destroyed
	_store_initial_level_state()
	
	# Connect to respawn signal for level reset
	if level_boundaries and level_boundaries.has_signal("player_died"):
		level_boundaries.player_died.connect(_on_player_died)
	
	# Reset collection manager for new session
	if CollectionManager:
		CollectionManager.reset_session()
		
		# Count diamonds in the level
		var fire_diamonds = 0
		var water_diamonds = 0
		
		var diamonds_node = get_node("Diamonds")
		if diamonds_node:
			var counts = _count_diamonds_recursive(diamonds_node)
			fire_diamonds = counts[0]
			water_diamonds = counts[1]
		
		# Set diamond counts in collection manager
		CollectionManager.set_level_diamond_counts(fire_diamonds, water_diamonds)
		
	

func _unhandled_input(event: InputEvent) -> void:
	# Handle pause toggle (ESC key)
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _setup_pause_menu() -> void:
	"""Setup the pause menu and button for this level"""
	# Add pause menu
	var pause_menu_scene = preload("res://scenes/ui/menus/PauseMenu.tscn")
	pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)
	
	# Add pause button to UI layer
	var ui_layer = get_node("UI")
	if ui_layer:
		var pause_button_scene = preload("res://scenes/ui/components/PauseButton.tscn")
		pause_button = pause_button_scene.instantiate()
		ui_layer.add_child(pause_button)
		
		# Connect pause button signal
		pause_button.pause_requested.connect(_on_pause_button_pressed)
	
	# Connect pause menu signals
	pause_menu.resume_requested.connect(_on_pause_resume)
	pause_menu.exit_requested.connect(_on_pause_exit)

func _toggle_pause() -> void:
	"""Toggle pause state"""
	if not is_paused:
		_pause_game()
	else:
		_resume_game()

func _pause_game() -> void:
	"""Pause the game and show pause menu"""
	is_paused = true
	pause_menu.show_pause_menu()

func _resume_game() -> void:
	"""Resume the game and hide pause menu"""
	is_paused = false
	pause_menu.hide_pause_menu()

func _on_pause_resume() -> void:
	"""Handle resume from pause menu"""
	_resume_game()

func _on_pause_exit() -> void:
	"""Handle exit from pause menu"""
	# Menu already handles scene transition


func _on_pause_button_pressed() -> void:
	"""Handle pause button press from UI"""
	_pause_game()

func _store_initial_level_state() -> void:
	"""Store the initial positions and types of all resetable objects"""
	
	# Store diamond data
	initial_diamond_data.clear()
	var diamonds_node = get_node("Diamonds")
	if diamonds_node:
		for diamond in diamonds_node.get_children():
			var diamond_data = {
				"name": diamond.name,
				"position": diamond.position,
				"scene_path": diamond.scene_file_path if diamond.scene_file_path else "",
				"type": "fire" if diamond.name.contains("Fire") else "water"
			}
			initial_diamond_data.append(diamond_data)
	
	# Store ice wall data
	var ice_wall = get_node("IceWall")
	if ice_wall:
		initial_ice_wall_data = {
			"name": ice_wall.name,
			"position": ice_wall.position,
			"scene_path": ice_wall.scene_file_path if ice_wall.scene_file_path else "res://scenes/obstacles/IceWall.tscn"
		}
	


func _on_player_died(player: Node2D) -> void:
	"""Called when Echo dies - reset the entire level to initial state"""

	
	# Defer all reset operations to avoid physics conflicts
	call_deferred("_perform_level_reset")

func _perform_level_reset() -> void:
	"""Perform all level reset operations safely outside physics processing"""
	# Reset all diamonds
	_reset_diamonds()
	
	# Reset ice walls
	_reset_ice_walls()
	
	# Reset game systems
	_reset_game_systems()
	
	# Reset Echo's health
	_reset_echo_health()

func _reset_diamonds() -> void:
	"""Reset all diamonds to uncollected state"""
	var diamonds_node = get_node("Diamonds")
	if not diamonds_node:
		return
	
	var reset_count = 0
	var created_count = 0
	
	# First, try to reset existing diamonds
	for child in diamonds_node.get_children():
		if child.has_method("reset_diamond"):
			child.reset_diamond()
			reset_count += 1
	
	# If we have fewer diamonds than expected, recreate missing ones
	var existing_diamonds = diamonds_node.get_children()
	if existing_diamonds.size() < initial_diamond_data.size():
		for diamond_data in initial_diamond_data:
			# Check if this diamond already exists
			var exists = false
			for existing in existing_diamonds:
				if existing.name == diamond_data.name:
					exists = true
					break
			
			# Create missing diamond
			if not exists:
				var scene_path = "res://scenes/collectibles/FireDiamond.tscn" if diamond_data.type == "fire" else "res://scenes/collectibles/WaterDiamond.tscn"
				var diamond_scene = load(scene_path)
				var diamond_instance = diamond_scene.instantiate()
				
				diamond_instance.name = diamond_data.name
				diamond_instance.position = diamond_data.position
				diamonds_node.add_child(diamond_instance)
				created_count += 1
	


func _reset_ice_walls() -> void:
	"""Remove existing ice wall and recreate from initial state"""
	var ice_wall = get_node_or_null("IceWall")
	if ice_wall:
		ice_wall.queue_free()
	
	# Wait for deletion to complete, then recreate
	await get_tree().process_frame
	
	if not initial_ice_wall_data.is_empty():
		var ice_wall_scene = load(initial_ice_wall_data.scene_path)
		var ice_wall_instance = ice_wall_scene.instantiate()
		
		ice_wall_instance.name = initial_ice_wall_data.name
		ice_wall_instance.position = initial_ice_wall_data.position
		add_child(ice_wall_instance)
		
	

func _reset_game_systems() -> void:
	"""Reset CollectionManager and other game systems"""
	if CollectionManager:
		# Reset collection stats
		CollectionManager.reset_session()
		
		# Recount and set diamond counts for the level
		var fire_count = 0
		var water_count = 0
		for diamond_data in initial_diamond_data:
			if diamond_data.type == "fire":
				fire_count += 1
			else:
				water_count += 1
		
		CollectionManager.set_level_diamond_counts(fire_count, water_count)
	

func _reset_echo_health() -> void:
	"""Reset Echo's health to full"""
	if echo_node and echo_node.has_method("heal"):
		var health_component = echo_node.get_node("HealthComponent")
		if health_component and health_component.has_method("restore_full_health"):
			health_component.restore_full_health()
		else:
			# Fallback: heal a large amount
			echo_node.heal(100)
		
	

func _count_diamonds_recursive(node: Node) -> Array:
	"""Recursively count diamonds in nested chamber structure"""
	var fire_count = 0
	var water_count = 0
	
	for child in node.get_children():
		if child.name.contains("Fire"):
			fire_count += 1
		elif child.name.contains("Water"):
			water_count += 1
		elif child.get_child_count() > 0:
			var child_counts = _count_diamonds_recursive(child)
			fire_count += child_counts[0]
			water_count += child_counts[1]
	
	return [fire_count, water_count] 



 
