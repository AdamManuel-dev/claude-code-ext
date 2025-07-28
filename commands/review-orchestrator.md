Run comprehensive code review and improvement cycle on a codebase.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

## Usage

### Option 1: Slash Command (Instant)
```
/review [directory] [git-command]
```

### Option 2: Global Command (After Installation)
```
review [directory] [git-command]
```

### Git Command Options
- No argument - Run Stage 1 only (basic validation - default behavior)
- `add` - Run Stage 1 only (basic validation before staging)
- `commit` - Run Stages 1-2 (basic + core quality before committing)
- `push` - Run Stages 1-3 (basic + core + advanced before pushing)
- `merge` - Run all Stages 1-4 (full review before merging to main)

## Description
Runs all review personas in parallel:
- Quality review (TypeScript, logic, patterns)
- Security review (vulnerabilities, auth, data protection)
- Readability review (naming, structure, documentation)
- Design review (UI/UX, accessibility, visual consistency)
- Basic review (anti-patterns, common mistakes)
- Testing review (test effectiveness, coverage, mocking)
- E2E review (integration testing, user flows)

Each reviewer automatically applies fixes and validates changes.

## Execution Workflow

The orchestrator runs different stages based on your intended git command, aligning with natural development workflow:

### Stage 1: Pre-Add Validation (`add`)
- 🟡 **Basic Review**: Anti-patterns, common mistakes, critical errors
- **When to use**: Before `git add` - catch obvious issues before staging
- **Exit action**: `git add .` (if no critical issues)

### Stage 2: Pre-Commit Quality (`commit`) 
- 🟡 **Stage 1**: Basic validation
- 🟢 **Readability Review**: Naming, structure, documentation
- 🔵 **Quality Review**: TypeScript, logic, patterns  
- 🔴 **Security Review**: Vulnerabilities, auth, data protection
- **When to use**: Before `git commit` - ensure code quality before committing
- **Exit action**: `git commit -m "feat: [generated message]"` (if stages 1-2 pass)

### Stage 3: Pre-Push Validation (`push`)
- 🟡🟢🔵🔴 **Stages 1-2**: Basic + Core Quality
- 🟣 **Design Review**: UI/UX, accessibility, visual consistency
- 🧪 **Testing Review**: Test effectiveness, coverage, mocking
- **When to use**: Before `git push` - comprehensive validation before sharing
- **Exit action**: `git push origin [branch]` (if stages 1-3 pass)

### Stage 4: Pre-Merge Review (`merge`)
- 🟡🟢🔵🔴🟣🧪 **All Previous Stages**: Complete validation
- 🔵 **E2E Review**: Integration testing, user flows, end-to-end validation
- 📝 **Final Documentation**: Ensure all changes are documented
- 🔍 **Merge Readiness**: Verify branch is ready for main integration
- **When to use**: Before merging to main - full quality gate
- **Exit action**: Notify user to proceed with merge (manual approval required)

## Failure Criteria for Early Exit

### Stage 1 (Basic) - Critical Failures:
- Compilation/syntax errors
- Hardcoded secrets or API keys
- Failing tests in main branch
- Missing essential dependencies
- Security vulnerabilities (Critical/High)

### Stage 2 (Core Quality) - Critical Failures:
- Major security vulnerabilities
- Logic errors in critical business paths  
- Type safety issues causing runtime errors
- Accessibility violations (WCAG AA)
- Performance issues causing timeouts

### Early Exit Benefits:
- **Time Saving**: Avoid complex analysis when basics fail
- **Resource Efficiency**: Don't waste compute on unfixable code
- **Developer Focus**: Address critical issues first
- **Faster Feedback**: Get essential fixes immediately

## Real-Time Unified Dashboard

The orchestrator provides a consolidated view of all reviewer activities and findings as they execute:

