# ATLAS Agentic Browser Testing Plan with Playwright Skill

## Executive Summary

This plan outlines a comprehensive strategy for testing the new ATLAS tabbed interface using Claude Code's playwright skill for agentic browser automation. Unlike traditional E2E tests (which we've already created), this approach uses intelligent browser automation to **visually validate** the UI, **take screenshots** for documentation, **test real user workflows**, and **catch visual regressions** through actual browser interaction.

### Goals

1. **Visual Validation** - Verify the ATLAS interface looks correct in light/dark modes
2. **User Workflow Testing** - Test real user journeys through agentic browsing
3. **Screenshot Documentation** - Generate visual documentation of all tabs and features
4. **Responsive Design Testing** - Validate mobile/tablet/desktop layouts
5. **Integration Testing** - Test interactions between tabs, filters, and navigation
6. **Regression Detection** - Catch visual bugs that unit tests miss

### Benefits of Agentic Testing

**Traditional E2E (atlas-tabs.spec.ts):**
- ✅ Automated regression testing
- ✅ Fast execution
- ✅ Deterministic results
- ❌ No visual validation
- ❌ Doesn't catch CSS issues
- ❌ Limited to predefined scenarios

**Agentic Browser Testing (playwright skill):**
- ✅ **Visual inspection** with screenshots
- ✅ **Adaptive testing** - AI determines what to test next
- ✅ **Catches CSS/styling issues**
- ✅ **Real browser interaction** (visible browser window)
- ✅ **Documentation generation** (screenshots of all features)
- ✅ **Exploratory testing** - finds issues traditional tests miss
- ❌ Slower execution
- ❌ Requires human review of screenshots

**Strategy:** Use **both approaches** - traditional E2E for regression testing, agentic testing for visual validation and exploration.

---

## Phase 1: Dev Server Management

### Challenge
The ATLAS app requires a running development server on `localhost`. The playwright skill auto-detects running servers, but we need a strategy for ensuring the server is available.

### Solution: Server Detection + Auto-Start

**Step 1: Check for Running Servers**
```bash
cd /Users/adammanuel/.claude/skills/playwright-skill && \
node -e "require('./lib/helpers').detectDevServers().then(s => console.log(JSON.stringify(s, null, 2)))"
```

**Expected Outputs:**

**Scenario A: Server Already Running**
```json
[
  {
    "url": "http://localhost:5173",
    "port": 5173,
    "name": "Vite Dev Server"
  }
]
```
→ **Action:** Use detected server, proceed with testing

**Scenario B: No Server Running**
```json
[]
```
→ **Action:** Start dev server in background, wait for ready, then test

**Scenario C: Multiple Servers**
```json
[
  { "url": "http://localhost:5173", "port": 5173, "name": "Vite Dev Server" },
  { "url": "http://localhost:3000", "port": 3000, "name": "API Server" }
]
```
→ **Action:** Use Vite server (5173), ignore API server

### Server Startup Script

```bash
# Start Vite dev server in background
cd /Users/adammanuel/Projects/tahoma-ai/Dashboard && \
npm run dev > /tmp/atlas-vite-server.log 2>&1 &

# Capture PID for later cleanup
VITE_PID=$!
echo "Vite server started with PID: $VITE_PID"

# Wait for server to be ready (check for "Local:" in logs)
timeout=30
elapsed=0
while [ $elapsed -lt $timeout ]; do
  if grep -q "Local:" /tmp/atlas-vite-server.log 2>/dev/null; then
    echo "✅ Vite server ready!"
    grep "Local:" /tmp/atlas-vite-server.log
    break
  fi
  sleep 1
  elapsed=$((elapsed + 1))
done

# Verify server is responding
curl -s http://localhost:5173 > /dev/null && echo "✅ Server responding" || echo "❌ Server not responding"
```

**Cleanup Script:**
```bash
# Kill Vite server after testing
kill $VITE_PID 2>/dev/null
echo "✅ Vite server stopped (PID: $VITE_PID)"
```

**Strategy Decision:**
- **Option A:** Start server, run all tests, stop server (efficient)
- **Option B:** Check if running, ask user to start if not (manual)
- **Recommendation:** Option A with automatic cleanup

---

## Phase 2: Test Scenario Mapping

### Mapping E2E Tests to Agentic Browser Tasks

Our `atlas-tabs.spec.ts` file has 25+ automated tests. For agentic testing, we'll focus on **visual validation** and **user journey testing** that complements (not duplicates) the automated tests.

### Test Categories

#### Category 1: Visual Validation Tests (Screenshots)

**Purpose:** Generate visual documentation and catch styling issues

| Test # | Scenario | Actions | Screenshots | Validation |
|--------|----------|---------|-------------|------------|
| V1 | Claims tab light mode | Navigate to /atlas, wait for load | claims-light.png | KPI cards visible, filters visible |
| V2 | Claims tab dark mode | Enable dark mode, navigate to /atlas | claims-dark.png | Dark backgrounds, readable text |
| V3 | Workflows tab light mode | Navigate to /atlas?tab=workflows | workflows-light.png | Table visible, gate filter visible |
| V4 | Workflows tab dark mode | Dark mode + workflows tab | workflows-dark.png | Dark table, badge colors correct |
| V5 | Executions tab light mode | Navigate to /atlas?tab=executions | executions-light.png | Status tabs, job table |
| V6 | Executions tab dark mode | Dark mode + executions tab | executions-dark.png | Dark theme consistent |
| V7 | Schedules tab light mode | Navigate to /atlas?tab=schedules | schedules-light.png | Schedule list, create button |
| V8 | Schedules tab dark mode | Dark mode + schedules tab | schedules-dark.png | Dark theme consistent |
| V9 | Global filters expanded | Show all 3 dropdowns with options | filters-expanded.png | Client, Account, Workflow visible |
| V10 | WorkflowDetailModal light | Open workflow detail modal | modal-light.png | All tabs visible, data populated |
| V11 | WorkflowDetailModal dark | Open modal in dark mode | modal-dark.png | Dark modal styling correct |
| V12 | Mobile Claims tab | Set viewport 375x667, claims tab | mobile-claims.png | Responsive layout works |
| V13 | Tablet Workflows tab | Set viewport 768x1024, workflows | tablet-workflows.png | Grid adapts correctly |

**Total: 13 visual validation tests**

#### Category 2: User Journey Tests (Agentic Flows)

**Purpose:** Test realistic user workflows with adaptive decision-making

