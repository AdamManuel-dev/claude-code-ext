---
description: Track code review health metrics - analyze review latency, PR size, quality indicators, and team performance
---

<context>
You are analyzing code review metrics from git history to assess review health and identify improvement opportunities. Your goal is to provide actionable insights that help teams optimize their code review process.

This command implements metrics tracking from the code-review-skill, measuring what matters for code review effectiveness.
</context>

<contemplation>
Teams need visibility into code review health to:
- Identify bottlenecks (slow reviews, large PRs)
- Measure improvement over time
- Justify continued investment in practices
- Catch anti-patterns early

Metrics should be actionable, not just numbers—every metric should suggest a concrete improvement if it's off-target.
</contemplation>

## Your Task

<task>
Analyze git history and PR data to generate a code review health dashboard with actionable recommendations.

**Primary Metrics:**
1. **Review Latency**: Time from PR open to first review
2. **Merge Latency**: Time from PR open to merge
3. **PR Size Distribution**: Lines changed per PR
4. **Review Depth**: Comments per PR (proxy for engagement)
5. **SLA Compliance**: % meeting response time targets
6. **Reviewer Distribution**: Load balance across team

**Workflow:**
1. **Gather data from git/GitHub/GitLab**
   - PR open/merge timestamps
   - Review timestamps
   - PR sizes (lines changed)
   - Comment counts
   - Reviewer assignments

2. **Calculate core metrics**
   - Averages, medians, distributions
   - Compare to targets (24h review, 5d merge, 80% under 400 lines)
   - Identify trends (improving or degrading)

3. **Identify anti-patterns**
   - Monster PRs (> 800 lines)
   - Stale PRs (> 10 days open)
   - Ghost reviewers (assigned but no response)
   - Rubber stamps (approved in < 2 minutes)

4. **Generate recommendations**
   - Specific, actionable improvements
   - Based on data, not assumptions
   - Prioritized by impact

5. **Output dashboard**
   - Visual summary (ASCII charts if possible)
   - Metrics with targets
   - Trends over time
   - Top action items

