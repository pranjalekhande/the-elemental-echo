# The Elemental Echo – MVP Technical Design Document

## 1. Project Structure (Godot)
```
res://
 ├── scenes/
 │   ├── MainLevel.tscn        # Root scene (Level 1)
 │   ├── Echo.tscn             # Player prefab
 │   ├── IceWall.tscn          # Obstacle
 │   └── Heartspring.tscn      # Goal object
 ├── src/                      # Scripts (GDScript)
 │   ├── echo/ElementalShift.gd
 │   ├── obstacles/IceWall.gd
 │   ├── world/Heartspring.gd
 │   ├── ui/TextTag.gd
 │   └── managers/TextTagManager.gd
 ├── assets/                   # Art & audio
 └── docs/                     # Design docs (this folder)
```
*Rule*: scenes and scripts mirror each other (one `*.tscn` prefab ➜ one `*.gd` script).

---
## 2. Coding Guidelines
* GDScript 2.0 strict typing (`class_name` where appropriate).  
* `@onready var` for node refs; never fetch in _process.  
* Signals over polling; avoid singleton Globals except `GameState` (future).  
* Max file length 300 lines; split modules into sub-folders as above.  
* Use enums for state (e.g. `enum Form { FIRE, WATER }`).

---
## 3. Core Systems
### 3.1 ElementalShift (attached to `Echo`)
* Stores `current_form : Form`.
* Emits `signal form_changed(form: int)`.
* Handles sprite/material swap + particle toggles.

### 3.2 IceWall
* Listens for `body_entered` from Area2D.  
* If body has `ElementalShift` and `current_form == FIRE`, plays melt animation then `queue_free()`.

### 3.3 Heartspring
* StaticBody2D with AnimationPlayer + Area2D.  
* On player body_entered → play `Activate` animation, emit `heartspring_restored` (global bus), then call `LevelEnd()` after 1.5 s.

### 3.4 TextTagManager
* Autoload (singleton) that spawns `TextTag.tscn` at a screen position.
* Provides `show_tag(text: String, world_pos: Vector2)`.

### 3.5 Level Flow (MainLevel.gd)
1. Listen to `heartspring_restored`.  
2. Disable player input, fade to white (CanvasLayer), load `Credits.tscn`.

---
## 4. Scene Trees (Key Prefabs)
```
Echo.tscn
 └─ CharacterBody2D
     ├─ Sprite2D (swap textures)
     ├─ CollisionShape2D
     ├─ GPUParticles2D (Fire)
     └─ GPUParticles2D (Water)

IceWall.tscn
 └─ StaticBody2D
     ├─ Sprite2D
     ├─ CollisionShape2D
     └─ AnimationPlayer

Heartspring.tscn
 └─ StaticBody2D
     ├─ Sprite2D (unlit → lit animation)
     ├─ CollisionShape2D (sensor)
     └─ AnimationPlayer
```

---
## 5. Asset Pipeline
* **Sprites**: 256×256 or smaller PNG; imported as CompressedTexture2D with mipmaps off.  
* **Audio**: 44.1 kHz OGG; loop points set in import panel.  
* **Particles**: GPU-based, max 250 particles per emitter.

---
## 6. Build & Deployment
* Export preset: Windows/Mac (debug & release).  
* Use Godot CLI for automated export:
  ```bash
  godot --headless --path . --export-release "Windows Desktop" builds/echo_win.exe
  ```
* Continuous export script in `/tools/export.sh` (to be added) for nightly builds.

---
## 7. Version Control Workflow
* **main** branch = stable builds only.  
* **dev** branch = daily work.  
* Feature branches prefixed `feat/`, merged via pull request.
* `.import/` and `builds/` are git-ignored.

---
## 8. Performance Budget (MVP)
| Metric | Target |
| --- | --- |
| FPS | 60 on Intel UHD 620 |
| Draw calls | < 150 |
| Texture memory | < 200 MB |
| CPU frame time | < 6 ms |

Profile every milestone with Godot’s built-in profiler.

---
## 9. Future-Proofing Notes
* Elemental forms system is data-driven: to add Earth/Air later, extend `Form` enum and particle/material sets.  
* Level loading via `PackedScene` allows additive scenes for multi-level builds.

---
*Last updated: {{DATE}}* 