| Journey # | Scenario | Steps | Expected Outcome | Screenshots |
|-----------|----------|-------|------------------|-------------|
| J1 | Find and review a specific claim | 1. Navigate to Claims<br>2. Select client from dropdown<br>3. Filter by "Ready for Review"<br>4. Click first claim<br>5. Review claim details | Claim detail modal opens with full info | claim-journey.png |
| J2 | Execute a workflow with credentials | 1. Navigate to Workflows tab<br>2. Select account from dropdown<br>3. Click Execute on workflow<br>4. Verify execution starts | Execution button works, job created | workflow-execute.png |
| J3 | Monitor job execution | 1. Navigate to Executions tab<br>2. Click "Running" status tab<br>3. Find running job<br>4. Watch progress bar | Progress bar updates, job details visible | execution-monitor.png |
| J4 | Create a new schedule | 1. Navigate to Schedules tab<br>2. Click "Create Schedule"<br>3. Select workflow<br>4. Set daily time<br>5. Select accounts<br>6. Submit | Schedule created successfully | schedule-create.png |
| J5 | Navigate via sidebar | 1. Click Executions in sidebar<br>2. Verify lands on Executions tab<br>3. Click Schedules in sidebar<br>4. Verify URL updates | Sidebar navigation works, no redirect flash | sidebar-nav.png |
| J6 | Test backwards compat redirect | 1. Navigate to /workflows<br>2. Verify redirect to /atlas?tab=workflows<br>3. Navigate to /executions<br>4. Verify redirect | All old URLs redirect correctly | redirect-test.png |
| J7 | Apply multiple filters | 1. Select client<br>2. Select account<br>3. Select workflow<br>4. Verify filtered results | All filters work together (AND logic) | multi-filter.png |
| J8 | Switch tabs with filters | 1. Apply filters on Claims<br>2. Switch to Workflows<br>3. Verify filters persist | Global filters apply to all tabs | filter-persistence.png |
| J9 | Dark mode toggle workflow | 1. Start in light mode<br>2. Toggle to dark mode<br>3. Switch between tabs<br>4. Verify consistency | All tabs have consistent dark theme | dark-mode-flow.png |

**Total: 9 user journey tests**

#### Category 3: Responsive Design Tests

**Purpose:** Validate layouts across different screen sizes

| Viewport | Width x Height | Tests | Screenshots Per Test |
|----------|----------------|-------|---------------------|
| Desktop 1080p | 1920 x 1080 | All 4 tabs | 4 screenshots |
| Desktop 720p | 1280 x 720 | All 4 tabs | 4 screenshots |
| Tablet Portrait | 768 x 1024 | All 4 tabs | 4 screenshots |
| Tablet Landscape | 1024 x 768 | All 4 tabs | 4 screenshots |
| Mobile iPhone SE | 375 x 667 | All 4 tabs | 4 screenshots |
| Mobile iPhone 12 | 390 x 844 | All 4 tabs | 4 screenshots |
| Mobile Pixel 5 | 393 x 851 | All 4 tabs | 4 screenshots |

**Total: 7 viewports × 4 tabs = 28 responsive screenshots**

#### Category 4: Integration Tests (Complex Workflows)

**Purpose:** Test end-to-end workflows spanning multiple tabs

| Test # | Integration Scenario | Steps | Validation |
|--------|---------------------|-------|------------|
| I1 | Claim submission to execution | 1. Submit claim in Claims tab<br>2. Switch to Executions tab<br>3. Find execution job<br>4. Monitor until complete | Job appears, progress tracked |
| I2 | Workflow to schedule | 1. View workflow in Workflows tab<br>2. Switch to Schedules<br>3. Create schedule for that workflow | Schedule created with correct workflow |
| I3 | Filter across all tabs | 1. Select workflow filter<br>2. Visit Claims tab<br>3. Visit Workflows tab<br>4. Visit Executions tab<br>5. Visit Schedules tab | All tabs show only filtered workflow's data |

**Total: 3 integration tests**

### Grand Total Test Coverage

- Visual Validation: 13 tests
- User Journeys: 9 tests
- Responsive Design: 28 screenshots (7 viewports)
- Integration: 3 tests
- **Total: 53 test scenarios**
- **Total Screenshots: 70+ screenshots**

---

## Phase 3: Test Execution Plan

### Execution Order

**Step 1: Server Preparation (5 minutes)**
1. Detect running dev servers
2. Start Vite dev server if needed
3. Wait for server ready signal
4. Verify server responds to requests

**Step 2: Visual Validation Tests (15 minutes)**
1. Run all 13 visual validation tests
2. Generate 13 screenshots
3. Review screenshots for visual issues
4. Document any CSS bugs found

**Step 3: User Journey Tests (25 minutes)**
1. Run all 9 user journey tests
2. Generate 9 screenshots
3. Validate user flows work correctly
4. Document any UX issues

**Step 4: Responsive Design Tests (20 minutes)**
1. Run all 7 viewports × 4 tabs
2. Generate 28 screenshots
3. Review responsive layouts
4. Document breakpoint issues

**Step 5: Integration Tests (15 minutes)**
1. Run 3 integration tests
2. Generate screenshots of key moments
3. Validate cross-tab interactions
4. Document integration issues

**Step 6: Server Cleanup (1 minute)**
1. Stop Vite dev server
2. Archive test logs
3. Organize screenshots

**Total Execution Time: ~80 minutes (1.3 hours)**

---

## Phase 4: Playwright Skill Invocation Strategy

### Pattern: Skill Invocation with Custom Scripts

For each test category, we'll use the playwright skill by:

1. **Invoking the skill**
   ```
   Use playwright-skill
   ```

2. **Providing test instructions** in natural language
   ```
   Test the ATLAS Claims tab:
   - Navigate to http://localhost:5173/#/atlas
   - Wait for page load
   - Take screenshot of Claims tab in light mode
   - Enable dark mode (emulateMedia colorScheme: dark)
   - Take screenshot of Claims tab in dark mode
   - Save screenshots to /tmp/atlas-claims-*.png
   ```

3. **Skill generates custom Playwright script** in `/tmp/playwright-test-*.js`

4. **Skill executes script** via `node run.js`

5. **Review results** - Screenshots saved to /tmp, console output shows results

### Test Script Template

Each agentic test will follow this structure:

