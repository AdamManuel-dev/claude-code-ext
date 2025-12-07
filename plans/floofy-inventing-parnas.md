# Plan: Consolidate useSocket to WebSocketProvider Pattern

## Summary
Consolidate the standalone `useSocket.ts` hook to use the global `WebSocketProvider` pattern, eliminating duplicate socket connections.

## Current State
- **`useSocket.ts`** creates its own socket instance for `dashboard:update` events
- **`WebSocketProvider`** provides a singleton socket for `job:event` events
- **Only 1 component** uses `useSocket`: `AtlasExecutionsTab.tsx`
- Result: Two separate WebSocket connections to the same server

## Target State
- Single shared socket connection via `WebSocketProvider`
- New `useDashboardUpdates` hook that uses the global socket
- `AtlasExecutionsTab` migrated to use the new hook
- `useSocket.ts` removed entirely (clean codebase)

---

## Implementation Steps

### Step 1: Create `useDashboardUpdates` Hook
**File:** `Dashboard/hooks/useDashboardUpdates.ts`

Create a new hook that:
- Uses `useWebSocketContext()` to get the global socket
- Listens for `dashboard:update` events
- Filters by `organizationId`
- Calls the `onUpdate` callback when matching events arrive

```typescript
export function useDashboardUpdates(
  organizationId: string,
  onUpdate: (update: DashboardUpdateEvent) => void
): { isConnected: boolean }
```

### Step 2: Update AtlasExecutionsTab
**File:** `Dashboard/features/agents/atlas/components/AtlasExecutionsTab.tsx`

Change from:
```typescript
import { useSocket } from "../hooks/useSocket";
const { isConnected } = useSocket({ organizationId, onUpdate: () => refetch() });
```

To:
```typescript
import { useDashboardUpdates } from "@/hooks/useDashboardUpdates";
const { isConnected } = useDashboardUpdates(organizationId, () => refetch());
```

### Step 3: Remove useSocket.ts
**File:** `Dashboard/features/agents/atlas/hooks/useSocket.ts`

Delete this file entirely - it has only one consumer which we're migrating.

### Step 4: Move DashboardUpdateEvent Type
**File:** `Dashboard/types/websocket.types.ts` (new or existing)

Move the `DashboardUpdateEvent` type from atlas-specific types to shared types for reuse.

### Step 5: Update Tests
- Add tests for `useDashboardUpdates` hook
- Update `AtlasExecutionsTab` tests if any mock `useSocket`

---

## Files to Modify

| File | Action |
|------|--------|
| `Dashboard/hooks/useDashboardUpdates.ts` | **CREATE** - New hook |
| `Dashboard/features/agents/atlas/components/AtlasExecutionsTab.tsx` | **MODIFY** - Use new hook |
| `Dashboard/features/agents/atlas/hooks/useSocket.ts` | **DELETE** - Remove entirely |
| `Dashboard/features/agents/atlas/types/execution.types.ts` | **READ** - Get DashboardUpdateEvent type |

---

## Benefits
1. **Single connection** - Reduces server load and client memory
2. **Consistent state** - All components share same connection status
3. **Simpler architecture** - One pattern for all WebSocket usage
4. **Better debugging** - Single socket to monitor in DevTools

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Test `useDashboardUpdates` thoroughly before deleting old hook |
| Different event timing | Verify behavior matches in dev environment |
| Server must emit to same socket | Verify server emits both `job:event` and `dashboard:update` on same connection |

---

## Estimated Scope
- **New code:** ~50 lines (useDashboardUpdates hook)
- **Modified code:** ~10 lines (AtlasExecutionsTab import change)
- **Tests:** ~30 lines (new hook tests)
- **Complexity:** Low - straightforward refactor with single consumer
