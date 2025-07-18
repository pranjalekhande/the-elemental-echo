#!/bin/bash

# The Elemental Echo - Debugging Session Script
# This script demonstrates how to run and debug the game using terminal commands

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== The Elemental Echo Debugging Session ===${NC}"
echo

# Check if GODOT_PATH is set
if [ -z "$GODOT_PATH" ]; then
    echo -e "${YELLOW}Warning: GODOT_PATH not set${NC}"
    echo "Please set it with: export GODOT_PATH=/path/to/your/Godot"
    echo "Example: export GODOT_PATH='/Applications/Godot.app/Contents/MacOS/Godot'"
    echo
else
    echo -e "${GREEN}GODOT_PATH is set to: $GODOT_PATH${NC}"
    echo
fi

# Function to run project in debug mode
run_debug() {
    echo -e "${BLUE}Starting game in debug mode...${NC}"
    if [ -n "$GODOT_PATH" ]; then
        "$GODOT_PATH" --path . --debug --verbose scenes/ui/menus/StartMenu.tscn
    else
        echo -e "${RED}Please set GODOT_PATH first${NC}"
    fi
}

# Function to run headless for testing
run_headless() {
    echo -e "${BLUE}Running headless test...${NC}"
    if [ -n "$GODOT_PATH" ]; then
        "$GODOT_PATH" --path . --headless --script test_startup.gd
    else
        echo -e "${RED}Please set GODOT_PATH first${NC}"
    fi
}

# Function to check project for errors
check_project() {
    echo -e "${BLUE}Checking project for errors...${NC}"
    if [ -n "$GODOT_PATH" ]; then
        "$GODOT_PATH" --path . --check-only
    else
        echo -e "${RED}Please set GODOT_PATH first${NC}"
    fi
}

# Function to show project info
show_info() {
    echo -e "${BLUE}Project Information:${NC}"
    echo "Project Name: The Elemental Echo"
    echo "Main Scene: scenes/ui/menus/StartMenu.tscn"
    echo "Key Scripts:"
    echo "  - src/entities/player/Echo.gd (Player controller)"
    echo "  - src/levels/Level2.gd (Level management)"
    echo "  - src/network/NetworkManager.gd (Multiplayer)"
    echo "  - src/autoloads/ (Global managers)"
    echo
}

# Function to monitor output
monitor_output() {
    echo -e "${BLUE}To monitor debug output with MCP server:${NC}"
    echo "1. Use Cursor's MCP 'run_project' tool"
    echo "2. Call 'get_debug_output' periodically"
    echo "3. Use 'stop_project' when done"
    echo
}

# Main menu
while true; do
    echo -e "${GREEN}=== Debug Options ===${NC}"
    echo "1. Show project info"
    echo "2. Check project for errors"
    echo "3. Run in debug mode"
    echo "4. Run headless test"
    echo "5. Monitor with MCP server"
    echo "6. Set GODOT_PATH"
    echo "7. Exit"
    echo
    read -p "Choose an option (1-7): " choice

    case $choice in
        1)
            show_info
            ;;
        2)
            check_project
            ;;
        3)
            run_debug
            ;;
        4)
            run_headless
            ;;
        5)
            monitor_output
            ;;
        6)
            read -p "Enter path to Godot executable: " godot_path
            export GODOT_PATH="$godot_path"
            echo -e "${GREEN}GODOT_PATH set to: $GODOT_PATH${NC}"
            echo "To make this permanent, add this to your ~/.zshrc or ~/.bash_profile:"
            echo "export GODOT_PATH=\"$GODOT_PATH\""
            ;;
        7)
            echo -e "${BLUE}Goodbye!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose 1-7.${NC}"
            ;;
    esac
    echo
done 