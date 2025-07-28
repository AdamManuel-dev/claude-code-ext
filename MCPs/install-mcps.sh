#!/bin/zsh

# MCP Auto-Installer for Claude Code CLI
# Automatically discovers and registers .bash/.sh files as MCPs
# Usage: ./install-mcps.sh [OPTIONS] [DIRECTORY]

# set -e # Disabled for now to avoid exit-on-error issues with grep commands

# Configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="${0:A:h}"  # zsh way to get absolute directory of script
DEFAULT_SCAN_DIR="$SCRIPT_DIR"
INSTALL_SCOPE="project"  # project or user
DRY_RUN=false
FORCE_REINSTALL=false
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to show help
show_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                    MCP Auto-Installer                         ║
║           Automatic MCP Registration for Claude CLI          ║
╚═══════════════════════════════════════════════════════════════╝

DESCRIPTION:
    Automatically discovers .bash and .sh files and registers them as 
    Model Context Protocols (MCPs) in Claude Code CLI.

USAGE:
    install-mcps.sh [OPTIONS] [DIRECTORY]

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version information
    --verbose           Enable verbose output
    --dry-run          Show what would be installed without installing
    --user             Install MCPs for user scope (global)
    --project          Install MCPs for project scope (default)
    --force            Force reinstall existing MCPs
    --list-existing    List currently installed MCPs
    --uninstall        Uninstall MCPs instead of installing

ARGUMENTS:
    DIRECTORY          Directory to scan for .bash/.sh files (default: current)

