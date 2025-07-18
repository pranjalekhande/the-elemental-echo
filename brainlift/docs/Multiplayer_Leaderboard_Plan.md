# 🏆 Multiplayer Scoreboard – Implementation Plan (Tier 2 Scope)

*Objective: add LAN multi-user support where each running game window submits its final score to a shared Top-10 leaderboard.  No real-time physics sync, minimal code churn, zero-crash requirement.*

---

## 1 — Scope & Assumptions
| Item | Decision |
|------|----------|
| Play style | Independent local game instances; one becomes **Host**, others **Join**. |
| Max players | Arbitrary N (tested with 4). |
| Identification | Player enters a **unique name** in the Lobby. |
| Shared data | Final score only (no positions, collisions, etc.). |
| Leaderboard | Single global list, **Top 10 by total points ever earned**. |
| Persistence | JSON file on Host: `user://leaderboard.json`. |
| Security | Trust all clients (demo/friends scenario). |
| Host quit | Ends session for everyone (simplest). |

---

## 2 — Architecture Snapshot
```
Host window
 ├─ NetworkManager (autoload)          ← starts server
 ├─ LeaderboardService (autoload)      ← loads/saves JSON
 └─ Game scenes …                      ← unchanged gameplay
Client windows
 ├─ NetworkManager (autoload)          ← connects to host
 └─ Game scenes …                      ← unchanged gameplay
```
Signals/RPCs  
```
submit_score(name:String, points:int)  -- client → host
leaderboard_update(array)              -- host → all clients
```

---

## 3 — Implementation Steps & Verification

| Milestone | Code Touch-points | What to Test / Verify |
|-----------|------------------|-----------------------|
| **M1** – Networking Skeleton | `src/network/NetworkManager.gd` (new autoload) | • Host can “Create Room” → console prints “Hosting at *:4321”<br>• Second window “Join” → console prints “Connected, peer_id = 2”<br>• Disconnect cleanly with **Esc**. |
| **M2** – Leaderboard Service | `src/network/LeaderboardService.gd` (host only)<br>`brainlift/resources` → `leaderboard.json` | • Launch host, file auto-created with empty list.<br>• Manually call `LeaderboardService._debug_add_fake_scores()` in debug — list broadcasts to clients.<br>• Clients receive `leaderboard_update` signal. |
| **M3** – Score Submission Hook | `src/autoloads/CollectionManager.gd` (emit `level_finished`)<br>`src/ui/menus/EndScreen.gd` (call `NetworkManager.submit_score`) | • Finish a level on host: leaderboard shows your score.<br>• Finish on client: host JSON updates, broadcast reflects new order.<br>• Restart session → scores persisted. |
| **M4** – UI Component | `scenes/ui/components/LeaderboardPanel.tscn` + `.gd` (new) | • Panel displays 10 rows (name, points).<br>• Live update when new entry arrives.<br>• Handles fewer than 10 gracefully. |
| **M5** – Lobby Scene | `scenes/ui/menus/MultiplayerLobby.tscn` + script | • Enter name, choose Host/Join.<br>• Prevent empty/duplicate name (client refuses connect). |
| **M6** – End-to-End Burn Test | – | • Run 3 clients + host, complete level simultaneously.<br>• No crashes, scores ordered correctly, JSON matches UI.<br>• Close host → clients drop to title menu without errors. |

---

## 4 — File & Autoload Inventory

1. **NEW** `src/network/NetworkManager.gd` → Autoload “NetworkManager”.  
2. **NEW** `src/network/LeaderboardService.gd` (autoload **host-only**).  
3. **MOD** `project.godot` → add autoloads.  
4. **NEW** `scenes/ui/components/LeaderboardPanel.tscn` + `.gd`.  
5. **NEW** `scenes/ui/menus/MultiplayerLobby.tscn` + `.gd`.  
6. **MOD** `CollectionManager.gd` → emit `level_finished` signal.  
7. **MOD** `EndScreen.gd` → on ready, call `NetworkManager.submit_score`.

---

## 5 — Timeline Estimate

| Day | Deliverable |
|-----|-------------|
| 1   | M1 + M2 complete. |
| 2   | M3 hooked; basic JSON persistence proven. |
| 3   | M4 UI done; burn test with 2 windows. |
| 4   | M5 Lobby polish, full verification checklist run. |
| 5   | Buffer / bug-fix / docs update. |

*Narrow feature set helps keep this < 1 work-week.*

---

## 6 — Rollback / Safety

*Every milestone ends with “all tests green”.*  
If a regression appears, revert the last milestone branch; previous gameplay remains intact because core game files (Echo, physics, etc.) are untouched.

---

## 7 — Open “Nice-to-Have” Items (not blocking)

*— Host migration on quit*  
*— Name colour/avatar selection*  
*— Distinct per-level top-10 tables*  
*— Remote-exec admin commands (“kick”, “clear leaderboard”)*

---

_Last updated: {{DATE}}_  
_Contact: **@you** for design questions._ 