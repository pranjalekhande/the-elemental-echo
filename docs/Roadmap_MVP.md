# The Elemental Echo – MVP Development Roadmap

> Total timeline: **5 weeks** (May 5 → June 8, 2025**)**
> Team: 1 developer (you) + part-time artist/audio.

| Week | Focus | Key Deliverables | Notes |
| --- | --- | --- | --- |
| 0 (Prep) | Setup & Planning |- Finalise design docs (PRD, GDD, TDD, Style Guide, Roadmap)<br/>- Create Git branches & CI export script | Complete ✔ |
| 1 | Core Systems |- Echo movement & float physics<br/>- ElementalShift script w/ Fire & Water materials<br/>- Simple greybox level | Playable in editor |
| 2 | Puzzle Objects |- IceWall prefab + melt animation<br/>- Heartspring prefab + activation flow<br/>- Level win condition & fade-out | End-to-end victory possible |
| 3 | Narrative & Polish Pass 1 |- TextTagManager + 3 trigger areas<br/>- Ambient music loop & core SFX<br/>- Basic particle trails | Feature-complete alpha build |
| 4 | Art & Polish Pass 2 |- Replace greybox with final sprites & lighting<br/>- Performance profiling & fixes<br/>- Add controller mapping | Beta build, content-locked |
| 5 | Release Prep |- Build exports (Windows/macOS)<br/>- Smoke-test on low-spec laptop<br/>- Create itch.io/Steam page assets<br/>- Collect final play-tester feedback | Release Candidate (RC1) |

## Milestone Exit Criteria
* **Alpha (end Week 3)**: player can start game, melt wall, restore Heartspring, and reach end screen without errors; FPS ≥ 60.
* **Beta (end Week 4)**: all art/audio final; no high-priority bugs; exported builds run on target OS.
* **Release (Week 5)**: RC build passes smoke test; store page live; optional post-launch patch backlog created.

## Task Tracking
* Use GitHub Issues with *milestone* tags `Alpha`, `Beta`, `Release`.
* Each task references relevant doc section (e.g., `TDD §3.2 IceWall`).

## Risk Buffers
Allocate 0.5 day each week for bug fixes & unexpected scope.

---
*Last updated: {{DATE}}* 