# Fix: Jobs API Returns No Data and Is Slow

## Problem Summary
`GET /api/v1/jobs?scope=organization&limit=100&page=1` returns empty results and is slow.

## Root Cause
**OrganizationId Mismatch**: When the user's JWT doesn't contain `org_id`, the auth middleware defaults to `'default-org'`. But jobs are stored with the actual Clerk organizationId, so the query `WHERE organizationId = 'default-org'` returns nothing.

**Code Path:**
```
Request → authenticateRequest middleware → no org_id in JWT → defaults to 'default-org'
       → JobsController.listJobs() → findManyByOrganization('default-org', filters)
       → Query: WHERE organizationId = 'default-org' → 0 results
```

## Files to Modify

1. **`orchestration-service/src/api/middleware/auth.middleware.ts`** (lines 117-123)
   - Issue: Falls back to hardcoded `'default-org'` when JWT lacks org_id

2. **`orchestration-service/src/database/repositories/jobs.repository.ts`** (lines 452-459)
   - Minor: Remove unnecessary `include: { workflow: {...} }` to improve performance

## Implementation Plan

### Step 1: Remove 'default-org' Fallback
**File:** `orchestration-service/src/api/middleware/auth.middleware.ts`

Remove lines 117-133 and replace with a proper error response:

```typescript
// BEFORE (lines 115-133):
if (!organizationId) {
  if (payload.sub) {
    organizationId = 'default-org';  // ← REMOVE THIS
    console.log('[Auth] No org context found, using default-org for user:', payload.sub);
  } else {
    res.status(403).json({...});
    return;
  }
}

// AFTER:
if (!organizationId) {
  res.status(403).json({
    error: 'No organization context',
    code: 'MISSING_ORG_CONTEXT',
    message: 'Organization context required. Provide org_id in JWT token or organizationId in request body/query params.',
  });
  return;
}
```

### Step 2: Require organizationId for scope=organization Requests
**File:** `orchestration-service/src/api/controllers/jobs.controller.ts`

Add validation in `listJobs()` method around line 232:

```typescript
if (scope === 'organization') {
  // Validate organizationId is not the fallback
  if (!organizationId || organizationId === 'default-org') {
    res.status(400).json({
      error: 'Organization ID required',
      code: 'ORG_ID_REQUIRED',
      message: 'scope=organization requires a valid organizationId in JWT or query params',
    });
    return;
  }
  const result = await this.jobsRepo.findManyByOrganization(organizationId, filters);
  // ...
}
```

### Step 3: Improve Query Performance
**File:** `orchestration-service/src/database/repositories/jobs.repository.ts`

Remove unnecessary workflow include in `findManyByOrganization()` (lines 452-459):
```typescript
// BEFORE:
const [jobs, total] = await Promise.all([
  this.prisma.job.findMany({
    where,
    include: {
      workflow: {
        select: { id: true, name: true, organizationId: true },
      },
    },
    // ...
  }),
]);

// AFTER:
const [jobs, total] = await Promise.all([
  this.prisma.job.findMany({
    where,
    // Remove include - organizationId is already denormalized on Job table
    orderBy: { [sortBy]: sortOrder },
    skip,
    take: Math.min(limit, 100),
  }),
]);
```

## Immediate Workaround
User can pass `organizationId` as query parameter:
```
GET /api/v1/jobs?scope=organization&limit=100&page=1&organizationId=org_ACTUAL_ID
```

The auth middleware already supports this (lines 106-113).

## Verification Steps
1. Check what organizationId jobs are stored with:
   ```sql
   SELECT DISTINCT "organizationId" FROM jobs LIMIT 10;
   ```
2. Ensure API request includes the correct organizationId
3. Verify query returns expected results

## Risk Assessment
- **Low Risk**: Changes to query include are safe
- **Medium Risk**: Changing auth fallback behavior could affect other endpoints
- **Mitigation**: Add logging before removing default-org fallback
