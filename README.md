# The Elemental Echo

A strategic puzzle-platformer where you play as Echo, a spark of elemental essence mastering form-switching to collect diamonds and restore the world's fading Heartsprings.

## 🎮 Game Overview

**Genre:** Strategic Puzzle-Platformer  
**Engine:** Godot 4.4+  
**Platform:** PC (Windows/macOS/Linux)  
**Development Status:** **MVP Complete** - Fully playable with strategic scoring system  

## 🌟 Core Features

### **Elemental Mastery System**
- **Form Switching:** Instant transformation between Fire and Water forms (Q key)
- **Strategic Collection:** Form-specific diamond collection creates meaningful choices
- **Visual Feedback:** Diamonds brighten/dim based on your current form compatibility

### **Strategic Gameplay**
- **Risk/Reward Decisions:** Choose optimal collection routes for maximum score
- **Performance Scoring:** Speed bonuses, efficiency bonuses, and completion multipliers
- **Replayability:** Multiple strategies for achieving high scores

### **Complete Game Experience**
- **Start Menu:** Atmospheric introduction with cave background
- **Level 1: First Steps** - Clean, beginner-friendly level design
- **End Screen:** Performance-based victory messages and detailed stats
- **Health System:** Visual feedback and Heartspring healing

## 🎯 How to Play

### **Controls**
- **WASD/Arrow Keys:** Move and jump
- **Q:** Switch between Fire and Water forms
- **Goal:** Collect diamonds and reach the Heartspring

### **Strategy**
- **Fire Echo** can only collect **red/orange diamonds**
- **Water Echo** can only collect **blue/cyan diamonds**  
- Plan your route to minimize form switches for efficiency bonuses
- Faster completion times earn speed bonuses

### **Scoring System**
- **Base Points:** 10 points per diamond
- **Speed Bonus:** Up to 500 points for fast completion
- **Efficiency Bonus:** Up to 200 points for minimal form switching
- **Completion Multiplier:** 2x bonus for collecting all diamonds

## 🏗️ Project Structure

```
src/
├── autoloads/          # Singleton systems (CollectionManager)
├── core/               # Shared utilities (ElementalForms, HealthComponent)
├── entities/           # Game objects organized by type
│   ├── player/         # Echo character controller
│   ├── collectibles/   # Diamond collection system
│   ├── obstacles/      # Environmental challenges
│   ├── interactables/  # Buttons, hazards, Heartspring
│   └── environment/    # Level boundaries, text triggers
├── ui/                 # User interface components
│   ├── menus/         # Start/End screens
│   └── components/    # Reusable UI elements
└── levels/             # Level-specific logic

scenes/                 # Godot scene files
├── components/         # Reusable scene components
assets/                 # Game art and audio
docs/                   # Design documents and guides
```

## 🚀 Development Status

### ✅ **Completed Features**
- **Core Gameplay:** Platformer movement with form switching
- **Strategic Systems:** Form-specific diamond collection with scoring
- **Complete Game Flow:** Start Menu → Strategic Level → Performance-based End Screen
- **Level Design:** Professional Level 1 with 4 strategically placed diamonds
- **UI Systems:** Health bars, score tracking, performance feedback
- **Code Organization:** Clean, maintainable codebase following Godot best practices

### 🎯 **Next Phase Goals**
- **Level Expansion:** Additional levels with increasing complexity
- **Enhanced Mechanics:** New elemental obstacles and interactions
- **Audio Implementation:** Background music and sound effects
- **Visual Polish:** Enhanced particles and lighting effects
- **Additional Forms:** Earth and Air elements for deeper strategy

## 🛠️ Technical Implementation

- **Game Engine:** Godot 4.4+
- **Architecture:** Organized MVC pattern with singleton managers
- **Scripting:** GDScript with strict typing and proper documentation
- **Performance:** Optimized for 60 FPS with efficient collision detection
- **Code Quality:** Follows Godot community standards and best practices

## 🎨 Design Philosophy

### **Visual Design**
- **Clean Aesthetics:** Professional cave environment with atmospheric lighting
- **Visual Hierarchy:** Clear distinction between interactive and decorative elements
- **Form Feedback:** Immediate visual response to elemental state changes

### **Game Design**
- **Strategic Depth:** Meaningful choices in collection route optimization
- **Progressive Difficulty:** Level 1 teaches mechanics before complex challenges
- **Player Psychology:** Reward optimization and skill mastery over luck

## 🚀 Getting Started

### **Requirements**
- Godot 4.4+ for development
- Git for version control

### **Running the Game**
1. Clone the repository
2. Open `project.godot` in Godot Engine
3. Press F5 to run the game
4. Enjoy strategic elemental mastery!

### **Development Setup**
1. Follow organized src/ structure for new features
2. Use proper autoloads for singleton systems
3. Maintain scene-script pairing convention
4. Test changes with the complete game flow

## 📈 Performance & Stats

- **Level Completion Time:** 30-120 seconds depending on strategy
- **Optimal Score Routes:** Multiple viable strategies for high scores
- **Replayability Factor:** High - players optimize routes and times
- **Code Maintainability:** Excellent - organized, documented, and tested

## 🤝 Contributing

This project demonstrates professional game development practices:
- **Clean Architecture:** Organized, maintainable codebase
- **Strategic Design:** Meaningful player choices and skill progression  
- **Complete Experience:** Full game flow from start to finish
- **Performance Focus:** Optimized and responsive gameplay

## 📄 License

[To be determined]

---

*"Master the elements, collect with strategy, achieve the perfect score..."* ✨ 