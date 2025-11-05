---
name: router-guide
description: User guide for the router skill with examples and best practices
type: documentation
version: 1.0.0
created: 2025-11-05T10:23:50Z
lastmodified: 2025-11-05T10:23:50Z
---

# Router Skill User Guide

Welcome to the Router Skill! This guide will help you understand and use the intelligent routing system in Claude Code.

## Table of Contents

1. [What is the Router Skill?](#what-is-the-router-skill)
2. [When to Use It](#when-to-use-it)
3. [How It Works](#how-it-works)
4. [Quick Start Examples](#quick-start-examples)
5. [Understanding Routing Decisions](#understanding-routing-decisions)
6. [Advanced Usage](#advanced-usage)
7. [Troubleshooting](#troubleshooting)
8. [Tips & Best Practices](#tips--best-practices)

---

## What is the Router Skill?

The Router Skill is an intelligent orchestration layer that analyzes your requests and automatically routes them to the most appropriate tool in the Claude Code ecosystem.

**Think of it as your development assistant** who knows:
- All available tools (Skills, Agents, Commands)
- What each tool is best at
- Your current project state (git status, errors, file types)
- How to coordinate multiple tools for complex tasks

**Key Benefits**:
- ✅ No need to memorize all commands and agents
- ✅ Context-aware routing based on your project state
- ✅ Automatic multi-step workflow coordination
- ✅ Learning system that improves over time
- ✅ Transparent explanations for every routing decision

---

## When to Use It

### Perfect For:

✅ **Learning Claude Code**: New users discovering available tools
```
You: "I want to test my website"
Router: Suggests playwright-skill, /reviewer:e2e, or ui-engineer based on your intent
```

✅ **Ambiguous Requests**: When multiple tools could work
```
You: "improve my code"
Router: Analyzes your project and suggests specific improvements
```

✅ **Complex Workflows**: Multi-step tasks requiring coordination
```
You: "build, test, and deploy a new feature"
Router: Orchestrates planning → implementation → testing → deployment
```

✅ **Context-Aware Decisions**: Routing that considers your project state
```
You: "commit my changes"
Router: Checks for errors first, suggests fixes if needed, then commits
```

### Not Needed For:

❌ **Direct Tool Invocation**: When you know exactly what you want
```
You: "/fix:types"  → Direct command (no routing needed)
You: "use playwright-skill" → Direct skill invocation
```

❌ **Simple, Clear Requests**: Unambiguous single operations
```
You: "read src/auth.ts" → Direct file read
```

---

## How It Works

The router follows a 5-phase process:

### Phase 1: Intent Analysis
Extracts what you want to do:
- **Action**: fix, review, document, test, plan, build, etc.
- **Domain**: TypeScript, React, security, testing, etc.
- **Scope**: File, module, or project-wide
- **Urgency**: Normal, high, or critical

### Phase 2: Context Gathering
Analyzes your project:
- Git status (modified files, branch, clean/dirty)
- Diagnostics (type errors, test failures, lint warnings)
- File types (tsx, ts, test files, etc.)
- Recent activity

### Phase 3: Decision Making
Matches patterns and calculates confidence:
- **High confidence (>70%)**: Direct routing with brief explanation
- **Medium confidence (40-70%)**: Route with alternatives offered
- **Low confidence (<40%)**: Ask clarifying questions

### Phase 4: Execution
Invokes the selected tool(s):
- **Single**: One tool execution
- **Sequential**: Multiple tools with dependencies (A → B → C)
- **Parallel**: Independent tools running concurrently (A + B + C)

### Phase 5: Communication
Explains the decision transparently:
- Why this route was chosen
- What alternatives exist
- How to invoke directly next time (learning tip)

---

## Quick Start Examples

### Example 1: Simple Fix Request

```
You: "fix my typescript errors"

Router: 🎯 Routing to: /fix:types
        I found 5 TypeScript errors across 2 files in your recent changes.
        Executing now...

Result: Types fixed automatically
```

**What happened**: Clear intent (fix + types) + errors detected = high confidence routing to /fix:types

---

### Example 2: Ambiguous Testing Request

```
You: "test my website"

Router: 🤔 Multiple routing options available:

        Your request could mean:
        1. playwright-skill - Manually test the website in a real browser
        2. /reviewer:e2e - Review existing E2E test coverage
        3. ui-engineer agent - Build automated E2E test infrastructure

        Which approach fits your current goal?
        - [ ] Manual browser testing (playwright-skill)
        - [ ] Review test coverage (/reviewer:e2e)
        - [ ] Build test infrastructure (ui-engineer)
        - [ ] Other (please describe)

Result: You clarify your intent, router proceeds
```

**What happened**: "Test" is ambiguous (manual? automated? review?) = low confidence = ask clarifying question

---

### Example 3: Multi-Step Feature Development

```
You: "plan and build a user authentication feature"

Router: 🔄 Multi-step routing planned:

        Your feature request needs 4 stages:

        1. Planning (/planning:feature) - Define requirements and tasks
        2. Implementation (parallel agents)
           - ui-engineer: Login component
           - ts-coder: Auth service backend
        3. Quality (/fix-all) - Fix types, tests, lint
        4. Review (/review-orchestrator) - Final review

        This sequence handles dependencies efficiently. Starting Stage 1...

Result: Complete workflow from planning to review
```

**What happened**: Multi-step request detected → workflow template activated → orchestrated execution

---

### Example 4: Context-Aware Commit

```
You: "commit my changes"

Context: 3 type errors detected, 2 test failures

Router: ⚠️ Before committing, let's resolve these blocking issues:
        - 3 TypeScript errors
        - 2 failing tests

        Proposed sequence:
        1. /fix:types (resolve 3 errors)
        2. /fix:tests (fix 2 failing tests)
        3. /git:commit (proceed with commit)

        Proceeding with fixes...

Result: Issues fixed first, then clean commit
```

**What happened**: Commit request + detected errors → context-aware routing → fix issues first

---

### Example 5: Emergency Production Fix

```
You: "URGENT: production is broken, fix NOW"

Context: 8 TypeScript errors in payment.ts

Router: 🚨 Emergency routing activated

        Critical issues detected:
        - 8 TypeScript errors in payment.ts
        - 3 failing tests in payment.test.ts

        Running emergency parallel fix:
        1. /fix:types + /fix:tests (concurrent)
        2. /git:commit (after fixes)
        3. Ready for immediate deployment

        Executing NOW...

Result: Fast-path parallel fixes → immediate commit
```

**What happened**: Urgency keywords + errors → emergency workflow → parallel execution → fast resolution

---

## Understanding Routing Decisions

### Confidence Levels

#### 🎯 High Confidence (>70%)
**Characteristics**:
- Clear intent matching known patterns
- Project context confirms the choice
- Single obvious tool for the job

**Communication Style**: Direct and brief
```
🎯 Routing to: /fix:types
I found 5 TypeScript errors that need resolution.
Executing now...
```

**Your Action**: None needed, trust the routing

---

#### 🎯 Medium Confidence (40-70%)
**Characteristics**:
- Intent mostly clear, minor ambiguity
- Multiple tools could work, one preferred
- Context provides guidance

**Communication Style**: Explanatory with alternatives
```
🎯 Routing to: ui-engineer agent

Based on your React component work, the ui-engineer agent is well-suited
for building interactive UI with modern patterns.

💡 Alternative: architecture-patterns skill - If you need structural
guidance before implementing.

Proceeding with ui-engineer agent...
```

**Your Action**: Review the explanation, can override if needed

---

#### 🤔 Low Confidence (<40%)
**Characteristics**:
- Ambiguous request with multiple interpretations
- Conflicting signals or unclear domain
- Need user input to proceed correctly

**Communication Style**: Questions with options
```
🤔 Multiple routing options available:

Your request could be handled by:
1. playwright-skill - Manual browser testing
2. /reviewer:e2e - Review test coverage
3. ui-engineer agent - Build test infrastructure

Which approach fits your current goal?
- [ ] Option 1
- [ ] Option 2
- [ ] Option 3
- [ ] Other (please specify)
```

**Your Action**: Select an option or provide clarification

---

### Routing Decision Factors

The router considers these factors when making decisions:

1. **Intent Match** (50% weight)
   - Exact keyword match: High
   - Partial match: Medium
   - Inferred match: Low

2. **Context Relevance** (30% weight)
   - Project state confirms intent: High
   - Somewhat relevant: Medium
   - Not relevant: Low

3. **Ambiguity** (20% weight, inverted)
   - Single clear option: High confidence
   - 2-3 options: Medium confidence
   - 4+ options: Low confidence

**Example Calculation**:
```
Request: "fix my typescript errors"
- Intent Match: 1.0 (exact: "fix" + "typescript")
- Context: 0.8 (5 type errors detected)
- Ambiguity: 0.0 (only /fix:types matches)

Score = (1.0 × 0.5) + (0.8 × 0.3) + ((1.0 - 0.0) × 0.2)
      = 0.5 + 0.24 + 0.2
      = 0.94 (High Confidence)
```

---

## Advanced Usage

### Workflow Templates

The router includes pre-defined workflow templates for common scenarios:

#### Feature Development Workflow
```
You: "build a new user profile feature"

Router: Activates feature_development_full workflow
        1. Planning (/planning:feature)
        2. Implementation (parallel agents)
        3. Quality (/fix-all)
        4. Review (/review-orchestrator)
        5. Commit (/git:commit)
```

**Available Workflows**:
- `feature_development_full` - Complete feature from planning to commit
- `bug_fix_workflow` - Systematic bug fixing with verification
- `comprehensive_code_review` - Multi-faceted review before merge
- `comprehensive_documentation` - Full docs from structure to content
- `comprehensive_testing` - Complete test implementation
- `production_emergency` - Fast-path for critical issues
- `hotfix_workflow` - Quick hotfix with minimal process
- `safe_refactoring` - Refactoring with comprehensive checks
- `security_audit` - Complete security analysis
- `performance_optimization` - Systematic performance improvement

#### Customizing Workflows

You can customize workflows:

**Skip Stages**:
```
You: "Run feature workflow but skip planning"
Router: Acknowledged - Starting at Stage 2: Implementation
```

**Adjust Scope**:
```
You: "Run security audit only for auth module"
Router: Limiting security audit to src/auth/**
```

**Change Execution**:
```
You: "Run fixes sequentially, not in parallel"
Router: Executing /fix:types → /fix:tests → /fix:lint sequentially
```

---

### Context-Aware Routing

The router adapts based on your project state:

#### Git Status Awareness
```
Clean working directory → Safe to commit, branch operations
Modified files present → Suggest commit after operations
Uncommitted changes → Warn before destructive operations
Merge conflicts → Route to exploration/resolution
```

#### Diagnostic Awareness
```
Type errors present → Suggest fixes before commit/deploy
Test failures present → Block deployment, suggest fixes
Lint warnings present → Allow commit but suggest fixing
All clean → Green light for all operations
```

#### File Type Awareness
```
tsx/jsx files → Prefer ui-engineer agent
.test.ts files → Prefer testing tools
Config files modified → Careful review suggested
```

---

### Multi-Tool Orchestration

#### Sequential Execution (Dependencies)
When tools depend on each other:
```
You: "fix errors and commit"

Router: Sequential execution:
        1. /fix-all (must complete first)
        2. /git:commit (depends on fixes)
```

#### Parallel Execution (Independent)
When tools are independent:
```
You: "fix types and tests"

Router: Parallel execution:
        - /fix:types (concurrent)
        - /fix:tests (concurrent)
        Aggregate results when both complete
```

#### Hybrid Execution (Both)
Complex workflows mixing both:
```
You: "fix, review, and commit everything"

Router: Hybrid execution:
        Stage 1 (Parallel): /fix:types + /fix:tests + /fix:lint
        Stage 2 (Sequential): /review-orchestrator
        Stage 3 (Sequential): /git:commit
```

---

## Troubleshooting

### "Router chose the wrong tool"

**Possible Causes**:
- Request was ambiguous
- Context misinterpreted
- Router pattern needs updating

**Solutions**:
1. **Provide more context**: "fix typescript errors in auth.ts"
2. **Specify tool explicitly**: "use ts-coder agent to fix this"
3. **Clarify intent**: "I want to write tests, not fix tests"

**The router learns**: Corrections help improve future routing

---

### "Router asks too many questions"

**Possible Causes**:
- Requests are genuinely ambiguous
- Need to be more specific

**Solutions**:
1. **Be more explicit**: Instead of "test this", say "write unit tests for auth.ts"
2. **Mention tool types**: "use playwright skill" vs "write e2e tests"
3. **Specify scope**: "project-wide" vs "just this file"

---

### "Router is too slow"

**Possible Causes**:
- Context gathering overhead
- Complex pattern matching

**Solutions**:
1. **Use direct invocation**: `/fix:types` instead of "fix types"
2. **Scope down context**: Specify files to analyze
3. **Skip routing**: For simple, known operations

---

### "Router suggested a tool I don't have"

**Possible Causes**:
- Skill not installed
- Command not available in this project

**Solutions**:
- Router will detect this and suggest alternatives
- Offers to help install missing tools
- Provides fallback options

---

## Tips & Best Practices

### 🎯 Be Specific When Possible

❌ **Vague**: "help me"
✅ **Specific**: "fix typescript errors in src/auth.ts"

❌ **Vague**: "make it better"
✅ **Specific**: "optimize React component performance"

---

### 🎯 Use Action Verbs

The router recognizes these action patterns:
- **fix** → Quality fixes
- **review** → Code review
- **document** → Documentation
- **test** → Testing operations
- **plan** → Planning/strategy
- **build/create** → Implementation
- **explore** → Codebase exploration
- **optimize** → Performance improvements

---

### 🎯 Mention Domain When Relevant

Include domain keywords to improve routing:
- "fix **typescript** errors"
- "build **react** component"
- "**security** audit"
- "**e2e** test"
- "**ai** chat feature"

---

### 🎯 Indicate Urgency When Needed

Use urgency signals for priority routing:
- **URGENT**: Fast-path routing
- **CRITICAL**: Emergency workflow
- **blocking**: High priority
- **when you can**: Low priority, more thorough

---

### 🎯 Leverage Multi-Step Requests

Combine operations efficiently:
- "fix and commit" → Sequential execution
- "fix types and tests" → Parallel execution
- "plan, build, test, and deploy" → Full workflow

---

### 🎯 Learn Direct Invocation

Pay attention to learning tips:
```
💡 Routing Tip:
Next time, you can directly invoke this with `/fix:types` for faster access!
```

Build muscle memory for common operations you do frequently.

---

### 🎯 Trust the Context Awareness

The router sees what you might not:
- Uncommitted changes
- Type errors
- Test failures
- File types involved

Trust its suggestions, especially for blocking issues.

---

### 🎯 Provide Feedback

When the router makes mistakes:
1. Correct it: "No, I want to use X instead"
2. Explain why: "I need Y because Z"
3. The router learns from corrections

---

## Available Tools Reference

### Skills (via `use {skill}`)
- **playwright-skill**: Browser automation and testing
- **jsdoc**: JSDoc documentation guidance
- **architecture-patterns**: Design patterns and architecture

### Agents (automatically routed)
- **Explore**: Codebase exploration and analysis
- **ui-engineer**: Frontend/React development
- **ts-coder**: TypeScript code writing
- **senior-code-reviewer**: Comprehensive code review
- **ai-engineer**: AI/ML features
- **deployment-engineer**: CI/CD and deployment
- **intelligent-documentation**: Advanced documentation
- **strategic-planning**: Feature planning and PRDs

### Commands (via `/command`)
- **/fix-all**: Fix all quality issues in parallel
- **/fix:types**: Fix TypeScript errors
- **/fix:tests**: Fix failing tests
- **/fix:lint**: Fix ESLint warnings
- **/git:commit**: Create conventional commit
- **/review-orchestrator**: Comprehensive review
- **/reviewer:{type}**: Specialized reviews (security, quality, testing, etc.)
- **/planning:{type}**: Planning commands (feature, prd, brainstorm)
- **/docs:{type}**: Documentation commands (general, diataxis)

---

## Getting Help

- **Ask the router**: "What tools can fix typescript errors?"
- **Explore options**: "What are my options for testing?"
- **Request workflow**: "Show me the feature development workflow"
- **Get clarification**: "Why did you choose that tool?"

---

## Summary

The Router Skill is your intelligent assistant that:
1. ✅ Analyzes your requests and project context
2. ✅ Routes to the best tool for the job
3. ✅ Orchestrates multi-step workflows
4. ✅ Explains decisions transparently
5. ✅ Learns and improves over time

**Remember**: You're always in control. The router suggests, you decide.

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05T10:23:50Z

**Feedback**: Found an issue or have a suggestion? The router learns from your corrections and feedback!
