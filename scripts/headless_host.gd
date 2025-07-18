extends SceneTree

func _init() -> void:
    var nm_scene := load("res://src/network/NetworkManager.gd")
    var nm: Node = nm_scene.new()
    get_root().add_child(nm)
    nm.set_player_name("TerminalHost")
    nm.start_host()
    print("✅ Headless host started. Waiting for clients…")
    # Keep running 