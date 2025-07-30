Remove debug logs from JS/TS code. Uses `.debug-session.json` for precise cleanup or pattern matching.

## System Prompt

Cleanup specialist for JS/TS debug artifacts. Removes `[DEBUG]` logs efficiently.

## Modes

### Default: Session-based cleanup
```bash
if [ -f .debug-session.json ]; then
  # Precise removal using session log
  echo "🎯 Using session log for precise cleanup"
  
  # Parse JSON and remove exact lines
  jq -r '.logs[] | "\(.file):\(.line)"' .debug-session.json | while read location; do
    file=$(echo $location | cut -d: -f1)
    line=$(echo $location | cut -d: -f2)
    sed -i "${line}d" "$file"
  done
  
  # Archive session
  mv .debug-session.json .debug-session-$(date +%s).json
else
  # Fallback to pattern matching
  echo "📍 No session log, using pattern matching"
  find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | \
    grep -v node_modules | \
    xargs sed -i '/\[DEBUG\]/d'
fi
```

### Input: "all" - Remove all console
```bash
find . \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) \
  -not -path "*/node_modules/*" \
  -exec sed -i '/console\./d' {} +
```

### Input: "preview" - Dry run
```bash
echo "Would remove:"
grep -n "\[DEBUG\]" -r . --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" | head -20
```

## Patterns Removed

```bash
# [DEBUG] logs
/\[DEBUG\]/d

# Debug blocks
/\/\* DEBUG START \*\//,/\/\* DEBUG END \*\//d

# Timing
/console\.time.*\[DEBUG\]/d
/console\.timeEnd.*\[DEBUG\]/d

# TODO comments
/\/\/ TODO: remove debug/,+1d

# Debugger
/^[[:space:]]*debugger;/d

# Empty functions after cleanup
/^function.*{[[:space:]]*}$/d
/^const.*=.*{[[:space:]]*}$/d
```

## Report
```
✅ Cleanup complete!

📊 Removed: 12 debug logs
📁 Files: 3 modified
📄 Session archived: .debug-session-1705337400.json

Run 'git diff' to review.
```

## Session Management

**List sessions**:
```bash
ls -la .debug-session*.json
```

**Restore session**:
```bash
cp .debug-session-1705337400.json .debug-session.json
```

**Clean old sessions**:
```bash
find . -name ".debug-session-*.json" -mtime +7 -delete
```

## .gitignore
```
.debug-session.json
.debug-session-*.json
```

Pairs with `/debug` for complete workflow.