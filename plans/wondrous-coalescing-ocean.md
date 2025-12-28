# Real-Time Messaging Debug & Fix Plan

## Problem Summary
Dashboard receives no real-time job updates from orchestrator in Azure deployment.

## Root Cause Analysis

### Critical Issues Identified

#### 1. URL Protocol Mismatch (CRITICAL)
**File**: `Dashboard/hooks/useWebSocket.ts:250`
```typescript
// CURRENT (broken):
const url = options?.url || import.meta.env.VITE_WEBSOCKET_URL || "ws://localhost:3001";

// REQUIRED: Socket.io uses http:// or https:// - it handles upgrade internally
const url = options?.url || import.meta.env.VITE_WEBSOCKET_URL || "http://localhost:3001";
```
- Socket.io client expects `http://` or `https://` protocols
- The `ws://` protocol is for native WebSocket, NOT Socket.io
- Socket.io handles the WebSocket upgrade internally via HTTP handshake

#### 2. Missing Authentication Token (CRITICAL)
**File**: `Dashboard/hooks/useWebSocket.ts:254-262`
```typescript
// CURRENT (no auth):
socketInstance = io(url, {
  transports: ["websocket", "polling"],
  reconnection: true,
  // ...
});

// REQUIRED: Must pass auth token
socketInstance = io(url, {
  transports: ["websocket", "polling"],
  auth: {
    token: getAuthToken(), // JWT from Clerk
  },
  // ...
});
```
- Server requires JWT in `socket.handshake.auth.token` (auth-middleware.ts:173)
- Without auth token, connection is rejected with "Authentication token required in auth field"

#### 3. Missing Re-subscription After Reconnect (MEDIUM)
**File**: `Dashboard/hooks/useWebSocket.ts`
- When socket reconnects, room subscriptions are lost
- Client needs to re-subscribe to job rooms after reconnection events

#### 4. Missing Error Handler for Subscription Failures (MEDIUM)
**File**: `Dashboard/hooks/useWebSocket.ts`
- Server emits `error:subscription` for unauthorized access
- Client only listens for `subscribed:job`, missing error feedback

---

## Implementation Plan

### Phase 1: Fix Dashboard WebSocket Connection

#### 1.1 Fix URL Protocol
**File**: `Dashboard/hooks/useWebSocket.ts`

Change default URL from `ws://` to `http://`:
```typescript
const url =
  options?.url ||
  import.meta.env.VITE_WEBSOCKET_URL ||
  "http://localhost:3001"; // Changed from ws://
```

#### 1.2 Add Authentication Token to Socket Connection
**File**: `Dashboard/hooks/useWebSocket.ts`

Add auth context to socket initialization:
```typescript
import { useAuth } from "@clerk/clerk-react"; // Add import

// In getSocket function or useWebSocket hook:
const { getToken } = useAuth();
const token = await getToken();

socketInstance = io(url, {
  transports: ["websocket", "polling"],
  auth: {
    token: token,
  },
  reconnection: true,
  reconnectionAttempts: options?.reconnectionAttempts ?? 10,
  // ... rest of options
});
```

**Alternative**: Create a new hook that wraps auth-aware socket creation since `useAuth()` is a React hook and can't be called in `getSocket()` directly.

#### 1.3 Add Reconnection Re-subscription
**File**: `Dashboard/hooks/useWebSocket.ts`

Add reconnection handler to re-subscribe to active jobs:
```typescript
// In useJobWebSocket or useWebSocket:
useEffect(() => {
  if (!socket) return;

  const handleReconnect = () => {
    // Re-subscribe to current job if any
    if (currentJobIdRef.current) {
      socket.emit("subscribe:job", currentJobIdRef.current);
    }
  };

  socket.io.on("reconnect", handleReconnect);

  return () => {
    socket.io.off("reconnect", handleReconnect);
  };
}, [socket]);
```

#### 1.4 Add Error Subscription Handler
**File**: `Dashboard/hooks/useWebSocket.ts`

Listen for subscription errors:
```typescript
// In useJobWebSocket:
socket.on("error:subscription", (data) => {
  if (data.jobId === jobId) {
    console.error("Subscription error:", data.error);
    setError(data.error);
    setIsSubscribed(false);
  }
});
```

### Phase 2: Verify Server Configuration

#### 2.1 Check WebSocket CORS Origins
**File**: `orchestration-service/src/config/websocket.config.ts`

Ensure Azure dashboard URL is in CORS origins:
- Add Dashboard's Azure URL to `WEBSOCKET_CORS_ORIGINS` env var
- Format: `https://dashboard-prod.azurecontainerapps.io`

#### 2.2 Verify WebSocket Enabled
**File**: Environment variables
- Ensure `WEBSOCKET_ENABLED=true` in Azure Container App config

### Phase 3: Update Environment Variables

#### Dashboard (.env.production or Azure config):
```env
VITE_WEBSOCKET_URL=https://orchestration-api-prod.azurecontainerapps.io
```

#### Orchestration Service (Azure Container App config):
```env
WEBSOCKET_ENABLED=true
WEBSOCKET_CORS_ORIGINS=https://dashboard-prod.azurecontainerapps.io,http://localhost:3000
WEBSOCKET_PATH=/socket.io
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `Dashboard/hooks/useWebSocket.ts` | Fix URL protocol, add auth, reconnection re-subscribe, error handler |
| `Dashboard/.env.production` (or Azure config) | Set `VITE_WEBSOCKET_URL` to https orchestration URL |
| Azure Portal - Orchestration Service | Add Dashboard URL to `WEBSOCKET_CORS_ORIGINS` |

---

## Testing Checklist

1. [ ] Verify WebSocket connects without auth errors (check browser console)
2. [ ] Verify `subscribed:job` event received after subscribing
3. [ ] Start a job execution and verify real-time updates
4. [ ] Test reconnection by temporarily disconnecting network
5. [ ] Verify job room re-subscription after reconnect

---

## Architecture Context

### Message Flow (Fixed)
```
Dashboard                     Orchestrator
   │                              │
   │─── io.connect() ────────────>│  (with auth token)
   │<── "connected" ──────────────│
   │                              │
   │─── subscribe:job ───────────>│
   │<── subscribed:job ───────────│
   │                              │
   │         [Job Execution]      │
   │                              │
   │<── job:event ────────────────│  (job:started, job:progress, etc.)
   │<── job:event ────────────────│
   │<── job:event ────────────────│  (job:completed)
```

### Key Files Reference
- **Dashboard Client**: `Dashboard/hooks/useWebSocket.ts`
- **Orchestrator Server**: `orchestration-service/src/websocket/socket-server.ts`
- **Auth Middleware**: `orchestration-service/src/websocket/auth-middleware.ts`
- **Event Emitter**: `orchestration-service/src/websocket/event-emitter.ts`
- **Workflow Processor**: `orchestration-service/src/queue/processors/workflow.processor.ts`
- **Server Initialization**: `orchestration-service/src/index.ts`
