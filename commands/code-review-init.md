---
description: Initialize code review infrastructure - generates PR template, CODEOWNERS, and team documentation
---

<context>
You are helping a team initialize code review best practices in their repository. Your goal is to generate the necessary files (PR template, CODEOWNERS, documentation) and provide guidance on team adoption.

This command sets up the infrastructure for high-quality code reviews, making it easy for the team to follow best practices.
</context>

<contemplation>
Teams want better code review practices but don't know where to start. Setting up infrastructure (templates, CODEOWNERS, docs) makes it easy to do the right thing.

The key is providing sensible defaults that teams can customize, not imposing rigid requirements.
</contemplation>

## Your Task

<task>
Initialize code review infrastructure for the current repository by generating files and providing setup guidance.

**Primary Goals:**
1. Generate PR template (`.github/pull_request_template.md` or `.gitlab/merge_request_templates/default.md`)
2. Generate CODEOWNERS file with team structure
3. Create code review documentation in `docs/`
4. Provide team adoption guidance
5. Suggest next steps for rollout

**Workflow:**
1. **Detect repository type and structure**
   - Git provider: GitHub, GitLab, Bitbucket, or generic
   - Project type: Node.js, Python, Go, etc.
   - Team structure: Infer from existing files or ask user

2. **Generate PR template**
   - Use skill template as base
   - Customize for detected project type
   - Add platform-specific features (if applicable)
   - Place in correct location for git provider

3. **Generate CODEOWNERS**
   - Ask user about team structure
   - Generate ownership patterns based on directory structure
   - Include helpful comments and examples
   - Place in correct location

4. **Create documentation**
   - Copy relevant playbook guides to `docs/`
   - Create `docs/code-review-guide.md` with team-specific guidance
   - Link to skill documentation for details

5. **Provide adoption plan**
   - Phased rollout strategy
   - Quick wins to demonstrate value
   - Metrics to track
   - Common objections and responses

**Output Format:**
```markdown
# Code Review Infrastructure Initialized 🎉

## ✅ Files Created

### PR Template
📄 `.github/pull_request_template.md`
- Context, Changes, Test Plan, Deployment Notes sections
- Security considerations checklist
- Author pre-PR checklist

### CODEOWNERS
📄 `.github/CODEOWNERS`
- Frontend: @frontend-team
- Backend: @backend-team
- Infrastructure: @devops-team
- Security-critical paths: @security-team

### Documentation
📄 `docs/code-review-guide.md` - Team code review standards
📄 `docs/code-review-author-checklist.md` - Author preparation guide
📄 `docs/code-review-reviewer-checklist.md` - Reviewer process guide

## 🚀 Next Steps

### Immediate (Today)
1. Review and customize generated files for your team
2. Commit and push to repository
3. Share with team in next standup

### Week 1-2: Individual Adoption
- You + 1-2 teammates try new practices
- Use PR template and author checklist
- Track improvements (review time, etc.)

### Week 3-4: Team Pilot
- Expand to 50% of team
- Establish SLAs (24h first response)
- Start tracking metrics

### Month 2+: Full Rollout
- All team members using practices
- Monthly metrics review
- Iterate based on feedback

## 📊 Metrics to Track
- Review latency (target: < 24h)
- Merge latency (target: < 5 days)
- PR size (target: 80% under 400 lines)
- Review depth (target: 2-5 comments/PR)

Run `/code-review-metrics` monthly to track progress.

## 💡 Quick Wins

**For Authors:**
- "My PRs merged 60% faster with better descriptions"
- "Self-review checklist caught issues before embarrassment"

**For Reviewers:**
- "PR template made reviews 30% faster"
- "Two-pass review keeps me focused"
- "Comment classification reduced friction"

## ❓ Common Questions

**"Won't this slow us down?"**
Actually speeds things up by reducing review cycles. Data shows PRs with good descriptions merge 2-3x faster.

**"Do we have to follow this rigidly?"**
No - these are guidelines, not rules. Customize for your team's needs.

**"What if people don't use the template?"**
Lead by example first. Once value is proven, can make it standard practice.

## 📚 Resources

For detailed guidance, see:
- `.claude/skills/code-review-skill/SKILL.md` - Complete methodology
- `.claude/skills/code-review-skill/playbook/` - Detailed guides
- `docs/code-review-guide.md` - Your team's guide

**Commands:**
- `/code-review-prep` - Author preparation before opening PR
- `/code-review-metrics` - Track review health metrics
```
</task>

