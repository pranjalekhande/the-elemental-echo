# The Elemental Echo – MVP Game Design Document

## 1. High-Level Summary
*A tranquil puzzle-platformer where a small elemental wisp, Echo, shifts between Fire and Water forms to rekindle fading Heartsprings.*

Player emotions to evoke: curiosity, calm focus, gentle wonder.

---
## 2. Core Gameplay Loop
```mermaid
flowchart LR
    A[Explore Cavern] --> B[Observe Obstacle]
    B --> C[Shift Elemental Form]
    C --> D[Solve / Bypass]
    D --> E[Restore Heartspring]
    E --> A
```
Each loop lasts ~30–60 s in the MVP.

---
## 3. Player Controls & Abilities
| Action | Key / Input | Details |
| --- | --- | --- |
| Move | WASD / Left-Stick | 8-way float, velocity capped at 200 px/s |
| Shift Form | Space / South Button (A) | Instant toggle between Fire & Water |
| Interact | Touch object | Auto-trigger on collision (Heartspring) |
| Reset | R / Start+Back | Respawn at entry if stuck (debug) |

### Form Properties
| Form | Visual | Passive Effect |
| --- | --- | --- |
| Fire | Orange glow, heat particles | Melts Ice Wall, illuminates nearby tiles |
| Water | Cyan glow, ripple particles | None in MVP (placeholder for future) |

---
## 4. Level 1 Layout
```
   [Spawn]───6m───[Ice Wall]──3m──[Heartspring]
```
• Ceiling & floor gently slope to guide player.  
• Three invisible **Text-Tag Areas**: at Spawn, before Wall, after activation.

---
## 5. Objects & Obstacles
| Object | Purpose | Interaction |
| --- | --- | --- |
| Echo (player) | Avatar | Responds to input, shifts forms |
| Ice Wall | Gate | On Fire collision → melt animation, removes collision |
| Heartspring | Goal | On touch → play light-up anim, end level |
| Text-Tag Area | Narrative | Emits floating text for 4 s on enter; cooldown 8 s |

---
## 6. Game Feel & UX
* Camera: smooth follow with 0.1 s lag, 1.1× zoom at activation.
* UI: bottom-left icon showing current form; fades after 2 s if unchanged.
* Audio: single ambient loop, cross-fade elemental shift SFX (–3 dB below music).
* Haptics: controller rumble 0.5 s at Heartspring ignition (stretch goal).

---
## 7. Progression & Failure
No health or enemies. Player cannot die; falling out of bounds teleports to spawn.  Level ends with 3 s fade-to-white then credits screen (placeholder).

---
## 8. Art & Audio References
See `docs/Style_Guide.md` (to be written) for palettes, sprite sizes, and audio specs.

---
## 9. Telemetry (Optional but recommended)
* Time from spawn to Ice Wall melt
* Number of form toggles
* Total completion time

---
*Last updated: {{DATE}}* 