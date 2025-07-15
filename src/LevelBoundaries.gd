extends Node2D

# LevelBoundaries - Manages level boundaries and respawn system
# Clean, reusable component for all levels

@onready var death_zone: Area2D = $InvisibleBoundaries/DeathZone
@onready var debug_markers: Node2D = $DebugMarkers

var player_spawn_point: Vector2 = Vector2.ZERO
var level_width: float = 2000.0
var level_height: float = 1000.0

signal player_died(player: Node)

func _ready() -> void:
	# Connect death zone with null check
	if death_zone:
		death_zone.body_entered.connect(_on_death_zone_entered)
	else:
		print("Warning: DeathZone node not found in LevelBoundaries")
	
	# Hide debug markers in production with null check
	if debug_markers:
		debug_markers.visible = OS.is_debug_build()
	else:
		print("Warning: DebugMarkers node not found in LevelBoundaries")
	
	# Find player spawn point from parent scene
	_find_spawn_point()

func _find_spawn_point() -> void:
	# Look for Echo in parent scene
	var parent_scene = get_parent()
	if parent_scene:
		var echo = parent_scene.find_child("Echo")
		if echo:
			player_spawn_point = echo.global_position

func _on_death_zone_entered(body: Node2D) -> void:
	if body.name == "Echo":
		print("Player fell off the level - respawning")
		_respawn_player(body)

func _respawn_player(player: Node2D) -> void:
	# Reset player position to spawn
	player.global_position = player_spawn_point
	
	# Reset player velocity if it's a CharacterBody2D
	if player is CharacterBody2D:
		player.velocity = Vector2.ZERO
	
	# Emit signal for other systems to handle
	player_died.emit(player)

func set_boundaries(width: float, height: float, spawn_pos: Vector2) -> void:
	"""Configure boundary dimensions and spawn point"""
	level_width = width
	level_height = height
	player_spawn_point = spawn_pos
	
	# Update boundary positions with null checks
	var right_wall = $InvisibleBoundaries/RightWall
	var ceiling = $InvisibleBoundaries/Ceiling
	var death_zone_node = $InvisibleBoundaries/DeathZone
	
	if right_wall:
		right_wall.position.x = width - 50
	if ceiling:
		ceiling.position.y = -height/2
	if death_zone_node:
		death_zone_node.position.y = height/2 + 100

func add_platform_tiles(layer_name: String, tile_positions: Array[Vector2i], tile_id: Vector2i = Vector2i(0, 0)) -> void:
	"""Add platform tiles to specified layer"""
	var tilemap = $MainTileMap
	if not tilemap:
		print("Warning: MainTileMap not found in LevelBoundaries")
		return
		
	var layer = tilemap.get_node(layer_name + "Layer")
	if layer:
		for pos in tile_positions:
			layer.set_cell(pos, 0, tile_id)
	else:
		print("Warning: Layer '", layer_name, "Layer' not found in MainTileMap")

func add_wall_tiles(tile_positions: Array[Vector2i], tile_id: Vector2i = Vector2i(0, 1)) -> void:
	"""Add wall tiles for solid boundaries"""
	add_platform_tiles("Wall", tile_positions, tile_id)

func add_decoration_tiles(tile_positions: Array[Vector2i], tile_id: Vector2i = Vector2i(0, 2)) -> void:
	"""Add decorative tiles (no collision)"""
	add_platform_tiles("Decoration", tile_positions, tile_id)

func clear_layer(layer_name: String) -> void:
	"""Clear all tiles from specified layer"""
	var tilemap = $MainTileMap
	if not tilemap:
		print("Warning: MainTileMap not found in LevelBoundaries")
		return
		
	var layer = tilemap.get_node(layer_name + "Layer")
	if layer:
		layer.clear()
	else:
		print("Warning: Layer '", layer_name, "Layer' not found in MainTileMap") 
