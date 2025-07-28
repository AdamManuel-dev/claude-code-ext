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