extends Node2D

# Main Level - Complete game level with diamond collection
# Initializes CollectionManager and handles level setup

func _ready() -> void:
	# Reset collection manager for new session
	if CollectionManager:
		CollectionManager.reset_session()
		
		# Count diamonds in the level across all chambers
		var fire_diamonds = 0
		var water_diamonds = 0
		
		var diamonds_node = get_node("Diamonds")
		if diamonds_node:
			var counts = _count_diamonds_recursive(diamonds_node)
			fire_diamonds = counts[0]
			water_diamonds = counts[1]
		
		# Set diamond counts in collection manager
		CollectionManager.set_level_diamond_counts(fire_diamonds, water_diamonds)
		
		print("Level initialized with %d fire diamonds and %d water diamonds" % [fire_diamonds, water_diamonds])

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