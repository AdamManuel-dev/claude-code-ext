#!/bin/bash

# Claude Code Slash Command Manager (ccsm) Installer
# This script installs ccsm and fetches slash commands from GitHub gists
#
# Installation Instructions:
# 1. Save this script to a file: 
#    curl -o install-ccsm.sh https://raw.githubusercontent.com/yourusername/yourrepo/main/install-ccsm.sh
#    OR copy and paste into a new file named install-ccsm.sh
#
# 2. Make the script executable:
#    chmod +x install-ccsm.sh
#
# 3. Run the installer:
#    ./install-ccsm.sh
#
# 4. (Optional) Add ccsm to your PATH for global access:
#    echo 'export PATH="$PATH:/Users/$(whoami)"' >> ~/.zshrc
#    source ~/.zshrc
#
# After installation, you can use:
#   ccsm list              # List installed slash commands
#   ccsm show commit       # View the commit command
#   ccsm install <gist>    # Install new commands from gists
#   ccsm help              # Show all available commands

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current username
USERNAME=$(whoami)

# Define paths
CLAUDE_DIR="/Users/${USERNAME}/.claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
CCSM_PATH="/Users/${USERNAME}/ccsm"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create directories
create_directories() {
    print_status "Creating directories..."
    mkdir -p "${COMMANDS_DIR}"
    print_success "Directories created"
}

# Function to fetch command from gist
fetch_command() {
    local gist_url="$1"
    local command_name="$2"
    local output_file="${COMMANDS_DIR}/${command_name}.md"
    
    print_status "Fetching ${command_name} command from gist..."
    
    # Extract raw URL from gist URL
    # Convert gist.github.com URL to raw githubusercontent.com URL
    local gist_id=$(echo "$gist_url" | grep -oE '[a-f0-9]{32}$')
    local raw_url="https://gist.githubusercontent.com/AdamManuel-dev/${gist_id}/raw/"
    
    if curl -s -L "$raw_url" -o "$output_file"; then
        print_success "Successfully downloaded ${command_name} command"
    else
        print_error "Failed to download ${command_name} command"
        return 1
    fi
}

# Function to create ccsm script
create_ccsm_script() {
    print_status "Creating ccsm script..."
    
    cat > "$CCSM_PATH" << 'EOF'
#!/bin/bash

# Claude Code Slash Command Manager (ccsm)
# Manage Claude Code slash commands

VERSION="1.0.0"
CLAUDE_DIR="/Users/$(whoami)/.claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Print functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Show help
show_help() {
    echo "Claude Code Slash Command Manager (ccsm) v${VERSION}"
    echo ""
    echo "Usage: ccsm [command] [options]"
    echo ""
    echo "Commands:"
    echo "  list              List all installed slash commands"
    echo "  install <url>     Install a slash command from a gist URL"
    echo "  remove <name>     Remove an installed slash command"
    echo "  show <name>       Display the content of a slash command"
    echo "  update <name>     Update a slash command from its source"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  ccsm list"
    echo "  ccsm install https://gist.github.com/user/gist_id"
    echo "  ccsm remove commit"
    echo "  ccsm show commit"
}

# List installed commands
list_commands() {
    print_status "Installed slash commands:"
    echo ""
    
    if [ -d "$COMMANDS_DIR" ] && [ "$(ls -A $COMMANDS_DIR 2>/dev/null)" ]; then
        for file in "$COMMANDS_DIR"/*.md; do
            if [ -f "$file" ]; then
                basename "$file" .md | sed 's/^/  /'
            fi
        done
    else
        print_warning "No slash commands installed"
    fi
}

# Install command from gist, GitHub repo, or clipboard
install_command() {
    local source="$1"
    
    if [ -z "$source" ]; then
        print_error "Please provide a source URL or use 'clipboard' to install from clipboard"
        echo "Usage: ccsm install <url|clipboard>"
        echo "Examples:"
        echo "  ccsm install https://gist.github.com/user/gist_id"
        echo "  ccsm install https://github.com/user/repo/blob/main/commands/commit.md"
        echo "  ccsm install clipboard"
        return 1
    fi
    
    # Check if installing from clipboard
    if [ "$source" = "clipboard" ] || [ "$source" = "clip" ] || [ "$source" = "paste" ]; then
        install_from_clipboard
    elif [[ "$source" =~ github\.com/.*/blob/ ]]; then
        # Handle GitHub repo file
        install_from_github_repo "$source"
    elif [[ "$source" =~ gist\.github\.com ]]; then
        # Handle gist
        install_from_gist "$source"
    else
        print_error "Invalid source. Use a GitHub URL or 'clipboard'"
        return 1
    fi
}

