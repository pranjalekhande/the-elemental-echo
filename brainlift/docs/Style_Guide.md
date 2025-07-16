# The Elemental Echo – Art & Audio Style Guide (MVP)

## 1. Visual Tone & Inspiration
Quiet, mystical caverns bathed in soft ambient light.  Art influences: *GRIS*’ pastel minimalism, *Ori*’s subtle glow accents.

## 2. Colour Palette
| Use | Hex | Notes |
| --- | --- | --- |
| Background rock | #2A2F38 | Desaturated blue-grey |
| Accent rock rim | #39404B | Slightly lighter edge |
| Fire form core | #E96D3C | Vibrant orange |
| Water form core | #3CC4FF | Vibrant cyan |
| Heartspring dim | #6F6F6F | Neutral grey |
| Heartspring lit | #F7F4D7 | Warm light yellow |
| UI text | #FFFFFF | High contrast on dark BG |

### Value Discipline
Keep value range mid-dark overall; highlights reserved for elemental effects & goal object.

## 3. Sprites & Resolution
* Base resolution: 256×256 max for single elements.
* Echo sprite: 96×96; round wisp, no outline; separate Fire/Water textures.
* Tileset: 64×64 grid; avoid repeating obvious patterns—use 3-tile variants.
* No hard black outlines; rely on contrast via glow/lighting.

## 4. Lighting & Post-Processing
* Global Environment: subtle blue ambient (#202833), energy 0.4.
* 2D Lights: one omni on Heartspring (lit), two low-energy lights near torches (future).
* Use CanvasModulate #1C1E24 at 85 % opacity for overall darkness.
* No bloom for MVP (keeps performance high); enable glow only on Heartspring.

## 5. Effects & Particles
| Effect | System | Limits |
| --- | --- | --- |
| Fire form trail | GPUParticles2D | 150 particles, lifetime 0.4 s |
| Water form trail | GPUParticles2D | 150 particles, lifetime 0.4 s |
| Heartspring ignite | AnimatedSprite or shader + 50-particle burst |
| Ice Wall melt | Frame-based sprite sheet (10 frames) |

Disable shadows on particles. Use additive blend for elemental trails.

## 6. UI Style
* Font: Noto Sans Regular, 32 px.
* Text-Tag background: none. Text appears directly with subtle 1 px shadow (#000, 60 % alpha).
* Form icon: 48×48 sprite displayed lower-left; fades after 2 s.

## 7. Audio Direction
### 7.1 Music
* Single looping ambient pad (C minor, 60 BPM). Length 2:00 min, seamless loop.
* Low-pass filter at 8 kHz to leave space for SFX.

### 7.2 Sound Effects
| Event | Description | Guideline |
| --- | --- | --- |
| Elemental shift | Soft „whoosh” with subtle crackle or ripple | -10 LU relative to music |
| Heartspring activation | Warm chime + rising airy swell | Peak -6 LU |
| Ice Wall melting | Gentle sizzle & crack | Peak -12 LU |

All SFX stereo, 44.1 kHz, OGG.

### 7.3 Mixing Rules
* Target overall LUFS: -16.
* Music at -20 LUFS, SFX mixed relative as above.
* Slight reverb (0.4 s) on Heartspring & shift sounds.

## 8. File Naming & Storage
`assets/sfx/shift_fire_water.ogg`  
`assets/music/ambient_loop.ogg`  
`assets/sprites/echo_fire.png` …

## 9. Credits & Licensing
* Font: Noto Sans (OFL).  
* Music & SFX: original or CC-0 sources, list in `docs/credits.md`.

---
*Last updated: {{DATE}}* 