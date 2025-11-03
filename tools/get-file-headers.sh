#!/bin/bash

##
# @fileoverview Extract file header documentation from source files
# @lastmodified 2025-07-28T06:08:48Z
# 
# Features: Multi-format header extraction, directory traversal, build folder exclusion
# Main APIs: find + awk pipeline for comment block extraction
# Constraints: Supports JS/TS/MD/TXT files, excludes build/dist/node_modules directories
# Patterns: JSDoc comment detection (/** */), HTML comment detection (<!-- -->), AWK state machine
##

# Extract file header documentation from source files
# Usage: ./get-file-headers.sh [path-to-search]
# Default: searches current directory (.)

find "${1:-.}" -type f \( -name "*.txt" -o -name "*.md" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) \
    -not -path "*/build/*" -not -path "*/build" \
    -not -path "*/dist/*" -not -path "*/dist" \
    -not -path "*/node_modules/*" -not -path "*/node_modules" \
    -exec sh -c '
    echo "File: $1"
    awk "
        /^\/\*\*/ { inComment=1; print; next }
        /^ \*\// && inComment { print; exit }
        /^-->/ && inComment { print; exit }
        /^<!--/ { inComment=1; print; next }  
        inComment { print }
    " "$1"
    echo ""
' _ {} \;