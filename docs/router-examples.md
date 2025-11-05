---
name: router-examples
description: Comprehensive scenario library with routing examples and outcomes
type: documentation
version: 1.0.0
created: 2025-11-05T10:23:50Z
lastmodified: 2025-11-05T10:23:50Z
---

# Router Examples Library

<context>
This document contains 20+ real-world scenarios demonstrating how the router skill analyzes requests and makes routing decisions. Each example includes the user request, context analysis, routing decision, and expected outcome.
</context>

## Table of Contents

1. [Simple Fix Requests](#simple-fix-requests)
2. [Build & Implementation](#build--implementation)
3. [Testing Scenarios](#testing-scenarios)
4. [Code Review](#code-review)
5. [Documentation](#documentation)
6. [Planning & Strategy](#planning--strategy)
7. [Emergency & Urgent](#emergency--urgent)
8. [Exploration & Learning](#exploration--learning)
9. [Multi-Step Workflows](#multi-step-workflows)
10. [Edge Cases & Ambiguity](#edge-cases--ambiguity)

---

## Simple Fix Requests

### Example 1: Fix TypeScript Errors

**User Request**: `"fix my typescript errors"`

**Intent Analysis**:
```yaml
action: fix
domain: typescript
scope: project-wide
urgency: normal
keywords: [fix, typescript, errors]
```

**Context Gathered**:
```yaml
git:
  branch: feature/auth
  modified_files: [src/auth.ts, src/user.ts]
  status: modified
diagnostics:
  type_errors: 5
  files: [src/auth.ts (3 errors), src/user.ts (2 errors)]
```

**Routing Decision**:
```yaml
primary: /fix:types
type: command
confidence: high (0.92)
reasoning: "Exact intent match (fix + typescript) + diagnostics confirm 5 type errors exist"
alternatives: []
```

**Router Communication**:
```
🎯 **Routing to: /fix:types**

I found 5 TypeScript errors across 2 files in your recent changes:
- src/auth.ts (3 errors)
- src/user.ts (2 errors)

Executing now...
```

**Outcome**: Types fixed successfully in both files

---

### Example 2: Fix All Quality Issues

**User Request**: `"fix everything before I commit"`

**Intent Analysis**:
```yaml
action: fix
domain: general
scope: project-wide
urgency: normal (pre-commit context)
keywords: [fix, everything, commit]
```

**Context Gathered**:
```yaml
git:
  modified_files: 8
diagnostics:
  type_errors: 3
  test_failures: 2
  lint_warnings: 7
```

**Routing Decision**:
```yaml
primary: /fix-all
type: command
execution: parallel (types + tests + lint)
confidence: high (0.88)
reasoning: "Multiple quality issues detected, 'everything' keyword, pre-commit context"
```

**Router Communication**:
```
🎯 **Routing to: /fix-all**

Multiple quality issues detected:
- 3 TypeScript errors
- 2 failing tests
- 7 ESLint warnings

Running all fix commands in parallel for efficiency...

After fixes complete, I'll prepare your commit.
```

**Outcome**: All issues fixed, clean state for commit

---

### Example 3: Fix Tests Only

**User Request**: `"fix failing tests in auth module"`

**Intent Analysis**:
```yaml
action: fix
domain: testing
scope: module (auth)
urgency: normal
keywords: [fix, failing, tests, auth]
```

**Context Gathered**:
```yaml
diagnostics:
  test_failures: 3
  files: [src/auth.test.ts]
file_types:
  primary: [ts, test.ts]
```

**Routing Decision**:
```yaml
primary: /fix:tests
type: command
confidence: high (0.90)
reasoning: "Clear test fix intent + test failures detected in auth module"
focus: src/auth.test.ts
```

**Router Communication**:
```
🎯 **Routing to: /fix:tests**

Found 3 failing tests in src/auth.test.ts. I'll analyze and fix these test failures.

Executing now...
```

**Outcome**: Auth tests fixed and passing

---

## Build & Implementation

### Example 4: Build React Component

**User Request**: `"build a dashboard component with charts"`

**Intent Analysis**:
```yaml
action: build
domain: react, ui
scope: component-level
urgency: normal
keywords: [build, dashboard, component, charts]
```

**Context Gathered**:
```yaml
git:
  branch: feature/dashboard
file_types:
  primary: [tsx, ts, css]
```

**Routing Decision**:
```yaml
primary: ui-engineer
type: agent
confidence: high (0.85)
reasoning: "React component creation is ui-engineer's specialty"
alternatives:
  - tool: architecture-patterns
    type: skill
    when_to_use: "If you need structural guidance before implementing"
```

**Router Communication**:
```
🎯 **Routing to: ui-engineer agent**

Perfect! The ui-engineer specializes in React components with modern patterns.
I'll delegate this dashboard creation with charts integration.

💡 **Alternative**: If you need architecture guidance first, try the
`architecture-patterns` skill for structural recommendations.

Starting implementation...
```

**Outcome**: Dashboard component created with chart library integration

---

### Example 5: Create Backend Service

**User Request**: `"create authentication service with JWT tokens"`

**Intent Analysis**:
```yaml
action: create
domain: backend, authentication
scope: service-level
urgency: normal
keywords: [create, authentication, service, jwt]
```

**Context Gathered**:
```yaml
file_types:
  primary: [ts]
git:
  branch: feature/auth
```

**Routing Decision**:
```yaml
primary: ts-coder
type: agent
confidence: high (0.87)
reasoning: "Backend service implementation requires TypeScript expertise"
focus: "JWT authentication, token management, security best practices"
```

**Router Communication**:
```
🎯 **Routing to: ts-coder agent**

I'll create a complete authentication service with JWT token management.
This will include:
- Token generation and verification
- Refresh token handling
- Security best practices

Starting implementation...
```

**Outcome**: Full auth service with JWT implementation

---

### Example 6: Implement AI Feature

**User Request**: `"add an AI chat feature using OpenAI"`

**Intent Analysis**:
```yaml
action: add
domain: ai, ml
scope: feature-level
urgency: normal
keywords: [add, ai, chat, openai]
```

**Context Gathered**:
```yaml
file_types:
  primary: [ts, tsx]
```

**Routing Decision**:
```yaml
primary: ai-engineer
type: agent
confidence: high (0.90)
reasoning: "AI feature implementation is ai-engineer's specialty"
```

**Router Communication**:
```
🎯 **Routing to: ai-engineer agent**

I'll implement an AI-powered chat feature integrated with OpenAI.
This will include:
- OpenAI API integration
- Chat UI component
- Conversation management
- Error handling and rate limiting

Starting implementation...
```

**Outcome**: AI chat feature with OpenAI integration

---

## Testing Scenarios

### Example 7: Ambiguous Test Request

**User Request**: `"test my website"`

**Intent Analysis**:
```yaml
action: test
domain: web, browser
scope: unclear
urgency: normal
ambiguity: high
keywords: [test, website]
```

**Context Gathered**:
```yaml
file_types:
  primary: [tsx, ts]
diagnostics:
  test_failures: 0
  existing_tests: 12 unit tests, 0 E2E tests
```

**Routing Decision**:
```yaml
confidence: low (0.35)
reasoning: "Ambiguous - could mean manual testing, write tests, or review coverage"
action: clarification_needed
```

**Router Communication**:
```
🤔 **Multiple routing options available:**

Your request "test my website" could mean:

1. **playwright-skill** - Manually test the website in a real browser with
   interactive controls
2. **/reviewer:e2e** - Review existing E2E test coverage and strategy
   (note: 0 E2E tests currently)
3. **ui-engineer agent** - Build automated E2E test infrastructure

Which approach fits your current goal?
- [ ] Manual browser testing (playwright-skill)
- [ ] Review test coverage (/reviewer:e2e)
- [ ] Build test infrastructure (ui-engineer)
- [ ] Other (please describe)
```

**Outcome**: User clarifies intent, router proceeds with selected option

---

### Example 8: Write Unit Tests

**User Request**: `"write unit tests for the auth service"`

**Intent Analysis**:
```yaml
action: write
domain: testing (unit tests)
scope: service (auth)
urgency: normal
keywords: [write, unit tests, auth service]
```

**Context Gathered**:
```yaml
file_types:
  primary: [ts]
target_file: src/services/auth.ts
existing_tests: none for auth.ts
```

**Routing Decision**:
```yaml
primary: ts-coder
type: agent
confidence: high (0.88)
reasoning: "Unit test writing for TypeScript service"
alternative: /create-tests command
```

**Router Communication**:
```
🎯 **Routing to: ts-coder agent**

I'll write comprehensive unit tests for src/services/auth.ts.
This will include:
- Happy path test cases
- Error handling scenarios
- Edge cases
- Mock setup for dependencies

Starting test implementation...

💡 **Tip**: For more structured test generation, you can also use the
`/create-tests` command which follows the Testing Hierarchy Framework.
```

**Outcome**: Comprehensive unit tests created for auth service

---

### Example 9: E2E Testing with Browser

**User Request**: `"test the login flow and take screenshots"`

**Intent Analysis**:
```yaml
action: test
domain: browser, e2e
scope: feature (login)
urgency: normal
keywords: [test, login flow, screenshots]
```

**Context Gathered**:
```yaml
file_types:
  primary: [tsx, ts]
dev_server: likely localhost:3000
```

**Routing Decision**:
```yaml
primary: playwright-skill
type: skill
confidence: high (0.92)
reasoning: "Browser testing with screenshots is playwright's core functionality"
```

**Router Communication**:
```
🎯 **Routing to: playwright-skill**

Perfect! Playwright skill specializes in browser testing and screenshots.
I'll:
1. Auto-detect your dev server (checking localhost:3000)
2. Test the login flow interactively
3. Capture screenshots at key steps
4. Save test script to /tmp for reuse

Launching playwright-skill...
```

**Outcome**: Login flow tested with screenshots captured

---

## Code Review

### Example 10: Pre-Merge Review

**User Request**: `"review my changes before I merge to main"`

**Intent Analysis**:
```yaml
action: review
domain: code quality
scope: git changes
urgency: normal (pre-merge)
keywords: [review, changes, merge, main]
```

**Context Gathered**:
```yaml
git:
  branch: feature/user-auth
  ahead_of_main: 5 commits
  modified_files: 8
  insertions: 342
  deletions: 67
file_types:
  primary: [ts, tsx, test.ts]
```

**Routing Decision**:
```yaml
primary: /review-orchestrator
type: command
confidence: high (0.90)
reasoning: "Comprehensive review needed for pre-merge, multiple files changed"
follow_up:
  - /reviewer:security (auth changes detected)
  - /fix-all (if issues found)
```

**Router Communication**:
```
🎯 **Routing to: /review-orchestrator**

I'll perform a comprehensive multi-reviewer analysis of your 8 changed files.

Given you're working on authentication, I'll pay special attention to:
- Security review (/reviewer:security)
- Code quality (/reviewer:quality)
- Testing coverage (/reviewer:testing)

After review, I'll suggest fixes if needed before merging to main.

Starting comprehensive review...
```

**Outcome**: Multi-faceted review with actionable feedback

---

### Example 11: Security Audit

**User Request**: `"security audit for authentication module"`

**Intent Analysis**:
```yaml
action: review/audit
domain: security
scope: module (auth)
urgency: normal
keywords: [security, audit, authentication]
```

**Context Gathered**:
```yaml
file_types:
  primary: [ts]
target_files: [src/auth/*, src/services/auth.ts]
```

**Routing Decision**:
```yaml
primary: /reviewer:security
type: command
confidence: high (0.95)
reasoning: "Explicit security audit request for auth module"
```

**Router Communication**:
```
🎯 **Routing to: /reviewer:security**

I'll perform a comprehensive security audit of your authentication module.

Focus areas:
- Authentication/authorization vulnerabilities
- Token handling security
- Input validation
- Password storage
- Session management
- Common OWASP vulnerabilities (XSS, injection, etc.)

Starting security audit...
```

**Outcome**: Detailed security report with vulnerabilities and recommendations

---

### Example 12: Performance Review

**User Request**: `"my app is slow, make it faster"`

**Intent Analysis**:
```yaml
action: optimize
domain: performance
scope: project-wide
urgency: normal
keywords: [slow, faster]
```

**Context Gathered**:
```yaml
file_types:
  primary: [tsx, ts]
modified_files: [src/components/Dashboard.tsx]
```

**Routing Decision**:
```yaml
primary: /reviewer:quality
type: command
confidence: medium (0.65)
reasoning: "Quality reviewer includes performance analysis"
alternatives:
  - tool: ui-engineer
    when_to_use: "For React-specific optimizations"
recommendation: "Run build analysis first to identify bottlenecks"
```

**Router Communication**:
```
🎯 **Routing to: /reviewer:quality**

I'll analyze your code for performance issues. The quality reviewer will check:
- Inefficient rendering patterns
- Bundle size opportunities
- Memory leaks and resource usage
- Algorithm optimizations

💡 **Recommendation**: Before optimizing, run `npm run build -- --analyze`
to identify specific bottlenecks with data.

**Alternative**: If this is React-specific, the ui-engineer agent can
implement targeted optimizations.

Starting performance analysis...
```

**Outcome**: Performance analysis with optimization recommendations

---

## Documentation

### Example 13: Document New Service

**User Request**: `"document my new authentication service"`

**Intent Analysis**:
```yaml
action: document
domain: backend service
scope: file/module
urgency: normal
keywords: [document, authentication, service]
```

**Context Gathered**:
```yaml
git:
  untracked_files: [src/services/auth.ts]
file_info:
  size: 450 lines
  has_jsdoc: partial (30% coverage)
```

**Routing Decision**:
```yaml
primary: /docs:general
type: command
confidence: high (0.88)
reasoning: "Service-level documentation is /docs:general's strength"
target: src/services/auth.ts
alternatives:
  - tool: jsdoc
    when_to_use: "For JSDoc-specific guidance"
```

**Router Communication**:
```
🎯 **Routing to: /docs:general src/services/auth.ts**

I'll generate comprehensive documentation for your authentication service.
This will include:
- File header with metadata
- Function documentation
- Usage examples
- API reference

💡 **Alternative**: The `jsdoc` skill can provide detailed JSDoc guidance
if you need specific documentation format help.

Starting documentation generation...
```

**Outcome**: Complete service documentation added

---

### Example 14: Organize Project Documentation

**User Request**: `"organize my project documentation properly"`

**Intent Analysis**:
```yaml
action: organize
domain: documentation
scope: project-wide
urgency: normal
keywords: [organize, documentation, properly]
```

**Context Gathered**:
```yaml
existing_docs: [README.md, scattered comments]
project_type: TypeScript library
```

**Routing Decision**:
```yaml
primary: /docs:diataxis
type: command
confidence: high (0.90)
reasoning: "Documentation structure and organization is diataxis framework's purpose"
```

**Router Communication**:
```
🎯 **Routing to: /docs:diataxis**

The Diataxis framework will organize your documentation into:
- **Tutorials** (learning-oriented) - Help users learn
- **How-to guides** (task-oriented) - Solve specific problems
- **Reference** (information-oriented) - Technical descriptions
- **Explanation** (understanding-oriented) - Deepen understanding

This creates a comprehensive, navigable documentation structure.

💡 **Follow-up**: Use /docs:general to generate content for each section.

Starting documentation organization...
```

**Outcome**: Structured documentation framework created

---

## Planning & Strategy

### Example 15: Plan New Feature

**User Request**: `"plan a new user authentication feature"`

**Intent Analysis**:
```yaml
action: plan
domain: feature
scope: feature-level
urgency: normal
keywords: [plan, user authentication, feature]
```

**Context Gathered**:
```yaml
git:
  branch: main
  status: clean
```

**Routing Decision**:
```yaml
primary: /planning:feature
type: command
confidence: high (0.90)
reasoning: "Feature planning request with clear scope"
```

**Router Communication**:
```
🎯 **Routing to: /planning:feature**

I'll create a comprehensive feature plan for user authentication.
This will include:
- Feature requirements and scope
- Technical approach and architecture
- Task breakdown and estimation
- Acceptance criteria
- Risk assessment

Starting feature planning...
```

**Outcome**: Detailed feature plan with tasks and approach

---

### Example 16: Architecture Guidance

**User Request**: `"how should I structure my domain models using DDD?"`

**Intent Analysis**:
```yaml
action: guidance
domain: architecture
scope: conceptual
urgency: low
keywords: [structure, domain models, ddd]
```

**Context Gathered**:
```yaml
file_types:
  primary: [ts]
```

**Routing Decision**:
```yaml
primary: architecture-patterns
type: skill
confidence: high (0.93)
reasoning: "Architectural guidance with explicit pattern mention (DDD)"
```

**Router Communication**:
```
🎯 **Routing to: architecture-patterns skill**

This skill provides comprehensive guidance on:
- Domain-Driven Design patterns
- Aggregate and Entity design
- Value Objects
- Domain Services
- Clean Architecture principles

Invoking architecture-patterns for domain model guidance...

💡 **Alternative**: If you need project-wide architecture planning,
the strategic-planning agent can help.
```

**Outcome**: DDD guidance with examples and best practices

---

## Emergency & Urgent

### Example 17: Production Emergency

**User Request**: `"URGENT: production is down, fix NOW"`

**Intent Analysis**:
```yaml
action: fix
domain: unknown (needs investigation)
scope: project-wide
urgency: CRITICAL
keywords: [URGENT, production, down, NOW]
```

**Context Gathered**:
```yaml
git:
  branch: main
  modified_files: [src/api/payment.ts]
diagnostics:
  type_errors: 8 (in payment.ts)
  test_failures: 3 (in payment.test.ts)
```

**Routing Decision**:
```yaml
workflow: production_emergency
urgency: critical
skip_confirmations: true
execution: parallel
tools: [/fix:types, /fix:tests]
confidence: high (emergency override)
```

**Router Communication**:
```
🚨 **EMERGENCY WORKFLOW ACTIVATED**

Critical issues detected:
- 8 TypeScript errors in src/api/payment.ts
- 3 failing tests in payment.test.ts

Running emergency parallel fix:
1. /fix:types + /fix:tests (concurrent)
2. /git:commit (after fixes)
3. Ready for immediate deployment

EXECUTING NOW - No confirmations required

⏱️ Estimated resolution time: 3-7 minutes
```

**Outcome**: Issues fixed rapidly, ready for deployment

---

### Example 18: Hotfix Request

**User Request**: `"need a hotfix for the login bug"`

**Intent Analysis**:
```yaml
action: fix
domain: bug (login)
scope: targeted
urgency: high
keywords: [hotfix, login, bug]
```

**Context Gathered**:
```yaml
git:
  branch: main
file_types:
  primary: [ts, tsx]
```

**Routing Decision**:
```yaml
workflow: hotfix_workflow
confidence: high (0.85)
```

**Router Communication**:
```
⚡ **Hotfix Workflow Activated**

Fast-path hotfix process:

1. **Branch** (suggested) - Create hotfix/login-bug branch
2. **Implement** (ts-coder) - Minimal targeted fix
3. **Verify** (/fix-all) - Quick quality check
4. **Commit** (/git:commit) - Commit with hotfix prefix
5. **PR** (suggested) - Create PR with hotfix label

Focus: Speed + Minimal Changes

Suggesting branch creation: `git checkout -b hotfix/login-bug`
```

**Outcome**: Rapid hotfix with minimal changes

---

## Exploration & Learning

### Example 19: Explore Codebase

**User Request**: `"I'm new to this project, help me understand the structure"`

**Intent Analysis**:
```yaml
action: explore, learn
domain: general
scope: project-wide
urgency: low
keywords: [new, understand, structure]
```

**Context Gathered**:
```yaml
git:
  branch: main
  status: clean
project_structure: src/ with 45 files
```

**Routing Decision**:
```yaml
primary: Explore
type: agent
subagent_type: Explore
mode: thorough
confidence: high (0.92)
reasoning: "New contributor exploration request requires thorough analysis"
```

**Router Communication**:
```
🎯 **Routing to: Explore agent (thorough mode)**

I'll analyze the codebase structure and provide a comprehensive overview.
This will include:
- Project architecture and module relationships
- Key components and their purposes
- Code patterns and conventions
- Entry points and data flow
- Dependencies and integrations

💡 **Follow-up**: After exploration, the `architecture-patterns` skill
can explain design patterns in depth.

Starting thorough codebase analysis...
⏱️ Estimated time: 5-15 minutes
```

**Outcome**: Comprehensive codebase overview and architecture understanding

---

### Example 20: Understand Specific Feature

**User Request**: `"how does the payment flow work?"`

**Intent Analysis**:
```yaml
action: understand
domain: feature (payment)
scope: feature-level
urgency: low
keywords: [how does, payment flow, work]
```

**Context Gathered**:
```yaml
relevant_files: [src/api/payment.ts, src/services/payment.ts]
```

**Routing Decision**:
```yaml
primary: Explore
type: agent
subagent_type: Explore
mode: medium
confidence: high (0.88)
reasoning: "Specific feature understanding with identified scope"
focus: payment-related files
```

**Router Communication**:
```
🎯 **Routing to: Explore agent (medium mode)**

I'll analyze the payment flow by examining:
- src/api/payment.ts
- src/services/payment.ts
- Related components and services
- Data flow and integrations

This will provide a clear explanation of how payments are processed.

Starting analysis...
⏱️ Estimated time: 2-5 minutes
```

**Outcome**: Clear explanation of payment flow with diagrams

---

## Multi-Step Workflows

### Example 21: Full Feature Development

**User Request**: `"plan and implement a user profile page with image upload"`

**Intent Analysis**:
```yaml
action: plan + implement (multi-step)
domain: fullstack feature
scope: feature-level
urgency: normal
multi_step: true
keywords: [plan, implement, profile page, image upload]
```

**Context Gathered**:
```yaml
git:
  branch: main
  status: clean
project_type: React + Node.js
```

**Routing Decision**:
```yaml
workflow: feature_development_full
confidence: high (0.90)
execution: multi_stage
```

**Router Communication**:
```
🔄 **Feature Development Workflow Activated**

I'll guide you through the complete feature development:

**Stage 1: Planning** (/planning:feature)
  - Define user profile requirements
  - Plan image upload flow
  - Create task breakdown
  ⏱️ ~10 minutes

**Stage 2: Implementation** (parallel agents)
  - ui-engineer agent: Profile page component
  - ts-coder agent: Image upload backend
  ⏱️ ~30-60 minutes

**Stage 3: Quality** (/fix-all)
  - Fix types, tests, lint
  ⏱️ ~5 minutes

**Stage 4: Review** (/review-orchestrator)
  - Comprehensive review
  ⏱️ ~7 minutes

**Stage 5: Finalize** (/git:commit)
  - Commit all changes
  ⏱️ ~1 minute

📊 **Total estimated time**: 50-85 minutes

Starting Stage 1: Planning...
```

**Outcome**: Complete feature from planning to commit

---

### Example 22: Fix and Commit Workflow

**User Request**: `"fix all errors and commit my changes"`

**Intent Analysis**:
```yaml
action: fix + commit (sequential)
domain: quality
scope: project-wide
urgency: normal
multi_step: true
keywords: [fix, all errors, commit, changes]
```

**Context Gathered**:
```yaml
git:
  modified_files: 6
diagnostics:
  type_errors: 4
  test_failures: 2
  lint_warnings: 5
```

**Routing Decision**:
```yaml
execution: sequential
stages:
  - stage: 1
    tool: /fix-all
    blocking: true
  - stage: 2
    tool: /git:commit
    blocking: false
confidence: high (0.92)
reasoning: "Clear sequential dependency: must fix before committing"
```

**Router Communication**:
```
🔄 **Sequential routing planned**

Your changes have quality issues that need fixing first:
- 4 TypeScript errors
- 2 failing tests
- 5 ESLint warnings

**Step 1**: /fix-all (parallel fixes)
  - /fix:types
  - /fix:tests
  - /fix:lint
  ⚠️ Must complete before commit

**Step 2**: /git:commit
  - Generate conventional commit message
  - Commit clean code

Starting Step 1: Parallel quality fixes...
```

**Outcome**: Issues fixed, then clean commit created

---

## Edge Cases & Ambiguity

### Example 23: Vague Help Request

**User Request**: `"help me with my code"`

**Intent Analysis**:
```yaml
action: unclear
domain: unclear
scope: unclear
urgency: normal
ambiguity: very high
keywords: [help, code]
```

**Context Gathered**:
```yaml
git:
  modified_files: 3
diagnostics:
  type_errors: 5
  test_failures: 0
  lint_warnings: 2
```

**Routing Decision**:
```yaml
confidence: low (0.25)
action: context_fallback
primary: /fix:types
reasoning: "Type errors detected (blocking issue) - fix these first"
```

**Router Communication**:
```
🤔 **Your request is a bit general, but I can help!**

I noticed you have some issues in your code:
- 5 TypeScript errors (blocking)
- 2 ESLint warnings

**Suggested action**: Fix these type errors first with /fix:types

**Or, tell me more specifically what you need**:
- "fix types" - Fix TypeScript errors
- "review code" - Code review
- "document code" - Add documentation
- "explain X" - Understand how something works
- "implement Y" - Build new feature

Proceeding with /fix:types to clear blocking issues...
```

**Outcome**: Type errors fixed based on context, user can refine request

---

### Example 24: Tool Not Found

**User Request**: `"use the playwright skill to test"`

**Intent Analysis**:
```yaml
action: test
domain: browser
tool_requested: playwright-skill
urgency: normal
```

**Context Gathered**:
```yaml
available_skills: [jsdoc, architecture-patterns]
# playwright-skill not in list
```

**Routing Decision**:
```yaml
error: tool_not_found
action: suggest_alternatives
```

**Router Communication**:
```
⚠️ **Tool not available**

The `playwright-skill` isn't currently installed or available.

**Alternatives I can help with**:

1. **ui-engineer agent** - Can implement E2E test infrastructure
   - Build test setup with Playwright
   - Create test scripts
   - Configure test environments

2. **Bash tool** - Can run existing Playwright tests
   - Execute: `npm run test:e2e`
   - Run specific test files
   - Generate test reports

3. **Install playwright-skill** - I can help you install it
   - Guide through installation process
   - Configure for your project

Which would you prefer?
- [ ] Use ui-engineer to build tests
- [ ] Run existing tests with Bash
- [ ] Help install playwright-skill
- [ ] Other approach
```

**Outcome**: User selects alternative or installs missing skill

---

### Example 25: Conflicting Operations

**User Request**: `"review and fix my tests at the same time"`

**Intent Analysis**:
```yaml
action: review + fix (conflicting)
domain: testing
urgency: normal
conflict: review should happen on clean code
keywords: [review, fix, tests, same time]
```

**Context Gathered**:
```yaml
diagnostics:
  test_failures: 3
```

**Routing Decision**:
```yaml
conflict_resolution: fix_first
confidence: medium (0.60)
reasoning: "Reviews are more valuable on passing tests"
```

**Router Communication**:
```
⚠️ **Routing conflict detected**

Your request involves both:
- **Fix tests** (3 failures detected)
- **Review tests** (strategy and coverage)

**Recommended sequence**:
1. **/fix:tests** - Fix the 3 failing tests first
   - Reviews are more valuable on passing tests
   - Can analyze failures to inform fixes

2. **/reviewer:testing** - Then review test strategy
   - Assess coverage
   - Recommend improvements
   - Identify gaps

After fixes complete, would you like me to automatically run the test review?
- [ ] Yes, fix then review
- [ ] No, just fix the tests
- [ ] Other approach
```

**Outcome**: User confirms sequence, router executes in correct order

---

## Summary Statistics

```
Total Examples: 25
Confidence Distribution:
  - High (>0.7): 19 examples (76%)
  - Medium (0.4-0.7): 4 examples (16%)
  - Low (<0.4): 2 examples (8%)

Execution Patterns:
  - Single tool: 15 examples (60%)
  - Sequential: 4 examples (16%)
  - Parallel: 3 examples (12%)
  - Workflow: 3 examples (12%)

Most Common Intents:
  1. Fix (7 examples)
  2. Build/Implement (4 examples)
  3. Review (4 examples)
  4. Test (3 examples)
  5. Document (3 examples)
  6. Plan (2 examples)
  7. Explore (2 examples)

Edge Cases Covered:
  - Ambiguous requests (2)
  - Tool not found (1)
  - Conflicting operations (1)
  - Emergency scenarios (2)
```

---

**Version**: 1.0.0
**Last Modified**: 2025-11-05T10:23:50Z

**Note**: These examples represent common patterns. The router adapts to unique scenarios and learns from each interaction.
