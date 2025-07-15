extends Node2D

# UpdatedMainLevel - Migration example showing how to convert existing levels
# to use the new modular background and boundary system

@onready var boundaries: Node2D = $LevelBoundaries
@onready var echo: CharacterBody2D = $Echo

func _ready() -> void:
	_setup_original_layout()

func _setup_original_layout() -> void:
	"""Recreate the original MainLevel layout using the new modular system"""
	
	# Configure boundaries for the original level size
	boundaries.set_boundaries(1400.0, 600.0, echo.global_position)
	
	# Recreate the original platforms
	_create_original_platforms()

func _create_original_platforms() -> void:
	"""Recreate the exact platform layout from the original MainLevel"""
	
	# Main ground platform (equivalent to the original Ground StaticBody2D)
	var ground_tiles = _create_platform_line(-12, 12, 3)  # Main ground level
	boundaries.add_platform_tiles("Platform", ground_tiles)
	
	# Platform1 equivalent (original position: Vector2(-300, 0))
	# Convert to tile coordinates: x=-300/64≈-5, y=0/64=0
	var platform1_tiles = _create_platform_line(-8, -5, -1)
	boundaries.add_platform_tiles("Platform", platform1_tiles)
	
	# Platform2 equivalent (original position: Vector2(500, -50))
	# Convert to tile coordinates: x=500/64≈8, y=-50/64≈-1
	var platform2_tiles = _create_platform_line(7, 10, -2)
	boundaries.add_platform_tiles("Platform", platform2_tiles)
	
	# Add some wall boundaries to prevent falling off
	var left_wall = _create_wall_column(-13, 0, 6)
	boundaries.add_wall_tiles(left_wall)
	
	var right_wall = _create_wall_column(13, 0, 6)
	boundaries.add_wall_tiles(right_wall)
	
	print("Original MainLevel layout recreated using modular system")

func _create_platform_line(start_x: int, end_x: int, y: int) -> Array[Vector2i]:
	"""Helper function to create horizontal platform lines"""
	var tiles: Array[Vector2i] = []
	for x in range(start_x, end_x + 1):
		tiles.append(Vector2i(x, y))
	return tiles

func _create_wall_column(x: int, start_y: int, end_y: int) -> Array[Vector2i]:
	"""Helper function to create vertical wall columns"""
	var tiles: Array[Vector2i] = []
	for y in range(start_y, end_y + 1):
		tiles.append(Vector2i(x, y))
	return tiles 