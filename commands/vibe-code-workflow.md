# Vibe Code Workflow

Execute a comprehensive development workflow based on the vibe coding methodology with enforced quality gates that prevent broken code from being committed or pushed.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

<instructions>
You are a Vibe Code Workflow Orchestrator responsible for executing a comprehensive development workflow with enforced quality gates.

PRIMARY OBJECTIVE: Implement a complete development cycle from research through deployment with mandatory quality enforcement at every critical checkpoint, ensuring no broken code enters the repository.
</instructions>

<context>
Development environment requiring systematic workflow execution with quality gates. The workflow encompasses research, planning, development, testing, documentation, and deployment phases with automated quality enforcement and comprehensive tracking.
</context>

<contemplation>
The vibe coding methodology emphasizes rapid development with uncompromising quality. This requires strategic balance between development velocity and code quality through automated gates that block progression until quality standards are met. The workflow must be comprehensive yet efficient, with clear checkpoints and recovery mechanisms.
</contemplation>

<phases>
<step name="Research & Planning">
**Phase 1: Deep Research & Documentation**
1. Deep research using Claude/Opus to analyze tooling needs
2. Create basic PRD document
3. Transform PRD → task-list.md
4. Enhance with dependencies → detailed-task-list.md
5. Extract critical-success-tasks.md (failure points)
6. Synthesize → imagediff-prd-detailed.md
7. Generate README.md from all notes
8. Create use-case documentation (e.g., figma-website-refinement-guide.md)
9. Generate TODO.md for vibe coding architecture
</step>

<step name="Development Cycle">
**Phase 2: Quality-Gated Development (Repeating)**
For each task in TODO/DAG:
1. Pick task and verify dependencies
2. Design & plan implementation
3. Initial coding
4. **Preliminary quality check** (informational only)
5. **Pre-commit validation** (BLOCKING):
   - Type checking (npm run typecheck/type-check)
   - Test execution (npm test)
   - Lint check (npm run lint)
   - ❌ If any fail → Commit blocked
   - ✅ If all pass → Commit allowed
6. Offers auto-fix options if checks fail:
   - Lint auto-fix
   - /fix-types integration
   - /fix-tests integration
7. Commit with message (only if quality gate passes)
8. Continue with next task or proceed to push
</step>

<step name="Final Push & Completion">
**Phase 3: Pre-Push Quality Validation**
1. **Pre-push validation** (BLOCKING):
   - Re-runs all quality checks
   - Type checking, tests, and lint must all pass
   - ❌ If any fail → Push blocked
   - ✅ If all pass → Push allowed
2. Push to feature branch (only if quality gate passes)
3. Create PR with comprehensive documentation
4. Workflow completion with quality metrics
</step>

<step name="Documentation & Archival">
**Phase 4: Documentation & TODO Updates**
1. Update TODO.md with completed tasks and new items discovered
2. Create documentation in /docs/{section.subsection}/ folder:
   - Implementation notes and decisions
   - Lessons learned and improvement suggestions
   - Architecture diagrams if applicable
   - API documentation for new features
3. Update project README with new features/changes
4. Archive workflow log to /docs/{section.subsection}/workflow-log.md
</step>
</phases>

<methodology>
**Quality Gates Enforcement:**

**Key Features:**
- ✅ **Quality Gates**: Enforces passing tests, type checks, and lint checks before allowing commits or pushes
- 🚦 **Pre-Commit Validation**: Blocks commits if quality checks fail
- 🚀 **Pre-Push Validation**: Re-runs all checks before pushing to ensure code quality
- 🔧 **Auto-Fix Integration**: Offers to run fix commands when checks fail

**Quality Enforcement Points:**
1. **Before Commit**: All tests, type checks, and lint must pass
2. **Before Push**: Re-validates all checks to ensure nothing broke
3. **Auto-Fix Support**: Offers to run fix commands when checks fail

**Advanced Features:**
- Interactive execution with user confirmation at each step
- Colored output for better visibility
- Workflow logging to `.vibe-workflow.log`
- State tracking for resume capability
- Integration with existing Claude commands (/fix-types, /fix-tests)
- Quality metrics tracking in documentation
</methodology>

<implementation_plan>
**Workflow Execution Strategy:**
1. **Research Phase**: Comprehensive analysis and documentation creation
2. **Planning Phase**: Task breakdown with dependency mapping
3. **Development Phase**: Quality-gated iterative development
4. **Validation Phase**: Multi-layer quality checking before commits/pushes
5. **Documentation Phase**: Comprehensive documentation and archival
6. **Completion Phase**: PR creation and workflow metrics reporting

**Quality Assurance Integration:**
- Mandatory pre-commit hooks for type checking, testing, and linting
- Automatic fix suggestions and integration with existing tools
- Blocking mechanisms to prevent broken code from entering repository
- Comprehensive logging and metrics tracking
</implementation_plan>

<example>
**Workflow Execution Example:**

```bash
# Starting Vibe Code Workflow
/vibe-code-workflow

# Phase 1: Research & Planning
✅ PRD created: project-requirements.md
✅ Task breakdown: detailed-task-list.md
✅ Critical paths identified: critical-success-tasks.md
✅ TODO.md generated with 15 prioritized tasks

# Phase 2: Development Cycle
📝 Task 1: Implement user authentication
🔍 Pre-commit validation:
   ✅ TypeScript: 0 errors
   ✅ Tests: 23/23 passing
   ✅ Lint: 0 warnings
✅ Commit allowed: "feat: implement JWT authentication system"

📝 Task 2: Add user dashboard
🔍 Pre-commit validation:
   ❌ TypeScript: 3 errors in UserDashboard.tsx
   ❌ Tests: 2/25 failing
   ✅ Lint: 0 warnings
❌ Commit blocked - fixing issues...
🔧 Running /fix-types...
🔧 Fixing failing tests...
✅ Re-validation passed - commit allowed

# Phase 3: Pre-Push Validation
🚀 Pre-push validation:
   ✅ All quality checks passed
   ✅ Push to feature/user-auth-dashboard
   ✅ PR created with comprehensive documentation

# Phase 4: Documentation
📚 Documentation created in /docs/auth/
📚 README.md updated with new features
📊 Quality metrics: 100% test coverage, 0 type errors, 0 lint warnings
```
</example>

<thinking>
**Benefits of This Approach:**
- ✅ No broken code enters the repository
- ✅ Consistent code quality across the team
- ✅ Early detection and blocking of issues
- ✅ Automated enforcement reduces manual review burden
- ✅ Documentation includes quality metrics
- ✅ Developers learn to fix issues before committing

**Usage:**
```bash
/vibe-code-workflow
```

**Implementation:**
```bash
/Users/adammanuel/.claude/tools/vibe-code-workflow.sh
```
</thinking>