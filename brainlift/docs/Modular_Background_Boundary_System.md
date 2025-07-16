# Modular Background & Boundary System Documentation
*Clean, Reusable Components for The Elemental Echo*

## 🎯 **Overview**

This system provides modular, reusable components for backgrounds and boundaries that can be easily integrated into any level scene. It replaces manual platform creation with a clean, organized tilemap-based approach.

---

## 📁 **System Components**

### **Core Assets** (copied from starter kit)
- `assets/platformPack_tilesheet.png` - Main tilemap spritesheet
- `assets/CloudTexture.png` - Atmospheric cloud textures  
- `assets/star_07.png` - Crystal/gem details (repurposed)
- `assets/platformPack_tile048.png` - Individual platform tile

### **Reusable Components**
- `scenes/components/CaveBackground.tscn` - Modular parallax background system
- `scenes/components/LevelBoundaries.tscn` - Tilemap boundaries with collision
- `resources/modular_platform_tileset.tres` - Comprehensive tileset resource

### **Supporting Scripts**
- `src/LevelBoundaries.gd` - Boundary management and respawn system
- `src/CleanMainLevel.gd` - Example of clean level creation
- `src/UpdatedMainLevel.gd` - Example of migrating existing levels

---

## 🚀 **Quick Start Guide**

### **Creating a New Level**

1. **Create new scene**:
   ```gdscript
   # Start with Node2D as root
   [node name="MyLevel" type="Node2D"]
   ```

2. **Add modular components**:
   ```gdscript
   # Add background system
   [node name="CaveBackground" parent="." instance=ExtResource("CaveBackground.tscn")]
   
   # Add boundary system  
   [node name="LevelBoundaries" parent="." instance=ExtResource("LevelBoundaries.tscn")]
   ```

3. **Add your level script**:
   ```gdscript
   extends Node2D
   
   @onready var boundaries: Node2D = $LevelBoundaries
   
   func _ready() -> void:
       # Configure level size and spawn point
       boundaries.set_boundaries(1600.0, 800.0, Vector2(-600, -50))
       
       # Create your level geometry
       _create_level_platforms()
   ```

### **Adding Platform Geometry**

```gdscript
func _create_level_platforms() -> void:
    # Main ground platform
    var ground = _create_platform_line(-20, 20, 3)
    boundaries.add_platform_tiles("Platform", ground)
    
    # Jumping platform
    var platform = _create_platform_line(-5, 5, -1) 
    boundaries.add_platform_tiles("Platform", platform)
    
    # Wall boundaries
    var wall = _create_wall_column(-21, 0, 6)
    boundaries.add_wall_tiles(wall)

func _create_platform_line(start_x: int, end_x: int, y: int) -> Array[Vector2i]:
    var tiles: Array[Vector2i] = []
    for x in range(start_x, end_x + 1):
        tiles.append(Vector2i(x, y))
    return tiles
```

---

## 🏗️ **System Architecture**

### **Background System Structure**
```
CaveBackground/
├── WorldEnvironment (cave lighting & fog)
├── ParallaxBackground/
│   ├── FarLayer (motion: 0.1-0.2) - Deep cave atmosphere
│   ├── MidLayer (motion: 0.3-0.5) - Rock formations & crystals
│   ├── CloseLayer (motion: 0.7-0.8) - Near cave walls
│   └── ForegroundEffects (motion: 1.2) - Atmospheric mist
```

### **Boundary System Structure**
```
LevelBoundaries/
├── MainTileMap/
│   ├── PlatformLayer - Walkable surfaces with collision
│   ├── WallLayer - Solid boundaries with collision
│   └── DecorationLayer - Visual details (no collision)
├── InvisibleBoundaries/
│   ├── LeftWall, RightWall - Level edge prevention
│   ├── Ceiling - Prevents escaping upward
│   └── DeathZone - Respawn trigger area
└── DebugMarkers/ - Visual guides (editor only)
```

### **Collision Layer Organization**
- **Layer 1**: Player (Echo)
- **Layer 2**: Environment (platforms, walls) 
- **Layer 4**: Invisible boundaries
- **Layer 8**: Death zones and triggers

---

## 🎨 **Customization Options**

### **Background Variations**
```gdscript
# Create different background moods
func setup_background_mood(mood: String) -> void:
    var bg = $CaveBackground
    match mood:
        "mysterious":
            bg.modulate = Color(0.8, 0.9, 1.0, 1.0)  # Blue tint
        "warm":
            bg.modulate = Color(1.0, 0.9, 0.8, 1.0)  # Orange tint
        "danger":
            bg.modulate = Color(1.0, 0.8, 0.8, 1.0)  # Red tint
```

### **Dynamic Platform Creation**
```gdscript
# Add temporary platforms
func add_temporary_platform(position: Vector2i, duration: float = 5.0) -> void:
    boundaries.add_platform_tiles("Platform", [position])
    await get_tree().create_timer(duration).timeout
    var tilemap = boundaries.get_node("MainTileMap/PlatformLayer")
    tilemap.erase_cell(position)

# Create safe zones
func create_safe_zone(center: Vector2i, size: int = 2) -> void:
    var safe_tiles: Array[Vector2i] = []
    for x in range(center.x - size, center.x + size + 1):
        for y in range(center.y, center.y + 1):
            safe_tiles.append(Vector2i(x, y))
    boundaries.add_platform_tiles("Platform", safe_tiles)
```