## Implementation Steps

<implementation_plan>
<step n="1" validation="repo_detected">
**Detect Repository Structure**

```bash
# Detect git provider
if [ -d ".github" ]; then
  GIT_PROVIDER="github"
elif [ -d ".gitlab" ]; then
  GIT_PROVIDER="gitlab"
else
  GIT_PROVIDER="generic"
fi

# Detect project type
if [ -f "package.json" ]; then
  PROJECT_TYPE="nodejs"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  PROJECT_TYPE="python"
elif [ -f "go.mod" ]; then
  PROJECT_TYPE="go"
else
  PROJECT_TYPE="generic"
fi

# Check existing directory structure for ownership patterns
find src -type d -maxdepth 2 2>/dev/null | head -20
```
</step>

<step n="2" validation="pr_template_created">
**Generate PR Template**

Based on git provider:

**GitHub:**
```bash
mkdir -p .github
cp .claude/skills/code-review-skill/templates/pr-template.md .github/pull_request_template.md
```

**GitLab:**
```bash
mkdir -p .gitlab/merge_request_templates
cp .claude/skills/code-review-skill/templates/pr-template.md .gitlab/merge_request_templates/default.md
```

**Generic:**
```bash
mkdir -p docs
cp .claude/skills/code-review-skill/templates/pr-template.md docs/PR_TEMPLATE.md
echo "ℹ️  Created PR template in docs/. Integrate with your git provider as needed."
```

Customize template based on project type:
- Add project-specific test commands
- Include language-specific sections
- Add deployment platform details
</step>

<step n="3" validation="codeowners_created">
**Generate CODEOWNERS**

**Ask user about team structure:**

<user_question>
Questions to ask:
1. "What teams do you have?" (e.g., frontend, backend, devops, qa)
2. "What are the main areas of your codebase?" (e.g., src/components, src/api)
3. "Are there security-critical paths?" (e.g., src/auth, src/payments)
4. "Any individual experts for specific subsystems?" (optional)
</user_question>

**Generate CODEOWNERS from template:**

```bash
# GitHub/Generic
cp .claude/skills/code-review-skill/templates/codeowners-template.md .github/CODEOWNERS

# GitLab
cp .claude/skills/code-review-skill/templates/codeowners-template.md .gitlab/CODEOWNERS
```

**Customize based on user input:**
- Replace generic team names with actual teams
- Map code directories to teams
- Add security-critical path overrides
- Include helpful comments

**Example customization:**
```
# User says: "We have frontend-team, backend-team, and alice is our DB expert"

# Generate:
/src/components/     @frontend-team
/src/api/            @backend-team
/src/database/       @backend-team @alice
```
</step>

<step n="4" validation="docs_created">
**Create Documentation**

```bash
mkdir -p docs

# Create main guide
cat > docs/code-review-guide.md <<EOF
# Code Review Guide

This guide outlines our team's code review practices...
[Team-specific content]

For detailed methodology, see: .claude/skills/code-review-skill/
EOF

# Copy checklists
cp .claude/skills/code-review-skill/templates/author-checklist.md docs/
cp .claude/skills/code-review-skill/templates/reviewer-checklist.md docs/
```

Customize `code-review-guide.md` with:
- Team SLAs (24h first response, 5d merge)
- PR size policies (< 400 lines target)
- When to use draft PRs
- Escalation process for blocked PRs
- Links to skill documentation for details
</step>

<step n="5" validation="adoption_plan_provided">
**Provide Adoption Plan**

Generate team-specific adoption plan based on team size and structure.

**For small teams (< 5 people):**
- Quick adoption (1-2 weeks)
- All team members start together
- Informal process, focus on habits

**For medium teams (5-15 people):**
- Phased rollout (4-6 weeks)
- Pilot with 2-3 members first
- Establish metrics and iterate

**For large teams (> 15 people):**
- Extended rollout (2-3 months)
- Multiple pilot groups
- Formal training and onboarding
- Dedicated metrics tracking

