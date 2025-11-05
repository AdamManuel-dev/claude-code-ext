---
name: router-README
description: Quick start guide and overview for the router skill
type: documentation
version: 1.0.0
created: 2025-11-05T10:23:50Z
lastmodified: 2025-11-05T10:23:50Z
---

# Router Skill - Quick Start

## What Is It?

The Router Skill is an **intelligent routing orchestrator** that analyzes your requests and automatically directs them to the best tool in Claude Code. Think of it as your personal development assistant who knows all the tools and how to use them effectively.

## Quick Example

```
You: "fix my typescript errors"

Router: 🎯 Routing to /fix:types
        Found 5 TypeScript errors across 2 files.
        Executing now...

Result: ✅ All type errors fixed
```

## Installation

The router skill is already installed in your Claude Code setup! All files are in place:

```
.claude/
├── skills/
│   ├── router.md              # Main skill
│   ├── router-patterns.md     # Pattern library
│   └── router-workflows.md    # Workflow templates
├── tools/
│   └── router-context.sh      # Context helper
└── docs/
    ├── router-guide.md        # Full user guide
    ├── router-decision-tree.md # Visual documentation
    ├── router-examples.md     # 25+ examples
    └── router-README.md       # This file
```

## How to Use

### Method 1: Direct Invocation

```
use router skill

Then: "fix my code"
Router analyzes and routes appropriately
```

### Method 2: Ask for Routing

```
You: "What's the best tool to test my website?"
Router: Provides options and routes based on your clarification
```

### Method 3: Let Router Handle Everything

Just make natural requests, and if you're using the router skill, it will automatically analyze and route:

```
"build a dashboard component"  → ui-engineer agent
"review my code"               → /review-orchestrator
"plan a new feature"           → /planning:feature
"URGENT: production broken"    → emergency workflow
```

## What Can It Do?

### 1. Simple Routing
Routes clear requests to the right tool:
- "fix types" → /fix:types
- "review security" → /reviewer:security
- "document code" → /docs:general

### 2. Context-Aware Routing
Considers your project state:
- Has errors? → Fix first before committing
- Clean state? → Proceed with confidence
- UI files? → Prefer ui-engineer agent

### 3. Multi-Step Workflows
Orchestrates complex tasks:
- "build, test, and commit feature" → Full workflow
- "fix and review changes" → Sequential execution
- Emergency workflows for production issues

### 4. Intelligent Clarification
Asks questions when needed:
- "test my website" → Manual? Automated? Review?
- Offers multiple options
- Learns from your choices

## Key Features

### 🎯 50+ Routing Patterns
- Action-based (fix, review, document, test, etc.)
- Domain-based (TypeScript, React, security, etc.)
- Context-aware (git status, diagnostics, file types)
- Urgency-based (normal, high, critical)

### 🔄 10 Workflow Templates
- Feature Development (full lifecycle)
- Bug Fix (systematic resolution)
- Code Review (comprehensive)
- Documentation (structure to content)
- Testing (strategy to implementation)
- Emergency & Hotfix (fast-path)
- Refactoring (safe transformations)
- Security Audit (comprehensive)
- Performance Optimization (data-driven)

### 📊 Confidence Scoring
- **High (>70%)**: Direct routing with brief explanation
- **Medium (40-70%)**: Route with alternatives
- **Low (<40%)**: Ask clarifying questions

### 🔧 Tool Integration
- **3 Skills**: playwright-skill, jsdoc, architecture-patterns
- **12+ Agents**: Explore, ui-engineer, ts-coder, senior-code-reviewer, etc.
- **20+ Commands**: /fix:*, /git:*, /review:*, /planning:*, /docs:*

## Real-World Examples

### Example 1: Fix Everything Before Commit
```
You: "fix everything and commit"
Context: 3 type errors, 2 test failures, 5 lint warnings detected

Router: 🔄 Sequential routing planned
        Step 1: /fix-all (parallel: types + tests + lint)
        Step 2: /git:commit

Result: All issues fixed → Clean commit created
```

### Example 2: Emergency Production Fix
```
You: "URGENT: production down"
Context: 8 type errors in payment.ts detected

Router: 🚨 Emergency workflow activated
        Running parallel fix: /fix:types + /fix:tests
        Fast-path commit → Ready for deployment

Result: Fixed in ~5 minutes, ready to deploy
```

### Example 3: Build New Feature
```
You: "build a dashboard with charts"

Router: 🎯 Routing to ui-engineer agent
        React component creation specialist
        Alternative: architecture-patterns for structure

Result: Dashboard component with chart integration
```

## Documentation

