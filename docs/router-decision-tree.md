---
name: router-decision-tree
description: Visual decision tree and flowcharts for router skill logic
type: documentation
version: 1.0.0
created: 2025-11-05T10:23:50Z
lastmodified: 2025-11-05T10:23:50Z
---

# Router Decision Tree Visualization

<context>
This document provides visual representations of the router's decision-making logic using ASCII flowcharts and decision trees. These visualizations help understand how the router analyzes requests and selects tools.
</context>

## Master Routing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER REQUEST                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: INTENT ANALYSIS                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Extract      │  │ Identify     │  │ Detect       │          │
│  │ Action Verbs │  │ Domain       │  │ Urgency      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PHASE 2: CONTEXT GATHERING                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Git Status   │  │ Diagnostics  │  │ File Types   │          │
│  │ - Branch     │  │ - Type Errors│  │ - .tsx/.ts   │          │
│  │ - Modified   │  │ - Test Fails │  │ - .test.ts   │          │
│  │ - Clean?     │  │ - Lint Warn  │  │ - Config     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────┴────────┐
                    │ Urgency Check   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
         CRITICAL        NORMAL         LOW PRIORITY
              │              │              │
              │              ▼              │
              │    ┌─────────────────┐     │
              │    │ PHASE 3:        │     │
              │    │ DECISION ENGINE │     │
              │    └────────┬────────┘     │
              │             │              │
              └─────────────┼──────────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
      HIGH CONFIDENCE  MEDIUM CONF   LOW CONFIDENCE
       (Score > 0.7)   (0.4-0.7)     (< 0.4)
              │             │             │
              ▼             ▼             ▼
       Direct Route   Route + Alts   Ask Questions
              │             │             │
              └─────────────┼─────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PHASE 4: EXECUTION                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Single     │  │  Sequential  │  │   Parallel   │          │
│  │   Tool       │  │  Chain       │  │  Multiple    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PHASE 5: COMMUNICATION                         │
│  - Explain routing decision                                      │
│  - Show alternatives (if medium confidence)                      │
│  - Provide learning tips                                         │
│  - Monitor execution and report results                          │
└─────────────────────────────────────────────────────────────────┘
```

## Action Verb Routing Tree

```
                        USER REQUEST
                             │
                    Extract Action Verb
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    "FIX"                "REVIEW"             "DOCUMENT"
        │                    │                    │
   Check Context        Check Context         Check Context
        │                    │                    │
   ┌────┴────┐          ┌────┴────┐         ┌────┴────┐
   ▼         ▼          ▼         ▼         ▼         ▼
Type Err?  Test Fail  Security?  Quality?  Code?    Structure?
   │         │          │         │         │         │
   ▼         ▼          ▼         ▼         ▼         ▼
/fix:types /fix:tests /reviewer  /review   /docs    /docs:
                      :security  :orch     :general  diataxis

        │                    │                    │
        ▼                    ▼                    ▼
    "BUILD"              "TEST"               "PLAN"
        │                    │                    │
   Domain Check         Clarify Type         Check Stage
        │                    │                    │
   ┌────┴────┐          ┌────┴────┐         ┌────┴────┐
   ▼         ▼          ▼         ▼         ▼         ▼
React?   Backend?    Manual?   Write?   Feature?  Architecture?
   │         │          │         │         │         │
   ▼         ▼          ▼         ▼         ▼         ▼
ui-eng   ts-coder   playwrigh ts-coder  /planning  arch-
agent    agent      t-skill   agent     :feature   patterns

        │                    │
        ▼                    ▼
   "COMMIT"            "DEPLOY"
        │                    │
  Pre-Check Quality    Check Readiness
        │                    │
   ┌────┴────┐               │
   ▼         ▼               ▼
Errors?    Clean?      deployment-
   │         │         engineer agent
   ▼         ▼
Fix First /git:commit
```

## Confidence Scoring Decision Tree

```
                     Calculate Confidence
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        Intent Match   Context Rel    Ambiguity
         (50% weight)  (30% weight)   (20% weight)
              │              │              │
         ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
         ▼         ▼    ▼         ▼    ▼         ▼
      Exact  Partial  High   Medium Single  Multiple
      Match  Match    Rel    Rel    Option  Options
        │      │       │       │       │       │
        ▼      ▼       ▼       ▼       ▼       ▼
       1.0    0.6     1.0     0.5     1.0     0.0
                             │
                    Weighted Sum
                             │
              Score = (IM×0.5)+(CR×0.3)+((1-A)×0.2)
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
          > 0.7          0.4-0.7          < 0.4
              │              │              │
              ▼              ▼              ▼
     HIGH CONFIDENCE  MEDIUM CONF    LOW CONFIDENCE
              │              │              │
              ▼              ▼              ▼
       Direct Route    Route + Alts   Ask Questions
       Brief Explain   Show Options   Multiple Choice
