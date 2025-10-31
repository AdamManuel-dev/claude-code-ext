Systematically add file header documentation to all source files in this repository following the CLAUDE.md specification with comprehensive task tracking, **batched git operations**, and **intelligent timestamp management**.

**Agent:** intelligent-documentation

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

<instructions>
You are a Header Optimization Specialist responsible for systematically adding and updating file header documentation across the entire codebase with **90% faster git operations** through intelligent batching.

PRIMARY OBJECTIVE: Implement comprehensive file header documentation following CLAUDE.md specifications with **batched git log operations**, intelligent timestamp management, and real-time progress monitoring via agent.log.
</instructions>

<context>
Codebase requiring systematic header documentation implementation across all source files. Headers must follow specific format with timestamp management, comprehensive tracking, and intelligent update logic based on git modification history.

**Optimization Improvements:**
- **Batched Git Operations**: Single git log call for all files (90% overhead reduction)
- **Parallel Processing**: Process multiple files concurrently when possible
- **Progress Monitoring**: Real-time logging to agent.log for visibility
- **Smart Caching**: Cache git history to avoid repeated subprocess calls
</context>

<contemplation>
File header documentation serves as crucial navigation and understanding tool for developers. The process requires balancing comprehensive documentation with efficiency.

Original approach: Individual `git log -1` call per file = N subprocess calls
Optimized approach: Single batched `git log` call = 1 subprocess call

For 100 files: 99% reduction in git operations overhead.
</contemplation>

<methodology>
**Header Format Specification:**

```javascript
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

**Optimized Timestamp Management with Batched Git Operations:**

```bash
#!/bin/bash

# STEP 1: Single batched git operation for ALL files
# Original: git log -1 --format="%ai" -- <filepath>  # Called N times
# Optimized: Single git log call with all file paths

# Get all source files
files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*")

# BATCH GIT LOG OPERATION (90% faster)
# Creates a lookup table: filepath -> last_modified_timestamp
git log --name-only --all --pretty=format:"%ai %H" -- . > /tmp/git-history-batch.txt

# Parse into associative array for O(1) lookup
declare -A git_timestamps

while IFS= read -r line; do
  if [[ $line =~ ^[0-9]{4}- ]]; then
    # This is a timestamp line
    current_timestamp="$line"
  elif [[ -n $line ]]; then
    # This is a filename line
    git_timestamps["$line"]="$current_timestamp"
  fi
done < /tmp/git-history-batch.txt

# STEP 2: Process each file using cached git data
for file in $files; do
  # Extract existing header timestamp if present
  if grep -q "@fileoverview" "$file"; then
    existing_timestamp=$(grep "@lastmodified" "$file" | sed 's/.*@lastmodified //; s/ \*\///')

    # Lookup git timestamp from cache (O(1) vs subprocess call)
    git_timestamp="${git_timestamps[$file]}"

    # Compare dates
    if [[ "$git_timestamp" > "$existing_timestamp" ]]; then
      echo "NEEDS UPDATE: $file (git: $git_timestamp, header: $existing_timestamp)"
      # Add to processing queue
      echo "$file" >> /tmp/needs-update.txt
    else
      echo "SKIP: $file (header up to date)"
    fi
  else
    echo "NEEDS HEADER: $file (no existing header found)"
    echo "$file" >> /tmp/needs-header.txt
  fi
done

# STEP 3: Process queued files with progress logging
total_files=$(wc -l < /tmp/needs-update.txt /tmp/needs-header.txt)
current=0

for file in $(cat /tmp/needs-update.txt /tmp/needs-header.txt); do
  current=$((current + 1))

  # Log progress to agent.log every 10 files
  if [ $((current % 10)) -eq 0 ]; then
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [header-optimization] [PROGRESS] Files: [$current/$total_files] | Phase: Documentation" >> /Users/adammanuel/.claude/agent.log
  fi

  # Generate/update header
  # ... header generation logic ...
done

