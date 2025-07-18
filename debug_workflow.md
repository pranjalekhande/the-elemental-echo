# The Elemental Echo - Debugging Workflow

## Prerequisites
1. Install Godot: `brew install godot` or download from godotengine.org
2. Set GODOT_PATH if needed: `export GODOT_PATH=/path/to/godot`
3. MCP server is built and configured in .cursor/mcp.json

## Terminal Commands for Development

### 1. Basic Project Running
```bash
# Run the game directly (once Godot is installed)
godot --path . scenes/ui/menus/StartMenu.tscn

# Run in debug mode with verbose output
godot --path . --debug --verbose scenes/ui/menus/StartMenu.tscn

# Run headless (for testing without GUI)
godot --path . --headless --script test_startup.gd
```

### 2. Export and Build Commands
```bash
# Export for different platforms
godot --path . --export-debug "macOS" build/macos/TheElementalEcho.dmg
godot --path . --export-release "macOS" build/macos/TheElementalEcho.dmg

# Check project for errors
godot --path . --check-only
```

## MCP Server Debugging Tools

Your custom MCP server provides these debugging capabilities:

### 1. Project Management
- **get_project_info**: Get project metadata and structure
- **list_projects**: Find all Godot projects in directories
- **get_godot_version**: Check Godot installation

### 2. Runtime Debugging
- **run_project**: Start project with debug capture
- **get_debug_output**: Retrieve all stdout/stderr output
- **stop_project**: Stop running instance

### 3. Scene Development
- **launch_editor**: Open Godot editor for the project
- **create_scene**: Create new scene files programmatically
- **add_node**: Add nodes to existing scenes
- **load_sprite**: Load and configure sprite resources

## Debugging Session Example

1. **Start Debug Session**: Use MCP `run_project` tool
2. **Monitor Output**: Continuously call `get_debug_output`
3. **Analyze Issues**: Parse output for errors/warnings
4. **Stop When Done**: Use `stop_project` tool

## Key Debug Areas for Your Game

### Player Movement (Echo.gd)
- Monitor transform changes
- Check collision detection
- Verify elemental form switching

### Level Management (Level2.gd, MainLevel.gd)
- Scene transitions
- Collectible spawning
- Boundary checking

### Network Integration (NetworkManager.gd)
- Connection status
- Data synchronization
- Error handling

### UI Systems
- Menu navigation
- Score display updates
- Pause functionality

## Performance Monitoring

```bash
# Run with profiler
godot --path . --debug --profile

# Monitor memory usage
godot --path . --debug --verbose | grep -i memory

# Track FPS and performance
godot --path . --debug --verbose | grep -i fps
```

## Common Debug Scenarios

### Scene Loading Issues
1. Use `get_debug_output` to check for resource loading errors
2. Verify scene paths in project.godot
3. Check for missing dependencies

### Script Errors
1. Monitor stderr output for script compilation errors
2. Check autoload registration in project settings
3. Verify signal connections

### Asset Loading Problems
1. Check sprite import settings
2. Verify resource paths are correct
3. Monitor texture loading in debug output

## Integration with Development

The MCP server allows you to:
- Automate testing workflows
- Capture debug output programmatically
- Create custom debugging tools
- Monitor game state in real-time
- Analyze performance metrics

This creates a powerful development environment where you can iterate quickly and debug effectively using both terminal commands and the structured MCP debugging tools. 