```javascript
// /tmp/playwright-test-atlas-[scenario].js
const { chromium } = require('playwright');
const helpers = require('/Users/adammanuel/.claude/skills/playwright-skill/lib/helpers');

const TARGET_URL = 'http://localhost:5173'; // Auto-detected

(async () => {
  const browser = await chromium.launch({
    headless: false,  // Visible browser for debugging
    slowMo: 100       // Slow down actions for visibility
  });

  const page = await browser.newPage();

  try {
    // Test scenario implementation
    console.log('🧪 Testing: [Scenario Name]');

    await page.goto(`${TARGET_URL}/#/atlas`);
    await page.waitForSelector('header', { timeout: 10000 });
    await page.waitForTimeout(1000); // React hydration

    // Test-specific actions
    // ...

    // Take screenshots with descriptive names
    await helpers.takeScreenshot(page, 'atlas-[scenario]-[state]');

    console.log('✅ Test complete');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: '/tmp/error-screenshot.png' });
  } finally {
    await browser.close();
  }
})();
```

---

## Phase 5: Detailed Test Scenarios

### Test Group 1: Visual Validation (13 tests)

#### V1: Claims Tab Light Mode
```
Skill Invocation:
"Test the ATLAS Claims tab in light mode:
1. Navigate to http://localhost:5173/#/atlas
2. Wait for page to load (header visible)
3. Verify Claims tab is active (has blue border)
4. Take full-page screenshot named 'atlas-claims-light.png'
5. Verify all 4 KPI cards are visible (Total Claims, Pending Review, Acceptance Rate, Total Billed)
6. Verify global filter dropdowns are visible (Client, Account, Workflow)
7. Verify status filter dropdown is visible
8. Log success message"
```

**Expected Screenshot:** Claims tab showing KPI cards, filter grid, claim list

**Validation Points:**
- ✅ KPI cards display with icons
- ✅ 3-column filter grid visible
- ✅ No Risk Tier dropdown
- ✅ Claim list or empty state

---

#### V2: Claims Tab Dark Mode
```
Skill Invocation:
"Test the ATLAS Claims tab in dark mode:
1. Navigate to http://localhost:5173/#/atlas
2. Enable dark mode: page.emulateMedia({ colorScheme: 'dark' })
3. Wait for theme to apply (500ms)
4. Take full-page screenshot named 'atlas-claims-dark.png'
5. Verify header has dark background
6. Verify KPI cards have dark backgrounds
7. Verify filter dropdowns have dark styling
8. Log color values of key elements (header bg, card bg, text colors)"
```

**Expected Screenshot:** Claims tab with dark theme applied

**Validation Points:**
- ✅ Header: dark:bg-gray-800
- ✅ KPI cards: dark backgrounds with colored icons
- ✅ Text: white/gray for readability
- ✅ Dropdowns: dark:bg-gray-700

---

#### V3-V4: Workflows Tab (Light + Dark)
```
Skill Invocation:
"Test the ATLAS Workflows tab in both light and dark modes:
1. Navigate to http://localhost:5173/#/atlas?tab=workflows
2. Wait for page load
3. Take screenshot 'atlas-workflows-light.png'
4. Enable dark mode
5. Wait 500ms
6. Take screenshot 'atlas-workflows-dark.png'
7. Verify gate filter dropdown is visible
8. Verify workflow table is visible
9. Verify credential selector is visible
10. Check if Active/Inactive badges use conditional colors (green vs gray)"
```

---

#### V5-V6: Executions Tab (Light + Dark)
```
Skill Invocation:
"Test the ATLAS Executions tab in both modes:
1. Navigate to http://localhost:5173/#/atlas?tab=executions
2. Wait for content load
3. Take screenshot 'atlas-executions-light.png'
4. Enable dark mode
5. Take screenshot 'atlas-executions-dark.png'
6. Verify 6 status tabs are visible (All, Running, Queued, Completed, Failed, Cancelled)
7. Verify refresh button is visible
8. Verify job table renders (or empty state)
9. Check status badge colors in dark mode"
```

---

#### V7-V8: Schedules Tab (Light + Dark)
```
Skill Invocation:
"Test the ATLAS Schedules tab in both modes:
1. Navigate to http://localhost:5173/#/atlas?tab=schedules
2. Take screenshot 'atlas-schedules-light.png'
3. Enable dark mode
4. Take screenshot 'atlas-schedules-dark.png'
5. Verify 'Create Schedule' button visible
6. Verify filter dropdown visible
7. Check schedule cards or empty state
8. Verify enabled/disabled badges use conditional colors"
```

---

#### V9: Global Filters Expanded
```
Skill Invocation:
"Test the global filter dropdowns:
1. Navigate to http://localhost:5173/#/atlas
2. Wait for credentials to load (look for Account dropdown population)
3. Click Account dropdown to expand
4. Take screenshot 'atlas-filters-expanded.png' showing dropdown options
5. Close dropdown
6. Click Workflow dropdown
7. Take screenshot 'atlas-workflow-dropdown.png'
8. Count options in each dropdown and log results"
```

**Expected Screenshot:** Expanded dropdowns showing available options

---

#### V10-V11: WorkflowDetailModal (Light + Dark)
```
Skill Invocation:
"Test the WorkflowDetailModal in both modes:
1. Navigate to http://localhost:5173/#/atlas?tab=workflows
2. Wait for workflow table to load
3. Click 'View' button on first workflow
4. Wait for modal to appear
5. Take screenshot 'atlas-modal-light.png'
6. Close modal
7. Enable dark mode
8. Click 'View' on first workflow again
9. Wait for modal
10. Take screenshot 'atlas-modal-dark.png'
11. Verify all modal sections visible: Overview, Metrics, Recorded Actions, Timeline
12. Check badge colors in dark mode"
```

**Expected Screenshots:** Full modal with all tabs/sections visible

---

#### V12-V13: Responsive Design
```
Skill Invocation:
"Test ATLAS responsive design:
1. Set viewport to 375x667 (iPhone SE)
2. Navigate to http://localhost:5173/#/atlas
3. Take screenshot 'atlas-mobile-claims.png'
4. Verify filter grid stacks vertically
5. Verify KPI cards stack vertically
6. Set viewport to 768x1024 (iPad)
7. Navigate to workflows tab
8. Take screenshot 'atlas-tablet-workflows.png'
9. Verify 3-column filter grid displays correctly
10. Verify table is scrollable if needed"
```

---

### Test Group 2: User Journey Tests (9 tests)

#### J1: Find and Review a Specific Claim
```
Skill Invocation:
"Simulate a user finding and reviewing a claim:
1. Navigate to http://localhost:5173/#/atlas
2. Wait for claims to load
3. If claims exist:
   a. Select first client from dropdown (not 'all')
   b. Wait for filtered results
   c. Change status filter to 'Ready for Review'
   d. Click on first claim in list
   e. Wait for claim detail modal
   f. Take screenshot 'journey-claim-review.png'
   g. Verify all claim fields visible (patient, payer, amount, etc.)
   h. Close modal
4. If no claims:
   a. Take screenshot of empty state
   b. Verify 'No claims found' message
5. Log the journey results"
```

**Agentic Decision:** If no claims exist, verify empty state instead

---

#### J2: Execute a Workflow with Credentials
```
Skill Invocation:
"Simulate executing a workflow:
1. Navigate to http://localhost:5173/#/atlas?tab=workflows
2. Wait for workflows and credentials to load
3. If credentials available:
   a. Select first credential from Account dropdown
   b. Wait for credential to be selected
4. If workflows exist:
   a. Click 'Execute' button on first workflow
   b. Wait for execution to start (may see confirmation or redirect)
   c. Take screenshot 'journey-workflow-execute.png'
   d. If redirected to Executions tab, verify job appears
5. Log execution status"
```

**Agentic Decision:** Handle missing credentials or workflows gracefully

---

#### J3: Monitor Job Execution
```
Skill Invocation:
"Simulate monitoring a running job:
1. Navigate to http://localhost:5173/#/atlas?tab=executions
2. Wait for job list to load
3. Click 'Running' status tab
4. Take screenshot 'journey-execution-monitor.png'
5. If running jobs exist:
   a. Find job with highest progress %
   b. Take screenshot of progress bar
   c. Check if Cancel button is visible
6. If no running jobs:
   a. Click 'Completed' tab
   b. Take screenshot of completed jobs
