---
description: Aggregate insights from log files and suggest additions to LEARNED_LESSONS.md
---

<context>
You are helping the user extract valuable insights from their Claude Code session logs and maintain a curated knowledge base of learned lessons. Throughout development sessions, important insights are marked with "★ Insight " in log files. These insights capture patterns, best practices, and discoveries that should be preserved for future reference.

This command automates the discovery, aggregation, and curation of these insights into a centralized LEARNED_LESSONS.md file.
</context>

<contemplation>
Development sessions generate valuable insights that often get lost:
- Effective parallelization patterns discovered during multi-agent orchestration
- Architectural decisions and their reasoning
- Performance optimization discoveries
- Security vulnerabilities caught and how they were identified
- Code review patterns that surface quality issues
- Tool usage patterns that improve efficiency

Without systematic capture, these insights disappear into log files and are never leveraged again. By aggregating insights periodically and maintaining a curated knowledge base, we create a continuous learning loop that improves development efficiency over time.
</contemplation>

## Your Task

<task>
Analyze Claude Code log files for marked insights and suggest additions to the LEARNED_LESSONS.md knowledge base.

**Primary Goals:**
1. Search all log files for "★ Insight " markers
2. Extract and categorize unique insights
3. Identify patterns and themes across insights
4. Generate suggestions for LEARNED_LESSONS.md
5. Avoid duplicates with existing learned lessons
6. Organize insights by category and impact
7. **Track last aggregation timestamp to avoid processing same insights repeatedly**

**Incremental Processing:**
The system maintains a timestamp file (`~/.claude/.insight-aggregation-timestamp`) that tracks when insights were last aggregated. This enables incremental processing:

- **Default behavior:** Process only NEW insights since last aggregation
- **Force all:** Use `--force-all` flag to reprocess all insights
- **Update timestamp:** Use `--update-timestamp` flag to mark current insights as processed

**Workflow:**

### Step 1: Check Last Aggregation Timestamp

Before scanning, check when insights were last processed:

```bash
# View last aggregation info
cat ~/.claude/.insight-aggregation-timestamp 2>/dev/null || echo "No previous aggregation found"
```

This file contains:
- `last_aggregation`: Unix timestamp of last run
- `last_aggregation_date`: Human-readable date
- `insights_processed`: Number of insights in last run

### Step 2: Scan Log Files for Insights

Search all JSONL log files in `~/.claude/projects/` for the "★ Insight " pattern.

**Use the helper script for extraction:**

```bash
# Incremental mode (default) - only process NEW insights since last aggregation
python3 ~/.claude/tools/extract-insights.py --since-last --output summary

# First-time run (no previous timestamp) - processes all insights
python3 ~/.claude/tools/extract-insights.py --output summary

# Force reprocess all insights (ignore timestamp)
python3 ~/.claude/tools/extract-insights.py --force-all --output summary

# Process and update timestamp in one command
python3 ~/.claude/tools/extract-insights.py --since-last --update-timestamp --output summary
```

**Or extract manually using Python to handle JSONL format:**

```python
import os
import re
from collections import defaultdict

insights = []
categories = defaultdict(list)

# Walk through all jsonl files
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.jsonl'):
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    # Find all occurrences of "★ Insight" with context
                    matches = re.finditer(
                        r'★ Insight\s+─+\\n(.+?)(?=\\n\\n##|\\n\\n\*\*Next|\\n\\n─{10,}|\\n\\n✅|$)',
                        content,
                        re.DOTALL
                    )

                    for match in matches:
                        insight_text = match.group(1).strip()
                        # Clean up escape sequences
                        insight_text = insight_text.replace('\\n', '\n').replace('\\"', '"')
                        insight_text = re.sub(r'\n{3,}', '\n\n', insight_text)

                        if len(insight_text) > 50:  # Filter out noise
                            insights.append({
                                'file': filepath.split('/')[-1],
                                'text': insight_text,
                                'timestamp': os.path.getmtime(filepath)
                            })
            except Exception:
                continue
```

### Step 2: Categorize Insights

Automatically categorize insights based on content keywords:

**Categories:**
- **Parallel Execution** - Keywords: parallel, concurrent, orchestration, multi-agent
- **Architecture & Design** - Keywords: architecture, design, pattern, hexagonal, clean
- **Performance** - Keywords: performance, optimization, speed, efficiency, resource
- **Security** - Keywords: security, vulnerability, auth, sanitize, validation
- **Code Review** - Keywords: review, quality, maintainability, readability
- **Testing** - Keywords: test, coverage, e2e, unit, integration
- **Tool Usage** - Keywords: agent, tool, command, workflow
- **Error Handling** - Keywords: error, exception, failure, resilience
- **General** - Default category for uncategorized insights