DISCOVERY:
    The script will find files matching these patterns:
    • *.sh files (shell scripts)
    • *.bash files (bash scripts)
    
    Excluded patterns:
    • install-*.sh (installer scripts)
    • test-*.sh (test scripts)
    • .*/*.sh (hidden directories)

NAMING CONVENTION:
    MCPs will be named based on filename:
    • example.sh → "example"
    • my-service.bash → "my-service"
    • claude-memory.sh → "claude-memory"

EXAMPLES:
    # Scan current directory and install as project MCPs
    install-mcps.sh

    # Scan specific directory with verbose output
    install-mcps.sh --verbose ./MCPs

    # Install as user-scoped MCPs (available globally)
    install-mcps.sh --user

    # Dry run to see what would be installed
    install-mcps.sh --dry-run ./scripts

    # Force reinstall all MCPs
    install-mcps.sh --force

    # List existing MCPs
    install-mcps.sh --list-existing

REQUIREMENTS:
    • Claude Code CLI installed and configured
    • Execute permissions on shell scripts
    • Valid shell script syntax

OUTPUT:
    • Detailed installation log
    • Summary of installed/skipped MCPs
    • Error reporting for failed installations

VERSION: 1.0.0
EOF
}

# Function to log with color and timestamp
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "info")
            echo -e "${BLUE}[INFO]${NC} [$timestamp] $message"
            ;;
        "success")
            echo -e "${GREEN}[SUCCESS]${NC} [$timestamp] $message"
            ;;
        "warning")
            echo -e "${YELLOW}[WARNING]${NC} [$timestamp] $message"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} [$timestamp] $message"
            ;;
        "debug")
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${PURPLE}[DEBUG]${NC} [$timestamp] $message"
            fi
            ;;
    esac
}

# Function to validate Claude CLI
validate_claude_cli() {
    if ! command -v claude &> /dev/null; then
        log "error" "Claude CLI not found. Please install Claude Code CLI first."
        echo ""
        echo "Installation instructions:"
        echo "1. Download from: https://claude.ai/download"
        echo "2. Follow the setup instructions"
        echo "3. Run 'claude --version' to verify installation"
        exit 1
    fi
    
    local claude_version=$(claude --version 2>/dev/null || echo "unknown")
    log "info" "Claude CLI found: $claude_version"
}

# Function to list existing MCPs
list_existing_mcps() {
    log "info" "Listing existing MCPs..."
    echo ""
    
    if claude mcp list &> /dev/null; then
        echo "Current MCPs:"
        echo "============="
        claude mcp list
    else
        log "warning" "Unable to list existing MCPs or no MCPs installed"
    fi
}

# Function to discover MCP files
discover_mcp_files() {
    local scan_dir="$1"
    
    # Find .sh and .bash files, excluding common patterns
    find "$scan_dir" -maxdepth 3 \( -name "*.sh" -o -name "*.bash" \) \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -name "install-*" \
        ! -name "test-*" \
        -type f \
        -size +0c 2>/dev/null | while read -r file; do
        
        # Make file executable if needed
        [[ -x "$file" ]] || chmod +x "$file" 2>/dev/null
        
        # Print the file
        echo "$file"
    done
}

# Function to generate MCP name from filename
generate_mcp_name() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local name="${filename%.*}"  # Remove extension
    
    # Clean up name (remove special characters, convert to lowercase)
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    echo "$name"
}

# Function to validate shell script
validate_script() {
    local script_path="$1"
    
    # Check if file exists and is readable
    if [[ ! -f "$script_path" ]] || [[ ! -r "$script_path" ]]; then
        log "error" "Script not found or not readable: $script_path"
        return 1
    fi
    
    # Check shebang
    local shebang=$(head -n 1 "$script_path")
    if [[ ! "$shebang" =~ ^#!.*(bash|sh|zsh) ]]; then
        log "warning" "Script may not have valid shebang: $script_path"
        log "debug" "Shebang: $shebang"
    fi
    
    # Basic syntax check for bash/sh scripts
    if [[ "$script_path" =~ \.(sh|bash)$ ]]; then
        if ! bash -n "$script_path" 2>/dev/null; then
            log "error" "Script has syntax errors: $script_path"
            return 1
        fi
    fi
    
    return 0
}

# Function to check if MCP is already installed
is_mcp_installed() {
    local mcp_name="$1"
    
    local mcp_list_output=$(claude mcp list 2>/dev/null || echo "")
    
    # Check if the output contains the actual MCP list (not the "No MCP servers" message)
    if [[ "$mcp_list_output" == *"No MCP servers configured"* ]] || [[ -z "$mcp_list_output" ]]; then
        return 1
    fi
    
    # Check if our MCP is in the list (format is "name: path")
    if echo "$mcp_list_output" | grep -q "^$mcp_name:" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install single MCP
install_mcp() {
    local script_path="$1"
    local mcp_name="$2"
    local absolute_path="$(cd "$(dirname "$script_path")" && pwd)/$(basename "$script_path")"
    
    log "info" "Installing MCP: $mcp_name"
    log "debug" "Script path: $absolute_path"
    
    # Validate script before installation
    if ! validate_script "$absolute_path"; then
        log "error" "Validation failed for: $script_path"
        return 1
    fi
    
    # Check if already installed
    if is_mcp_installed "$mcp_name"; then
        if [[ "$FORCE_REINSTALL" == "true" ]]; then
            log "warning" "MCP '$mcp_name' already exists, forcing reinstall..."
            claude mcp remove "$mcp_name" 2>/dev/null || true
        else
            log "warning" "MCP '$mcp_name' already exists, skipping (use --force to reinstall)"
            return 0
        fi
    fi
    
    # Build installation command
    local install_cmd="claude mcp add $mcp_name"
    
    # Add scope flag
    if [[ "$INSTALL_SCOPE" == "user" ]]; then
        install_cmd="$install_cmd --user"
    fi
    
    # Add script path
    install_cmd="$install_cmd \"$absolute_path\""
    
    log "debug" "Running: $install_cmd"
    
    # Execute installation
    if eval "$install_cmd" 2>/dev/null; then
        log "success" "Successfully installed MCP: $mcp_name"
        return 0
    else
        log "error" "Failed to install MCP: $mcp_name"
        return 1
    fi
}

# Function to uninstall MCPs
uninstall_mcps() {
    local scan_dir="$1"
    local files=()
    local uninstalled=0
    
    log "info" "Scanning directory: $scan_dir"
    
    # Read files into array
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(discover_mcp_files "$scan_dir")
    
    log "info" "Uninstalling MCPs from discovered files..."
    
    for file in "${files[@]}"; do
        local mcp_name=$(generate_mcp_name "$file")
        
        if is_mcp_installed "$mcp_name"; then
            log "info" "Uninstalling MCP: $mcp_name"
            if claude mcp remove "$mcp_name" 2>/dev/null; then
                log "success" "Successfully uninstalled: $mcp_name"
                ((uninstalled++))
            else
                log "error" "Failed to uninstall: $mcp_name"
            fi
        else
            log "debug" "MCP not installed: $mcp_name"
        fi
    done
    
    log "info" "Uninstalled $uninstalled MCPs"
}

# Function to perform dry run
perform_dry_run() {
    local scan_dir="$1"
    local files=()
    
    log "info" "Scanning directory: $scan_dir"
    
    # Read files into array
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(discover_mcp_files "$scan_dir")
    
    echo ""
    echo "Dry Run - MCP Installation Preview"
    echo "=================================="
    echo ""
    echo "Scan Directory: $scan_dir"
    echo "Install Scope: $INSTALL_SCOPE"
    echo "Force Reinstall: $FORCE_REINSTALL"
    echo ""
    
    [[ "$VERBOSE" == "true" ]] && log "debug" "Found ${#files[@]} files"
    
    if [[ ${#files[@]} -eq 0 ]]; then
        log "warning" "No MCP files found in $scan_dir"
        return 0
    fi
    
    echo "Would install the following MCPs:"
    echo ""
    
    local new_installs=0
    local existing_installs=0
    local invalid_files=0
    
    for file in "${files[@]}"; do
        [[ "$VERBOSE" == "true" ]] && log "debug" "Processing file: $file"
        
        local mcp_name=$(generate_mcp_name "$file")
        [[ "$VERBOSE" == "true" ]] && log "debug" "Generated MCP name: $mcp_name"
        
        local install_status=""
        local color=""
        
        if ! validate_script "$file"; then
            [[ "$VERBOSE" == "true" ]] && log "debug" "Validation failed for: $file"
            install_status="INVALID"
            color="$RED"
            ((invalid_files++))
        elif is_mcp_installed "$mcp_name"; then
            [[ "$VERBOSE" == "true" ]] && log "debug" "MCP already installed: $mcp_name"
            if [[ "$FORCE_REINSTALL" == "true" ]]; then
                install_status="REINSTALL"
                color="$YELLOW"
                ((existing_installs++))
            else
                install_status="EXISTS"
                color="$CYAN"
                ((existing_installs++))
            fi
        else
            [[ "$VERBOSE" == "true" ]] && log "debug" "New MCP: $mcp_name"
            install_status="NEW"
            color="$GREEN"
            ((new_installs++))
        fi
        
        echo -e "${color}[$install_status]${NC} $mcp_name → $file"
    done
    
    echo ""
    echo "Summary:"
    echo "--------"
    echo "Total files found: ${#files[@]}"
    echo "New installations: $new_installs"
    echo "Existing MCPs: $existing_installs"
    echo "Invalid files: $invalid_files"
    echo ""
    echo "Use '$SCRIPT_NAME $scan_dir' to perform actual installation."
}

# Function to install all MCPs
install_all_mcps() {
    local scan_dir="$1"
    local files=()
    local installed=0
    local skipped=0
    local failed=0
    
    log "info" "Scanning directory: $scan_dir"
    
    # Read files into array
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(discover_mcp_files "$scan_dir")
    
    if [[ ${#files[@]} -eq 0 ]]; then
        log "warning" "No MCP files found in $scan_dir"
        return 0
    fi
    
    log "info" "Found ${#files[@]} potential MCP files"
    echo ""
    
    for file in "${files[@]}"; do
        local mcp_name=$(generate_mcp_name "$file")
        
        echo -e "${BLUE}Processing:${NC} $file → $mcp_name"
        
        if install_mcp "$file" "$mcp_name"; then
            ((installed++))
        else
            if is_mcp_installed "$mcp_name" && [[ "$FORCE_REINSTALL" != "true" ]]; then
                ((skipped++))
            else
                ((failed++))
            fi
        fi
        echo ""
    done
    
    # Summary
    echo "Installation Summary:"
    echo "===================="
    echo "Total files processed: ${#files[@]}"
    echo -e "${GREEN}Successfully installed: $installed${NC}"
    echo -e "${YELLOW}Skipped (already exists): $skipped${NC}"
    echo -e "${RED}Failed installations: $failed${NC}"
    
    if [[ $installed -gt 0 ]]; then
        echo ""
        log "success" "Installation complete! Use 'claude mcp list' to verify."
    fi
}

# Parse command line arguments
SCAN_DIR="$DEFAULT_SCAN_DIR"
ACTION="install"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "MCP Auto-Installer v1.0.0"
            echo "Automatic MCP Registration for Claude CLI"
            exit 0
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --user)
            INSTALL_SCOPE="user"
            shift
            ;;
        --project)
            INSTALL_SCOPE="project"
            shift
            ;;
        --force)
            FORCE_REINSTALL=true
            shift
            ;;
        --list-existing)
            ACTION="list"
            shift
            ;;
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        -*)
            log "error" "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            SCAN_DIR="$1"
            shift
            ;;
    esac
done

# Validate scan directory
if [[ ! -d "$SCAN_DIR" ]]; then
    log "error" "Directory not found: $SCAN_DIR"
    exit 1
fi

# Convert to absolute path
SCAN_DIR="$(cd "$SCAN_DIR" && pwd)"

# Main execution
main() {
    echo -e "${NC}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    MCP Auto-Installer                         ║"
    echo "║           Automatic MCP Registration for Claude CLI          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Validate prerequisites
    validate_claude_cli
    
    # Execute based on action
    case $ACTION in
        "list")
            list_existing_mcps
            ;;
        "uninstall")
            uninstall_mcps "$SCAN_DIR"
            ;;
        "install")
            if [[ "$DRY_RUN" == "true" ]]; then
                perform_dry_run "$SCAN_DIR"
            else
                install_all_mcps "$SCAN_DIR"
            fi
            ;;
    esac
}

# Handle Ctrl+C gracefully
cleanup() {
    echo ""
    log "warning" "Installation interrupted by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function only if script is executed directly (not sourced)
if [[ "${(%):-%x}" == "${(%):-%N}" ]] || [[ "$0" == *"install-mcps.sh" ]]; then
    main "$@"
fi 