**Output Format:**
```markdown
# Code Review Health Dashboard

**Analysis Period:** Last 30 days (Oct 5 - Nov 5, 2024)
**PRs Analyzed:** 47

---

## 📊 Core Metrics

### Review Latency
⏱️  **18.5 hours** avg time to first review
✅ **Target: < 24 hours** - MEETING TARGET

**Distribution:**
< 6 hours:  ████████████████░░░░ (42% - 20 PRs)
6-24 hours: ████████████░░░░░░░░ (32% - 15 PRs)
24-48 hours: ███████░░░░░░░░░░░░ (19% - 9 PRs)
> 48 hours:   ███░░░░░░░░░░░░░░░ (6% - 3 PRs)

**Trend:** ↗️ Improved 22% from last month (23.7h → 18.5h)

### Merge Latency
⏱️  **3.2 days** avg time to merge
✅ **Target: < 5 days** - MEETING TARGET

**Trend:** ↗️ Improved 18% from last month (3.9d → 3.2d)

### PR Size Distribution
📏 **82%** of PRs under 400 lines
✅ **Target: > 80%** - MEETING TARGET

**Distribution:**
< 200 lines:   ████████████████████████ (51% - 24 PRs)
200-400 lines: ███████████████░░░░░░░░░ (31% - 15 PRs)
400-800 lines: █████░░░░░░░░░░░░░░░░░░░ (13% - 6 PRs)
> 800 lines:   ██░░░░░░░░░░░░░░░░░░░░░░ (4% - 2 PRs)

**Largest PR:** #456 (1,247 lines) - Auth refactor
**Action:** Consider splitting large refactors

### Review Depth
💬 **3.8 comments** avg per PR
✅ **Target: 2-5 comments** - HEALTHY

**Trend:** → Stable from last month (3.6 → 3.8)

### SLA Compliance
✅ **89%** of PRs reviewed within 24h
⚠️  **Target: > 90%** - CLOSE, NEEDS IMPROVEMENT

**Missed SLA PRs (5):**
- PR #461: 52h (assigned to @alice who was OOO)
- PR #445: 36h (complex security change)
- PR #439: 41h (Friday evening PR)
- PR #432: 28h (no clear owner)
- PR #428: 30h (large refactor)

---

## 👥 Team Performance

### Reviewer Distribution
**PRs Reviewed (Last 30 Days):**

@alice:    ████████████████████░░░ (23 PRs) - 49%
@bob:      ████████████████░░░░░░░ (18 PRs) - 38%
@charlie:  ███░░░░░░░░░░░░░░░░░░░░ (6 PRs)  - 13%

⚠️  **ALERT: Uneven distribution**
- @alice is carrying nearly half the load
- @charlie may be underutilized or has other responsibilities
- Consider rebalancing CODEOWNERS

### Review Speed by Reviewer
@bob:     ✅ 12.3h avg (fastest)
@charlie: ✅ 16.7h avg
@alice:   ⚠️  25.4h avg (slowest, possibly overloaded)

### Approval Patterns
- **Avg time to approve:** 2.1 days
- **Rubber stamps** (< 2 min): 2 PRs (4%) - acceptable
- **Thorough reviews** (> 10 min): 41 PRs (87%) - excellent
- **Multi-round** (> 2 rounds): 8 PRs (17%) - reasonable

---

## 🚨 Anti-Patterns Detected

### Monster PRs (> 800 lines)
Found **2 PRs** exceeding 800 lines:
- PR #456: 1,247 lines (auth refactor) - ⚠️  justified but large
- PR #442: 934 lines (UI redesign) - ⚠️  could have been split

**Recommendation:** Encourage splitting large changes or using feature flags for incremental delivery.

### Stale PRs (> 10 days open)
Found **1 PR** open longer than 10 days:
- PR #434: 14 days (waiting on design review)

**Recommendation:** Set up escalation process for blocked PRs.

### Ghost Reviewers
**@alice** missed SLA on 3 PRs this month.
- Possible cause: Overload (23 PRs assigned vs 18 for @bob, 6 for @charlie)

**Recommendation:** Rebalance CODEOWNERS to distribute load more evenly.

### Bystander Effect (No Comments)
Found **3 PRs** merged without any review comments:
- PR #459: Small typo fix (acceptable)
- PR #447: Dependency update (acceptable)
- PR #438: Logic change (⚠️  should have had review)

**Recommendation:** Encourage reviewers to leave at least one comment (even [praise]) to show engagement.

---

## 🎯 Top Recommendations

### 1. Rebalance CODEOWNERS ⚡ HIGH IMPACT
**Problem:** @alice is overloaded (23 PRs vs team avg of 15.7)
**Solution:** Redistribute ownership patterns in `.github/CODEOWNERS`
**Expected Impact:** Reduce @alice's load by ~30%, improve review latency

**Action:**
```bash
# Update CODEOWNERS to spread load
/src/components/  @frontend-team   # (was @alice, @frontend-team)
/src/utils/       @frontend-team   # (was @alice)
```

### 2. Split Large PRs 📏 MEDIUM IMPACT
**Problem:** 4% of PRs exceed 800 lines, harder to review thoroughly
**Solution:** Encourage splitting, use feature flags for incremental delivery
**Expected Impact:** Better review quality, fewer bugs

**Action:**
- Add PR size check in CI (warn if > 400 lines, block if > 1000 unless justified)
- Share PR splitting guide from code-review-skill

### 3. Address Stale PRs 🕐 MEDIUM IMPACT
**Problem:** 1 PR open > 10 days (PR #434 blocked on design)
**Solution:** Establish escalation process for blocked PRs
**Expected Impact:** Faster resolution, less frustration

**Action:**
- Daily standup: Flag PRs open > 5 days
- Auto-comment on PRs open > 7 days: "This PR needs attention"

### 4. Improve SLA Compliance 📈 LOW IMPACT (Already Close)
**Problem:** 89% compliance vs 90% target
**Solution:** Focus on reducing @alice's load (already covered in #1)
**Expected Impact:** +3-5% compliance

---

## 📈 Trends (vs. Last 30 Days)

- Review Latency: ↗️ **+22%** improvement (23.7h → 18.5h)
- Merge Latency: ↗️ **+18%** improvement (3.9d → 3.2d)
- PR Size: ↗️ **+8%** more PRs under 400 lines (74% → 82%)
- Review Depth: → **Stable** (3.6 → 3.8 comments)
- SLA Compliance: ↗️ **+5%** improvement (84% → 89%)

**Overall Trend:** ✅ **IMPROVING**
Code review health is trending positively. Continue current practices and address recommendations above to maintain momentum.

---

## 🎉 Wins to Celebrate

- **Review latency under target** for first time in 3 months
- **PR size distribution** hitting 80% under 400 lines target
- **Review depth** healthy at 3.8 comments (engaged, not nitpicky)
- **Improvement trend** across all metrics month-over-month

**Share these wins in team meeting!** Recognition reinforces good behavior.

---

## 📅 Next Review

**Recommended Frequency:** Monthly

**Next Steps:**
1. Share this dashboard in team meeting
2. Implement top recommendations (rebalance CODEOWNERS)
3. Track metrics again in 30 days
4. Compare trends and adjust

Run `/code-review-metrics` again on **December 5, 2024** to track progress.
```
</task>