7. Click 'All' tab
8. Verify all jobs visible again"
```

---

#### J4: Create a New Schedule
```
Skill Invocation:
"Simulate creating a workflow schedule:
1. Navigate to http://localhost:5173/#/atlas?tab=schedules
2. Wait for page load
3. Click 'Create Schedule' button
4. Wait for modal to open
5. Take screenshot 'journey-schedule-modal.png'
6. If workflows available:
   a. Click workflow dropdown in modal
   b. Select first workflow
   c. Set schedule type to 'Daily'
   d. Set time to '09:00'
   e. Enter schedule name: 'Test Schedule'
   f. Take screenshot 'journey-schedule-form-filled.png'
   g. Click Cancel (don't actually submit in test)
7. Verify modal closes
8. Log results"
```

**Agentic Decision:** Don't submit (avoid creating test data), just validate form works

---

#### J5: Navigate via Sidebar
```
Skill Invocation:
"Test sidebar navigation to ATLAS tabs:
1. Navigate to http://localhost:5173/#/atlas
2. Wait for page load
3. Locate 'Executions' link in sidebar
4. Take screenshot 'journey-sidebar-before.png'
5. Click 'Executions' sidebar link
6. Wait 500ms
7. Verify URL contains '?tab=executions'
8. Verify Executions tab is active (blue border)
9. Take screenshot 'journey-sidebar-after.png'
10. Click 'Schedules' in sidebar
11. Verify URL updates to '?tab=schedules'
12. Verify no page reload (SPA navigation)
13. Log navigation results"
```

---

#### J6: Test Backwards Compatibility Redirects
```
Skill Invocation:
"Test that old URLs redirect correctly:
1. Navigate to http://localhost:5173/#/workflows
2. Wait 500ms for redirect
3. Verify URL changed to '/atlas?tab=workflows'
4. Take screenshot 'journey-redirect-workflows.png'
5. Navigate to http://localhost:5173/#/executions
6. Wait 500ms
7. Verify URL changed to '/atlas?tab=executions'
8. Take screenshot 'journey-redirect-executions.png'
9. Navigate to http://localhost:5173/#/schedules
10. Wait 500ms
11. Verify URL changed to '/atlas?tab=schedules'
12. Navigate to http://localhost:5173/#/activity
13. Verify redirects to '/atlas?tab=executions'
14. Log all redirect results (pass/fail for each)"
```

**Validation:** All 4 redirects work without errors

---

#### J7: Apply Multiple Filters
```
Skill Invocation:
"Test combining multiple global filters:
1. Navigate to http://localhost:5173/#/atlas?tab=claims
2. Wait for all dropdowns to populate
3. Select non-'all' option from Client dropdown
4. Wait 500ms
5. Select non-'all' option from Account dropdown (if available)
6. Wait 500ms
7. Select non-'all' option from Workflow dropdown (if available)
8. Wait 500ms
9. Take screenshot 'journey-multi-filter.png'
10. Count visible claims (should be filtered)
11. Switch to Workflows tab
12. Verify filters persist (same selections in dropdowns)
13. Take screenshot 'journey-filter-persistence.png'
14. Log filter results"
```

---

#### J8: Switch Tabs with Filters Active
```
Skill Invocation:
"Test filter persistence across tabs:
1. Navigate to http://localhost:5173/#/atlas
2. Select a client from dropdown
3. Take screenshot 'journey-filter-claims.png'
4. Click Workflows tab
5. Verify client dropdown still has same selection
6. Take screenshot 'journey-filter-workflows.png'
7. Click Executions tab
8. Verify client dropdown still selected
9. Take screenshot 'journey-filter-executions.png'
10. Click Schedules tab
11. Verify client dropdown still selected
12. Log: Filter persists across all tabs"
```

---

#### J9: Dark Mode Toggle Workflow
```
Skill Invocation:
"Test dark mode consistency across all tabs:
1. Navigate to http://localhost:5173/#/atlas in light mode
2. Take screenshot 'journey-light-claims.png'
3. Click Workflows tab
4. Take screenshot 'journey-light-workflows.png'
5. Enable dark mode: page.emulateMedia({ colorScheme: 'dark' })
6. Wait 500ms
7. Verify Workflows tab has dark theme
8. Take screenshot 'journey-dark-workflows.png'
9. Click Executions tab
10. Take screenshot 'journey-dark-executions.png'
11. Click Schedules tab
12. Take screenshot 'journey-dark-schedules.png'
13. Click Claims tab
14. Take screenshot 'journey-dark-claims.png'
15. Verify all tabs have consistent dark theme
16. Log: Dark mode consistent across tabs"
```

---

### Test Group 3: Responsive Design Tests

#### Responsive Test Template
```
Skill Invocation:
"Test ATLAS responsive design across viewports:
1. Launch browser with headless: false
2. For each viewport in [Desktop 1920x1080, Tablet 768x1024, Mobile 375x667]:
   a. Set viewport size
   b. Navigate to http://localhost:5173/#/atlas?tab=claims
   c. Wait for load
   d. Take screenshot '[viewport]-claims.png'
   e. Click Workflows tab
   f. Take screenshot '[viewport]-workflows.png'
   g. Click Executions tab
   h. Take screenshot '[viewport]-executions.png'
   i. Click Schedules tab
   j. Take screenshot '[viewport]-schedules.png'
3. Log results for each viewport
4. Create summary of responsive issues found"
```

**Output:** 28 screenshots (7 viewports × 4 tabs)

---

### Test Group 4: Integration Tests

#### I1: Claim Submission to Execution
```
Skill Invocation:
"Test claim-to-execution workflow:
1. Navigate to http://localhost:5173/#/atlas?tab=claims
2. Find a claim with status 'Approved'
3. If found:
   a. Click 'Submit Claim' button
   b. Wait for submission (toast notification or state change)
   c. Take screenshot 'integration-claim-submitted.png'
   d. Click Executions tab
   e. Wait for executions to load
   f. Look for newest execution (should be the submitted claim)
   g. Take screenshot 'integration-execution-created.png'
   h. Log: Claim submission created execution
4. If not found:
   a. Log: No approved claims available
   b. Take screenshot of claims list"
```

**Agentic Decision:** Adapt based on available data

---

#### I2: Workflow to Schedule
```
Skill Invocation:
"Test workflow-to-schedule integration:
1. Navigate to http://localhost:5173/#/atlas?tab=workflows
2. Find first workflow in table
3. Note the workflow name/ID
4. Take screenshot 'integration-workflow-list.png'
5. Click Schedules tab
6. Click 'Create Schedule' button
7. In the modal:
   a. Click workflow dropdown
   b. Verify the noted workflow appears in list
   c. Take screenshot 'integration-schedule-workflow-select.png'
   d. Click Cancel
8. Log: Workflows available in schedule creation"
```

---

#### I3: Filter Across All Tabs
```
Skill Invocation:
"Test global filter working across all tabs:
1. Navigate to http://localhost:5173/#/atlas
2. Select a specific workflow from Workflow dropdown (not 'all')
3. Note which workflow was selected
4. Take screenshot 'integration-filter-claims.png'
5. Count visible claims (filtered by workflow)
6. Click Workflows tab
7. Take screenshot 'integration-filter-workflows.png'
8. Verify workflow dropdown still has same selection
9. Count visible workflows (should show only selected one)
10. Click Executions tab
11. Take screenshot 'integration-filter-executions.png'
12. Count visible executions (should be filtered)
13. Click Schedules tab
14. Take screenshot 'integration-filter-schedules.png'
15. Log filter consistency across tabs"
```

---

## Phase 6: Screenshot Organization Strategy

### Directory Structure

```
/tmp/atlas-testing-[timestamp]/
├── visual-validation/
│   ├── claims-light.png
│   ├── claims-dark.png
│   ├── workflows-light.png
│   ├── workflows-dark.png
│   ├── executions-light.png
│   ├── executions-dark.png
│   ├── schedules-light.png
│   ├── schedules-dark.png
│   ├── filters-expanded.png
│   ├── modal-light.png
│   ├── modal-dark.png
│   ├── mobile-claims.png
│   └── tablet-workflows.png
├── user-journeys/
│   ├── claim-review.png
│   ├── workflow-execute.png
│   ├── execution-monitor.png
│   ├── schedule-create.png
│   ├── sidebar-nav.png
│   ├── redirect-test.png
│   ├── multi-filter.png
│   ├── filter-persistence.png
│   └── dark-mode-flow.png
├── responsive/
│   ├── desktop-1080p/
│   │   ├── claims.png
│   │   ├── workflows.png
│   │   ├── executions.png
│   │   └── schedules.png
│   ├── desktop-720p/
│   ├── tablet-portrait/
│   ├── tablet-landscape/
│   ├── mobile-iphone-se/
│   ├── mobile-iphone-12/
│   └── mobile-pixel-5/
├── integration/
│   ├── claim-to-execution.png
│   ├── workflow-to-schedule.png
│   └── filter-across-tabs.png
└── test-results.md
```

### Screenshot Naming Convention

```
Format: [category]-[scenario]-[state].png

Examples:
- visual-claims-light.png
- visual-claims-dark.png
- journey-workflow-execute.png
- responsive-mobile-claims.png
- integration-filter-all-tabs.png
```

### Test Results Document

Create `/tmp/atlas-testing-[timestamp]/test-results.md`:

```markdown
# ATLAS Agentic Browser Testing Results
**Date:** 2025-12-02
**Tester:** Claude Code (playwright-skill)
**Environment:** Vite Dev Server (localhost:5173)

## Visual Validation Tests (13/13)
- ✅ V1: Claims Light Mode
- ✅ V2: Claims Dark Mode
- ✅ V3: Workflows Light Mode
- ✅ V4: Workflows Dark Mode
...

## User Journey Tests (9/9)
- ✅ J1: Find and Review Claim
- ✅ J2: Execute Workflow
...

## Responsive Design Tests (28/28)
- ✅ Desktop 1080p: 4/4 tabs
- ✅ Tablet: 4/4 tabs
...

## Integration Tests (3/3)
- ✅ I1: Claim to Execution
...

## Issues Found
1. [Priority] Description of issue - Screenshot: [filename]
2. ...

## Summary
- Total Tests: 53
- Passed: XX
- Failed: XX
- Warnings: XX
- Screenshots: 70+
```

---

## Phase 7: Execution Workflow

### Master Test Execution Plan

**Complete testing session workflow:**

```bash
#!/bin/bash
# ATLAS Agentic Testing Session

# Step 1: Setup
echo "🚀 Starting ATLAS agentic browser testing"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_DIR="/tmp/atlas-testing-$TIMESTAMP"
mkdir -p $TEST_DIR/{visual-validation,user-journeys,responsive,integration}

# Step 2: Start Dev Server (if needed)
echo "📡 Detecting dev servers..."
cd /Users/adammanuel/.claude/skills/playwright-skill
SERVERS=$(node -e "require('./lib/helpers').detectDevServers().then(s => console.log(JSON.stringify(s)))")

if [ "$SERVERS" = "[]" ]; then
  echo "🔧 Starting Vite dev server..."
  cd /Users/adammanuel/Projects/tahoma-ai/Dashboard
  npm run dev > $TEST_DIR/vite-server.log 2>&1 &
  VITE_PID=$!
  echo "Waiting for server..."
  sleep 10
  TARGET_URL="http://localhost:5173"
else
  echo "✅ Found running server"
  TARGET_URL=$(echo $SERVERS | grep -o 'http://[^"]*' | head -1)
fi

echo "🎯 Testing URL: $TARGET_URL"

# Step 3: Run Test Groups (via playwright skill invocations)
# This will be done interactively via Claude Code

echo "📸 Running visual validation tests (13 tests)..."
# Invoke playwright skill for V1-V13

echo "🚶 Running user journey tests (9 tests)..."
# Invoke playwright skill for J1-J9

echo "📱 Running responsive design tests (28 screenshots)..."
# Invoke playwright skill for responsive tests

echo "🔗 Running integration tests (3 tests)..."
# Invoke playwright skill for I1-I3

# Step 4: Cleanup
echo "🧹 Cleaning up..."
if [ -n "$VITE_PID" ]; then
  kill $VITE_PID 2>/dev/null
  echo "Stopped Vite server (PID: $VITE_PID)"
fi

echo "✅ Testing complete! Results in: $TEST_DIR"
ls -lh $TEST_DIR/**/*.png | wc -l
echo "screenshots generated"
```

---

## Phase 8: Skill Invocation Sequence

### Execution Plan (Step-by-Step)

**Session Start:**
1. Enter plan mode (current)
2. Review this plan
3. Exit plan mode
4. Begin execution

**Test Execution (Sequential):**

1. **Invoke playwright-skill** - "Detect dev servers and prepare testing environment"

2. **For Visual Validation (13 tests):**
   - Invoke skill with V1 instructions → Screenshot generated
   - Invoke skill with V2 instructions → Screenshot generated
   - ... continue for V3-V13
   - Review all screenshots for visual issues

3. **For User Journeys (9 tests):**
   - Invoke skill with J1 instructions → Journey completed
   - Invoke skill with J2 instructions → Journey completed
   - ... continue for J3-J9
   - Review journey results

4. **For Responsive Design (7 viewports):**
   - Invoke skill with responsive test instructions
   - Generate 28 screenshots (7 viewports × 4 tabs)
   - Review responsive layouts

5. **For Integration (3 tests):**
   - Invoke skill with I1 instructions
   - Invoke skill with I2 instructions
   - Invoke skill with I3 instructions
   - Review integration results

6. **Compile Results:**
   - Gather all screenshots
   - Create test-results.md summary
   - Document any issues found
   - Commit screenshots and results

**Total Skill Invocations: ~30-40** (some tests can be batched)

---

## Phase 9: Alternative Approaches

### Approach A: Sequential Individual Tests (Recommended)

**Strategy:** Invoke playwright skill once per test scenario

**Pros:**
- Clear separation of concerns
- Easy to debug failures
- Screenshots clearly labeled
- Can stop/resume at any point

**Cons:**
- More skill invocations (30-40)
- Longer total execution time
- More verbose output

**Estimated Time:** 2-3 hours total

---

### Approach B: Batched Test Groups

**Strategy:** Invoke playwright skill once per test group (4 invocations)

**Pros:**
- Fewer skill invocations (4)
- Faster execution
- More efficient

**Cons:**
- Harder to debug individual failures
- Less granular control
- More complex scripts
- If one test fails, whole batch may fail

**Estimated Time:** 1 hour total

---

### Approach C: Hybrid (Recommended for This Project)

**Strategy:**
- Visual Validation: 2 batches (light mode all tabs, dark mode all tabs)
- User Journeys: Individual tests (9 invocations)
- Responsive: 1 batch (all viewports + tabs)
- Integration: Individual tests (3 invocations)

**Total Invocations:** ~15

**Pros:**
- Balances efficiency and clarity
- Easy to debug user journeys
- Efficient for visual validation
- Manageable execution time

**Cons:**
- Requires careful batching strategy

**Estimated Time:** 1.5 hours total

**Recommendation:** Use Approach C (Hybrid)

---

## Phase 10: Test Output Documentation

### Screenshot Review Checklist

For each screenshot, verify:

**Layout & Structure:**
- [ ] No duplicate headers
- [ ] No layout overflow (content fits viewport)
- [ ] No overlapping elements
- [ ] Proper spacing and alignment
- [ ] Grid layouts render correctly

**Typography:**
- [ ] All text readable
- [ ] Proper font sizes
- [ ] No text cutoff
- [ ] Proper color contrast (light and dark modes)

**Dark Mode Specific:**
- [ ] Header has dark background
- [ ] Cards/panels have dark backgrounds
- [ ] Text is white/gray (readable)
- [ ] Borders are visible but subtle
- [ ] Badges have dark mode colors
- [ ] Inputs have dark styling
- [ ] Hover states work (if captured)

**Functional Elements:**
- [ ] All buttons visible
- [ ] All dropdowns accessible
- [ ] Tab navigation clear
- [ ] Active states obvious
- [ ] Loading states (if captured)
- [ ] Empty states (if applicable)

**Mobile/Responsive:**
- [ ] Filter grid stacks vertically
- [ ] KPI cards stack vertically
- [ ] Tables are scrollable
- [ ] Buttons accessible (not cut off)
- [ ] Text doesn't overflow
- [ ] No horizontal scrolling

### Issue Documentation Template

```markdown
## Issue #[N]: [Brief Description]

**Severity:** [Critical | High | Medium | Low]
**Category:** [Layout | Dark Mode | Responsive | Typography | Functional]
**Affected Component:** [Component name]
**Screenshot:** [filename.png]

**Description:**
[Detailed description of the issue]

**Steps to Reproduce:**
1. Navigate to [URL]
2. [Action]
3. [Observed behavior]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Fix Recommendation:**
[Suggested fix with code example if applicable]
```

---

## Phase 11: Success Criteria

### Visual Validation Success Criteria

- [ ] All 4 tabs render without errors in light mode
- [ ] All 4 tabs render without errors in dark mode
- [ ] No duplicate headers in embedded tabs
- [ ] No layout overflow on any tab
- [ ] All global filter dropdowns visible and populated
- [ ] No Risk Tier dropdown present
- [ ] WorkflowDetailModal displays correctly in both modes
- [ ] All status badges use correct colors
- [ ] All text readable in both modes
- [ ] No console errors during tab switching

### User Journey Success Criteria

- [ ] Can navigate between all tabs via UI
- [ ] URL updates correctly on tab switch
- [ ] Browser refresh maintains selected tab
- [ ] Browser back/forward works with tabs
- [ ] Global filters persist across tabs
- [ ] Can open and view claim details
- [ ] Can execute workflow (button works)
- [ ] Can view execution list and filter by status
- [ ] Can open schedule creation modal
- [ ] Sidebar navigation works without redirect flash

### Responsive Design Success Criteria

- [ ] Mobile (375px): Filter grid stacks vertically
- [ ] Mobile: KPI cards stack vertically
- [ ] Mobile: Tables are scrollable horizontally
- [ ] Mobile: No horizontal page scrolling
- [ ] Tablet (768px): Filter grid shows 2-3 columns
- [ ] Tablet: All content accessible
- [ ] Desktop (1920px): All content uses available space
- [ ] All viewports: Tab navigation accessible

### Integration Success Criteria

- [ ] Claim submission creates execution job
- [ ] Workflows appear in schedule creation dropdown
- [ ] Global filters affect all tabs consistently
- [ ] Switching tabs doesn't break filter state
- [ ] No data inconsistencies across tabs

### Overall Success Criteria

- [ ] 0 critical issues found
- [ ] 0 high severity issues found
- [ ] < 5 medium severity issues found
- [ ] All screenshots generated successfully
- [ ] Test results documented
- [ ] Visual regression baseline established

---

## Phase 12: Risk Assessment & Mitigation

### Testing Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Dev server not starting | Low | High | Auto-detect + fallback instructions |
| Authentication required for testing | High | High | Use test credentials or mock auth |
| Network requests fail in test env | Medium | Medium | Mock API responses or use staging data |
| Screenshots too large for analysis | Low | Medium | Use selective screenshots (key areas only) |
| Dark mode not triggering | Low | Medium | Use emulateMedia + verify computed styles |
| Flaky tests due to timing | Medium | Low | Use proper waitFor strategies |

### Authentication Strategy

**Challenge:** ATLAS requires Clerk authentication

**Solutions:**

**Option 1: Test Credentials**
```javascript
// In test script
await page.goto(`${TARGET_URL}/#/login`);
await page.fill('input[name="email"]', process.env.TEST_USER_EMAIL);
await page.fill('input[name="password"]', process.env.TEST_USER_PASSWORD);
await page.click('button:has-text("Sign In")');
await page.waitForURL('**/atlas');
```

**Option 2: Session Replay**
- Save authenticated session cookies
- Restore cookies before each test
- Avoid login flow in every test

**Option 3: Mock Authentication**
- Bypass Clerk in development mode
- Use local development tokens
- Configure for testing environment

**Recommendation:** Use Option 1 with test credentials stored in environment variables

---

## Phase 13: Implementation Strategy

### Test Execution Order

**Priority 1: Core Visual Validation (High Value)**
1. V1-V2: Claims tab (light + dark) - 5 min
2. V3-V4: Workflows tab (light + dark) - 5 min
3. V5-V6: Executions tab (light + dark) - 5 min
4. V7-V8: Schedules tab (light + dark) - 5 min

**Checkpoint 1:** Review screenshots, verify dark mode looks correct

**Priority 2: Critical User Journeys (High Value)**
1. J6: Backwards compatibility redirects - 5 min
2. J5: Sidebar navigation - 5 min
3. J1: Find and review claim - 5 min
4. J7: Apply multiple filters - 5 min

**Checkpoint 2:** Verify core user flows work

**Priority 3: Modal and Filters (Medium Value)**
1. V9: Global filters expanded - 3 min
2. V10-V11: WorkflowDetailModal - 5 min
3. J8: Filter persistence - 5 min
4. J9: Dark mode toggle - 5 min

**Checkpoint 3:** Verify filtering and modals work

**Priority 4: Responsive (Medium Value)**
1. V12-V13: Mobile + Tablet - 5 min
2. Full responsive suite - 20 min

**Checkpoint 4:** Verify responsive design

**Priority 5: Integration (Low Value - Already Tested)**
1. I1-I3: Integration tests - 15 min

**Total: ~90 minutes with checkpoints**

### Batching Strategy (Hybrid Approach)

**Batch 1: Light Mode Visual Validation (1 invocation)**
```
Test all tabs in light mode:
- Claims, Workflows, Executions, Schedules
- Take 4 screenshots
- Verify all elements visible
```

**Batch 2: Dark Mode Visual Validation (1 invocation)**
```
Test all tabs in dark mode:
- Enable dark mode
- Claims, Workflows, Executions, Schedules
- Take 4 screenshots
- Verify dark styling applied
```

**Individual Tests: User Journeys (9 invocations)**
- One skill invocation per journey
- More control and clarity
- Easier debugging

**Batch 3: Responsive Design (1 invocation)**
```
Test responsive design:
- 3 viewports × 4 tabs = 12 screenshots
- Automated viewport switching
- Generate comparison report
```

**Individual Tests: Integration (3 invocations)**
- One per integration scenario
- Allows careful validation

**Total Invocations: 15** (vs 53 if all individual)

---

## Phase 14: Post-Testing Actions

### Screenshot Review & Documentation

1. **Organize Screenshots**
   ```bash
   # Move from /tmp to project docs
   mkdir -p Dashboard/docs/screenshots/atlas-testing-[date]
   cp -r /tmp/atlas-testing-*/  Dashboard/docs/screenshots/
   ```

2. **Create Visual Regression Baseline**
   - Select best screenshots as baseline
   - Store in git for future comparison
   - Use tools like Percy or Chromatic for automated visual diffs (future)

3. **Update User Guide with Screenshots**
   - Add screenshots to `ATLAS_USER_GUIDE.md`
   - Replace text descriptions with actual visuals
   - Create annotated screenshots pointing out features

4. **Document Issues Found**
   - Create GitHub issues for any bugs
   - Tag with `visual-bug`, `dark-mode`, `responsive`, etc.
   - Prioritize based on severity

### Test Results Integration

**Create:** `Dashboard/docs/ATLAS_TESTING_RESULTS.md`

**Contents:**
- Executive summary of testing session
- Screenshots showcase (embedded images)
- Issues found with severity ratings
- Recommendations for improvements
- Visual regression baseline established
- Next testing session recommendations

### Commit Strategy

```bash
# Commit test results and screenshots
git add docs/screenshots/
git add docs/ATLAS_TESTING_RESULTS.md
git commit -m "test(atlas): agentic browser testing results with screenshots

- 53 test scenarios executed via playwright skill
- 70+ screenshots captured (light/dark/responsive)
- Visual validation: All tabs render correctly
- User journeys: All flows work as expected
- Responsive design: Layouts adapt properly
- 0 critical issues, X medium issues found

Screenshots organized in docs/screenshots/atlas-testing-[date]/"
```

---

## Phase 15: Continuous Testing Strategy

### When to Run Agentic Tests

**Trigger Events:**
1. **After major UI changes** (like this refactoring)
2. **Before production deployment** (visual QA)
3. **When design changes** (new colors, spacing, fonts)
4. **Monthly visual regression** (catch drift)
5. **On demand** (investigating reported visual bugs)

### Automated vs Agentic Testing Matrix

| Scenario | Use Automated E2E | Use Agentic Testing |
|----------|------------------|---------------------|
| Regression testing | ✅ Yes (fast, deterministic) | ❌ No |
| Visual validation | ❌ No (can't see UI) | ✅ Yes (screenshots) |
| Exploratory testing | ❌ No (predefined only) | ✅ Yes (adaptive) |
| Performance testing | ✅ Yes (metrics) | ⚠️ Partial (load time) |
| Accessibility testing | ✅ Yes (automated scans) | ✅ Yes (manual review) |
| Cross-browser testing | ✅ Yes (multiple browsers) | ✅ Yes (flexible) |
| Documentation | ❌ No | ✅ Yes (screenshots) |
| CI/CD integration | ✅ Yes | ❌ No (manual review needed) |

**Recommendation:** Use both - automated for CI/CD, agentic for visual QA

---

## Appendix A: Playwright Skill Quick Reference

### Skill Directory
```
/Users/adammanuel/.claude/skills/playwright-skill/
├── SKILL.md           - This skill documentation
├── run.js             - Universal executor
├── lib/
│   └── helpers.js     - Utility functions
├── package.json       - Dependencies
└── node_modules/      - Playwright installed
```

### Key Commands

**Detect Dev Servers:**
```bash
cd /Users/adammanuel/.claude/skills/playwright-skill && \
node -e "require('./lib/helpers').detectDevServers().then(s => console.log(JSON.stringify(s)))"
```

**Execute Test Script:**
```bash
cd /Users/adammanuel/.claude/skills/playwright-skill && \
node run.js /tmp/playwright-test-[name].js
```

**Inline Execution:**
```bash
cd /Users/adammanuel/.claude/skills/playwright-skill && \
node run.js "
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.goto('http://localhost:5173/#/atlas');
  await page.screenshot({ path: '/tmp/quick.png' });
  await browser.close();
"
```

### Helper Functions Available

```javascript
const helpers = require('./lib/helpers');

await helpers.detectDevServers()        // Find running servers
await helpers.safeClick(page, selector) // Click with retry
await helpers.safeType(page, selector, text) // Type with clear
await helpers.takeScreenshot(page, name) // Timestamped screenshot
await helpers.handleCookieBanner(page)  // Dismiss cookie notice
await helpers.extractTableData(page, selector) // Parse tables
```

---

## Appendix B: Test Script Templates

### Template 1: Single Tab Visual Test

```javascript
// /tmp/playwright-test-visual-[tab]-[mode].js
const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:5173';
const TAB_NAME = 'claims'; // or workflows, executions, schedules
const MODE = 'light'; // or dark

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 100 });
  const page = await browser.newPage();

  try {
    // Enable dark mode if needed
    if (MODE === 'dark') {
      await page.emulateMedia({ colorScheme: 'dark' });
    }

    // Navigate to specific tab
    const url = TAB_NAME === 'claims'
      ? `${TARGET_URL}/#/atlas`
      : `${TARGET_URL}/#/atlas?tab=${TAB_NAME}`;

    await page.goto(url);
    await page.waitForSelector('header', { timeout: 10000 });
    await page.waitForTimeout(1000);

    // Take screenshot
    await page.screenshot({
      path: `/tmp/atlas-${TAB_NAME}-${MODE}.png`,
      fullPage: true
    });

    console.log(`✅ Screenshot: atlas-${TAB_NAME}-${MODE}.png`);

    // Verify key elements
    const hasKPIs = TAB_NAME === 'claims'
      ? await page.locator('text=Total Claims').isVisible()
      : true;

    console.log(`   KPIs visible: ${hasKPIs}`);

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: `/tmp/error-${TAB_NAME}-${MODE}.png` });
  } finally {
    await browser.close();
  }
})();
```

### Template 2: User Journey Test

```javascript
// /tmp/playwright-test-journey-[name].js
const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:5173';

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 150 });
  const page = await browser.newPage();

  try {
    console.log('🚶 User Journey: [Journey Name]');

    // Step 1: Navigate
    await page.goto(`${TARGET_URL}/#/atlas`);
    await page.waitForSelector('header', { timeout: 10000 });
    await page.waitForTimeout(1000);
    console.log('  ✓ Step 1: Navigated to ATLAS');

    // Step 2: Interact
    await page.click('button:has-text("Workflows")');
    await page.waitForTimeout(500);
    console.log('  ✓ Step 2: Clicked Workflows tab');

    // Step 3: Verify
    const url = page.url();
    if (url.includes('tab=workflows')) {
      console.log('  ✓ Step 3: URL updated correctly');
    } else {
      console.log('  ❌ Step 3: URL did not update');
    }

    // Screenshot at key moment
    await page.screenshot({ path: '/tmp/journey-[name].png', fullPage: true });

    console.log('✅ Journey complete: [Journey Name]');

  } catch (error) {
    console.error('❌ Journey failed:', error.message);
    await page.screenshot({ path: '/tmp/journey-error.png' });
  } finally {
    await browser.close();
  }
})();
```

### Template 3: Responsive Test Batch

```javascript
// /tmp/playwright-test-responsive-all.js
const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:5173';
const VIEWPORTS = [
  { name: 'desktop-1080p', width: 1920, height: 1080 },
  { name: 'tablet-portrait', width: 768, height: 1024 },
  { name: 'mobile-iphone', width: 375, height: 667 }
];
const TABS = ['claims', 'workflows', 'executions', 'schedules'];

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  for (const viewport of VIEWPORTS) {
    console.log(`📱 Testing: ${viewport.name} (${viewport.width}x${viewport.height})`);

    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height
    });

    for (const tab of TABS) {
      const url = tab === 'claims'
        ? `${TARGET_URL}/#/atlas`
        : `${TARGET_URL}/#/atlas?tab=${tab}`;

      await page.goto(url);
      await page.waitForSelector('header', { timeout: 10000 });
      await page.waitForTimeout(1000);

      await page.screenshot({
        path: `/tmp/responsive-${viewport.name}-${tab}.png`,
        fullPage: true
      });

      console.log(`  ✓ ${tab} tab captured`);
    }
  }

  console.log('✅ Responsive testing complete');
  console.log(`   Screenshots: ${VIEWPORTS.length * TABS.length} files`);

  await browser.close();
})();
```

---

## Appendix C: Expected Test Results

### Visual Validation Expected Outcomes

**V1-V2 (Claims Light/Dark):**
```
✅ Screenshot: atlas-claims-light.png
   - 4 KPI cards visible with icons
   - 3-column filter grid (Client, Account, Workflow)
   - Status dropdown below filters
   - Claim list or empty state
   - No Risk Tier dropdown

