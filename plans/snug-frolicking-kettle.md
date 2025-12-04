# ATLAS UI Refactoring Plan

## Summary

This plan outlines a comprehensive refactoring of the ATLAS interface to consolidate navigation, improve UX, and add consistent dark mode support.

**Main Document:** `/Users/adammanuel/Projects/tahoma-ai/Dashboard/ATLAS_UI_REFACTORING_PLAN.md`

## Key Changes

### 1. Dark Mode Support
- Add dark mode to global Header component
- Ensure Workflows component has dark mode (Executions and Schedules already have it)
- Use Tailwind's `dark:` utility classes consistently

### 2. ATLAS Tab Consolidation
**Current:** Separate pages for Workflows, Executions, Schedules
**New:** All three embedded as tabs within ATLAS

```
ATLAS
├── Claims Tab (existing)
├── Workflows Tab (new - embedded content)
├── Executions Tab (new - embedded component)
└── Schedules Tab (new - embedded component)
```

### 3. Dropdown Filters
**Add:**
- Account dropdown (filter by credential/account)
- Workflow dropdown (filter by workflow ID)

**Remove:**
- Risk Tier dropdown (no longer needed)

**Keep:**
- Client dropdown (existing)
- Status dropdown per tab (update Claims status to align better)

### 4. Routing Updates
**New Routes:**
- `/atlas` → ATLAS with Claims tab (default)
- `/atlas?tab=claims` → Claims tab
- `/atlas?tab=workflows` → Workflows tab
- `/atlas?tab=executions` → Executions tab
- `/atlas?tab=schedules` → Schedules tab

**Backwards Compatibility Redirects:**
- `/workflows` → `/atlas?tab=workflows`
- `/executions` → `/atlas?tab=executions`
- `/schedules` → `/atlas?tab=schedules`
- `/activity` → `/atlas?tab=executions`

## Implementation Phases

### Phase 1: Dark Mode (30 min)
Add dark mode classes to Header component

### Phase 2: Dropdown Changes (2 hours)
- Remove Risk Tier dropdown
- Add Account and Workflow dropdowns
- Update filtering logic

### Phase 3: Tab Consolidation (4-5 hours)
- Extract reusable components (ExecutionsTable, WorkflowsList, SchedulesList)
- Add tab navigation to ATLAS
- Implement URL parameter syncing
- Embed components in tabs

### Phase 4: Routing (30 min)
- Update App.tsx with redirects
- Update Header route mappings

### Phase 5: Dark Mode for Workflows (45 min)
Add dark mode classes to Workflows component

### Phase 6: Component Extraction (5 hours)
Create reusable sub-components for embedding

**Total Effort:** ~20 hours (including testing, documentation, buffer)

## Benefits

✅ **Reduced Navigation Friction** - All workflow-related info in one place
✅ **Better Context** - No page switching required
✅ **Consistent UX** - Unified tab interface
✅ **Improved Theme Support** - Proper dark mode throughout
✅ **Backwards Compatible** - Existing links/bookmarks work

## Risk Mitigation

- **Phased rollout** minimizes risk
- **Backwards compatibility redirects** preserve existing links
- **Component extraction** maintains code quality
- **Thorough testing** at each phase
- **Rollback plan** available if issues arise

## Next Steps

1. ✅ Review comprehensive plan document
2. Create feature branch for development
3. Begin Phase 1 (Dark Mode for Header)
4. Test each phase before proceeding
5. Deploy to staging → production

---

**Full Plan Location:** `/Users/adammanuel/Projects/tahoma-ai/Dashboard/ATLAS_UI_REFACTORING_PLAN.md`

This plan includes:
- Detailed implementation steps with code examples
- Component-by-component changes
- Testing strategy
- Timeline and effort estimates
- Risk assessment
- Open questions and decisions needed
