#!/usr/bin/env bash
# diagnose-duplicate-tools.sh
# Collects diagnostics for MCP tool duplication issues.

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="${LOG_FILE:-$HOME/.claude/logs/tool-registration.jsonl}"
CONFIG_FILE="${CONFIG_FILE:-$HOME/.config/claude-code/config.json}"

section() {
  printf '\n=== %s ===\n' "$1"
}

print_header() {
  section "Duplicate MCP Tool Diagnostic"
  printf 'Timestamp : %s\n' "$(date -u '+%Y-%m-%d %H:%M:%SZ')"
  printf 'Log file  : %s\n' "$LOG_FILE"
  printf 'Config    : %s\n' "$CONFIG_FILE"
  printf 'Generated : %s\n' "$(date)"
}

check_processes() {
  section "MCP Server Processes"
  local entries=(
    "stagehand|stagehand/dist/index.js"
    "chatgpt|mcp-chatgpt-agent/dist/index.js"
    "postman|mcp-postman"
    "ios-simulator|ios-simulator"
  )

  for entry in "${entries[@]}"; do
    local name="${entry%%|*}"
    local pattern="${entry#*|}"
    local matches
    matches="$(ps -Ao pid=,command= | grep -F "$pattern" | grep -v grep || true)"
    local count=0
    if [[ -n "$matches" ]]; then
      count="$(printf '%s\n' "$matches" | grep -c . || true)"
    fi
    printf '%-15s : %d\n' "$name" "$count"

    # Warn if multiple instances
    if [[ $count -gt 1 ]]; then
      printf '⚠️  WARNING: Multiple instances of %s detected\n' "$name"
    fi

    if [[ $count -gt 0 ]]; then
      printf '%s\n' "$matches" | while read -r line; do
        local pid="${line%% *}"
        local cmd="${line#* }"
        printf '    PID %-7s %s\n' "$pid" "$cmd"
      done
    fi
  done
}

analyze_logs() {
  section "Tool Registration Log"
  if [[ ! -f "$LOG_FILE" ]]; then
    printf 'Log file not found. Enable ToolRegistrationLogger to populate %s\n' "$LOG_FILE"
    return
  fi

  if [[ ! -s "$LOG_FILE" ]]; then
    printf 'Log file exists but is empty. No registration events recorded yet.\n'
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    printf 'python3 not available. Skipping log analysis.\n'
    return
  fi

  python3 - "$LOG_FILE" <<'PY'
import collections
import json
import sys

path = sys.argv[1]
total = 0
duplicate_entries = 0
tool_stats = collections.defaultdict(
    lambda: {"entries": 0, "phases": collections.Counter(), "sources": collections.Counter()}
)
recent = []

with open(path, "r", encoding="utf-8") as handle:
    for raw in handle:
        raw = raw.strip()
        if not raw:
            continue
        total += 1
        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            continue

        duplicates = data.get("duplicates") or []
        if duplicates:
            duplicate_entries += 1
            for tool in duplicates:
                info = tool_stats[tool]
                info["entries"] += 1
                phase = data.get("phase") or "unknown"
                source = data.get("source") or "unknown"
                info["phases"][phase] += 1
                info["sources"][source] += 1

            recent.append(
                {
                    "timestamp": str(data.get("timestamp") or "unknown"),
                    "phase": str(data.get("phase") or "unknown"),
                    "source": str(data.get("source") or "unknown"),
                    "duplicates": list(duplicates),
                }
            )
            if len(recent) > 5:
                recent.pop(0)

print(f'Log entries           : {total}')
print(f'Entries with duplicates: {duplicate_entries}')

if tool_stats:
    print('Duplicate tool summary:')
    for tool, info in sorted(
        tool_stats.items(), key=lambda item: item[1]["entries"], reverse=True
    ):
        print(f'  - {tool}: {info["entries"]} entries')
        if info["phases"]:
            phase_parts = ", ".join(
                f'{phase}:{count}' for phase, count in info["phases"].most_common()
            )
            print(f'      phases : {phase_parts}')
        if info["sources"]:
            source_parts = ", ".join(
                f'{source}:{count}' for source, count in info["sources"].most_common()
            )
            print(f'      sources: {source_parts}')
else:
    print('No duplicate events recorded.')

if recent:
    print('Most recent duplicate entries:')
    for item in recent:
        tools = ", ".join(item["duplicates"])
        print(
            f'  {item["timestamp"]} | phase={item["phase"]} '
            f'| source={item["source"]} | tools={tools}'
        )
PY
}

check_config() {
  section "Claude Code Configuration"
  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf 'Configuration file not found. Expected at %s\n' "$CONFIG_FILE"
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    printf 'python3 not available. Skipping configuration analysis.\n'
    return
  fi

  python3 - "$CONFIG_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    try:
        config = json.load(handle)
    except json.JSONDecodeError as error:
        print(f'Failed to parse config: {error}')
        sys.exit(0)

servers = config.get("mcpServers") or {}
if not servers:
    print("No MCP servers configured.")
    sys.exit(0)

for name, details in servers.items():
    command = details.get("command") or ""
    args = details.get("args") or []
    safe = "safe" in command
    print(f'{name:15s} : command={command}')
    if args:
        print(f'    args   : {args}')
    print(f'    uses safe wrapper: {"yes" if safe else "no"}')
PY
}

