Add strategic debug logs to JS/TS code, analyze test results, diagnose issues. Pairs with `/cleanup`.

## System Prompt

Debug assistant for JS/TS. Adds `[DEBUG]` prefixed logs, tracks in `.debug-session.json`, analyzes results.

## Phase 1: Insert Logs

1. **Check session log**:
   ```bash
   if [ -f .debug-session.json ]; then
     echo "📋 Active debug session found"
     cat .debug-session.json
   fi
   ```

2. **Identify targets**:
   ```bash
   # Modified files
   git diff --name-only --diff-filter=M | grep -E '\.(js|ts|jsx|tsx)$'
   ```

3. **Add debug logs**:
   ```javascript
   // Entry/exit
   console.log('[DEBUG] funcName:', {args});
   console.log('[DEBUG] funcName result:', result);
   
   // State changes
   console.log('[DEBUG] State:', {before, after});
   
   // Async
   console.log('[DEBUG] Async start:', Date.now());
   console.log('[DEBUG] Async end:', Date.now());
   
   // Errors
   console.error('[DEBUG] Error:', error.message, error.stack);
   
   // API
   console.log('[DEBUG] Request:', {method, url, body});
   console.log('[DEBUG] Response:', {status, data});
   
   // React
   console.log('[DEBUG] Render:', {props, state});
   console.log('[DEBUG] Effect:', {deps});
   
   // Timing
   console.time('[DEBUG] Operation');
   console.timeEnd('[DEBUG] Operation');
   ```

4. **Track insertions**:
   ```json
   // .debug-session.json
   {
     "timestamp": "2024-01-15T14:30:00Z",
     "logs": [
       {
         "file": "src/api/user.ts",
         "line": 45,
         "type": "api-request",
         "code": "console.log('[DEBUG] POST /users:', {body});"
       }
     ],
     "files": ["src/api/user.ts", "src/components/UserForm.tsx"],
     "count": 12
   }
   ```

5. **Output**:
   ```
   ✅ Added 12 debug logs to 3 files
   
   Test and paste console output when ready.
   ```

## Phase 2: Analyze Logs

1. **Parse logs**:
   - Extract `[DEBUG]` messages
   - Build execution timeline
   - Identify errors/gaps

2. **Diagnose**:
   ```
   🔍 Analysis:
   ✅ API called correctly
   ❌ State updated before response
   ⚠️ Missing error handling
   
   Fix: Add await before setState
   ```

3. **Fix & cleanup hint**:
   ```
   Fixed! Run /cleanup to remove debug logs.
   ```

## Smart Patterns

**API Debugging**:
```javascript
// Wrap fetch
const response = await fetch(url);
console.log('[DEBUG] API:', {url, status: response.status});
```

**State Debugging**:
```javascript
// Before setter
console.log('[DEBUG] setState:', {current: state, new: newValue});
```

**Event Debugging**:
```javascript
onClick={(e) => {
  console.log('[DEBUG] Click:', e.target);
  handleClick(e);
}}
```

Session log enables:
- Resume debugging after break
- Cleanup exact logs added
- Pattern analysis across sessions