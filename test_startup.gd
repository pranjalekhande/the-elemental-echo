extends SceneTree

func _init():
	print("Testing StartMenu scene loading...")
	var scene = load("res://scenes/ui/menus/StartMenu.tscn")
	if scene:
		print("✅ StartMenu scene loaded successfully!")
		var instance = scene.instantiate()
		if instance:
			print("✅ StartMenu scene instantiated successfully!")
			instance.queue_free()
		else:
			print("❌ Failed to instantiate StartMenu scene")
	else:
		print("❌ Failed to load StartMenu scene")
	
	quit() 