## Implementation Steps

<implementation_plan>
<step n="1" validation="data_gathered">
**Gather Git/PR Data**

**Option A: Using GitHub CLI (gh)**
```bash
# Get PRs from last 30 days
gh pr list --state closed --limit 100 --json number,title,createdAt,mergedAt,additions,deletions,reviews,comments,author

# Get PR review data
gh api repos/:owner/:repo/pulls/:pr_number/reviews

# Get PR comments
gh api repos/:owner/:repo/pulls/:pr_number/comments
```

**Option B: Using GitLab CLI (glab)**
```bash
# Get merge requests from last 30 days
glab mr list --closed --per-page 100

# Get MR details
glab mr view :mr_number --json
```

**Option C: Using git log (basic, no PR metadata)**
```bash
# Get commits from last 30 days
git log --since="30 days ago" --pretty=format:"%H|%an|%ae|%ai|%s" --numstat

# Infer PR info from merge commits
git log --since="30 days ago" --merges --first-parent --pretty=format:"%H|%ai|%s"
```

**Prefer GitHub/GitLab API when available for richer data.**
</step>

<step n="2" validation="metrics_calculated">
**Calculate Core Metrics**

```python
# Pseudocode for metric calculation

# Review Latency
review_latencies = []
for pr in prs:
    first_review_time = min(pr.reviews, key=lambda r: r.submitted_at)
    latency = first_review_time - pr.created_at
    review_latencies.append(latency.total_hours())

avg_review_latency = mean(review_latencies)
median_review_latency = median(review_latencies)

# Merge Latency
merge_latencies = []
for pr in prs:
    if pr.merged_at:
        latency = pr.merged_at - pr.created_at
        merge_latencies.append(latency.total_days())

avg_merge_latency = mean(merge_latencies)

# PR Size Distribution
pr_sizes = [(pr.additions + pr.deletions) for pr in prs]
under_200 = count(pr_sizes, lambda s: s < 200)
under_400 = count(pr_sizes, lambda s: s < 400)
# ... etc

# Review Depth
comment_counts = [len(pr.comments) for pr in prs]
avg_comments = mean(comment_counts)

# SLA Compliance
sla_met = count(review_latencies, lambda l: l < 24)
sla_compliance = (sla_met / len(prs)) * 100
```
</step>

<step n="3" validation="anti_patterns_identified">
**Identify Anti-Patterns**

```python
# Monster PRs
monster_prs = [pr for pr in prs if (pr.additions + pr.deletions) > 800]

# Stale PRs (still open > 10 days)
stale_prs = [pr for pr in open_prs if (now - pr.created_at).days > 10]

# Ghost reviewers (assigned but no review)
ghost_reviews = []
for pr in prs:
    assigned = pr.requested_reviewers
    reviewed = [r.user for r in pr.reviews]
    ghosts = set(assigned) - set(reviewed)
    if ghosts:
        ghost_reviews.append((pr, ghosts))

# Rubber stamps (approved in < 2 minutes)
rubber_stamps = []
for pr in prs:
    for review in pr.reviews:
        if review.state == "APPROVED":
            review_time = review.submitted_at - pr.created_at
            if review_time.total_minutes() < 2:
                rubber_stamps.append((pr, review))

# Bystander effect (merged without comments)
no_comment_prs = [pr for pr in prs if len(pr.comments) == 0 and pr.merged]
```
</step>