### Step 3: Check Existing LEARNED_LESSONS.md

Read the current LEARNED_LESSONS.md file to avoid duplicates:

```bash
# Read existing learned lessons
cat ~/.claude/LEARNED_LESSONS.md 2>/dev/null || echo "# Learned Lessons\n\nNo lessons file exists yet."
```

Use semantic similarity to identify duplicate insights:
- Compare key phrases and concepts
- Flag insights that overlap >70% with existing lessons
- Mark unique insights for addition

### Step 4: Generate Suggestions

Create structured suggestions for LEARNED_LESSONS.md additions:

**Output Format:**

```markdown
# Insight Aggregation Report
**Generated:** [timestamp]
**Log Files Scanned:** [count]
**Total Insights Found:** [count]
**Unique Insights:** [count]
**Duplicate/Similar:** [count]

---

## 📊 Summary by Category

| Category | Count | New Insights | Duplicates |
|----------|-------|--------------|------------|
| Parallel Execution | X | Y | Z |
| Architecture & Design | X | Y | Z |
| Performance | X | Y | Z |
| Security | X | Y | Z |
| Code Review | X | Y | Z |
| Testing | X | Y | Z |
| Tool Usage | X | Y | Z |
| Error Handling | X | Y | Z |
| General | X | Y | Z |

---

## 💡 Suggested Additions to LEARNED_LESSONS.md

### Category: [Category Name]

#### Insight 1: [Brief Title]
**Source:** [log file name]
**Date:** [timestamp]
**Uniqueness:** New / Similar to existing lesson #X

**Content:**
[Full insight text, cleaned and formatted]

**Suggested Section:**
[Which section of LEARNED_LESSONS.md this belongs in]

**Priority:** High / Medium / Low
[Based on impact and applicability]

---

[Repeat for each unique insight]

---

## 🔄 Pattern Analysis

**Cross-Cutting Themes Identified:**
1. [Theme 1]: [Description and frequency]
2. [Theme 2]: [Description and frequency]
3. [Theme 3]: [Description and frequency]

**Emerging Patterns:**
- [Pattern 1 with insights that support it]
- [Pattern 2 with insights that support it]

**High-Impact Insights:**
[Top 5 insights by potential impact on future work]

---

## 📝 Recommendations

**Immediate Actions:**
1. Add [X] high-priority unique insights to LEARNED_LESSONS.md
2. Create new section for [emerging category]
3. Consolidate [Y] similar insights into single lesson

**Maintenance:**
1. Archive old insights from logs older than [timeframe]
2. Review LEARNED_LESSONS.md for outdated practices
3. Consider restructuring by [suggested organization]

**Next Steps:**
- [ ] Review suggested insights for accuracy
- [ ] Add selected insights to LEARNED_LESSONS.md
- [ ] Update CLAUDE.md with new patterns
- [ ] Share high-impact insights with team
```

### Step 5: Interactive Review (Optional)

After generating suggestions, offer to:
1. Show insights one at a time for user approval
2. Automatically add all unique high-priority insights
3. Create a draft LEARNED_LESSONS.md update for review
4. Export insights to separate files by category

### Step 6: Update LEARNED_LESSONS.md

If user approves, update the file following this structure:

```markdown
# Learned Lessons

**Last Updated:** [timestamp]
**Total Lessons:** [count]

---

## 🚀 Parallel Execution & Orchestration

### [Date] - [Lesson Title]
**Context:** [When/where this was learned]

**Lesson:**
[The insight content]

**Application:**
[How to apply this in future work]

**Related:** [Links to other lessons or documentation]

---

[Repeat for each category]
```

</task>

## Implementation Notes

<instructions>
**Key Requirements:**

1. **Deduplication Logic:**
   - Compare new insights against existing LEARNED_LESSONS.md
   - Use semantic similarity (not just exact string matching)
   - Flag insights that overlap >70% as potential duplicates
   - Preserve user choice to add similar insights if they add new context

2. **Categorization Accuracy:**
   - Use keyword matching as baseline
   - Consider context and content structure
   - Allow insights to belong to multiple categories
   - Default to "General" only when truly ambiguous

3. **Quality Filtering:**
   - Minimum insight length: 50 characters
   - Filter out noise (repeated patterns, malformed text)
   - Prioritize insights with concrete examples or metrics
   - Prefer insights with actionable takeaways