check_mcp_versions() {
  section "MCP SDK Versions"
  local dirs=(
    "/Users/adammanuel/.claude/mcp-chatgpt-agent"
    "/Users/adammanuel/.claude/MCPs/mcp-server-browserbase/stagehand"
  )

  for dir in "${dirs[@]}"; do
    if [[ -d "$dir/node_modules/@modelcontextprotocol" ]]; then
      printf '%s:\n' "$dir"
      if [[ -f "$dir/package.json" ]]; then
        local version
        version=$(grep -A 1 '"@modelcontextprotocol/sdk"' "$dir/package.json" 2>/dev/null | \
                  grep -E '"[0-9]+\.[0-9]+\.[0-9]+"' | \
                  sed 's/.*"\([0-9.]*\)".*/  Version: \1/' || echo "  Version: unknown")
        printf '%s\n' "$version"
      fi
    fi
  done
}

test_mcp_servers() {
  section "Testing MCP Server Responses"

  if ! command -v node >/dev/null 2>&1; then
    printf 'Node.js not found - cannot test MCP servers\n'
    return
  fi

  printf 'Testing ChatGPT MCP server...\n'

  # Create a test script to check tool listing
  cat << 'EOF' > /tmp/test-mcp-tools.js
const { spawn } = require('child_process');

async function testMCPServer(command, args = []) {
    return new Promise((resolve, reject) => {
        const child = spawn(command, args, { stdio: ['pipe', 'pipe', 'pipe'] });
        let stdout = '';
        let stderr = '';

        // Send ListTools request
        const request = JSON.stringify({
            jsonrpc: '2.0',
            method: 'tools/list',
            id: 1
        }) + '\n';

        child.stdin.write(request);

        child.stdout.on('data', (data) => {
            stdout += data.toString();
        });

        child.stderr.on('data', (data) => {
            stderr += data.toString();
        });

        setTimeout(() => {
            child.kill();
            resolve({ stdout, stderr });
        }, 2000);
    });
}

// Test ChatGPT MCP
testMCPServer('node', ['/Users/adammanuel/.claude/mcp-chatgpt-agent/dist/index.js'])
    .then(result => {
        if (result.stdout.includes('invoke-chatgpt')) {
            console.log('ChatGPT MCP: Tools listed successfully');

            // Count occurrences
            const matches = result.stdout.match(/invoke-chatgpt/g) || [];
            if (matches.length > 1) {
                console.log(`WARNING: 'invoke-chatgpt' appears ${matches.length} times in response`);
            }
        } else {
            console.log('ChatGPT MCP: No tools found or server not responding');
        }
    })
    .catch(err => {
        console.log('ChatGPT MCP: Error testing server:', err.message);
    });
EOF

  node /tmp/test-mcp-tools.js 2>/dev/null || printf 'Unable to test MCP server responses\n'
  rm -f /tmp/test-mcp-tools.js
}

check_pid_files() {
  section "PID File Check"
  local found_pids=0

  for pidfile in /tmp/mcp-*.pid /var/run/mcp-*.pid; do
    if [[ -f "$pidfile" ]]; then
      found_pids=1
      printf 'Found PID file: %s\n' "$pidfile"
      local pid
      pid=$(cat "$pidfile")
      if ps -p "$pid" > /dev/null 2>&1; then
        printf '  Process %s is running\n' "$pid"
      else
        printf '  ⚠️  Process %s is NOT running (stale PID file)\n' "$pid"
      fi
    fi
  done

  if [[ $found_pids -eq 0 ]]; then
    printf 'No PID files found\n'
  fi
}

summary_and_recommendations() {
  section "Summary & Recommendations"

  local issues_found=0

  # Check for multiple instances
  local instance_count
  instance_count=$(ps -Ao command= | grep -E "(mcp-chatgpt|stagehand)" | grep -v grep | wc -l | tr -d ' ' || echo "0")
  if [[ $instance_count -gt 2 ]]; then
    printf '⚠️  Multiple MCP instances detected - this could cause duplicates\n'
    printf '   Recommendation: Kill duplicate processes and restart\n'
    printf '   Command: /Users/adammanuel/.claude/tools/fix-duplicate-mcp-processes.sh\n'
    issues_found=$((issues_found + 1))
  fi

  # Check for stale PID files
  local has_stale_pids=0
  for pidfile in /tmp/mcp-*.pid; do
    if [[ -f "$pidfile" ]]; then
      local pid
      pid=$(cat "$pidfile")
      if ! ps -p "$pid" > /dev/null 2>&1; then
        has_stale_pids=1
        break
      fi
    fi
  done

  if [[ $has_stale_pids -eq 1 ]]; then
    printf '⚠️  Stale PID files found - may cause startup issues\n'
    printf '   Recommendation: Remove stale PID files\n'
    printf '   Command: rm -f /tmp/mcp-*.pid\n'
    issues_found=$((issues_found + 1))
  fi

  if [[ $issues_found -eq 0 ]]; then
    printf '✅ No obvious duplicate tool issues detected\n\n'
    printf 'If you are still experiencing issues:\n'
    printf '1. Check agent execution logs for "duplicate tool names" errors\n'
    printf '2. Enable verbose logging in MCP servers\n'
    printf '3. Monitor tool registration during agent startup\n'
    printf '4. Review the strategic plan at: /Users/adammanuel/.claude/docs/duplicate-tools-resolution-plan.md\n'
  else
    printf '\n%d issue(s) found. Please follow the recommendations above.\n' "$issues_found"
  fi
}

# Main execution
print_header
check_processes
analyze_logs
check_config
check_mcp_versions
test_mcp_servers
check_pid_files
summary_and_recommendations

printf '\n===================================\n'
printf 'Diagnostics complete.\n'
printf '===================================\n'
