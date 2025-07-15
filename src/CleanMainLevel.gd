extends Node2D

# CleanMainLevel - Demonstrates clean, modular level design
# Uses reusable components and programmatic level creation

@onready var boundaries: Node2D = $LevelBoundaries
@onready var echo: CharacterBody2D = $Echo

# Level configuration
const LEVEL_WIDTH = 1600.0
const LEVEL_HEIGHT = 800.0

func _ready() -> void:
	_setup_level()
	_connect_signals()

func _setup_level() -> void:
	"""Configure the level using modular components"""
	# Set up boundaries with proper dimensions
	boundaries.set_boundaries(LEVEL_WIDTH, LEVEL_HEIGHT, echo.global_position)
	
	# Create platform tiles programmatically
	_create_level_geometry()

func _create_level_geometry() -> void:
	"""Create the main platform layout using the tilemap system"""
	
	# Starting platform (spawn area)
	var starting_platform = _create_platform_line(-25, -20, -1)  # x from -25 to -20, y at -1
	boundaries.add_platform_tiles("Platform", starting_platform)
	
	# Main ground level
	var main_ground = _create_platform_line(-30, 30, 3)  # Long ground platform
	boundaries.add_platform_tiles("Platform", main_ground)
	
	# Intermediate platform (before ice wall)
	var mid_platform = _create_platform_line(-5, 5, -1)  # Small platform near ice wall
	boundaries.add_platform_tiles("Platform", mid_platform)
	
	# Final platform (near Heartspring)
	var final_platform = _create_platform_line(20, 30, -1)  # Platform at goal
	boundaries.add_platform_tiles("Platform", final_platform)
	
	# Add some wall tiles for visual interest
	var wall_tiles = _create_wall_column(-30, 3, 8)  # Left wall
	boundaries.add_wall_tiles(wall_tiles)
	
	var right_wall_tiles = _create_wall_column(30, 3, 8)  # Right wall
	boundaries.add_wall_tiles(right_wall_tiles)
	
	# Add decorative elements
	_add_decorative_elements()

func _create_platform_line(start_x: int, end_x: int, y: int) -> Array[Vector2i]:
	"""Create a horizontal line of platform tiles"""
	var tiles: Array[Vector2i] = []
	for x in range(start_x, end_x + 1):
		tiles.append(Vector2i(x, y))
	return tiles

func _create_wall_column(x: int, start_y: int, end_y: int) -> Array[Vector2i]:
	"""Create a vertical column of wall tiles"""
	var tiles: Array[Vector2i] = []
	for y in range(start_y, end_y + 1):
		tiles.append(Vector2i(x, y))
	return tiles

func _add_decorative_elements() -> void:
	"""Add decorative tiles that don't have collision"""
	var decorations: Array[Vector2i] = [
		Vector2i(-28, 2),   # Left side decorations
		Vector2i(-26, 2),
		Vector2i(26, 2),    # Right side decorations  
		Vector2i(28, 2),
		Vector2i(0, -3),    # Central decorations
		Vector2i(2, -3),
		Vector2i(-2, -3)
	]
	boundaries.add_decoration_tiles(decorations)

func _connect_signals() -> void:
	"""Connect level-specific signals"""
	# Connect boundary death signal
	boundaries.player_died.connect(_on_player_died)
	
	# You can add more signal connections here

func _on_player_died(player: Node) -> void:
	"""Handle player death/respawn"""
	print("Player respawned in CleanMainLevel")
	
	# Reset any level-specific state here
	# For example: reset moving platforms, respawn collectibles, etc.

# Utility functions for dynamic level modification
func add_temporary_platform(position: Vector2i, duration: float = 5.0) -> void:
	"""Add a temporary platform that disappears after duration"""
	boundaries.add_platform_tiles("Platform", [position])
	
	# Remove after duration
	await get_tree().create_timer(duration).timeout
	var tilemap = boundaries.get_node("MainTileMap/PlatformLayer")
	tilemap.erase_cell(position)

func create_safe_zone(center: Vector2i, size: int = 2) -> void:
	"""Create a safe zone platform area"""
	var safe_tiles: Array[Vector2i] = []
	for x in range(center.x - size, center.x + size + 1):
		for y in range(center.y, center.y + 1):
			safe_tiles.append(Vector2i(x, y))
	
	boundaries.add_platform_tiles("Platform", safe_tiles)

# Debug functions
func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# Test: Add temporary platform at mouse position
				var mouse_pos = get_global_mouse_position()
				var tile_pos = Vector2i(int(mouse_pos.x / 64), int(mouse_pos.y / 64))
				add_temporary_platform(tile_pos, 3.0)
				print("Added temporary platform at: ", tile_pos)
			
			KEY_2:
				# Test: Create safe zone at Echo's position
				var echo_tile_pos = Vector2i(int(echo.global_position.x / 64), int(echo.global_position.y / 64) + 1)
				create_safe_zone(echo_tile_pos)
				print("Created safe zone at: ", echo_tile_pos) 