✅ Screenshot: atlas-claims-dark.png
   - Dark header (bg-gray-800)
   - Dark KPI cards
   - Dark filter dropdowns
   - White/gray text readable
   - Blue accent colors for active elements
```

**V3-V4 (Workflows Light/Dark):**
```
✅ Screenshot: atlas-workflows-light.png
   - Gate filter dropdown
   - Credential selector
   - Workflow table with columns
   - Active/Inactive badges (conditional colors)
   - Execute and View buttons

✅ Screenshot: atlas-workflows-dark.png
   - Same as light but dark theme
   - Table has dark backgrounds
   - Badges use dark mode variants
   - Text readable
```

**V5-V6 (Executions Light/Dark):**
```
✅ Screenshot: atlas-executions-light.png
   - 6 status filter tabs
   - Refresh button
   - Job table or empty state
   - Progress bars
   - Cancel/Retry buttons (if applicable)

✅ Screenshot: atlas-executions-dark.png
   - Dark status tabs
   - Dark table
   - Progress bars visible
   - Status badges with dark colors
```

**V7-V8 (Schedules Light/Dark):**
```
✅ Screenshot: atlas-schedules-light.png
   - Create Schedule button
   - Filter dropdown (All/Enabled/Disabled)
   - Schedule cards or empty state
   - Enable/Disable/Edit/Delete buttons