<step n="4" validation="recommendations_generated">
**Generate Recommendations**

Based on metrics and anti-patterns, prioritize recommendations:

**High Impact:**
- Address uneven reviewer distribution
- Fix blocking bottlenecks (stale PRs, ghost reviewers)

**Medium Impact:**
- Reduce PR sizes (if > 20% over 400 lines)
- Improve SLA compliance (if < 85%)

**Low Impact:**
- Fine-tune processes (already working well)
- Celebrate wins to reinforce behavior

**Make recommendations specific and actionable:**
- "Rebalance CODEOWNERS: move src/utils from @alice to @frontend-team"
- "Add PR size warning in CI at 400 lines, block at 1000 lines"
- "Set up daily standup checkin for PRs open > 5 days"
</step>

<step n="5" validation="trends_calculated">
**Calculate Trends**

Compare current period to previous period:

```python
# Get previous period data (e.g., previous 30 days)
prev_avg_review_latency = calculate_for_period(60_days_ago, 30_days_ago)
curr_avg_review_latency = calculate_for_period(30_days_ago, now)

# Calculate % change
change_pct = ((curr - prev) / prev) * 100

# Determine trend direction
if change_pct > 5:
    trend = "↗️ Improved"
elif change_pct < -5:
    trend = "↘️ Degraded"
else:
    trend = "→ Stable"
```
</step>

<step n="6" validation="dashboard_generated">
**Generate ASCII Dashboard**

Use simple ASCII art for visual representation:

```python
def generate_bar(value, max_value, width=20):
    filled = int((value / max_value) * width)
    return "█" * filled + "░" * (width - filled)

# Example: PR size distribution
print("< 200 lines:  ", generate_bar(under_200_count, total_prs), f"({under_200_pct}%)")
print("200-400 lines:", generate_bar(under_400_count, total_prs), f"({under_400_pct}%)")
```
</step>
</implementation_plan>

## Data Sources

<data_sources>
**Preferred: GitHub/GitLab API**
- Most complete data
- PR metadata (open/merge times, reviewers, comments)
- Review approval timestamps
- Requires `gh` or `glab` CLI, or API tokens

**Fallback: Git Log**
- Basic commit data
- Merge commit timestamps
- Less precise (no PR-level data)
- Works without external tools

**Best Practice:**
1. Try GitHub/GitLab API first
2. Fall back to git log if not available
3. Warn user if data is limited
</data_sources>

## Special Considerations

<special_cases>
**If no PR data available (git-only):**
- Calculate based on merge commits
- Estimate review latency from commit timestamps
- Warn that metrics are approximate
- Suggest setting up GitHub/GitLab for better tracking

**If insufficient data (< 10 PRs):**
- Warn that sample size is too small
- Show metrics but mark as "insufficient data"
- Suggest running again after more PRs merged

**If metrics are all red:**
- Don't be discouraging - frame as opportunity
- Provide specific, achievable first steps
- Highlight any bright spots
- Offer phased improvement plan

**If metrics are all green:**
- Celebrate wins prominently
- Identify next-level optimizations
- Encourage sharing learnings with other teams
- Suggest expanding practices (e.g., async reviews, pair reviews)
</special_cases>

## Integration with Code Review Skill

<integration>
This command tracks effectiveness of practices from code-review-skill.

**Related commands:**
- `/code-review-init` - Set up infrastructure to enable metrics
- `/code-review-prep` - Author workflow that metrics track
- `/review-orchestrator` - Quality checks that improve metrics

**Metrics align with skill targets:**
- Review latency < 24h (from skill SLA)
- Merge latency < 5d for medium PRs (from skill SLA)
- 80% of PRs under 400 lines (from skill size policy)
- 2-5 comments per PR (from skill review depth guidance)

**See also:**
- `.claude/skills/code-review-skill/playbook/team-adoption.md` - Adoption metrics
- `.claude/skills/code-review-skill/metrics/success-metrics.md` - Detailed metric definitions
</integration>

---

**Note:** Run this command monthly to track code review health and identify improvement opportunities. Share results in team meetings to maintain focus on continuous improvement.
