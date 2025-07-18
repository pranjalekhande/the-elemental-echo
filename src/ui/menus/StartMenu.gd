extends Control

# StartMenu - Main menu for The Elemental Echo
# Handles navigation to level selection and quick play

@onready var play_button_animated_sprite: AnimatedSprite2D = $UI/PlayButton/AnimatedSprite2D
@onready var play_button_area: Area2D = $UI/PlayButton/ClickArea
@onready var play_button_control: Control = $UI/PlayButton
@onready var collision_shape: CollisionShape2D = $UI/PlayButton/ClickArea/CollisionShape2D

func _ready() -> void:
	# Enable responsive scaling
	resized.connect(_on_menu_resized)
	
	# Initialize solo host for leaderboard functionality
	_initialize_solo_host()
	
	# Settings icon button is ready
	
	# Initial scale setup
	call_deferred("_on_menu_resized")
	
	# Ensure animated sprite starts with idle animation (after scene is ready)
	call_deferred("_initialize_animation")
	
	# Add backup click detection to the Control node
	if play_button_control:
		play_button_control.gui_input.connect(_on_play_button_gui_input)

func _initialize_animation() -> void:
	"""Initialize the button animation safely after scene is ready"""
	if play_button_animated_sprite and play_button_animated_sprite.sprite_frames:
		play_button_animated_sprite.play("idle")
		print("✅ Play button animation initialized with idle")

func _on_play_button_clicked(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Handle mouse click on animated play button
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🎮 Play button clicked!")
		_play_click_animation()

func _play_click_animation() -> void:
	# Play the water dip animation, then navigate
	if play_button_animated_sprite and play_button_animated_sprite.sprite_frames:
		print("🌊 Playing click_dip animation...")
		play_button_animated_sprite.play("click_dip")
		# Wait for animation to finish, then navigate
		await play_button_animated_sprite.animation_finished
		print("✅ Animation finished, navigating to level select...")
		get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")
	else:
		print("❌ Could not find animated sprite or sprite frames")
		# Fallback: navigate immediately if animation fails
		get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

func _on_menu_resized() -> void:
	"""Handle menu resize to scale elements appropriately"""
	var screen_size = get_rect().size
	var base_width = 1920.0  # Base design width
	var base_height = 1080.0  # Base design height
	
	# Calculate scale factors
	var width_scale = screen_size.x / base_width
	var height_scale = screen_size.y / base_height
	var scale_factor = min(width_scale, height_scale)
	
	# Scale animated sprite with a more reasonable base scale
	if play_button_animated_sprite:
		var base_scale = 1.2  # Increased from 0.2 to make button more visible
		var adjusted_scale = base_scale * scale_factor
		# Ensure minimum scale for usability
		var final_scale = max(adjusted_scale, 0.8)
		play_button_animated_sprite.scale = Vector2(final_scale, final_scale)
		
		# Scale collision area to match the sprite
		if collision_shape and collision_shape.shape is RectangleShape2D:
			var base_collision_size = Vector2(300, 150)  # Base collision size
			var scaled_size = base_collision_size * final_scale
			collision_shape.shape.size = scaled_size

# Optional: Add methods for future menu options
func _on_quit_button_pressed() -> void:
	# Quit game
	get_tree().quit()

# Backup click detection using Control node gui_input
func _on_play_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🎮 Play button clicked! (via Control gui_input)")
		_play_click_animation()

# Fallback method for simple TextureButton
func _on_play_button_pressed_fallback() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menus/LevelSelectMenu.tscn")

func _initialize_solo_host() -> void:
	"""Initialize NetworkManager as host for solo play leaderboard functionality"""
	print("🔄 Initializing solo host...")
	
	var nm = null
	if Engine.has_singleton("NetworkManager"):
		print("✅ NetworkManager singleton found via Engine.has_singleton")
		nm = Engine.get_singleton("NetworkManager")
	else:
		print("⚠️ NetworkManager not found via Engine.has_singleton, trying direct access...")
		# Try direct access via /root/ path
		var root_nm = get_tree().get_root().get_node_or_null("NetworkManager")
		if root_nm:
			nm = root_nm
			print("✅ Found NetworkManager via /root/ path")
	
	if not nm:
		print("❌ NetworkManager not accessible via any method")
		return
	
	print("📋 NetworkManager found, checking current state...")
	print("   Current is_host: ", nm.is_host)
	print("   Has multiplayer property: ", nm.has_method("get_multiplayer"))
	
	# Check if already hosting or in multiplayer mode
	var has_peer = false
	if nm.has_method("get_multiplayer") or "multiplayer" in nm:
		var mp = nm.multiplayer
		if mp and mp.multiplayer_peer != null:
			has_peer = true
			print("   Existing multiplayer peer detected")
	
	# Only start host if not already hosting and no multiplayer peer exists
	if not nm.is_host and not has_peer:
		print("🚀 Starting solo host...")
		nm.set_player_name("Solo Player")
		nm.start_host()
		print("✅ Solo host initialized for leaderboard functionality")
	else:
		print("ℹ️ Solo host not needed - already hosting or in multiplayer mode")

func _on_settings_icon_button_pressed() -> void:
	"""Handle settings icon button press"""
	print("⚙️ Settings icon clicked!")
	get_tree().change_scene_to_file("res://scenes/ui/menus/SettingsMenu.tscn")
