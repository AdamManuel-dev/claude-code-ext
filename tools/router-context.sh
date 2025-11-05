#!/usr/bin/env bash
#
# router-context.sh - Context gathering helper for router skill
#
# @fileoverview Collects git status, diagnostics, and file type information
#   to inform routing decisions. Designed for fast execution and JSON output.
# @lastmodified 2025-11-05T10:23:50Z
#
# Features:
# - Git status parsing (branch, modified files, status)
# - File type detection and counting
# - Diagnostic placeholder (integrate with IDE tools)
# - JSON output for easy parsing
#
# Usage:
#   ./router-context.sh [directory]
#   ./router-context.sh --help

set -euo pipefail

# Colors for output (if not piping to JSON parser)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default directory is current directory
TARGET_DIR="${1:-.}"

# Show help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat <<EOF
router-context.sh - Context gathering for router skill

Usage:
  ./router-context.sh [directory]

Options:
  -h, --help    Show this help message
  directory     Target directory (default: current directory)

Output:
  JSON object with git status, file types, and diagnostics

Example:
  ./router-context.sh
  ./router-context.sh /path/to/project
  ./router-context.sh | jq .

Output Format:
{
  "git": {
    "branch": "main",
    "status": "modified",
    "modified_files": ["src/auth.ts", "src/user.ts"],
    "untracked_files": ["src/new.ts"],
    "is_clean": false
  },
  "file_types": {
    "primary": ["ts", "tsx", "js"],
    "counts": {
      "ts": 45,
      "tsx": 12,
      "js": 8,
      "json": 5
    }
  },
  "diagnostics": {
    "type_errors": 0,
    "lint_warnings": 0,
    "test_failures": 0,
    "files_with_issues": []
  }
}
EOF
    exit 0
fi

# Navigate to target directory
cd "$TARGET_DIR" || {
    echo "Error: Cannot access directory '$TARGET_DIR'" >&2
    exit 1
}

# Initialize JSON output
echo "{"

#
# 1. Git Status
#
echo '  "git": {'

# Get current branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "    \"branch\": \"$BRANCH\","

    # Get git status
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "")

    if [ -z "$GIT_STATUS" ]; then
        echo '    "status": "clean",'
        echo '    "modified_files": [],'
        echo '    "untracked_files": [],'
        echo '    "is_clean": true'
    else
        # Parse modified files (M, MM, etc.)
        MODIFIED_FILES=$(echo "$GIT_STATUS" | grep -E "^[ MARC]M|^M[ MD]" | awk '{print $NF}' | jq -R . | jq -s . || echo "[]")

        # Parse untracked files (??)
        UNTRACKED_FILES=$(echo "$GIT_STATUS" | grep "^??" | awk '{print $2}' | jq -R . | jq -s . || echo "[]")

        echo '    "status": "modified",'
        echo "    \"modified_files\": $MODIFIED_FILES,"
        echo "    \"untracked_files\": $UNTRACKED_FILES,"
        echo '    "is_clean": false'
    fi
else
    echo '    "branch": "not_a_git_repo",'
    echo '    "status": "no_git",'
    echo '    "modified_files": [],'
    echo '    "untracked_files": [],'
    echo '    "is_clean": true'
fi

echo "  },"

#
# 2. File Types
#
echo '  "file_types": {'

# Find all files and count by extension
# Exclude common directories: node_modules, dist, build, .git
FILE_LIST=$(find . -type f \
    ! -path "*/node_modules/*" \
    ! -path "*/dist/*" \
    ! -path "*/build/*" \
    ! -path "*/.git/*" \
    ! -path "*/coverage/*" \
    ! -path "*/.next/*" \
    2>/dev/null || echo "")

if [ -z "$FILE_LIST" ]; then
    echo '    "primary": [],'
    echo '    "counts": {}'
else
    # Count extensions
    EXTENSIONS=$(echo "$FILE_LIST" | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10)

    # Extract top 3 extensions as "primary"
    PRIMARY=$(echo "$EXTENSIONS" | head -3 | awk '{print $2}' | jq -R . | jq -s .)
    echo "    \"primary\": $PRIMARY,"

    # Build counts object
    echo '    "counts": {'
    FIRST=true
    while IFS= read -r line; do
        COUNT=$(echo "$line" | awk '{print $1}')
        EXT=$(echo "$line" | awk '{print $2}')

        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo ","
        fi

        echo -n "      \"$EXT\": $COUNT"
    done <<< "$EXTENSIONS"
    echo ""
    echo "    }"
fi

echo "  },"

#
# 3. Diagnostics (placeholder for IDE integration)
#
echo '  "diagnostics": {'
echo '    "type_errors": 0,'
echo '    "lint_warnings": 0,'
echo '    "test_failures": 0,'
echo '    "files_with_issues": [],'
echo '    "note": "Integrate with IDE diagnostics API or tsc/eslint output"'
echo "  }"

# Close JSON
echo "}"