# Install from clipboard
install_from_clipboard() {
    print_status "Installing command from clipboard..."
    
    # Read command name
    echo -n "Enter command name (e.g., 'commit', 'stash'): "
    read -r command_name
    
    if [ -z "$command_name" ]; then
        print_error "Command name cannot be empty"
        return 1
    fi
    
    # Sanitize command name
    command_name=$(echo "$command_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    
    # Create directories if needed
    mkdir -p "$COMMANDS_DIR"
    
    local output_file="${COMMANDS_DIR}/${command_name}.md"
    
    # Check if command already exists
    if [ -f "$output_file" ]; then
        echo -n "Command '${command_name}' already exists. Overwrite? (y/n): "
        read -r response
        if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
            print_warning "Installation cancelled"
            return 1
        fi
    fi
    
    # Get clipboard content
    print_status "Reading from clipboard..."
    
    # Try different clipboard commands depending on OS
    local clipboard_content=""
    if command -v pbpaste &> /dev/null; then
        # macOS
        clipboard_content=$(pbpaste)
    elif command -v xclip &> /dev/null; then
        # Linux with xclip
        clipboard_content=$(xclip -selection clipboard -o)
    elif command -v xsel &> /dev/null; then
        # Linux with xsel
        clipboard_content=$(xsel --clipboard --output)
    else
        print_error "No clipboard utility found. Please install pbpaste (macOS), xclip, or xsel (Linux)"
        return 1
    fi
    
    if [ -z "$clipboard_content" ]; then
        print_error "Clipboard is empty"
        return 1
    fi
    
    # Validate content looks like a command
    if ! echo "$clipboard_content" | grep -q "^#"; then
        print_warning "Content doesn't appear to be a valid command (should start with # header)"
        echo -n "Continue anyway? (y/n): "
        read -r response
        if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
            return 1
        fi
    fi
    
    # Save to file
    echo "$clipboard_content" > "$output_file"
    
    # Store metadata
    echo "# Source: Clipboard" > "${output_file}.meta"
    echo "# Installed: $(date)" >> "${output_file}.meta"
    
    print_success "Successfully installed '${command_name}' command from clipboard"
    
    # Show preview
    echo ""
    echo "Preview of installed command:"
    echo "---"
    head -n 10 "$output_file"
    if [ $(wc -l < "$output_file") -gt 10 ]; then
        echo "..."
        echo "(Full command saved to ${output_file})"
    fi
    echo "---"
}

# Install from GitHub repository file
install_from_github_repo() {
    local repo_url="$1"
    
    # Convert blob URL to raw URL
    # https://github.com/user/repo/blob/main/file.md -> https://raw.githubusercontent.com/user/repo/main/file.md
    local raw_url=$(echo "$repo_url" | sed 's|github\.com|raw.githubusercontent.com|' | sed 's|/blob/|/|')
    
    # Extract filename from URL
    local filename=$(basename "$repo_url")
    
    if [[ ! "$filename" =~ \.md$ ]]; then
        print_error "File must be a .md file"
        return 1
    fi
    
    # Extract command name from filename
    local command_name=$(basename "$filename" .md | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    
    print_status "Installing '${command_name}' command from GitHub repo..."
    
    # Create directories if needed
    mkdir -p "$COMMANDS_DIR"
    
    local output_file="${COMMANDS_DIR}/${command_name}.md"
    
    if curl -s -L "$raw_url" -o "$output_file"; then
        # Check if file was actually downloaded (not 404)
        if [ ! -s "$output_file" ] || grep -q "404: Not Found" "$output_file"; then
            rm -f "$output_file"
            print_error "File not found at the specified URL"
            return 1
        fi
        
        # Store metadata
        echo "# Source: $repo_url" > "${output_file}.meta"
        echo "# Installed: $(date)" >> "${output_file}.meta"
        print_success "Successfully installed '${command_name}' command"
    else
        print_error "Failed to download command"
        return 1
    fi
}

# Install from gist
install_from_gist() {
    local gist_url="$1"
    
    # Extract gist ID and username
    local gist_id=$(echo "$gist_url" | grep -oE '[a-f0-9]{32}

# Remove command
remove_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm remove <command_name>"
        return 1
    fi
    
    local command_file="${COMMANDS_DIR}/${command_name}.md"
    local meta_file="${command_file}.meta"
    
    if [ -f "$command_file" ]; then
        rm -f "$command_file" "$meta_file"
        print_success "Removed '${command_name}' command"
    else
        print_error "Command '${command_name}' not found"
        return 1
    fi
}

# Show command content
show_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm show <command_name>"
        return 1
    fi
    
    local command_file="${COMMANDS_DIR}/${command_name}.md"
    
    if [ -f "$command_file" ]; then
        cat "$command_file"
    else
        print_error "Command '${command_name}' not found"
        return 1
    fi
}

# Update command
update_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm update <command_name>"
        return 1
    fi
    
    local meta_file="${COMMANDS_DIR}/${command_name}.md.meta"
    
    if [ ! -f "$meta_file" ]; then
        print_error "No metadata found for '${command_name}' command"
        return 1
    fi
    
    # Extract source URL from metadata
    local source_url=$(grep "^# Source:" "$meta_file" | cut -d' ' -f3)
    
    if [ -z "$source_url" ]; then
        print_error "No source URL found in metadata"
        return 1
    fi
    
    if [ "$source_url" = "Clipboard" ]; then
        print_error "Cannot update commands installed from clipboard"
        print_status "Please reinstall using 'ccsm install clipboard'"
        return 1
    fi
    
    print_status "Updating '${command_name}' command from ${source_url}..."
    
    # Remove and reinstall
    remove_command "$command_name" > /dev/null 2>&1
    install_command "$source_url"
}

# Main command handler
case "$1" in
    list|ls)
        list_commands
        ;;
    install|add)
        install_command "$2"
        ;;
    remove|rm)
        remove_command "$2"
        ;;
    show|cat)
        show_command "$2"
        ;;
    update|up)
        update_command "$2"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run 'ccsm help' for usage information"
        exit 1
        ;;
