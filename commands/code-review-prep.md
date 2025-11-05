---
description: Author pre-PR preparation - validates code quality, generates PR description, and checks review readiness
---

<context>
You are helping an author prepare their pull request before opening it. Your goal is to validate code quality, catch common issues, generate a helpful PR description, and ensure the PR is ready for review.

This command implements the "Author Pre-Flight Checklist" from the code-review-skill, automating as much as possible to save author time and ensure reviewer-friendly PRs.
</context>

<contemplation>
Authors often skip important preparation steps, leading to:
- PRs with missing context (reviewers waste time asking questions)
- Obvious issues that could have been caught locally (wasted review cycles)
- Large, unfocused PRs (poor review quality)
- Missing tests or documentation

Automating the pre-flight checklist catches these issues before reviewer involvement, saving time and improving PR quality.
</contemplation>

## Your Task

<task>
Prepare the current branch for PR by running automated checks and generating helpful artifacts.

**Primary Goals:**
1. Validate code quality (tests, lint, types)
2. Analyze PR size and scope
3. Generate PR description from git diff
4. Identify potential reviewers from CODEOWNERS
5. Check for common issues (debug code, secrets, etc.)
6. Provide readiness assessment

**Workflow:**
1. **Check current git state**
   - Verify on a feature branch (not main/master)
   - Identify commits since divergence from main
   - Calculate lines changed

2. **Run quality gates**
   - Tests: Run test suite, report results
   - Linting: Check for linting errors
   - Types: Verify TypeScript compilation (if applicable)
   - Security: Check for hardcoded secrets, console.log, debugger

3. **Analyze changes**
   - PR size (line count, file count)
   - Scope (single purpose or mixed concerns?)
   - Affected areas (frontend, backend, tests, docs)
   - Modified file patterns

4. **Generate PR description**
   - Context: Infer from commit messages and file changes
   - Changes: Summarize modifications by category
   - Test plan: Suggest tests to run based on changes
   - Deployment notes: Identify migrations, breaking changes, etc.

5. **Suggest reviewers**
   - Parse CODEOWNERS file if exists
   - Match changed files to ownership patterns
   - Suggest 1-2 appropriate reviewers

6. **Readiness assessment**
   - Green: Ready to open PR
   - Yellow: Minor issues, address or document
   - Red: Blocking issues, fix before opening

**Output Format:**
```markdown
# PR Preparation Summary

## ✅ Quality Gates
- [x] Tests: Passing (47/47)
- [x] Lint: No errors
- [x] Types: Compiled successfully
- [x] No debug code found
- [x] No secrets detected

## 📊 PR Analysis
- **Size:** 287 lines changed (good, under 400 line target)
- **Files:** 8 files modified
- **Scope:** Single feature (user profile editing)
- **Affected areas:** Frontend (components), Backend (API), Tests

## 📝 Generated PR Description

### Context
[Inferred context from commits and changes]

### Changes
- [High-level summary of modifications]
- [Grouped by category]

### Test Plan
- [ ] Unit tests: npm test src/components/ProfileEdit.test.tsx
- [ ] Manual testing: [Suggested steps based on changes]

### Deployment Notes
- [ ] Database migration: No
- [ ] Breaking changes: No
- [ ] Rollback plan: Standard

## 👥 Suggested Reviewers
Based on CODEOWNERS:
- @frontend-team (modified src/components/)
- @backend-team (modified src/api/)

## 🎯 Readiness Assessment
✅ **Ready to open PR!**

All quality gates passed, PR size is good, scope is clear.

**Next steps:**
1. Copy generated PR description
2. Open PR on GitHub/GitLab
3. Paste description into PR body
4. Assign suggested reviewers
5. Add relevant labels
```
</task>

## Implementation Steps

<implementation_plan>
<step n="1" validation="git_state_verified">
**Check Git State**

```bash
# Verify on feature branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "⚠️  WARNING: You're on $CURRENT_BRANCH. Create a feature branch first."
  exit 1
fi

# Get main branch name (main or master)
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "⚠️  You have uncommitted changes. Commit them first."
  exit 1
fi

# Get diff stats
git diff --stat $MAIN_BRANCH...HEAD
```
</step>

<step n="2" validation="quality_gates_checked">
**Run Quality Gates**

Run in parallel for speed:

```bash
# Tests
npm test > test-results.txt 2>&1 &
TEST_PID=$!

# Linting
npm run lint > lint-results.txt 2>&1 &
LINT_PID=$!

# Type checking (if TypeScript project)
if [ -f "tsconfig.json" ]; then
  npm run type-check > type-results.txt 2>&1 &
  TYPE_PID=$!
fi

# Wait for all to complete
wait $TEST_PID $LINT_PID $TYPE_PID

# Parse results
# [Analyze exit codes and output]
```

**Security Checks:**
```bash
# Check for common issues
git diff $MAIN_BRANCH...HEAD | grep -E "(console\.(log|debug|warn)|debugger|TODO|FIXME)"
git diff $MAIN_BRANCH...HEAD | grep -E "(password|secret|api_key|apiKey|token).*=.*['\"]"
```
</step>

<step n="3" validation="pr_analyzed">
**Analyze PR**