### **Boundary Configuration**
```gdscript
# Adjust boundary sizes for different level types
func configure_boundaries(level_type: String) -> void:
    match level_type:
        "tutorial":
            boundaries.set_boundaries(800.0, 400.0, spawn_point)
        "challenge":
            boundaries.set_boundaries(2000.0, 1000.0, spawn_point)
        "boss":
            boundaries.set_boundaries(1200.0, 800.0, spawn_point)
```

---

## 🔄 **Migration Guide**

### **Converting Existing Levels**

1. **Replace manual backgrounds**:
   ```gdscript
   # OLD: Manual ColorRect background
   [node name="BG" type="ColorRect" parent="."]
   color = Color(0.11, 0.12, 0.15, 1)
   
   # NEW: Modular background component
   [node name="CaveBackground" parent="." instance=ExtResource("CaveBackground.tscn")]
   ```

2. **Replace manual platforms**:
   ```gdscript
   # OLD: Manual StaticBody2D platforms
   [node name="Ground" type="StaticBody2D" parent="."]
   [node name="GroundShape" type="CollisionShape2D" parent="Ground"]
   
   # NEW: Tilemap-based system
   [node name="LevelBoundaries" parent="." instance=ExtResource("LevelBoundaries.tscn")]
   # + Script to generate platforms programmatically
   ```

3. **Preserve existing game objects**:
   ```gdscript
   # Keep all existing game objects in same positions
   [node name="Echo" parent="." instance=ExtResource("Echo.tscn")]
   [node name="IceWall" parent="." instance=ExtResource("IceWall.tscn")]
   [node name="Heartspring" parent="." instance=ExtResource("Heartspring.tscn")]
   ```

### **Example Migration Script**
See `src/UpdatedMainLevel.gd` for a complete example of migrating an existing level.

---

## 🎮 **Tilemap System Reference**

### **Tile Coordinates**
- **64x64 pixel tiles**: Position ÷ 64 = Tile coordinate
- **Example**: Object at (320, -128) = Tile (5, -2)

### **Available Tile Types**
```gdscript
# Platform tiles (row 0)
Vector2i(0, 0) # Solid ground block
Vector2i(1, 0) # Left edge platform  
Vector2i(2, 0) # Right edge platform
Vector2i(3, 0) # Single platform tile

# Wall tiles (row 1) 
Vector2i(0, 1) # Solid wall
Vector2i(1, 1) # Wall variation
Vector2i(2, 1) # Wall variation

# Decorative tiles (row 2) - No collision
Vector2i(0, 2) # Decoration 1
Vector2i(1, 2) # Decoration 2
Vector2i(2, 2) # Decoration 3

# Hazard tiles (row 3)
Vector2i(0, 3) # Spike tile
Vector2i(1, 3) # Spike variation
```

### **Layer Management**
```gdscript
# Add tiles to specific layers
boundaries.add_platform_tiles("Platform", tile_positions)  # Walkable surfaces
boundaries.add_wall_tiles(tile_positions)                 # Solid boundaries  
boundaries.add_decoration_tiles(tile_positions)           # Visual details

# Clear entire layers
boundaries.clear_layer("Platform")
boundaries.clear_layer("Wall") 
boundaries.clear_layer("Decoration")
```

---

## 🔧 **Advanced Features**

### **Death Zone System**
- Automatic player respawn when falling off level
- Configurable respawn position
- Signal emission for custom death handling

### **Debug Features**
- Visual boundary markers (editor only)
- Debug key bindings for testing:
  - **Key 1**: Add temporary platform at mouse
  - **Key 2**: Create safe zone at player position

### **Performance Optimization**
- Efficient tile rendering with collision layers
- Parallax background optimization for different distances
- Modular loading system for large levels

---

## 📊 **Example Scenes**

### **CleanMainLevel.tscn**
- Complete example of new modular system
- Demonstrates programmatic level creation
- Includes dynamic platform features

### **UpdatedMainLevel.tscn** 
- Migration example preserving original layout
- Shows how to convert existing scenes
- Maintains all original functionality

---

## 🏆 **Best Practices**

### **Code Organization**
1. Always instance background and boundaries first
2. Group related game objects under organized nodes
3. Use consistent naming conventions for clarity
4. Keep level-specific logic in dedicated scripts

### **Performance Tips**
1. Use tilemap layers efficiently (don't overlap unnecessarily)
2. Limit parallax background complexity for target hardware
3. Batch tile operations when possible
4. Hide debug markers in production builds

### **Maintenance Guidelines**
1. Document custom tile layouts for future reference
2. Use helper functions for common platform patterns
3. Test boundary configuration on different screen sizes
4. Regularly verify collision layer assignments

---

## 🚀 **Future Enhancements**

### **Planned Features**
- **Moving platform support** - Animated tilemap sections
- **Environmental hazards** - Lava, water, wind areas
- **Interactive backgrounds** - Layers that respond to player actions
- **Theme variations** - Different cave biomes and moods

### **Extensibility**
The modular system is designed to be easily extended. You can:
- Create new background themes by duplicating CaveBackground.tscn
- Add new tile types to the tileset resource
- Create specialized boundary components for unique level types
- Integrate with other game systems (audio, particles, etc.)

---

*This modular system provides a clean, reusable foundation for creating varied and atmospheric levels while maintaining code organization and performance.* 