esac
EOF

    chmod +x "$CCSM_PATH"
    print_success "ccsm script created"
}

# Main installation process
main() {
    echo "Claude Code Slash Command Manager Installer"
    echo "=========================================="
    echo ""
    
    # Create directories
    create_directories
    
    # Fetch commit command from gist
    fetch_command "https://gist.github.com/AdamManuel-dev/8fbe3d061acc67a26a477ed01853ce78" "commit"
    
    # Create ccsm script
    create_ccsm_script
    
    # Final instructions
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Installed components:"
    echo "  - Claude commands directory: ${COMMANDS_DIR}"
    echo "  - ccsm command: ${CCSM_PATH}"
    echo "  - commit slash command: ${COMMANDS_DIR}/commit.md"
    echo ""
    echo "To use ccsm from anywhere, add it to your PATH:"
    echo "  echo 'export PATH=\"\$PATH:/Users/${USERNAME}\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo ""
    echo "Then you can use:"
    echo "  ccsm list              # List installed commands"
    echo "  ccsm show commit       # View the commit command"
    echo "  ccsm install <gist>    # Install new commands"
    echo "  ccsm help              # Show all available commands"
}

# Run main installation
main)
    local username=$(echo "$gist_url" | sed -n 's|https://gist.github.com/\([^/]*\)/.*|\1|p')
    
    if [ -z "$gist_id" ] || [ -z "$username" ]; then
        print_error "Invalid gist URL format"
        return 1
    fi
    
    # Fetch gist metadata
    local api_url="https://api.github.com/gists/${gist_id}"
    local gist_data=$(curl -s "$api_url")
    
    # Extract filename (first .md file)
    local filename=$(echo "$gist_data" | grep -o '"filename": "[^"]*\.md"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$filename" ]; then
        print_error "No .md file found in gist"
        return 1
    fi
    
    # Extract command name from filename
    local command_name=$(basename "$filename" .md | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    
    print_status "Installing '${command_name}' command from gist..."
    
    # Create directories if needed
    mkdir -p "$COMMANDS_DIR"
    
    # Download the file
    local raw_url="https://gist.githubusercontent.com/${username}/${gist_id}/raw/"
    local output_file="${COMMANDS_DIR}/${command_name}.md"
    
    if curl -s -L "$raw_url" -o "$output_file"; then
        # Store metadata
        echo "# Source: $gist_url" > "${output_file}.meta"
        echo "# Installed: $(date)" >> "${output_file}.meta"
        print_success "Successfully installed '${command_name}' command"
    else
        print_error "Failed to download command"
        return 1
    fi
}

# Remove command
remove_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm remove <command_name>"
        return 1
    fi
    
    local command_file="${COMMANDS_DIR}/${command_name}.md"
    local meta_file="${command_file}.meta"
    
    if [ -f "$command_file" ]; then
        rm -f "$command_file" "$meta_file"
        print_success "Removed '${command_name}' command"
    else
        print_error "Command '${command_name}' not found"
        return 1
    fi
}

