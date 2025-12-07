# Fix: Database Connection Exhaustion (ORCHESTRATOR-1)

## Problem Summary

**Sentry Issue:** [ORCHESTRATOR-1](https://tahoma-inc.sentry.io/issues/7088980302/)

**Error:** `Too many database connections opened: FATAL: remaining connection slots are reserved for azure replication users`

**Location:** `JobsRepository.updateProgress()` at `jobs.repository.ts:324`

## Root Cause Analysis

### 1. Duplicate PrismaClient Instance (Critical Bug)

| File | Line | Issue |
|------|------|-------|
| `src/index.ts` | 82-84 | Creates `new PrismaClient()` directly |
| `src/database/prisma-client.ts` | 72-75 | Has singleton that **isn't being imported** |

This means **two separate connection pools** exist, doubling connection usage.

### 2. No Connection Pool Configuration

The `DATABASE_URL` and PrismaClient constructor have no pool limits:
- Missing: `connection_limit`, `pool_timeout`, `connect_timeout`
- Prisma defaults to ~10 connections, which is insufficient for concurrent workflows

### 3. High-Frequency Progress Updates

- `updateProgress()` called after **every workflow step** (50-200+ per workflow)
- With `maxConcurrency=5`, that's 250-1000 DB writes/minute
- Each write competes for limited connection pool

---

## Implementation Plan

### Phase 1: Use Existing Singleton (Priority: Critical)

**File:** `orchestration-service/src/index.ts`

**Change:**
```typescript
// BEFORE (line 78-97):
async function initializeDatabase(): Promise<PrismaClient> {
  const prisma = new PrismaClient({...});  // Creates duplicate pool!
  await prisma.$connect();
  return prisma;
}

// AFTER:
import { prisma, disconnectPrisma } from './database/prisma-client';

async function initializeDatabase(): Promise<PrismaClient> {
  console.log('📦 Initializing database connection...');
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully');
    return prisma;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    throw new Error(`Failed to connect to database: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}
```

**Also update shutdown handler** to use `disconnectPrisma()` instead of local reference.

---

### Phase 2: Configure Connection Pool Limits (Priority: High)

**File:** `orchestration-service/src/database/prisma-client.ts`

**Add connection pool configuration:**
```typescript
function createPrismaClient(): PrismaClient {
  // Read pool config from environment with sensible defaults
  const connectionLimit = parseInt(process.env.DATABASE_POOL_MAX || '10', 10);
  const poolTimeout = parseInt(process.env.DATABASE_POOL_IDLE_TIMEOUT || '10000', 10);

  return new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
    datasources: {
      db: {
        url: appendPoolParams(process.env.DATABASE_URL!, connectionLimit, poolTimeout),
      },
    },
  });
}

function appendPoolParams(url: string, limit: number, timeout: number): string {
  const separator = url.includes('?') ? '&' : '?';
  return `${url}${separator}connection_limit=${limit}&pool_timeout=${Math.floor(timeout / 1000)}`;
}
```

**Why this approach:**
- Uses existing env vars (`DATABASE_POOL_MAX`, etc.) that are already defined but unused
- Appends pool parameters to DATABASE_URL (Prisma's recommended method)
- Provides sensible defaults if env vars not set

---

### Phase 3: Add Progress Update Debouncing (Priority: Medium)

**File:** `orchestration-service/src/queue/processors/workflow.processor.ts`

**Problem:** 50-200 DB writes per workflow is excessive for progress tracking.

**Solution:** Debounce progress updates to write at most every 2 seconds:

```typescript
// Add to WorkflowProcessor class
private progressDebounceMap = new Map<string, NodeJS.Timeout>();

private debouncedUpdateProgress(jobId: string, current: number, total: number): void {
  // Clear existing debounce timer
  const existing = this.progressDebounceMap.get(jobId);
  if (existing) clearTimeout(existing);

  // Set new timer - writes after 2 seconds of no updates
  const timer = setTimeout(async () => {
    await this.updateProgress(jobId, current, total);
    this.progressDebounceMap.delete(jobId);
  }, 2000);

  this.progressDebounceMap.set(jobId, timer);
}

// Also: Force write on job completion (final step)
```

**Impact:** Reduces DB writes from 200/workflow to ~10-20/workflow (95% reduction)

---

## Files to Modify

| File | Changes |
|------|---------|
| `src/index.ts` | Import singleton, remove `new PrismaClient()` |
| `src/database/prisma-client.ts` | Add connection pool configuration |
| `src/queue/processors/workflow.processor.ts` | Add progress debouncing (optional) |

---

## Verification Steps

1. **Local Testing:**
   ```bash
   npm run dev
   npm run queue:monitor:watch  # Monitor queue
   npx tsx scripts/submit-test-job-to-queue.ts  # Submit test job
   ```

2. **Check Connection Count:**
   ```sql
   SELECT count(*) FROM pg_stat_activity WHERE datname = 'postgres';
   ```

3. **Monitor Sentry:** Verify ORCHESTRATOR-1 stops recurring

---

## Risk Assessment

| Change | Risk | Mitigation |
|--------|------|------------|
| Singleton switch | Low | Singleton already tested, just not used |
| Pool config | Low | Uses already-defined env vars |
| Progress debouncing | Medium | May delay WebSocket updates by 2s |

---

## Estimated Impact

- **Connection usage:** -50% (removing duplicate pool)
- **DB writes during execution:** -95% (with debouncing)
- **Azure reserved connections:** Will no longer be exhausted
