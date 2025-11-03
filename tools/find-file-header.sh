#!/bin/bash

##
# @fileoverview Find files matching patterns across JavaScript/TypeScript/Markdown files
# @lastmodified 2025-07-28T06:32:44Z
# 
# Features: Multi-extension search, pattern matching, node_modules exclusion, file path display
# Main APIs: find + xargs + grep pipeline for pattern search with file context
# Constraints: Supports JS/TS/JSX/TSX/MD files, excludes node_modules, requires grep/xargs
# Patterns: Directory traversal with exclusions, grep -l for file listing, read loop for output
##

# Find all files with specified extensions and search for a pattern
# Usage: ./find-file-header.sh [directory] [search_pattern]
# Example: ./find-file-header.sh ../some/path "CLI testing"

SEARCH_DIR="${1:-.}"
SEARCH_PATTERN="${2:-CLI testing}"

echo "Searching for '$SEARCH_PATTERN' in $SEARCH_DIR"

find "$SEARCH_DIR" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.md" \) -not -path "*/node_modules/*" | xargs -r grep -l "$SEARCH_PATTERN" | while read -r file; do 
    echo "$file: $(grep "$SEARCH_PATTERN" "$file")"
done