### Quick References
- **This file**: Quick start overview
- **router-guide.md**: Complete user guide (17KB)
- **router-examples.md**: 25+ real scenarios (28KB)
- **router-decision-tree.md**: Visual flowcharts (29KB)

### Deep Dives
- **router.md**: Main skill implementation (32KB)
- **router-patterns.md**: Pattern library (24KB)
- **router-workflows.md**: Workflow templates (22KB)

### Tools
- **router-context.sh**: Context gathering script (4.5KB)

**Total Documentation**: ~156KB

## How It Works (5 Phases)

```
1. Intent Analysis
   └─> Extract: action, domain, scope, urgency

2. Context Gathering
   └─> Check: git status, diagnostics, file types

3. Decision Engine
   └─> Calculate: confidence score, route selection

4. Execution
   └─> Invoke: single | sequential | parallel

5. Communication
   └─> Explain: decision, alternatives, learning tips
```

## Tips & Best Practices

### ✅ Do This
- Be specific: "fix typescript errors in auth.ts"
- Use action verbs: fix, review, document, test, build
- Mention domain: typescript, react, security
- Indicate urgency: URGENT, blocking, when you can

### ❌ Avoid This
- Too vague: "help me"
- No context: "make it better"
- Unclear intent: "do something"

### 💡 Pro Tips
1. **Trust the context awareness**: Router sees errors you might not
2. **Learn direct commands**: Router shows you shortcuts
3. **Provide feedback**: Corrections help router learn
4. **Use workflows**: Let router orchestrate complex tasks

## Troubleshooting

### Router chose wrong tool?
- Be more specific in your request
- Mention the tool explicitly: "use ts-coder agent"
- Provide more context about what you want

### Router asks too many questions?
- Your request might be genuinely ambiguous
- Be more explicit: "write unit tests" vs "test this"
- Specify the tool type you want

### Router not available?
- Check: `ls ~/.claude/skills/router.md`
- Verify: File exists and is readable
- Invoke: `use router skill`

## Performance

- **Routing Decision**: < 2 seconds
- **Context Gathering**: < 1 second
- **Pattern Matching**: Optimized for speed
- **Token Usage**: Efficient (varies by task complexity)

## Learning System

The router improves over time by:
- ✅ Tracking successful routing patterns
- ✅ Learning from user corrections
- ✅ Identifying confused scenarios
- ✅ Adjusting confidence thresholds
- ✅ Building user preference profiles

## Get Started Now

### Step 1: Invoke the Router
```
use router skill
```

### Step 2: Make a Request
```
"fix my typescript errors"
"build a dashboard component"
"review my changes"
"plan a new feature"
```

### Step 3: Watch It Work
The router will:
1. Analyze your request
2. Gather project context
3. Calculate confidence
4. Route to best tool
5. Explain decision
6. Execute task

### Step 4: Provide Feedback
If routing wasn't perfect:
- Correct it: "No, I want X instead"
- Explain why: "I need Y because Z"
- Router learns and improves!

## FAQ

**Q: When should I use the router vs direct commands?**
A: Use router when exploring, learning, or handling complex tasks. Use direct commands when you know exactly what you want.

**Q: Can I customize routing decisions?**
A: Yes! The router learns from your corrections and feedback over time.

**Q: What if my request is ambiguous?**
A: Router will ask clarifying questions and offer multiple options.

**Q: Does it work for emergency situations?**
A: Yes! Use keywords like URGENT, CRITICAL, or PRODUCTION to trigger fast-path routing.

**Q: How do I see all available tools?**
A: Check router-guide.md "Available Tools Reference" section.

## What's Next?

1. **Read the full guide**: Open `router-guide.md` for detailed documentation
2. **Study examples**: Review `router-examples.md` for 25+ scenarios
3. **Understand logic**: Check `router-decision-tree.md` for visual flowcharts
4. **Start using it**: Invoke the router and make requests!

## Support & Feedback

- **Found a bug?** Correct the routing and router learns
- **Want a feature?** Request new patterns or workflows
- **Have feedback?** All corrections improve the system

---

## Quick Command Reference

```bash
# Invoke router skill
use router skill

# View context (manual check)
~/.claude/tools/router-context.sh

# Read documentation
cat ~/.claude/docs/router-guide.md
cat ~/.claude/docs/router-examples.md

# Check routing logic
cat ~/.claude/skills/router-patterns.md
cat ~/.claude/skills/router-workflows.md
```

---

**Version**: 1.0.0
**Created**: 2025-11-05T10:23:50Z
**Status**: ✅ Ready for Production Use
**Total Size**: ~156KB of comprehensive documentation and code

**Ready to route intelligently? Let's go!** 🚀
