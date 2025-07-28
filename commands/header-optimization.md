Systematically add file header documentation to all source files in this repository following the CLAUDE.md specification. Use `ADD_HEADER_TODO.md` for comprehensive task tracking.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

## Task Management

1. Create `ADD_HEADER_TODO.md` to track all files needing headers
2. For each file, think through its purpose before writing the header
3. Mark tasks as completed in the todo file as you progress

## Header Format

```
/**
 * @fileoverview JWT auth service with token management
 * @lastmodified 2024-01-15T10:30:00Z
 * 
 * Features: JWT creation/verification, password hashing, token blacklisting
 * Main APIs: authenticate(), refreshToken(), revokeToken()
 * Constraints: Requires JWT_SECRET + REDIS_URL, 5 attempts/15min limit
 * Patterns: All throw AuthError, 24h token + 7d refresh expiry
 */
```

## Header Timestamp Management

Before processing each file, check if the header needs updating:

1. **Extract header timestamp**: Parse the `@lastmodified` field from existing headers
2. **Get git last modified**: Use `git log -1 --format="%ai" -- <filepath>` to get file's last commit date
3. **Compare dates**: If git date is newer than header timestamp, the header needs updating
4. **Update process**: When updating headers, set `@lastmodified` to current ISO timestamp

Example check command:
```bash
# Get file's last git modification
git log -1 --format="%ai" -- src/auth.js

# Compare with header @lastmodified timestamp
# If git date > header date, update header
```

## Implementation Logic

For each file, follow this decision flow:

```bash
# 1. Check if file has existing header
if grep -q "@fileoverview" "$file"; then
    # Extract existing timestamp
    existing_timestamp=$(grep "@lastmodified" "$file" | sed 's/.*@lastmodified //; s/ \*\///')
    
    # Get git last modified date
    git_timestamp=$(git log -1 --format="%ai" -- "$file")
    
    # Convert to comparable format and compare
    if [[ "$git_timestamp" > "$existing_timestamp" ]]; then
        echo "NEEDS UPDATE: $file (git: $git_timestamp, header: $existing_timestamp)"
        # Update header with new timestamp
    else
        echo "SKIP: $file (header up to date)"
        # Skip this file
    fi
else
    echo "NEEDS HEADER: $file (no existing header found)"
    # Add new header with current timestamp
fi
```

## Update Decision Matrix

| Condition | Action | New Timestamp |
|-----------|--------|---------------|
| No header exists | Add full header | Current datetime |
| Header exists, git date > header date | Update header content | Current datetime |
| Header exists, git date ≤ header date | Skip file | No change |
| File not in git | Add header | Current datetime |

## Timestamp Format

Always use ISO 8601 format for consistency:
```javascript
// Generate current timestamp
const timestamp = new Date().toISOString(); // "2024-01-15T10:30:00.000Z"

// For header use (simplified)
const headerTimestamp = new Date().toISOString().slice(0, 19) + 'Z'; // "2024-01-15T10:30:00Z"
```

## File Type Mapping

- **`.js/.ts/.jsx/.tsx`**: `/** */` JSDoc style
- **`.py`**: `"""` docstring style  
- **`.sh/.bash`**: `# ` comment style
- **`.md`**: HTML comment `<!-- -->`
- **`.json`**: Not applicable (skip)
- **`.css/.scss`**: `/* */` style
- **`.html`**: HTML comment `<!-- -->`

## Process

1. **File Discovery**: Search for all source files excluding `node_modules`, `.git`, `dist`, `build`
2. **Todo Creation**: Create `ADD_HEADER_TODO.md` with all identified files
3. **File Processing**: For each file:
   - Check if existing header timestamp is older than git last modified date
   - Read and analyze the file's purpose and functionality (if header needs update)
   - Think through what belongs in each header section
   - Add/update header as first documentation block (after shebang if present)
   - Set `@lastmodified` to current ISO timestamp
   - Update todo file marking task complete
4. **Guidelines**: Keep headers concise (under 10 lines total)
5. **Focus**: What the file DOES, not HOW it does it

## Priority Order

Process files in this order:

1. **Main entry points** (index.js, main.py, etc.)
2. **Core modules/services**
3. **Components/utilities**
4. **Configuration files**
5. **Scripts and tools**

## Analysis Before Each Header

Before writing each header, think and consider:

- What is this file's primary responsibility?
- What are the key exports/functions users interact with?
- What dependencies or environment requirements exist?
- What patterns or conventions should developers know?

## Execution Steps

1. Start with a comprehensive file scan
2. Create the todo tracking file
3. For each file, check timestamp vs git before processing
4. Process each file thoughtfully, updating timestamps

This enhanced prompt ensures systematic tracking, timestamp management, and thoughtful analysis before adding each header.