Include:
- Timeline
- Responsibilities
- Success metrics
- Common objections and responses
</step>
</implementation_plan>

## User Interaction

<user_interaction>
**Gather team information interactively:**

1. **Team structure:**
   > "Let's set up CODEOWNERS. What teams do you have? (e.g., frontend, backend, qa, devops)"

   User: "frontend-team, backend-team, infra-team"

2. **Code organization:**
   > "Great! What are your main code directories?"

   User: "src/client for frontend, src/server for backend, infrastructure/ for infra"

3. **Security-critical areas:**
   > "Are there any security-critical paths that need special review? (auth, payments, etc.)"

   User: "src/server/auth and src/server/payments"

4. **Individual experts (optional):**
   > "Any individual experts who should be owners of specific subsystems? (optional)"

   User: "Alice for database, Bob for the ML pipeline"

**Use responses to generate customized CODEOWNERS.**
</user_interaction>

## Customization Examples

<examples>
**Example 1: Node.js/React project with typical structure**

Generated CODEOWNERS:
```
# Frontend
/src/components/      @frontend-team
/src/pages/           @frontend-team
/src/hooks/           @frontend-team
/src/styles/          @frontend-team

# Backend
/src/api/             @backend-team
/src/services/        @backend-team
/src/database/        @backend-team

# Shared utilities
/src/utils/           @frontend-team @backend-team

# Tests
**/*.test.ts          @frontend-team @backend-team

# Infrastructure
/.github/             @infra-team
/docker/              @infra-team
```

Generated PR template sections:
```markdown
## Test Plan
- [ ] Unit tests: `npm test`
- [ ] E2E tests: `npm run test:e2e`
- [ ] Lint: `npm run lint`
- [ ] Type check: `npm run type-check`
```

**Example 2: Python/Django project**

Generated CODEOWNERS:
```
# Django apps
/apps/users/          @backend-team
/apps/api/            @backend-team
/apps/admin/          @backend-team @admin-team

# Frontend (if applicable)
/frontend/            @frontend-team

# Infrastructure
/infrastructure/      @devops-team
/terraform/           @devops-team

# Tests
**/tests/             @backend-team @qa-team
```

Generated PR template sections:
```markdown
## Test Plan
- [ ] Unit tests: `pytest`
- [ ] Integration tests: `pytest --integration`
- [ ] Lint: `flake8` and `black --check`
- [ ] Type check: `mypy`
```

**Example 3: Go microservices project**

Generated CODEOWNERS:
```
# Services
/services/auth/       @backend-team @security-team
/services/api/        @backend-team
/services/worker/     @backend-team

# Shared packages
/pkg/                 @backend-team

# Infrastructure
/k8s/                 @devops-team
/terraform/           @devops-team

# Tests
**/*_test.go          @backend-team
```

Generated PR template sections:
```markdown
## Test Plan
- [ ] Unit tests: `go test ./...`
- [ ] Integration tests: `go test ./... -tags=integration`
- [ ] Lint: `golangci-lint run`
```
</examples>

## Special Considerations

<special_cases>
**If files already exist:**
- Don't overwrite existing files
- Show diff of what would change
- Offer to merge or create alternative versions
- Example: Create `.github/pull_request_template_claude.md` if template exists

**If no team structure:**
- Offer simplified CODEOWNERS with placeholders
- Suggest reviewing with team lead
- Provide examples of common structures

**If monorepo:**
- Ask about workspace/package structure
- Generate CODEOWNERS per workspace
- Consider package-level ownership

**If team is resistant:**
- Emphasize opt-in approach
- Start with just PR template (lowest overhead)
- Provide data on benefits from similar teams
- Suggest pilot with volunteer sub-team
</special_cases>

## Integration with Code Review Skill

<integration>
This command sets up infrastructure for the code-review-skill methodology.

**Related commands:**
- `/code-review-prep` - Author prepares PR using infrastructure
- `/code-review-metrics` - Track effectiveness of practices
- `/review-orchestrator` - Automated quality checks

**Related files:**
- `.claude/skills/code-review-skill/` - Complete methodology and guides
- Generated files integrate with skill documentation
</integration>

---

**Note:** This command is typically run once per repository to set up infrastructure. Customize generated files for your team's specific needs.
