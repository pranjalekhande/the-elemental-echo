# The Elemental Echo – MVP Product Requirements Document

## 1. Overview
*The Elemental Echo* is a serene 2D puzzle-platformer built with Godot 4.x.  Players control **Echo**, a spark of elemental essence that can shift between Fire and Water forms to restore fading Heartsprings.  The MVP focuses on delivering a single, polished level that proves the core mechanic and atmosphere.

## 2. Problem & Vision
The game world is slowly losing elemental balance; ancient Heartsprings are dimming.  Players seek a calm, reflective experience rather than combat-heavy action titles.  Our vision is to offer a short, meditative adventure that blends light environmental puzzles with rich ambience—an experience currently under-served in the indie market.

## 3. Target Audience
* Age 14 – 35
* Enjoy atmospheric indies (e.g. *Journey*, *GRIS*, *Ori* exploration segments)
* Platforms: Windows/macOS (keyboard, controller).  Tablet port considered post-MVP.

## 4. MVP Goals
1. Validate the **Elemental Shifting** mechanic is fun & intuitive.
2. Showcase world tone via art, sound, and text-tags.
3. Achieve a downloadable, replay-stable build in under 5 minutes of play-time.

## 5. Core Features (Must-Have)
| Area | Requirement |
| --- | --- |
| Movement | 360° float control with momentum damping |
| Elemental Shift | Toggle Fire/Water on key press (instant, no cooldown) |
| Obstacle | Single **Ice Wall** that melts when Fire form touches it |
| Goal | Interactable **Heartspring** that re-lights and ends level |
| Text-Tags | Contextual text at 3 trigger zones (wall, spring, start) |
| Audio | Looping ambient track + 2 SFX (shift & spring activation) |
| Build | Exported PC build, <100 MB, <30 s initial load |

### Nice-to-Have (Stretch)
* Basic particle VFX for forms and Heartspring
* Subtle camera shake on spring activation
* Gamepad vibration feedback

## 6. Success Metrics
| Metric | Target |
| --- | --- |
| First-run completion rate | ≥ 80 % |
| Average session length | 3 – 6 min |
| Wishlist conversions (Steam demo) | 5 % of demo DLs |
| Qualitative feedback | ≥ 70 % testers label controls “intuitive” |

## 7. Constraints
* Engine: Godot 4.4+ only
* Team size: 1 dev + part-time artist/composer
* Timeline: 5 weeks total (see Roadmap)
* Budget: $0 external—open-source tools & CC-0 assets where possible

## 8. Risks & Mitigations
| Risk | Probability | Impact | Mitigation |
| --- | --- | --- | --- |
| Godot 4.x stability issues | Medium | High | Daily exports; stay on LTS build |
| Scope creep | High | Medium | Strict MVP checklist; weekly reviews |
| Performance on low-end PCs | Low | Medium | 60 FPS cap; profile early |

## 9. Dependencies
* Finalised GDD for level layout
* Style Guide for art & audio assets

## 10. Approval
This PRD is considered *accepted* when the stakeholder (you) comments "approved" in the project chat.

---
*Last updated: {{DATE}}* 