4. **Timestamp Handling:**
   - Extract timestamps from log file modification times
   - Sort insights chronologically within categories
   - Track when insights were added to LEARNED_LESSONS.md
   - Enable "recent insights" view (last 7/30/90 days)

5. **Output Format:**
   - Use clear markdown formatting with emoji indicators
   - Include metrics and statistics for transparency
   - Provide actionable recommendations, not just data
   - Support both summary view and detailed view

6. **Integration Points:**
   - Check for existing LEARNED_LESSONS.md structure
   - Respect user's custom categories if they exist
   - Maintain consistent formatting with existing content
   - Preserve manual edits and annotations

7. **Error Handling:**
   - Handle missing or malformed log files gracefully
   - Continue processing if individual files fail
   - Report parsing errors without stopping analysis
   - Provide partial results if full scan incomplete

**Best Practices:**

- Run this command weekly or monthly to capture insights regularly
- Review suggestions before automatic addition to maintain quality
- Archive old log files after extracting insights
- Use this as input for team knowledge sharing sessions
- Cross-reference insights with architecture documentation
</instructions>

## Example Usage

<example>
**Scenario 1: Regular Maintenance (Weekly/Monthly)**
```bash
# User runs regular insight aggregation
/aggregate-insights

# System checks last aggregation: 2025-10-29 14:30:00
# Scans only log files modified since that timestamp
# Finds 5 new insights across 3 categories
# User reviews and approves 4 high/medium priority insights
# LEARNED_LESSONS.md updated automatically
# Timestamp updated to current time
```

**Scenario 2: First-Time Setup**
```bash
# User runs command for the first time
/aggregate-insights

# No previous timestamp found - processes ALL log files
# Finds 47 insights across 8 categories
# Identifies 12 duplicates, suggests 35 unique additions
# User reviews top 15 high-priority insights
# Adds to LEARNED_LESSONS.md
# Timestamp created for future incremental runs
```

**Scenario 3: After Major Feature Development**
```bash
# User completes 2-week feature sprint with extensive agent usage
# Runs command to capture fresh insights while context is hot
/aggregate-insights

# Checks timestamp: 2025-10-28 (before sprint started)
# Processes only sprint-related logs (last 14 days)
# Finds 8 insights about parallel orchestration
# Identifies new pattern: "Multi-agent coordination with shared state"
# Suggests new section in LEARNED_LESSONS.md
# User reviews, adds insights, updates timestamp
```

**Scenario 4: Force Reprocess (After Timestamp File Issues)**
```bash
# User suspects some insights were missed or wants to reanalyze
/aggregate-insights --force-all

# Ignores timestamp, processes ALL log files
# Useful for rebuilding LEARNED_LESSONS.md from scratch
# Or when timestamp file is corrupted/deleted
# User can selectively add insights that were previously missed
```

**Scenario 5: Knowledge Transfer**
```bash
# New team member onboarding
# Run command to show recent insights (last 90 days)
/aggregate-insights --recent-days 90

# Bypasses timestamp, uses explicit time window
# Command generates onboarding guide from recent lessons
# Highlights high-impact patterns and best practices
# Provides concrete examples from actual development sessions
```
</example>

## Success Criteria

<validation>
Command execution is successful when:

1. **Completeness:**
   - All log files in ~/.claude/projects/ scanned
   - All "★ Insight " markers extracted
   - No parsing errors that block analysis

2. **Accuracy:**
   - Insights correctly categorized (>90% accuracy)
   - Duplicates properly identified
   - Timestamps and sources accurate

3. **Actionability:**
   - Clear suggestions for LEARNED_LESSONS.md additions
   - Priority levels help guide decisions
   - Recommendations are specific and implementable

4. **Quality:**
   - Noise and malformed insights filtered out
   - Insights provide genuine value
   - Content is coherent and well-formatted

5. **Usability:**
   - Output is readable and well-organized
   - User can easily approve/reject suggestions
   - LEARNED_LESSONS.md remains well-structured

6. **Efficiency:**
   - Command completes in <60 seconds for typical log volume
   - Memory usage reasonable (<500MB)
   - Handles large log files (>1GB total) gracefully
</validation>

---

**Note:** This command is designed to be run periodically (weekly/monthly) to maintain a living knowledge base of lessons learned. The insights captured represent real-world discoveries from your development sessions and should be curated, not just dumped, to maintain high signal-to-noise ratio.