# Final completion log
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[$timestamp] [header-optimization] [COMPLETE] Result: $total_files files documented | Duration: ${SECONDS}s" >> /Users/adammanuel/.claude/agent.log
```

**Performance Comparison:**

| Metric | Original | Optimized | Improvement |
|--------|----------|-----------|-------------|
| Git Operations | N calls | 1 call | 90-99% reduction |
| Subprocess Overhead | High | Minimal | ~95% reduction |
| Execution Time (100 files) | ~45s | ~5s | 9x faster |
| Progress Visibility | None | Real-time | Infinite improvement |

**File Type Mapping:**
- **`.js/.ts/.jsx/.tsx`**: `/** */` JSDoc style
- **`.py`**: `"""` docstring style
- **`.sh/.bash`**: `# ` comment style
- **`.md`**: HTML comment `<!-- -->`
- **`.json`**: Not applicable (skip)
- **`.css/.scss`**: `/* */` style
- **`.html`**: HTML comment `<!-- -->`
</methodology>

<phases>
<step name="Discovery & Setup">
**Task Management Setup (Optimized):**
1. Create `ADD_HEADER_TODO.md` to track all files needing headers
2. **File Discovery**: Search for all source files excluding `node_modules`, `.git`, `dist`, `build`
3. **Batched Git Operation**: Single git log call to generate timestamp lookup table
4. **Cache Creation**: Build in-memory lookup table for O(1) timestamp retrieval
5. **Priority Categorization**: Sort files by priority for processing
6. **Progress Logging Init**: Initialize agent.log for real-time monitoring
</step>

<step name="Analysis & Processing">
**For Each File Processing (with cached git data):**
1. Check if existing header timestamp < cached git timestamp (O(1) lookup)
2. Queue files needing updates/additions
3. Read and analyze queued file's purpose and functionality
4. Think through what belongs in each header section:
   - What is this file's primary responsibility?
   - What are the key exports/functions users interact with?
   - What dependencies or environment requirements exist?
   - What patterns or conventions should developers know?
5. Add/update header as first documentation block (after shebang if present)
6. Set `@lastmodified` to current ISO timestamp
7. Update todo file marking task complete
8. Log progress every 10 files to agent.log
</step>

<step name="Quality Assurance">
**Guidelines & Standards:**
- Keep headers concise (under 10 lines total)
- Focus on what the file DOES, not HOW it does it
- Maintain consistent formatting across all files
- Ensure timestamp accuracy and format compliance
- Validate against CLAUDE.md specification
</step>
</phases>

<implementation_plan>
**Optimized Git Batching Implementation:**

```javascript
// Example: Batched git operation in Node.js

const { execSync } = require('child_process');
const fs = require('fs');

// STEP 1: Single batched git log operation
const batchGitLog = (basePath) => {
  const gitLog = execSync(
    `git log --name-only --all --pretty=format:"%ai|||%H" -- "${basePath}"`,
    { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 } // 10MB buffer
  );

  // Parse into lookup table
  const timestamps = new Map();
  const lines = gitLog.split('\n');
  let currentTimestamp = null;

  for (const line of lines) {
    if (line.includes('|||')) {
      // Timestamp line
      currentTimestamp = line.split('|||')[0];
    } else if (line.trim() && currentTimestamp) {
      // Filename line
      timestamps.set(line.trim(), currentTimestamp);
    }
  }

  return timestamps;
};

// STEP 2: Use cached data for all files
const processFiles = async (files, gitTimestamps) => {
  const needsUpdate = [];
  const needsHeader = [];

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const hasHeader = /@fileoverview/.test(content);

    if (hasHeader) {
      const match = content.match(/@lastmodified\s+([^\s*]+)/);
      const existingTimestamp = match ? match[1] : null;
      const gitTimestamp = gitTimestamps.get(file);

      if (gitTimestamp && gitTimestamp > existingTimestamp) {
        needsUpdate.push({ file, gitTimestamp, existingTimestamp });
      }
    } else {
      needsHeader.push(file);
    }
  }

  // Log to agent.log
  const timestamp = new Date().toISOString();
  fs.appendFileSync(
    '/Users/adammanuel/.claude/agent.log',
    `[${timestamp}] [header-optimization] [ANALYSIS] Found ${needsHeader.length} files needing headers, ${needsUpdate.length} needing updates\n`
  );

  return { needsUpdate, needsHeader };
};

// STEP 3: Process with progress monitoring
const processWithProgress = async (fileQueue) => {
  const total = fileQueue.length;
  const agentLog = '/Users/adammanuel/.claude/agent.log';

  for (let i = 0; i < fileQueue.length; i++) {
    const file = fileQueue[i];

    // Generate/update header
    await generateHeader(file);

    // Log progress every 10 files
    if ((i + 1) % 10 === 0 || i === fileQueue.length - 1) {
      const timestamp = new Date().toISOString();
      fs.appendFileSync(
        agentLog,
        `[${timestamp}] [header-optimization] [PROGRESS] Files: [${i + 1}/${total}] | Phase: Documentation\n`
      );
    }
  }

  // Completion log
  const timestamp = new Date().toISOString();
  fs.appendFileSync(
    agentLog,
    `[${timestamp}] [header-optimization] [COMPLETE] Result: ${total} files documented\n`
  );
};

// Main execution
const main = async () => {
  const startTime = Date.now();

  // Single batched git operation
  const gitTimestamps = batchGitLog('.');

  // Discover files
  const files = discoverSourceFiles();

  // Analyze with cached git data
  const { needsUpdate, needsHeader } = await processFiles(files, gitTimestamps);

  // Process queues with progress monitoring
  await processWithProgress([...needsUpdate, ...needsHeader]);

  const duration = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`✅ Completed in ${duration}s`);
};
```

**Update Decision Matrix:**

| Condition | Action | New Timestamp |
|-----------|--------|---------------|
| No header exists | Add full header | Current datetime |
| Header exists, git date > header date | Update header content | Current datetime |
| Header exists, git date ≤ header date | Skip file | No change |
| File not in git | Add header | Current datetime |

**Priority Processing Order:**
1. **Main entry points** (index.js, main.py, etc.)
2. **Core modules/services**
3. **Components/utilities**
4. **Configuration files**
5. **Scripts and tools**
</implementation_plan>

<example>
**Optimized Workflow Execution Example:**

```bash
# Header Optimization Session (Optimized)
🔍 Scanning codebase for source files...
✅ Found 247 source files requiring header analysis

⚡ Batched Git Operations:
- Running single git log for all files...
- ✅ Created timestamp lookup table in 1.2s (vs 45s for 247 individual calls)
- 97% reduction in git subprocess overhead

📊 File Analysis Results:
[02:38:15] [header-optimization] [ANALYSIS] Found 89 files needing headers, 43 needing updates

# Total to process: 132 files
# Skipping: 115 files (headers current)

🚀 Processing with Progress Monitoring:
[02:38:16] [header-optimization] [PROGRESS] Files: [10/132] | Phase: Documentation
[02:38:25] [header-optimization] [PROGRESS] Files: [20/132] | Phase: Documentation
[02:38:34] [header-optimization] [PROGRESS] Files: [30/132] | Phase: Documentation
...
[02:40:12] [header-optimization] [PROGRESS] Files: [130/132] | Phase: Documentation
[02:40:15] [header-optimization] [COMPLETE] Result: 132 files documented

# Summary:
✅ 132 files processed in 2.0 minutes
⚡ Performance: 9x faster git operations (1.2s vs 45s)
📈 Throughput: 66 files/minute
- 89 new headers added
- 43 headers updated
- 115 files skipped (current)
- 100% coverage achieved

# Performance Comparison:
Original approach: ~8 minutes (247 × 2s git calls + processing)
Optimized approach: 2.0 minutes (1.2s batched git + processing)
**Improvement: 4x faster overall, 37x faster git operations**
```
</example>

<thinking>
**Optimization Strategy:**

The key bottleneck in the original implementation was:
```bash
git log -1 --format="%ai" -- <filepath>  # Called 247 times
```

This spawned 247 separate subprocesses, each with:
- Process creation overhead (~5-10ms)
- Git repository initialization
- File history traversal
- Result formatting and return

Total overhead: 247 × ~200ms = ~45 seconds of pure git operations

Optimized approach:
```bash
git log --name-only --all --pretty=format:"%ai|||%H" -- .  # Called once
```

Single subprocess:
- One process creation (~5-10ms)
- One git repository initialization
- One bulk history traversal
- Parse results into in-memory lookup table

Total overhead: ~1.2 seconds

**Result: 37x faster git operations, 4x faster overall**

The in-memory lookup table provides O(1) timestamp retrieval vs O(n) subprocess call per file.
</thinking>

## Final Output:
- Updated source files with CLAUDE.md compliant headers
- ADD_HEADER_TODO.md with comprehensive tracking
- Real-time progress logged to agent.log
- Performance metrics comparing original vs optimized approach
- Validation report ensuring all headers meet standards

## Performance Metrics to Track:
```markdown
# Header Optimization Performance Report

## Execution Metrics
- **Total Files Scanned**: 247
- **Files Needing Headers**: 89
- **Files Needing Updates**: 43
- **Files Skipped (Current)**: 115
- **Total Processed**: 132
- **Execution Time**: 2.0 minutes

## Git Operation Performance
- **Original Approach**: 247 subprocess calls (~45s)
- **Optimized Approach**: 1 batched call (~1.2s)
- **Improvement**: 37x faster (97% reduction)

## Overall Performance
- **Original Total Time**: ~8 minutes
- **Optimized Total Time**: 2.0 minutes
- **Overall Improvement**: 4x faster (75% reduction)
- **Throughput**: 66 files/minute (vs 15 files/minute original)

## Resource Efficiency
- **Subprocess Overhead**: 97% reduction
- **Memory Usage**: Minimal (in-memory lookup table ~50KB)
- **CPU Efficiency**: Single git process vs 247 processes
```
