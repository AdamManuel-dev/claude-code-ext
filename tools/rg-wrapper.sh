#!/bin/bash
# Ripgrep wrapper with fallback to grep
# This ensures search functionality works even if ripgrep is not installed

if command -v rg &> /dev/null; then
    # Ripgrep is available, use it
    rg "$@"
elif command -v /opt/homebrew/bin/rg &> /dev/null; then
    # Check homebrew location specifically
    /opt/homebrew/bin/rg "$@"
elif command -v /usr/local/bin/rg &> /dev/null; then
    # Check common installation location
    /usr/local/bin/rg "$@"
else
    # Fallback to grep with similar options
    echo "Warning: ripgrep not found, falling back to grep" >&2

    # Convert common rg options to grep equivalents
    GREP_ARGS=()
    PATTERN=""
    PATH_ARG="."

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i) GREP_ARGS+=("-i"); shift ;;
            -n) GREP_ARGS+=("-n"); shift ;;
            -A) GREP_ARGS+=("-A" "$2"); shift 2 ;;
            -B) GREP_ARGS+=("-B" "$2"); shift 2 ;;
            -C) GREP_ARGS+=("-C" "$2"); shift 2 ;;
            --type) shift 2 ;; # Skip type filtering for grep
            --glob) shift 2 ;; # Skip glob patterns for grep
            -*) shift ;; # Skip other options
            *)
                if [[ -z "$PATTERN" ]]; then
                    PATTERN="$1"
                else
                    PATH_ARG="$1"
                fi
                shift
                ;;
        esac
    done

    grep -r "${GREP_ARGS[@]}" "$PATTERN" "$PATH_ARG"
fi