```

## Context-Aware Routing Flow

```
                        Request Received
                             │
                    Gather Project Context
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   Git Status          Diagnostics           File Types
        │                    │                    │
        │                    │                    │
   ┌────┴────┐          ┌────┴────┐         ┌────┴────┐
   ▼         ▼          ▼         ▼         ▼         ▼
Modified?  Clean?    Type Err?  Tests?    .tsx?    .test.ts?
   │         │          │         │         │         │
   │         │          │         │         │         │
   └─────────┴──────────┴─────────┴─────────┴─────────┘
                             │
                    Adjust Routing Based on Context
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
  BLOCKING ISSUES      CLEAN STATE        UI FOCUS
        │                    │                    │
        ▼                    ▼                    ▼
Prioritize Fixes     Enable All Ops    Prefer ui-engineer
Warn Before Commit   High Confidence   React patterns
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                      Apply Routing
```

## Multi-Step Orchestration Decision

```
                        Request Analysis
                             │
                    Multi-Step Detected?
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
                   YES                NO
                    │                 │
            Analyze Dependencies      │
                    │                 │
        ┌───────────┴───────────┐     │
        │                       │     │
        ▼                       ▼     ▼
    Sequential?             Parallel?  Single Tool
        │                       │       │
        ▼                       ▼       │
  Steps Depend             Independent  │
  on Each Other            Operations   │
        │                       │       │
        │                       │       │
  Example:                Example:      │
  fix → commit           fix types +    │
  plan → implement       fix tests      │
        │                       │       │
        └───────────┬───────────┘       │
                    │                   │
                    ▼                   │
            Hybrid Pattern?             │
                    │                   │
                    ▼                   │
           Sequential Stages            │
           with Parallel Within         │
                    │                   │
           Example:                     │
           Stage1: fix:all (parallel)   │
           Stage2: review (sequential)  │
           Stage3: commit (sequential)  │
                    │                   │
                    └───────────────────┘
                            │
                       Execute Plan
```

## Emergency Routing Decision

```
                        Request Received
                             │
                    Check Urgency Keywords
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    "URGENT"             "CRITICAL"           "PRODUCTION"
    "NOW"                "BROKEN"             "DOWN"
    "ASAP"               "EMERGENCY"          "BLOCKING"
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    EMERGENCY MODE ACTIVATED
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
           Skip Confirmations   Fast-Path Routing
                    │                 │
                    └────────┬────────┘
                             │
                    Rapid Diagnostics
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   Type Errors?         Test Failures?        Lint Errors?
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                   PARALLEL FIXES
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    /fix:types          /fix:tests           /fix:lint
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    All Fixes Complete?
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
                   YES                NO
                    │                 │
                    │            Report Issues
                    │            Manual Intervention
                    ▼
           Immediate Commit
                    │
                    ▼
         Ready for Deployment
```

## Workflow Selection Tree

```
                        Request Keywords
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   "build feature"      "fix bug"          "review code"
   "create feature"     "broken"           "code review"
        │                    │                    │
        ▼                    ▼                    ▼
  Feature Dev Wf        Bug Fix Wf         Review Wf
        │                    │                    │
  5 stages:             5 stages:           4 stages:
  plan → impl           explore → fix       fixes → review
  → quality             → verify            → specialized
  → review              → review            → address findings
  → commit              → commit            → commit
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
  "add tests"          "security audit"     "optimize"
  "test coverage"      "vulnerability"      "performance"
        │                    │                    │
        ▼                    ▼                    ▼
  Testing Wf          Security Audit      Performance Opt
        │                    │                    │
  6 stages:             5 stages:           5 stages:
  strategy              automated scan      baseline
  → unit tests          → auth review       → analysis
  → integration         → input val         → optimization
  → e2e tests           → dependencies      → verification
  → verification        → compliance        → review
  → coverage            → report
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    Execute Workflow
```

## Tool Selection Matrix

```
                        Intent + Domain
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    FIX + TYPE           BUILD + REACT       REVIEW + SECURITY
        │                    │                    │
        ▼                    ▼                    ▼
    /fix:types          ui-engineer         /reviewer:security
      COMMAND              AGENT                COMMAND
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   PLAN + FEATURE      TEST + BROWSER      DOCUMENT + CODE
        │                    │                    │
        ▼                    ▼                    ▼
   /planning:feature    playwright-skill    /docs:general
      COMMAND              SKILL                COMMAND
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
  EXPLORE + CODE      DEPLOY + APP        OPTIMIZE + PERF
        │                    │                    │
        ▼                    ▼                    ▼
   Explore agent      deployment-eng      /reviewer:quality
      AGENT              AGENT                COMMAND