✅ Screenshot: atlas-schedules-dark.png
   - Dark theme applied
   - Schedule cards with dark backgrounds
   - Buttons with dark mode styling
```

### User Journey Expected Outcomes

**J1 (Find and Review Claim):**
```
✅ Journey complete
   - Filtered claims by client
   - Filtered by status
   - Opened claim detail modal
   - All claim fields visible
   Screenshot: journey-claim-review.png shows modal open
```

**J6 (Backwards Compatibility):**
```
✅ All redirects working
   - /workflows → /atlas?tab=workflows ✓
   - /executions → /atlas?tab=executions ✓
   - /schedules → /atlas?tab=schedules ✓
   - /activity → /atlas?tab=executions ✓
   Screenshot: journey-redirect-test.png shows final redirected page
```

---

## Appendix D: Troubleshooting Guide

### Common Issues During Testing

**Issue: "Cannot find element"**
```
Cause: React component not yet mounted
Fix: Add proper wait strategy
  await page.waitForSelector('button:has-text("Workflows")', { timeout: 10000 });
```

**Issue: "Navigation timeout"**
```
Cause: Server not responding or slow
Fix: Increase timeout or check server logs
  await page.goto(url, { timeout: 30000, waitUntil: 'domcontentloaded' });
```

**Issue: "Dark mode not applying"**
```
Cause: emulateMedia called after page load
Fix: Call before navigation or reload after setting
  await page.emulateMedia({ colorScheme: 'dark' });
  await page.reload();