### Live Progress Dashboard
```
╔══════════════════════════════════════════════════════════════════════════╗
║                        Review Orchestrator Dashboard                    ║
║                            Live Progress View                            ║
╚══════════════════════════════════════════════════════════════════════════╝

🟡 Stage 1: Basic Review                                            [COMPLETE]
├─ Issues Found: 12 critical errors                                      ✅
├─ Fixes Applied: 12/12 automated                                        ✅
└─ Status: PASSED - Proceeding to Stage 2                               ✅

🔄 Stage 2: Core Quality Analysis                                   [IN PROGRESS]
├─ 🟢 Readability Review                                            [COMPLETE]
│  ├─ Issues: 15 naming violations                                       ✅
│  ├─ Fixes: 15/15 applied                                              ✅
│  └─ Status: PASSED                                                    ✅
├─ 🔵 Quality Review                                                [COMPLETE]
│  ├─ Issues: 7 TypeScript errors, 3 logic issues                       ✅
│  ├─ Fixes: 10/10 applied                                              ✅
│  └─ Status: PASSED                                                    ✅
└─ 🔴 Security Review                                              [RUNNING...]
   ├─ Issues: 3 critical vulnerabilities found                          🔍
   ├─ Fixes: 1/3 applied (hardcoded API key removed)                   ⏳
   └─ Status: IN PROGRESS                                               ⏳

📊 Overall Progress: Stage 2/4 (50%) | Files Modified: 8 | Issues Fixed: 27
```

### Consolidated Findings View
```
╔══════════════════════════════════════════════════════════════════════════╗
║                          Consolidated Findings                          ║
║                        Real-Time Issue Tracking                         ║
╚══════════════════════════════════════════════════════════════════════════╝

🔴 CRITICAL ISSUES (3 remaining)
├─ [Security] Hardcoded JWT secret in auth.ts:23                  [FIXING...]
├─ [Security] SQL injection in user-queries.ts:45                [PENDING]
└─ [Security] Unvalidated file upload in upload.ts:12            [PENDING]

🟡 HIGH PRIORITY (7 fixed, 2 remaining)
├─ [Quality] ✅ Missing return type in calculateTotal()               [FIXED]
├─ [Quality] ✅ Logic error in date comparison                         [FIXED]  
├─ [Readability] ✅ Unclear variable name 'data' -> 'userProfile'     [FIXED]
├─ [Basic] ❌ Missing error handling in async function            [REMAINING]
└─ [Basic] ❌ Console.log in production code                      [REMAINING]

📈 COVERAGE IMPROVEMENTS
├─ Test coverage: 67% → 84% (+17%)
├─ New test files: 5 added
└─ Flaky tests: 3 fixed

📋 FILES MODIFIED (8)
├─ src/auth/auth.ts - Security fixes, type improvements
├─ src/components/Button.tsx - Accessibility, naming
├─ src/utils/calculations.ts - Logic fixes, TypeScript  
├─ src/hooks/useAuth.ts - Error handling, readability
└─ ... 4 more files
```

### Reviewer Status Matrix
```
┌─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│  Reviewer   │   Status    │   Issues    │    Fixes    │   Priority  │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ 🟡 Basic    │     ✅      │    12/12    │    12/12    │   Complete  │
│ 🟢 Read.    │     ✅      │    15/15    │    15/15    │   Complete  │  
│ 🔵 Quality  │     ✅      │    10/10    │    10/10    │   Complete  │
│ 🔴 Security │     ⏳      │     3/6     │     1/3     │   Critical  │
│ 🟣 Design   │     ⏸️      │      -      │      -      │   Waiting   │
│ 🧪 Testing  │     ⏸️      │      -      │      -      │   Waiting   │
│ 🔵 E2E      │     ⏸️      │      -      │      -      │   Waiting   │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ 📝 Commit   │     ⏸️      │      -      │      -      │   Pending   │
│ 🚀 Push     │     ⏸️      │      -      │      -      │   Pending   │
│ 🔔 Notify   │     ⏸️      │      -      │      -      │   Pending   │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
```

## Implementation of Unified Dashboard

### Real-Time Update Mechanism
The orchestrator maintains a shared state that aggregates findings from all active reviewers:

```typescript
interface UnifiedDashboard {
  stages: {
    current: number;
    total: number;
    status: 'running' | 'complete' | 'failed';
  };
  reviewers: {
    [key: string]: {
      status: 'waiting' | 'running' | 'complete' | 'failed';
      issuesFound: number;
      issuesFixed: number;
      criticalIssues: Issue[];
      progress: number;
    };
  };
  consolidatedFindings: {
    critical: Issue[];
    high: Issue[];
    medium: Issue[];
    low: Issue[];
  };
  filesModified: string[];
  metricsTimeline: MetricPoint[];
}
```

### Cross-Reviewer Issue Correlation
Issues found by multiple reviewers are automatically merged and prioritized:

```
🔗 CROSS-REVIEWER CORRELATIONS
├─ auth.ts:23 - Found by Security (hardcoded secret) + Basic (magic string)
├─ Button.tsx:45 - Found by Design (poor contrast) + Readability (unclear name)  
└─ api.ts:12 - Found by Security (no validation) + Quality (missing types)
```

### Live Update Frequency
- **Stage transitions**: Immediate update
- **Issue discovery**: Real-time as found
- **Fix application**: Update per fix applied
- **Progress metrics**: Every 5 seconds
- **File modifications**: Immediate on change

### Dashboard Refresh Strategy
```
┌─ Update Trigger ─┬─ Frequency ─┬─ Components Updated ─────────────────┐
├─ Stage Change    │ Immediate   │ Stage indicator, reviewer status     │
├─ Issue Found     │ Real-time   │ Issue counter, consolidated findings │  
├─ Fix Applied     │ Real-time   │ Fix counter, file list              │
├─ Reviewer Done   │ Immediate   │ Status matrix, progress bar         │
└─ Critical Error  │ Immediate   │ Error banner, early exit display    │
```

### Stage 4: Automatic Finalization

After all reviews complete successfully, the orchestrator automatically:

#### 1. Commit Changes
```bash
# Generate conventional commit message based on applied fixes
git add .
git commit -m "feat(review): automated code improvements

- Fixed 27 issues across 7 review domains
- Applied TypeScript fixes (7 issues)
- Resolved security vulnerabilities (3 critical)
- Improved test coverage from 67% to 84%
- Enhanced code readability (15 naming issues)
- Added accessibility improvements (5 UI issues)
- Applied basic anti-pattern fixes (15 issues)

Co-authored-by: Review-Orchestrator <review-orchestrator@ai>"
```

#### 2. Push to Remote
```bash
# Push the improved code to remote repository
git push origin $(git branch --show-current)
```

#### 3. User Notification
```bash
# Alert user that review cycle is complete
BRANCH_NAME=$(git branch --show-current)
osascript -e "display notification \"📢 [$BRANCH_NAME]\" with title \"🎯 Review Orchestrator Complete! 27 issues fixed across 8 files\" sound name \"Submarine\""
```

## Git Command Integration

### Automatic Execution
When stages pass, the orchestrator automatically runs the appropriate git command:

```bash
# Stage 1 (add) - Basic validation passed
git add .
osascript -e "display notification \"📢 Files Staged\" with title \"✅ Basic validation passed - files added to staging\" sound name \"Submarine\""

# Stage 2 (commit) - Quality checks passed  
git commit -m "feat: automated code improvements

- Fixed 15 basic issues (console.logs, unused imports)
- Improved code readability (8 naming violations)
- Applied TypeScript fixes (4 type errors)
- Resolved security issues (2 vulnerabilities)

Co-authored-by: Review-Orchestrator <review-orchestrator@ai>"
osascript -e "display notification \"📢 Committed\" with title \"✅ Code quality validated - changes committed\" sound name \"Submarine\""

# Stage 3 (push) - Full validation passed
git push origin $(git branch --show-current)
osascript -e "display notification \"📢 Pushed\" with title \"✅ Full validation passed - code pushed to remote\" sound name \"Submarine\""

# Stage 4 (merge) - Complete review passed
echo "🎯 Code is ready for merge to main branch"
echo "📋 All quality gates passed - manual merge approval recommended"
osascript -e "display notification \"📢 Ready for Merge\" with title \"✅ Complete review passed - ready for main branch\" sound name \"Submarine\""
```

## Examples

### Slash Command Examples
```
/review add                         # Stage 1 only - basic validation before git add
/review commit                      # Stages 1-2 - quality check before git commit
/review push                        # Stages 1-3 - full validation before git push
/review merge                       # All stages - complete review before merge
/review src/ commit                 # Review src/ directory before committing
/review                            # All stages (default)
```

### Global Command Examples
```bash
# Development workflow
review add                          # Before staging files
review commit                       # Before committing changes
review push                         # Before pushing to remote
review merge                        # Before merging to main

# With specific directories
review src/ commit                  # Review src/ before commit
review . push                       # Review current dir before push

# Using aliases (after installation)
ro add                              # Quick basic validation (alias)
review commit                       # Quality check before commit
```

## Output
- Individual reports for each reviewer type
- Aggregated comprehensive report
- Automatic code fixes applied
- Before/after comparisons
- Prioritized remaining issues