```

## Edge Case Handling Flow

```
                        Routing Decision Made
                             │
                    Execution Attempted
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
                 SUCCESS            ERROR
                    │                 │
                    │            Analyze Error
                    │                 │
                    │    ┌────────────┼────────────┐
                    │    │            │            │
                    │    ▼            ▼            ▼
                    │  Not Found   Timeout    Permission
                    │    │            │         Denied
                    │    │            │            │
                    │    ▼            ▼            ▼
                    │  Fuzzy      Suggest      Explain
                    │  Match      Smaller      & Guide
                    │  Correct    Scope
                    │    │            │            │
                    │    └────────────┼────────────┘
                    │                 │
                    │           Offer Alternative
                    │                 │
                    └─────────────────┼─────────────┐
                                      │             │
                                      ▼             ▼
                                  Try Again    Manual Resolution
                                      │             │
                                      └──────┬──────┘
                                             │
                                        Report to User
```

## Context Priority Matrix

```
                    URGENCY LEVEL
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
    CRITICAL          NORMAL           LOW
        │                │                │
        ▼                ▼                ▼

BLOCKING ISSUES:
Type Errors        Priority 1       Priority 2       Priority 3
Test Failures      Priority 1       Priority 2       Priority 3
Lint Warnings      Priority 2       Priority 3       Priority 4

USER REQUEST:
New Feature        Priority 2       Priority 3       Priority 4
Refactoring        Priority 3       Priority 4       Priority 5
Documentation      Priority 4       Priority 5       Priority 5

ROUTING BEHAVIOR:
Priority 1  → Immediate parallel fix, skip confirmations
Priority 2  → Fix first, then proceed with request
Priority 3  → Suggest fixes, proceed with request
Priority 4  → Note issues, proceed, suggest later
Priority 5  → Proceed, mention improvements available
```

## Parallel vs Sequential Decision

```
                    Multiple Operations Detected
                             │
                    Analyze Dependencies
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    All Independent      Some Depend          All Depend
        │                    │                    │
        ▼                    ▼                    ▼
    PARALLEL            HYBRID               SEQUENTIAL
        │                    │                    │
        │              Group by Stage             │
        │                    │                    │
  Execute All           Within Stage:             │
  Concurrently          - Parallel               │
        │               Across Stages:            │
        │               - Sequential              │
        │                    │                    │
        │                    │               Execute in Order
        │                    │               Wait for Each
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                      Monitor Execution
                             │
                    Aggregate Results
                             │
                      Report to User
```

## Summary Flow

```
USER → Intent Analysis → Context Gathering → Decision Engine
                                                    │
                    ┌───────────────────────────────┼───────────────────────┐
                    │                               │                       │
              HIGH CONFIDENCE                MEDIUM CONFIDENCE        LOW CONFIDENCE
                    │                               │                       │
              Direct Route                    Route + Alts            Ask Questions
                    │                               │                       │
                    └───────────────────────────────┼───────────────────────┘
                                                    │
                                            Execute Tool(s)
                                                    │
                                    ┌───────────────┼───────────────┐
                                    │               │               │
                                Single         Sequential        Parallel
                                    │               │               │
                                    └───────────────┼───────────────┘
                                                    │
                                            Monitor & Report
                                                    │
                                            Learning Update
```

---

## Legend

```
┌─────┐
│ Box │  = Process/Stage
└─────┘

  │
  ▼     = Flow Direction

┌──┴──┐
│ ? ? │ = Decision Point
└──┬──┘

[ABC]   = Multiple Options

CAPS    = States/Modes

lowercase = actions
```

---

**Version**: 1.0.0
**Last Modified**: 2025-11-05T10:23:50Z

**Note**: These visualizations represent the logical flow. The actual implementation may optimize certain paths or combine steps for efficiency.
