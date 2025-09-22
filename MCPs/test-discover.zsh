#!/bin/zsh

scan_dir="."
files=()

while IFS= read -r -d '' file; do
    echo "Found file: $file"
    local basename_file=$(basename "$file")
    local relative_path="${file#$scan_dir/}"
    
    echo "  Basename: $basename_file"
    echo "  Relative: $relative_path"
    
    # Skip installer scripts, test scripts, hidden directories, and node_modules
    if [[ "$basename_file" =~ ^install-.* ]]; then
        echo "  Skipping: install script"
        continue
    fi
    if [[ "$basename_file" =~ ^test-.* ]]; then
        echo "  Skipping: test script"  
        continue
    fi
    if [[ "$file" =~ /\..*/.*\.sh$ ]]; then
        echo "  Skipping: hidden directory"
        continue
    fi
    if [[ "$relative_path" =~ node_modules ]]; then
        echo "  Skipping: node_modules"
        continue
    fi
    if [[ "$relative_path" =~ \.git/ ]]; then
        echo "  Skipping: git directory"
        continue
    fi
    
    # Only include files that exist and are not empty
    if [[ ! -f "$file" ]]; then
        echo "  Skipping: not a file"
        continue
    fi
    if [[ ! -s "$file" ]]; then
        echo "  Skipping: empty file"
        continue
    fi
    
    echo "  Including: $file"
    files+=("$file")
done < <(find "$scan_dir" -maxdepth 3 -name "*.sh" -print0 2>/dev/null)

echo "Total files found: ${#files[@]}"
for file in "${files[@]}"; do
    echo "  -> $file"
done
