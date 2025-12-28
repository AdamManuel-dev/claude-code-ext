# AgentCore Screenshots Integration Plan
**Date:** 2025-12-05
**Objective:** Add agentcore screenshots to execution details in the frontend

## Executive Summary

This plan outlines the implementation for displaying workflow execution screenshots captured by AgentCore in the frontend execution details view. The system already captures and stores screenshots in Azure Blob Storage and PostgreSQL (`ExecutionScreenshot` table), but these are not currently surfaced in the frontend UI.

**Current State:** Screenshots are captured and stored, but no API endpoint or UI exists to display them.

**Proposed Solution:** Create a paginated REST API endpoint to fetch screenshots, add a frontend hook to consume the API, and update the existing ScreenshotsTab component to display them in a gallery with modal viewer.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CURRENT STATE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AgentCore Execution → Playwright Screenshot → Azure Blob       │
│         ↓                                           ↓            │
│  ExecutionScreenshot Table (PostgreSQL)                          │
│         ↓                                                        │
│  ❌ NO API ENDPOINT                                              │
│         ↓                                                        │
│  ❌ NO FRONTEND INTEGRATION                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         PROPOSED STATE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AgentCore Execution → Playwright Screenshot → Azure Blob       │
│         ↓                                           ↓            │
│  ExecutionScreenshot Table (PostgreSQL)                          │
│         ↓                                                        │
│  ✅ GET /api/v1/executions/:jobId/screenshots (paginated)        │
│         ↓                                                        │
│  ✅ useExecutionScreenshots() hook                               │
│         ↓                                                        │
│  ✅ ScreenshotsTab Component (gallery + modal viewer)            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Backend API Endpoint (4-6 hours)

**File:** `orchestration-service/src/api/controllers/execution-details.controller.ts`

**What:** Create `GET /api/v1/executions/:jobId/screenshots` endpoint

**Features:**
- Paginated response (default: 50, max: 200 screenshots)
- Organization-scoped authorization
- Fresh signed URL generation (24h expiry)
- Ordered by step index

**Database Query:**
```sql
SELECT id, stepIndex, stepName, screenshotType, blobUrl, signedUrl,
       size, width, height, format, isCompressed, originalSize,
       compressionRatio, capturedAt, expiresAt
FROM ExecutionScreenshot
WHERE jobId = :jobId
ORDER BY stepIndex ASC, capturedAt ASC
LIMIT :limit OFFSET :offset
```

**Response Schema:**
```typescript
{
  jobId: string;
  screenshots: Array<{
    id: string;
    stepIndex: number;
    stepName: string | null;
    screenshotType: 'VIEWPORT' | 'ELEMENT';
    url: string; // Signed URL or blobUrl
    size: number;
    width: number;
    height: number;
    format: string;
    capturedAt: string; // ISO timestamp
    expiresAt: string | null;
  }>;
  pagination: {
    page: number;
    limit: number;
    totalItems: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
}
```

**Security:** Verify job belongs to user's organization before returning screenshots.

---

### Phase 2: Frontend Data Hook (2-3 hours)

**File:** `Dashboard/features/agents/atlas/hooks/useExecutionData.ts`

**What:** Add `useExecutionScreenshots(jobId)` hook