```bash
# Get line counts
ADDITIONS=$(git diff $MAIN_BRANCH...HEAD --numstat | awk '{sum+=$1} END {print sum}')
DELETIONS=$(git diff $MAIN_BRANCH...HEAD --numstat | awk '{sum+=$2} END {print sum}')
TOTAL=$(( ADDITIONS + DELETIONS ))

# Get file counts
FILES_CHANGED=$(git diff $MAIN_BRANCH...HEAD --name-only | wc -l)

# Categorize changes
FRONTEND_FILES=$(git diff $MAIN_BRANCH...HEAD --name-only | grep -E "src/(components|pages|styles)" | wc -l)
BACKEND_FILES=$(git diff $MAIN_BRANCH...HEAD --name-only | grep -E "src/(api|services|database)" | wc -l)
TEST_FILES=$(git diff $MAIN_BRANCH...HEAD --name-only | grep -E "\.(test|spec)\." | wc -l)

# Assess size
if [ $TOTAL -lt 200 ]; then
  SIZE_ASSESSMENT="✅ Small PR (< 200 lines) - quick review"
elif [ $TOTAL -lt 400 ]; then
  SIZE_ASSESSMENT="✅ Good size (< 400 lines) - manageable review"
elif [ $TOTAL -lt 800 ]; then
  SIZE_ASSESSMENT="⚠️  Large PR (400-800 lines) - consider splitting"
else
  SIZE_ASSESSMENT="❌ Very large PR (> 800 lines) - should be split"
fi
```
</step>

<step n="4" validation="description_generated">
**Generate PR Description**

```bash
# Get commit messages since divergence
COMMITS=$(git log $MAIN_BRANCH..HEAD --pretty=format:"%s")

# Get file changes summary
FILES=$(git diff $MAIN_BRANCH...HEAD --name-only)

# Use this data to infer context and generate description
# [AI generates description based on commits and file changes]
```

Use commit messages and file diff to generate:
- **Context**: Why is this needed? (infer from commits)
- **Changes**: What changed? (summarize by category)
- **Test Plan**: What to test? (based on affected files)
- **Deployment Notes**: Any special considerations? (detect migrations, env changes)
</step>

<step n="5" validation="reviewers_suggested">
**Suggest Reviewers**

```bash
# Check if CODEOWNERS exists
if [ -f ".github/CODEOWNERS" ] || [ -f "CODEOWNERS" ]; then
  # Parse CODEOWNERS and match changed files
  # [Extract owners for changed file patterns]
else
  echo "No CODEOWNERS file found. Consider creating one with /code-review-init"
fi
```
</step>

<step n="6" validation="readiness_assessed">
**Assess Readiness**

Combine all checks:
- ✅ Green: All gates pass, size good, scope clear
- ⚠️  Yellow: Minor issues (nits, suggestions)
- ❌ Red: Blocking issues (failing tests, too large, etc.)

Provide actionable next steps based on assessment.
</step>
</implementation_plan>

## Special Considerations

<special_cases>
**If tests are failing:**
- Show which tests failed
- Don't block on test failures, but warn strongly
- Suggest running `/fix-tests` to address

**If PR is too large:**
- Suggest splitting strategies
- Offer to help identify split points
- Explain why size matters for review quality

**If no CODEOWNERS:**
- Suggest running `/code-review-init` to create one
- For now, suggest reviewers based on git blame of changed files

**If on main/master branch:**
- Stop and instruct to create feature branch first
- Explain why feature branches matter

**If security issues found:**
- Flag prominently in readiness assessment
- Run `/review-security` for detailed analysis
- Block with red assessment
</special_cases>

## Examples

<example>
**Scenario:** Small feature addition, all tests passing

```bash
User: /code-review-prep

# Claude runs checks and responds:

# PR Preparation Summary

## ✅ Quality Gates
- [x] Tests: All passing (23/23)
- [x] Lint: No errors
- [x] Types: Compiled successfully
- [x] No debug code found
- [x] No secrets detected

## 📊 PR Analysis
- **Size:** 187 lines changed (✅ great, well under 400 line target)
- **Files:** 4 files modified
- **Scope:** Single feature (add export button to dashboard)
- **Affected areas:** Frontend (1 component), Tests (1 test file)

## 📝 Generated PR Description

### Context
Users requested ability to export dashboard data to CSV. This addresses issue #456 and enables data analysis in external tools.

### Changes
- Added ExportButton component to Dashboard
- Implemented CSV generation from dashboard data
- Added unit tests for export functionality
- Updated Dashboard component to include export button

### Test Plan
- [ ] Unit tests: `npm test src/components/Dashboard.test.tsx`
- [ ] Manual testing:
  1. Open dashboard
  2. Click "Export" button
  3. Verify CSV downloads with correct data
  4. Test with empty dashboard (should show appropriate message)
  5. Test with large dataset (> 1000 rows)

### Deployment Notes
- [ ] Database migration: No
- [ ] Feature flag: No (enable immediately)
- [ ] Configuration changes: No
- [ ] Breaking changes: No
- [ ] Rollback plan: Standard deployment rollback

## 👥 Suggested Reviewers
Based on CODEOWNERS:
- @frontend-team (modified src/components/Dashboard.tsx)

## 🎯 Readiness Assessment
✅ **Ready to open PR!**

All quality gates passed, PR size is excellent, scope is crystal clear. This looks great!

**Next steps:**
1. Copy the generated PR description above
2. Open PR on GitHub: `gh pr create` or via web UI
3. Paste description into PR body
4. Assign @frontend-team as reviewers
5. Add label: `feature`

**Estimated review time:** 15-20 minutes (small, focused PR)
```
</example>

## Integration with Code Review Skill

<integration>
This command is part of the code-review-skill and implements the "Author Pre-Flight Checklist" methodology.

**Related commands:**
- `/code-review-init` - Generate PR template and CODEOWNERS
- `/code-review-metrics` - Track review health metrics
- `/review-orchestrator commit` - Alternative full quality check

**Related guides:**
- See `.claude/skills/code-review-skill/playbook/author-guide.md` for detailed guidance
- See `.claude/skills/code-review-skill/templates/author-checklist.md` for manual checklist
</integration>

---

**Note:** This command automates the author preparation workflow. Run it before opening any PR to ensure reviewer-friendly, high-quality pull requests.