# Show command content
show_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm show <command_name>"
        return 1
    fi
    
    local command_file="${COMMANDS_DIR}/${command_name}.md"
    
    if [ -f "$command_file" ]; then
        cat "$command_file"
    else
        print_error "Command '${command_name}' not found"
        return 1
    fi
}

# Update command
update_command() {
    local command_name="$1"
    
    if [ -z "$command_name" ]; then
        print_error "Please provide a command name"
        echo "Usage: ccsm update <command_name>"
        return 1
    fi
    
    local meta_file="${COMMANDS_DIR}/${command_name}.md.meta"
    
    if [ ! -f "$meta_file" ]; then
        print_error "No metadata found for '${command_name}' command"
        return 1
    fi
    
    # Extract source URL from metadata
    local source_url=$(grep "^# Source:" "$meta_file" | cut -d' ' -f3)
    
    if [ -z "$source_url" ]; then
        print_error "No source URL found in metadata"
        return 1
    fi
    
    print_status "Updating '${command_name}' command from ${source_url}..."
    
    # Remove and reinstall
    remove_command "$command_name" > /dev/null 2>&1
    install_command "$source_url"
}

# Main command handler
case "$1" in
    list|ls)
        list_commands
        ;;
    install|add)
        install_command "$2"
        ;;
    remove|rm)
        remove_command "$2"
        ;;
    show|cat)
        show_command "$2"
        ;;
    update|up)
        update_command "$2"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run 'ccsm help' for usage information"
        exit 1
        ;;
esac
EOF

    chmod +x "$CCSM_PATH"
    print_success "ccsm script created"
}

# Main installation process
main() {
    echo "Claude Code Slash Command Manager Installer"
    echo "=========================================="
    echo ""
    
    # Create directories
    create_directories
    
    # Fetch commit command from gist
    fetch_command "https://gist.github.com/AdamManuel-dev/8fbe3d061acc67a26a477ed01853ce78" "commit"
    
    # Create ccsm script
    create_ccsm_script
    
    # Final instructions
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Installed components:"
    echo "  - Claude commands directory: ${COMMANDS_DIR}"
    echo "  - ccsm command: ${CCSM_PATH}"
    echo "  - commit slash command: ${COMMANDS_DIR}/commit.md"
    echo ""
    echo "To use ccsm from anywhere, add it to your PATH:"
    echo "  echo 'export PATH=\"\$PATH:/Users/${USERNAME}\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo ""
    echo "Then you can use:"
    echo "  ccsm list              # List installed commands"
    echo "  ccsm show commit       # View the commit command"
    echo "  ccsm install <gist>    # Install new commands"
    echo "  ccsm help              # Show all available commands"
}

# Run main installation
main