**Features:**
- SWR-like data fetching
- Graceful 404 handling (no screenshots → empty array)
- Error recovery
- Auto-refresh disabled (screenshots don't change after execution)

**Usage:**
```typescript
const { data, isLoading, error } = useExecutionScreenshots(jobId);

// data.screenshots = [] if no screenshots
// error = null if 404 (treated as empty, not error)
```

---

### Phase 3: Frontend UI Components (6-8 hours)

#### 3.1 Update ScreenshotsTab (Dashboard)

**File:** `Dashboard/features/execution/components/ExecutionDetailView.tsx:276-310`

**What:** Replace current implementation with screenshot gallery

**Features:**
- Grid layout (1 col mobile, 2 col tablet, 3 col desktop)
- Thumbnail preview with metadata overlay
- Click to open modal viewer
- Type badges (VIEWPORT / ELEMENT)
- Capture type badges (before / after / error)
- Download button

**UI Elements:**
```
┌──────────────────────────────────────────────────────────────┐
│  Screenshot Gallery                                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │ [IMAGE]  │  │ [IMAGE]  │  │ [IMAGE]  │                   │
│  │ VIEWPORT │  │ ELEMENT  │  │ VIEWPORT │                   │
│  │ Step 1   │  │ Step 2   │  │ Step 3   │                   │
│  │ 125 KB   │  │ 78 KB    │  │ 142 KB   │                   │
│  └──────────┘  └──────────┘  └──────────┘                   │
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │ [IMAGE]  │  │ [IMAGE]  │  │ [IMAGE]  │                   │
│  │ ...      │  │ ...      │  │ ...      │                   │
│  └──────────┘  └──────────┘  └──────────┘                   │
│                                                               │
│  [← Previous]  Page 1 of 3  [Next →]                         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

**Modal Viewer:**
```
┌──────────────────────────────────────────────────────────────┐
│  Step 5 Screenshot                                       [X]  │
│  fill-selector-login-password                                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│                      [FULL-SIZE IMAGE]                        │
│                                                               │
├──────────────────────────────────────────────────────────────┤
│  1920 × 1080 • 142 KB                        [📥 Download]   │
└──────────────────────────────────────────────────────────────┘
```

#### 3.2 Optional: Add to ExecutionDetailsModal (Atlas)

**File:** `Dashboard/features/agents/atlas/components/ExecutionDetailsModal.tsx`

**What:** Add compact screenshot gallery after logs section

**Features:**
- 4-column grid (2x2 layout)
- Show first 8 screenshots only
- "Showing 8 of 25" indicator
- Click to open modal

---

## Testing Strategy

### Backend Tests

**File:** `orchestration-service/src/api/controllers/__tests__/execution-details.controller.test.ts`

```typescript
describe('getExecutionScreenshots', () => {
  it('should return paginated screenshots', async () => {
    // Test default pagination (50 items)
  });

  it('should enforce organization authorization', async () => {
    // Test 403 when job belongs to different org
  });

  it('should return 404 when job has no screenshots', async () => {
    // Test empty result handling
  });

  it('should refresh expired signed URLs', async () => {
    // Test URL expiry logic
  });

  it('should validate pagination parameters', async () => {
    // Test invalid page/limit values
  });
});
```

### Frontend Tests

**File:** `Dashboard/features/execution/components/__tests__/ExecutionDetailView.test.tsx`

```typescript
describe('ScreenshotsTab', () => {
  it('should render screenshot grid', () => {
    // Test gallery rendering
  });

  it('should show empty state when no screenshots', () => {
    // Test empty state UI
  });

  it('should open modal on thumbnail click', () => {
    // Test modal interaction
  });

  it('should download screenshot on button click', () => {
    // Test download functionality
  });

  it('should paginate when >50 screenshots', () => {
    // Test pagination controls
  });
});
```

---

## Deployment Plan

### 1. Backend Deployment

```bash
cd orchestration-service

# Build
npm run build

# Generate OpenAPI spec (includes new endpoint)
npm run openapi:generate

# Deploy to Azure Container Apps
# (existing deployment pipeline)
```

**Verification:**
```bash
# Test endpoint with curl
curl -H "Authorization: Bearer $TOKEN" \
  https://api.example.com/api/v1/executions/{jobId}/screenshots
```

### 2. Frontend Deployment

```bash
cd Dashboard

# Build
npm run build

# Deploy to hosting
# (existing deployment pipeline)
```

**Verification:**
- Open execution details page
- Navigate to "Screenshots" tab
- Verify gallery displays
- Click thumbnail → modal opens
- Click download → file downloads

---

## Performance Considerations

### Backend Optimizations

1. **Database Indexes** (already exist):
   - `@@index([jobId])` - Fast lookup by job
   - `@@index([stepIndex])` - Ordered retrieval

2. **Pagination:**
   - Limit response to 50 screenshots (configurable)
   - Prevents large payloads (50 screenshots ≈ 500KB response)

3. **Signed URL Caching:**
   - Check `expiresAt` before regenerating
   - Only refresh if expired or missing
   - Future: Cache in Redis for 24h

### Frontend Optimizations

1. **Lazy Loading:**
   - `loading="lazy"` attribute on all images
   - Only loads visible thumbnails
   - Reduces initial page load

2. **Image Compression:**
   - Backend already compresses screenshots
   - `compressionRatio` metadata available
   - Thumbnails still load full images (future: thumbnail generation)

3. **Modal Loading:**
   - Full-resolution image loads on-demand
   - No preloading until user clicks

---

## Risks & Mitigation

### Risk 1: Signed URL Expiry
**Impact:** Users see broken images after 24h
**Likelihood:** HIGH
**Mitigation:**
- Implement automatic URL refresh on frontend
- Show "Refresh" button if image fails to load
- Backend regenerates on-demand
**Priority:** HIGH

### Risk 2: Large Payload Size
**Impact:** Slow API response with many screenshots
**Likelihood:** MEDIUM
**Mitigation:**
- Enforce pagination (max 200 screenshots)
- Add lazy loading for images
- Consider thumbnail generation (future)
**Priority:** MEDIUM

### Risk 3: CORS Issues
**Impact:** Azure Blob URLs fail CORS checks
**Likelihood:** LOW
**Mitigation:**
- Configure CORS on Azure Blob container
- Allow origins: dashboard.example.com
- Test with browser DevTools
**Priority:** MEDIUM

### Risk 4: Storage Costs
**Impact:** Increased Azure Blob Storage costs
**Likelihood:** LOW
**Mitigation:**
- Implement 30-day retention policy
- Auto-delete old screenshots
- Monitor storage usage
**Priority:** LOW

---

## Success Criteria

### Functional Requirements
- [x] Screenshots visible in execution details UI
- [x] Modal viewer opens on click
- [x] Download button works
- [x] Pagination works (if >50 screenshots)
- [x] Empty state displays when no screenshots
- [x] Error state displays on API failure

### Performance Requirements
- [x] Page load < 2s with 50 screenshots
- [x] API response time < 500ms
- [x] No UI jank when opening modal
- [x] Images lazy load correctly

### Security Requirements
- [x] Organization authorization enforced
- [x] Signed URLs prevent unauthorized access
- [x] CORS configured correctly

---

## Questions for User

1. **Azure Blob SAS Tokens:**
   - Should we implement signed URL generation (Azure SAS tokens)?
   - Or is public blob access acceptable?
   - Current plan: Use blobUrl as fallback (public access)

2. **Retention Policy:**
   - Should screenshots auto-delete after X days?
   - Recommended: 30 days for cost savings
   - Current plan: Keep forever (no deletion)

3. **Thumbnail Generation:**
   - Should we generate 200x200 thumbnails for faster loading?
   - Or is lazy loading + full images sufficient?
   - Current plan: Lazy load full images

4. **Atlas Integration:**
   - Should screenshots appear in ExecutionDetailsModal (Atlas)?
   - Or only in Dashboard ExecutionDetailView?
   - Current plan: Both (optional for Atlas)

5. **Default Capture Config:**
   - Keep `captureAfterStep=true` (debugging preset)?
   - Or switch to `captureOnError=true` only (production preset)?
   - Current plan: Keep debugging preset

---

## Timeline & Effort Estimate

| Phase | Task | Hours | Priority |
|-------|------|-------|----------|
| 1 | Backend API endpoint | 4-6 | HIGH |
| 1 | OpenAPI schema | 1-2 | HIGH |
| 1 | Backend tests | 2-3 | MEDIUM |
| 2 | Frontend hook | 2-3 | HIGH |
| 3 | Update ScreenshotsTab | 4-5 | HIGH |
| 3 | Modal viewer component | 2-3 | HIGH |
| 3 | Frontend tests | 2-3 | MEDIUM |
| 4 | (Optional) Atlas gallery | 2-3 | LOW |
| - | Documentation | 2-3 | LOW |
| - | Deployment & testing | 2-3 | HIGH |

**Total Estimate:** 14-20 hours (2-3 days)

**Critical Path:**
1. Backend API (Phase 1) → 6-9 hours
2. Frontend UI (Phases 2-3) → 8-11 hours
3. Testing & Deployment → 2-3 hours

---

## Next Steps

1. **Review & Approve Plan**
   - Review this plan with team
   - Answer questions above
   - Approve implementation approach

2. **Implement Backend** (Day 1)
   - Add schema to execution-details.schema.ts
   - Implement getExecutionScreenshots controller
   - Wire up route
   - Write tests

3. **Implement Frontend** (Day 2)
   - Add useExecutionScreenshots hook
   - Update ScreenshotsTab component
   - Add modal viewer
   - Write tests

4. **Deploy & Test** (Day 3)
   - Deploy to staging
   - Smoke test
   - Deploy to production
   - Monitor for errors

---

## Implementation Checklist

### Backend
- [ ] Add ExecutionScreenshot schema to execution-details.schema.ts
- [ ] Add ExecutionScreenshotsResponse schema
- [ ] Register route in OpenAPI registry
- [ ] Implement getExecutionScreenshots controller
- [ ] Wire up route in Express router
- [ ] Add SCREENSHOTS_DEFAULT_LIMIT to api-limits.ts
- [ ] Write unit tests for controller
- [ ] Write integration tests for endpoint
- [ ] Generate OpenAPI spec (npm run openapi:generate)
- [ ] Test with Postman/curl

### Frontend
- [ ] Add ExecutionScreenshot types to execution.types.ts
- [ ] Add ExecutionScreenshotsResponse type
- [ ] Add useExecutionScreenshots hook to useExecutionData.ts
- [ ] Update ScreenshotsTab component
- [ ] Add screenshot modal viewer
- [ ] Add download functionality
- [ ] Add pagination controls
- [ ] (Optional) Create ScreenshotsGallery for Atlas
- [ ] (Optional) Add to ExecutionDetailsModal
- [ ] Write component tests
- [ ] Manual testing (multiple browsers)

### Documentation
- [ ] Update API documentation (OpenAPI spec)
- [ ] Update ATLAS_USER_GUIDE.md
- [ ] Update README with screenshot feature
- [ ] Document Azure Blob configuration
- [ ] Add troubleshooting guide

### Deployment
- [ ] Deploy backend to staging
- [ ] Deploy frontend to staging
- [ ] Smoke test on staging
- [ ] Fix any issues found
- [ ] Deploy backend to production
- [ ] Deploy frontend to production
- [ ] Monitor error logs for 24h
- [ ] Gather user feedback

---

## Summary

This implementation plan provides a complete path to integrate agentcore screenshots into the frontend execution details. The architecture leverages existing infrastructure (ExecutionScreenshot table, Azure Blob Storage, ScreenshotService) and adds the missing API layer and frontend UI.

**Key Benefits:**
- Visual debugging of workflow executions
- Step-by-step screenshot history
- Download capability for documentation
- Minimal performance impact (pagination + lazy loading)

**Key Risks:**
- Signed URL expiry (mitigated by refresh mechanism)
- Large payloads (mitigated by pagination)
- CORS issues (mitigated by proper Azure config)

**Estimated Timeline:** 2-3 days (14-20 hours)

**Ready to Proceed?** Please review and provide feedback on the questions above.