```

**Issue: "Screenshot shows loading spinner"**
```
Cause: Content still loading
Fix: Add wait for specific elements
  await page.waitForSelector('[data-testid="content"]');
  await page.waitForLoadState('networkidle');
```

**Issue: "Modal not opening"**
```
Cause: Click timing or element not ready
Fix: Wait for element, then click with force
  await page.waitForSelector('button:has-text("View")');
  await page.click('button:has-text("View")', { force: true });
```

---

## Conclusion

This plan provides a comprehensive strategy for testing the ATLAS interface using agentic browser automation with the playwright skill. By combining visual validation, user journey testing, responsive design checks, and integration tests, we'll achieve thorough coverage that complements our automated E2E test suite.

### Key Success Factors

1. ✅ **Hybrid batching approach** - Balance efficiency and clarity (15 invocations)
2. ✅ **Visual documentation** - 70+ screenshots for user guide and baseline
3. ✅ **Adaptive testing** - AI-driven decisions based on actual page state
4. ✅ **Comprehensive coverage** - 53 test scenarios across all features
5. ✅ **Efficient execution** - ~90 minutes total with checkpoints
6. ✅ **Actionable results** - Screenshots + documented issues

### Next Steps

1. ✅ Review and approve this plan
2. Start dev server (or verify running)
3. Begin Batch 1 (Light Mode Visual Validation)
4. Checkpoint review
5. Continue through all test groups
6. Compile results and screenshots
7. Update documentation with visuals
8. Create visual regression baseline

---

**Plan Version:** 1.0
**Created:** 2025-12-02
**Author:** Claude Code (Plan Mode)
**Estimated Execution Time:** 90 minutes
**Total Test Coverage:** 53 scenarios, 70+ screenshots
**Status:** Ready for Execution
