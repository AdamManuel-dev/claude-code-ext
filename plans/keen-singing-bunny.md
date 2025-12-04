# Redis Removal Implementation Plan

## Summary

I've created a detailed implementation plan to remove Redis from the entire Tahoma AI project and consolidate to PostgreSQL-only storage.

**Full plan document**: `/Users/adammanuel/Projects/tahoma-ai/REDIS_REMOVAL_IMPLEMENTATION_PLAN.md`

---

## Quick Overview

### Services Affected (5 total)

| Service | Current Redis Usage | Replacement |
|---------|---------------------|-------------|
| **orchestration-service** | JWT tokens, Webhook queue | PostgreSQL + pgmq |
| **CredentialsManager** | TOTP rate limiting | PostgreSQL upsert |
| **Dashboard/azure-functions** | API rate limiting | PostgreSQL upsert |
| **RagService** | Token bucket rate limiting | PostgreSQL upsert |
| **WebAI/backend** | Rate limiting | PostgreSQL upsert |

**Note**: WebSocket rate limiter is already in-memory (no changes needed).

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
- Add Prisma models for `RefreshToken` and `RateLimit`
- Create `PostgresRateLimiter` utility class
- Create token cleanup cron job
- Run Prisma migration

### Phase 2: JWT Token Migration (Week 2-3)
- Replace Redis client with Prisma in `jwt.service.ts`
- Update all token methods (generate, validate, revoke)
- Add mass revocation using single UPDATE query
- Remove Redis imports and initialization

### Phase 3: Rate Limiting Migration (Week 3-4)
- Replace `redisRateLimiter.ts` with PostgreSQL implementation
- Update all services to use PostgreSQL rate limiting
- Maintain backward-compatible exports

### Phase 4: Webhook Queue Migration (Week 4-5)
- Install pgmq PostgreSQL extension
- Replace BullMQ with pgmq-based queue
- Implement polling worker for message processing

### Phase 5: Cleanup (Week 5-6)
- Remove Redis packages from all services
- Delete Redis environment variables
- Delete backup files and unused code

---

## Key Code Changes

### New Files to Create
1. `orchestration-service/src/utils/postgres-rate-limiter.ts`
2. `orchestration-service/src/jobs/token-cleanup.job.ts`

### Files to Modify
1. `orchestration-service/prisma/schema.prisma` - Add RefreshToken and RateLimit models
2. `orchestration-service/src/services/auth/jwt.service.ts` - Replace Redis with Prisma
3. `orchestration-service/src/queue/webhook-queue.ts` - Replace BullMQ with pgmq
4. `CredentialsManager/src/utils/redisRateLimiter.ts` - Replace with PostgreSQL

### Files/Packages to Delete
- Redis packages from all 5 services
- `CredentialsManager/src/storage/redisRateLimitStorage.ts`
- `RagService/src/resilience/storage/redis-adapter.ts`
- All `.bak` and `.old` backup files

---

## Estimated Effort

| Phase | Hours | Duration |
|-------|-------|----------|
| Phase 1: Foundation | 40h | 1-2 weeks |
| Phase 2: JWT Migration | 50h | 2-3 weeks |
| Phase 3: Rate Limiting | 30h | 1 week |
| Phase 4: Webhook Queue | 25h | 1 week |
| Phase 5: Cleanup | 10h | 1 week |
| **Total** | **135-200h** | **6-8 weeks** |

---

## Cost Savings

| Current | After Migration | Monthly Savings |
|---------|-----------------|-----------------|
| PostgreSQL + Redis + MongoDB | PostgreSQL only | **$100-350/month** |

---

## Ready for Implementation?

The full plan with specific code snippets is in:
`/Users/adammanuel/Projects/tahoma-ai/REDIS_REMOVAL_IMPLEMENTATION_PLAN.md`

Approve to proceed with implementation.
