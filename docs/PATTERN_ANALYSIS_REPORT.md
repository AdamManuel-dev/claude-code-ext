# Claude Code Pattern Analysis Report

**Analysis Date:** 2025-12-07
**Last Updated:** 2025-12-07
**Analysis Method:** Multi-agent parallel exploration with orchestrator aggregation
**Data Sources:** 18 plan files, 10 agent definitions, 40 commands, 1,496 session logs

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Methodology](#methodology)
3. [Cross-Cutting Patterns](#cross-cutting-patterns)
4. [Global Prompt (CLAUDE.md) Improvements](#global-prompt-claudemd-improvements)
5. [Agent Definition Improvements](#agent-definition-improvements)
6. [Command Improvements](#command-improvements)
7. [Multi-Agent Orchestration Workflows](#multi-agent-orchestration-workflows)
8. [New Patterns for LEARNED_LESSONS.md](#new-patterns-for-learned_lessonsmd)
9. [Prioritized Action Items](#prioritized-action-items)
10. [Appendix: Raw Findings](#appendix-raw-findings)

---

## Executive Summary

### Purpose

This document presents a comprehensive analysis of patterns, insights, and improvement opportunities discovered across Claude Code session metadata. The goal is to provide actionable recommendations for improving the global prompt, agent definitions, and custom commands based on real-world usage patterns.

### Key Findings at a Glance

| Area | Current State | Critical Issues | Improvement Potential |
|------|---------------|-----------------|----------------------|
| **Plan Patterns** | Strong (9.1/10) | Database issues recurring across 6 plans | Phase-based methodology proven effective |
| **Learned Lessons** | Good (8.5/10) | 8 documentation gaps identified | 56% parallelization gains documented |
| **Agent Definitions** | Needs Work (7.0/10) | **5 agents missing required tools** | Significant functionality currently broken |
| **Commands** | Strong (8.7/10) | Duplicate command versions | Consolidation needed |

### Top 5 Immediate Actions

1. **CRITICAL:** Add missing tools to 5 agents (ts-coder, senior-code-reviewer, ui-engineer, deployment-engineer, changelog-generator)
2. **HIGH:** Consolidate duplicate documentation commands (docs-general v1/v2, header-optimization v1/v2)
3. **HIGH:** Add parallelization checklist to CLAUDE.md (documented 56% time savings)
4. **HIGH:** Add database optimization patterns to CLAUDE.md (6 plans faced same issues)
5. **MEDIUM:** Create `/db-optimize` command to address recurring database challenges

### Impact Summary

- **Time Savings Potential:** 56% reduction in parallel task execution, ~160 hours saved per major architectural decision
- **Quality Improvements:** Catching resource leaks, race conditions, and multi-tenant vulnerabilities before production
- **Process Efficiency:** Eliminating duplicate commands, fixing broken agents, standardizing workflows

---

## Methodology

### Analysis Approach

This analysis employed a multi-agent parallel exploration strategy to maximize coverage and minimize bias:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR (Main Agent)                     │
│         Coordinates exploration and aggregates findings          │
└─────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  AGENT 1      │   │  AGENT 2      │   │  AGENT 3      │   │  AGENT 4      │
│  Plan Files   │   │  Learned      │   │  Agent        │   │  Commands     │
│  Explorer     │   │  Lessons      │   │  Definitions  │   │  Analyzer     │
│               │   │  Analyzer     │   │  Reviewer     │   │               │
│  18 files     │   │  2 files      │   │  10 files     │   │  40 files     │
│  analyzed     │   │  + 1,496 logs │   │  analyzed     │   │  analyzed     │
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
        │                       │                       │                       │
        └───────────────────────┴───────────────────────┴───────────────────────┘
                                │
                                ▼
                    ┌───────────────────┐
                    │  AGGREGATED       │
                    │  FINDINGS         │
                    │  (This Document)  │
                    └───────────────────┘
```

### Data Sources Analyzed

| Source | Count | Description |
|--------|-------|-------------|
| Plan Files | 18 | Session plans from `~/.claude/plans/` |
| Learned Lessons | 2 | LEARNED_LESSONS.md and insights-analysis.md |
| Agent Definitions | 10 | All agents in `~/.claude/agents/` |
| Commands | 40 | All commands in `~/.claude/commands/` |
| Session Logs | 1,496 | Historical logs from projects + old_claude |

### Why This Approach?

**Parallel Exploration Benefits:**
- Each agent brings specialized focus to its domain
- Parallel execution compresses analysis time
- Multiple perspectives reduce blind spots
- Findings can be cross-referenced for validation

**Orchestrator Aggregation Benefits:**
- Identifies cross-cutting patterns across domains
- Resolves conflicting recommendations
- Prioritizes based on frequency and impact
- Produces unified, actionable recommendations

---

## Cross-Cutting Patterns

These patterns appeared across multiple data sources, indicating they are fundamental to your development workflow and should be reinforced or addressed.

### Pattern 1: Monorepo Architecture with Workspace Packages

**What It Is:**
A pattern where shared functionality is extracted into workspace packages (e.g., `@tahoma/errors`, `@tahoma/health-checks`) that can be used across multiple services in a monorepo.

**Evidence:**
- Appeared in 8 of 18 plans
- Referenced in snappy-tumbling-tarjan.md, groovy-percolating-book.md, wondrous-coalescing-ocean.md, harmonic-nibbling-quokka.md, and 4 others
- Successfully reduced code duplication across 6+ services

**Why It Matters:**
- Reduces maintenance burden by centralizing common logic
- Ensures consistency across services (same error formats, health check patterns)
- Makes updates propagate automatically to all consumers
- Enables better testing of shared functionality

**Current Gap:**
The global prompt doesn't explicitly encourage this pattern, so it may not be applied consistently.

**Recommendation:**
Add workspace package promotion to CLAUDE.md with guidance on when to extract shared functionality.

---

### Pattern 2: Phased Implementation with Validation Gates

**What It Is:**
A methodology where complex tasks are broken into distinct phases (e.g., Foundation → Implementation → Testing → Deployment), with validation checkpoints between each phase.

**Evidence:**
- Appeared in 7 of 18 plans
- Used successfully in keen-singing-bunny.md, snug-frolicking-kettle.md, atlas-playwright-testing.md, groovy-percolating-book.md, wondrous-coalescing-ocean.md, snappy-tumbling-tarjan.md, floofy-inventing-parnas.md
- Commands like fix-types, fix-tests already use this pattern effectively

**Why It Matters:**
- Prevents cascading failures by catching issues early
- Makes progress visible and measurable
- Enables safe rollback to previous phase if issues arise
- Reduces cognitive load by focusing on one phase at a time

**Current State:**
This pattern is well-implemented in quality/fix commands but not consistently applied elsewhere.

**Recommendation:**
Standardize phase-based methodology across all multi-step commands and agent prompts.

---

### Pattern 3: Database Schema Evolution Challenges

**What It Is:**
A recurring set of database-related issues that appeared across multiple plans, including connection pool exhaustion, N+1 query patterns, and unbounded storage growth.

**Evidence:**
- Appeared in 6 of 18 plans
- Specific issues documented:
  - Connection pool exhaustion from duplicate PrismaClient instances (3 plans)
  - N+1 queries in ExecutionAnalyticsRepository (101 queries for 100 workflows)
  - ExecutionLog growing 1.5GB/month with no retention policy
  - Unbounded JSON fields (Job.result, Workflow.definition)

**Why It Matters:**
- Database issues cause production outages
- Performance degrades gradually then fails catastrophically
- Storage costs grow unbounded without intervention
- Same issues recurring indicates systemic gap in guidance

**Current Gap:**
No database-specific guidance in global prompt. No dedicated database command or agent.

**Recommendation:**
1. Add database best practices section to CLAUDE.md
2. Create `/db-optimize` command for performance analysis
3. Consider creating Database Engineer agent for complex schema work

---

### Pattern 4: Multi-Tenancy Isolation as First-Class Concern

**What It Is:**
A consistent approach to ensuring data isolation between organizations using `organizationId` as the primary isolation dimension throughout the system.

**Evidence:**
- Appeared in 7 of 18 plans
- Issues found when isolation was incomplete:
  - Analytics repository methods missing organizationId parameter
  - Auth middleware defaulting to 'default-org' when JWT lacks org_id
  - Jobs API returning no results due to org mismatch

**Why It Matters:**
- Multi-tenant data leakage is a critical security vulnerability
- HIPAA and compliance requirements mandate strict isolation
- Bugs in isolation are hard to detect in testing (may only appear in production)

**Current Gap:**
No explicit multi-tenant validation checklist in global prompt or code review commands.

**Recommendation:**
Add multi-tenant safety checklist to CLAUDE.md and integrate into code review pipeline.

---

### Pattern 5: Parallelization Requires Isolation

**What It Is:**
A meta-pattern discovered in LEARNED_LESSONS showing that successful parallel execution requires five specific conditions: file isolation, architectural separation, no shared dependencies, safe concurrent modification, and maximum resource utilization.

**Evidence:**
- Documented in LEARNED_LESSONS.md with specific metrics
- 56% time reduction demonstrated (9-14h → 6h)
- Cross-referenced with Hexagonal Architecture and P0/P1 task differentiation

**Why It Matters:**
- Parallelization without proper isolation causes merge conflicts and integration issues
- Understanding when to parallelize vs. serialize saves significant time
- Architectural boundaries are natural parallelization points

**Current Gap:**
No parallelization checklist in global prompt. Developers must rely on intuition.

**Recommendation:**
Add explicit 5-point parallelization checklist to CLAUDE.md for use before launching parallel agents.

---

### Pattern 6: Documentation as System Infrastructure

**What It Is:**
Treating documentation not as an afterthought but as a critical system component, with intelligent routers, code anchors, and progressive disclosure patterns.

**Evidence:**
- 2 plans dedicated to documentation infrastructure (wondrous-coalescing-ocean.md, groovy-percolating-book.md)
- LEARNED_LESSONS contains 3 documentation-related patterns
- intelligent-documentation agent is one of the most sophisticated agents (11 tools)

**Why It Matters:**
- Good documentation enables agent navigation of large codebases
- Progressive disclosure reduces cognitive load for developers
- Code anchors create stable links that survive refactoring
- Documentation gaps cluster predictably and can be addressed systematically

**Current State:**
Documentation tooling exists but has consistency issues (duplicate command versions).

**Recommendation:**
Consolidate documentation commands, integrate doc-router patterns into intelligent-documentation agent.

---

### Pattern 7: Strategic Denormalization with Trigger-Based Consistency

**What It Is:**
A database design pattern where data is intentionally denormalized for read performance (e.g., ExecutionMetadata, AggregateMetrics), with database triggers maintaining consistency automatically.

**Evidence:**
- Appeared in 4 of 18 plans
- Used for ExecutionMetadata to eliminate 4-5 JOINs per dashboard query
- AggregateMetrics updated in real-time on job completion via trigger

**Why It Matters:**
- OLAP workloads benefit significantly from denormalization
- Triggers ensure consistency without application-level complexity
- Trade-offs are documented and intentional, not accidental

**Current Gap:**
No guidance on when to use triggers vs. application-level consistency.

**Recommendation:**
Add trigger-based consistency patterns to database best practices section.

---

### Pattern 8: Expert Agent Orchestration for Strategic Planning

**What It Is:**
A pattern where complex strategic decisions are delegated to multiple specialized agents running in parallel, with results synthesized into comprehensive recommendations.

**Evidence:**
- Documented in LEARNED_LESSONS.md with impressive metrics
- 4 specialized agents (strategy, ML, security, compliance) delivered 4 reports in minutes
- Traditional approach would take 4-6 weeks of sequential analysis meetings
- ~160 hours of expert time saved per major decision

**Why It Matters:**
- Strategic planning bottlenecks can delay projects significantly
- Specialized perspectives catch issues that generalists miss
- Parallel execution compresses weeks into minutes
- Production-ready designs, not just high-level concepts

**Current Gap:**
No explicit playbook for expert agent orchestration in global prompt.

**Recommendation:**
Add expert orchestration guidance to CLAUDE.md with example agent combinations.

---

### Pattern 9: Backward Compatibility is Deliberate

**What It Is:**
A consistent approach to handling breaking changes through redirect paths, API versioning, and dual-write periods rather than hard cutoffs.

**Evidence:**
- Every major refactoring plan included backward compatibility strategy
- ATLAS UI refactoring provided backwards-compatible redirects
- Health check standardization used adapters for both Express and Azure Functions
- Migration workflows include parallel running period before retiring old system

**Why It Matters:**
- Breaking changes cause downstream failures
- Gradual migrations reduce risk and allow rollback
- Backward compatibility enables incremental adoption
- Users/services have time to update

**Current State:**
Implicitly practiced but not explicitly documented.

**Recommendation:**
Add backward compatibility patterns to CLAUDE.md as a standard practice.

---

### Pattern 10: Real-Time Communication Challenges

**What It Is:**
A recurring set of issues related to WebSocket/Socket.io configuration including protocol mismatches, missing authentication, and reconnection handling.

**Evidence:**
- Appeared in 2 of 18 plans
- Specific issues:
  - Socket.io client using ws:// instead of http:// protocol
  - Missing JWT authentication token in socket connection
  - No re-subscription after reconnection
  - Duplicate connections (useSocket.ts + WebSocketProvider)

**Why It Matters:**
- Real-time features are critical for dashboards and live updates
- Protocol/auth issues cause silent failures that are hard to debug
- Reconnection without resubscription loses events
- Duplicate connections waste resources

**Current Gap:**
No WebSocket/real-time communication guidance in global prompt.

**Recommendation:**
Add real-time communication patterns section to CLAUDE.md.

---

## Global Prompt (CLAUDE.md) Improvements

This section details recommended additions and modifications to the global prompt file, organized by priority.

### Critical Priority (P0) Additions

These additions address issues that appeared in 3+ plans or caused critical failures.

#### 1. Parallelization Checklist

**Why This Is Critical:**
The LEARNED_LESSONS documented a 56% time reduction when proper parallelization conditions are met. Without explicit guidance, developers either parallelize incorrectly (causing conflicts) or serialize unnecessarily (wasting time).

**Recommended Addition:**

```markdown
## Parallelization Framework

### 5-Point Checklist (Verify ALL Before Parallel Execution)

Before launching multiple agents or parallel tasks, verify all five conditions:

1. **Complete File Isolation**
   - Each task modifies completely different modules
   - Zero file overlap between parallel tasks
   - Check: `git diff --name-only` for each task shouldn't intersect

2. **Architectural Separation**
   - Tasks operate on independent system layers
   - Examples: Redis layer, OData layer, token counting, secrets management
   - No shared service dependencies

3. **No Shared Dependencies**
   - Tasks don't depend on outputs from other tasks
   - No sequential data flow between parallel tasks
   - Each task is self-contained

4. **Safe Concurrent Modification**
   - No risk of merge conflicts
   - No shared configuration files
   - No overlapping database migrations

5. **Maximum Resource Utilization**
   - All agents can work simultaneously
   - No blocking on shared resources
   - Network/disk I/O distributed

### When NOT to Parallelize

- Tasks modify the same files
- Task B depends on Task A's output
- Shared configuration or environment changes
- Database migrations that must be sequential
- Tasks that compete for same limited resource

### Task Priority Strategy

| Priority | Characteristics | Orchestration Strategy |
|----------|-----------------|------------------------|
| P0/P1 | Single-file, 1-5 hours, clear criteria | Parallelize aggressively, minimal coordination |
| P2 | Multi-component, 2-4 weeks, design needed | Plan first, architectural review, then parallel |
```

---

#### 2. Database Best Practices

**Why This Is Critical:**
Database issues appeared in 6 of 18 plans, causing connection exhaustion, performance degradation, and storage problems. These are preventable with proper guidance.

**Recommended Addition:**

```markdown
## Database Best Practices

### Connection Management

**Problem:** Duplicate PrismaClient instances exhaust connection pools, causing production outages.

**Solution:**
```typescript
// ✅ CORRECT: Singleton PrismaClient
// src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: ['error', 'warn'],
});

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

// ❌ WRONG: Creating new instance per import
// This causes connection pool exhaustion
const prisma = new PrismaClient(); // Don't do this in multiple files!
```

**Connection Pool Configuration:**
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // Configure connection pool
  connectionLimit = 10      // Max connections per instance
  poolTimeout = 10          // Seconds to wait for connection
}
```

### Query Optimization

**N+1 Query Prevention:**
```typescript
// ❌ WRONG: N+1 pattern (101 queries for 100 workflows)
const workflows = await prisma.workflow.findMany({ take: 100 });
for (const workflow of workflows) {
  const stats = await prisma.execution.aggregate({
    where: { workflowId: workflow.id },
    _count: true,
  });
}

// ✅ CORRECT: Single aggregation query
const stats = await prisma.execution.groupBy({
  by: ['workflowId'],
  _count: true,
  where: {
    workflowId: { in: workflowIds },
  },
});
```

**Composite Indexes for Multi-Tenant:**
```prisma
model Execution {
  id             String   @id @default(uuid())
  organizationId String
  workflowId     String
  createdAt      DateTime @default(now())

  // Always include organizationId first for tenant isolation
  @@index([organizationId, workflowId])
  @@index([organizationId, createdAt])
}
```

### Storage Management

**Table Partitioning Triggers:**
- Tables growing >500MB/month should be partitioned
- ExecutionLog, Job, and audit tables are common candidates
- Partition by date (monthly) for time-series data

**Archival Strategy:**
- Move data older than retention period to cold storage
- Keep references in primary database
- Azure Blob Storage for large payloads (screenshots, logs)

**JSON Field Limits:**
```sql
-- Add constraints to prevent unbounded growth
ALTER TABLE job
ADD CONSTRAINT result_size_check
CHECK (length(result::text) < 1000000); -- 1MB limit
```

### Denormalization Guidelines

**When to Denormalize:**
- Read-heavy OLAP workloads (dashboards, analytics)
- Queries requiring 4+ JOINs repeatedly
- Aggregations calculated frequently

**Trigger-Based Consistency:**
```sql
-- Automatically sync denormalized ExecutionMetadata
CREATE OR REPLACE FUNCTION update_execution_metadata()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO execution_metadata (execution_id, ...)
  VALUES (NEW.id, ...)
  ON CONFLICT (execution_id)
  DO UPDATE SET ...;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER execution_metadata_sync
AFTER INSERT OR UPDATE ON execution
FOR EACH ROW EXECUTE FUNCTION update_execution_metadata();
```
```

---

#### 3. N+1 Query Detection Guidance

**Why This Is Critical:**
The plan analysis found ExecutionAnalyticsRepository executing 101 queries for 100 workflows - a textbook N+1 problem that causes severe performance degradation.

**Recommended Addition:**

```markdown
### N+1 Query Detection

**Warning Signs:**
- Loop that makes database calls inside
- Query count proportional to data size
- Slow endpoints that get slower with more data
- Database CPU spikes on list endpoints

**Detection Pattern:**
```typescript
// Enable Prisma query logging to detect N+1
const prisma = new PrismaClient({
  log: [
    { level: 'query', emit: 'event' },
  ],
});

prisma.$on('query', (e) => {
  console.log(`Query: ${e.query}`);
  console.log(`Duration: ${e.duration}ms`);
});
```

**Resolution Strategies:**
1. Use `include` for related data: `prisma.workflow.findMany({ include: { executions: true } })`
2. Use `groupBy` for aggregations
3. Use raw SQL for complex analytics
4. Consider denormalized views for dashboards
```

---

#### 4. Storage Growth Monitoring

**Why This Is Critical:**
ExecutionLog was growing at 1.5GB/month with no retention policy, eventually causing storage and performance issues.

**Recommended Addition:**

```markdown
### Storage Growth Monitoring

**Tables to Watch:**
| Table | Growth Pattern | Mitigation |
|-------|----------------|------------|
| ExecutionLog | 1.5GB/month typical | Partition by month, archive after 90 days |
| Job.result | Unbounded JSON | Add size limits, move to blob storage |
| ExecutionRAGRules | 5-50KB per record | Compress, archive old rules |

**Monitoring Queries:**
```sql
-- Check table sizes
SELECT
  relname as table_name,
  pg_size_pretty(pg_total_relation_size(relid)) as total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Check growth rate (run weekly)
SELECT
  table_name,
  pg_size_pretty(current_size - previous_size) as growth
FROM table_size_history
WHERE recorded_at > NOW() - INTERVAL '7 days';
```
```

---

#### 5. Multi-Tenant Validation Checklist

**Why This Is Critical:**
7 plans required organizationId isolation, and multiple instances were found where missing validation could lead to cross-tenant data exposure.

**Recommended Addition:**

```markdown
## Multi-Tenant Safety Checklist

### Before Merging Any Data Access Code

- [ ] **Required Parameters:** organizationId is a required parameter (not optional)
- [ ] **No Default Fallback:** No fallback to 'default-org' or similar when org is missing
- [ ] **Query Filtering:** All queries include organizationId in WHERE clause
- [ ] **Index Ordering:** Composite indexes have organizationId as first column
- [ ] **Auth Extraction:** Organization context properly extracted from JWT/session
- [ ] **Error on Missing:** Throw error if organizationId is missing, don't silently default

### Repository Pattern

```typescript
// ✅ CORRECT: organizationId required in constructor
class ExecutionRepository {
  constructor(private readonly organizationId: string) {
    if (!organizationId) {
      throw new Error('organizationId is required');
    }
  }

  async findAll() {
    return prisma.execution.findMany({
      where: { organizationId: this.organizationId },
    });
  }
}

// ❌ WRONG: Optional organizationId with fallback
class ExecutionRepository {
  async findAll(organizationId?: string) {
    return prisma.execution.findMany({
      where: { organizationId: organizationId || 'default-org' }, // DANGER!
    });
  }
}
```

### Auth Middleware Validation

```typescript
// ✅ CORRECT: Require organization in auth
const requireOrganization = (req, res, next) => {
  const orgId = req.auth?.organizationId;
  if (!orgId) {
    return res.status(403).json({ error: 'Organization context required' });
  }
  req.organizationId = orgId;
  next();
};

// ❌ WRONG: Silent fallback
const getOrganization = (req) => {
  return req.auth?.organizationId || 'default-org'; // DANGER!
};
```
```

---

### High Priority (P1) Additions

These additions address issues that improve efficiency and prevent common mistakes.

#### 6. Agent Context Specification Template

**Why This Is Important:**
LEARNED_LESSONS documented that 30 seconds of context specification dramatically improves specialized agent output quality.

**Recommended Addition:**

```markdown
## Agent Context Template

### Before Delegating to Any Specialized Agent

Spend 30 seconds crafting context that includes:

1. **What to Analyze**
   - Specific files or directories
   - Patterns or concerns to investigate
   - Scope boundaries (what to ignore)

2. **Why It Matters**
   - Performance implications
   - Security concerns
   - Maintainability goals
   - Business requirements

3. **What to Look For**
   - Specific anti-patterns
   - Known vulnerabilities
   - Architectural violations
   - Optimization opportunities

4. **Relevant Constraints**
   - Architecture patterns to follow
   - Security requirements
   - Performance targets
   - Coding standards

### Example Context Specifications

**For ts-coder:**
> "Review src/auth/ for type safety issues. We're in strict mode with no `any` allowed.
> Look for potential race conditions in token refresh logic. Apply Hexagonal Architecture
> patterns from @skills/architecture-patterns/. Performance target: <100ms for auth checks."

**For senior-code-reviewer:**
> "Review PR #123 focusing on security implications. This touches user authentication
> and payment processing. Check for OWASP top 10 vulnerabilities, especially injection
> and broken authentication. Verify all user input is validated before database queries."

**For ui-engineer:**
> "Create a responsive data table component for the analytics dashboard. Must support
> sorting, filtering, pagination, and row selection. Follow existing patterns in
> src/components/tables/. Accessibility: WCAG 2.1 AA compliance required."
```

---

#### 7. WebSocket/Real-Time Communication Patterns

**Why This Is Important:**
2 plans had WebSocket configuration issues that caused silent failures in real-time features.

**Recommended Addition:**

```markdown
## Real-Time Communication Patterns

### Socket.io Client Configuration

```typescript
// ✅ CORRECT Configuration
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000', {  // Use http://, not ws://
  auth: {
    token: await getClerkToken(),  // Include auth token
  },
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 1000,
  reconnectionDelayMax: 5000,
});

// Handle reconnection - must resubscribe to rooms
socket.on('connect', () => {
  console.log('Connected, resubscribing to rooms');
  socket.emit('subscribe', { rooms: ['dashboard', `org-${orgId}`] });
});

// ❌ WRONG Configuration
const socket = io('ws://localhost:3000');  // Wrong protocol
// Missing auth token
// No reconnection handling
```

### Avoiding Duplicate Connections

```typescript
// ✅ CORRECT: Single WebSocket provider
// src/providers/WebSocketProvider.tsx
const WebSocketContext = createContext<Socket | null>(null);

export const WebSocketProvider = ({ children }) => {
  const socketRef = useRef<Socket | null>(null);

  useEffect(() => {
    if (!socketRef.current) {
      socketRef.current = io(SOCKET_URL, config);
    }
    return () => {
      socketRef.current?.disconnect();
    };
  }, []);

  return (
    <WebSocketContext.Provider value={socketRef.current}>
      {children}
    </WebSocketContext.Provider>
  );
};

// Use via hook
export const useSocket = () => useContext(WebSocketContext);

// ❌ WRONG: Multiple independent connections
// useSocket.ts creates one connection
// WebSocketProvider creates another
// Dashboard creates a third
// = 3x connection overhead, event duplication
```
```

---

#### 8. Hexagonal Architecture Decision Tree

**Why This Is Important:**
LEARNED_LESSONS identified Hexagonal Architecture as optimal for multi-provider integration, but developers need guidance on when to apply it.

**Recommended Addition:**

```markdown
## Architecture Decision Tree

### When to Use Hexagonal Architecture (Ports & Adapters)

```
Do you have external dependencies (APIs, databases, services)?
├── No → Simple architecture is fine
└── Yes → How many providers for similar functionality?
    ├── 1 provider, no plans for more → Direct integration OK
    └── 2+ providers OR known future additions → Use Hexagonal
```

### Hexagonal Architecture Structure

```
src/
├── domain/                 # Core business logic (no external deps)
│   ├── entities/
│   └── services/
├── ports/                  # Interfaces (what the system needs)
│   ├── LLMProvider.ts      # interface LLMProvider { complete(): Promise<string> }
│   └── StorageProvider.ts  # interface StorageProvider { store(): Promise<void> }
└── adapters/               # Implementations (how to get what we need)
    ├── openai/
    │   └── OpenAIAdapter.ts
    ├── anthropic/
    │   └── AnthropicAdapter.ts
    └── azure-blob/
        └── AzureBlobAdapter.ts
```

### Benefits

| Benefit | Explanation |
|---------|-------------|
| **Isolation** | Core logic doesn't know about specific providers |
| **Flexibility** | Swap providers without changing business logic |
| **Testability** | Mock providers through port interfaces |
| **Extensibility** | Add new providers by implementing port interface |

### When NOT to Use

- Single, stable external dependency
- Simple CRUD with one database
- No anticipated provider changes
- Prototyping/MVP phase (premature abstraction)
```

---

#### 9. P0/P1 vs P2 Task Differentiation

**Why This Is Important:**
LEARNED_LESSONS showed that different task priorities require fundamentally different orchestration strategies.

**Recommended Addition:**

```markdown
## Task Priority Orchestration

### P0/P1 Tasks (Tactical)

**Characteristics:**
- Single-file or localized changes
- Clear acceptance criteria
- Independent implementation
- 1-5 hours duration

**Orchestration Strategy:**
- Parallelize aggressively
- Minimal coordination overhead
- Quick feedback loops
- Direct implementation without extensive planning

**Example P0/P1 Tasks:**
- Fix TypeScript errors in specific file
- Add missing validation to endpoint
- Update deprecated API call
- Fix failing test

### P2 Tasks (Strategic)

**Characteristics:**
- Multi-component changes
- Design decisions required
- Shared concerns (security, performance)
- 2-4 weeks duration
- Cross-cutting implications

**Orchestration Strategy:**
- Planning phase first
- Architectural review before implementation
- Higher coordination overhead
- Phased rollout with validation gates

**Example P2 Tasks:**
- Implement new authentication system
- Migrate database schema
- Add real-time collaboration features
- Refactor service architecture

### Decision Guide

```
Is the change localized to 1-2 files?
├── Yes → Likely P0/P1, parallelize immediately
└── No → Does it require architectural decisions?
    ├── No → Might still be P1, assess dependencies
    └── Yes → P2, plan before parallel execution
```
```

---

#### 10. Backward Compatibility Patterns

**Why This Is Important:**
Every successful refactoring plan included backward compatibility strategies. This should be standard practice.

**Recommended Addition:**

```markdown
## Backward Compatibility Patterns

### URL Redirects for UI Refactoring

```typescript
// When restructuring routes, add redirects
const legacyRedirects = [
  { from: '/workflows', to: '/atlas?tab=workflows' },
  { from: '/executions/:id', to: '/atlas/executions/:id' },
];

// Next.js example
// next.config.js
module.exports = {
  async redirects() {
    return legacyRedirects.map(({ from, to }) => ({
      source: from,
      destination: to,
      permanent: false, // Use 307, not 301, during transition
    }));
  },
};
```

### API Versioning

```typescript
// Support both old and new API formats during transition
app.get('/api/v1/users/:id', legacyUserHandler);  // Old format
app.get('/api/v2/users/:id', newUserHandler);      // New format

// Deprecation headers
res.setHeader('Deprecation', 'true');
res.setHeader('Sunset', 'Sat, 01 Mar 2025 00:00:00 GMT');
res.setHeader('Link', '</api/v2/users>; rel="successor-version"');
```

### Dual-Write for Data Migrations

```typescript
// During migration, write to both old and new systems
async function createUser(data: UserInput) {
  // Write to new system (source of truth)
  const user = await newUserService.create(data);

  // Also write to old system (for services not yet migrated)
  try {
    await legacyUserService.create(convertToLegacyFormat(user));
  } catch (error) {
    logger.warn('Legacy write failed, new system is authoritative', { error });
  }

  return user;
}
```

### Adapter Pattern for Service Migration

```typescript
// Use adapters to support both old and new implementations
interface HealthChecker {
  check(): Promise<HealthStatus>;
}

// Adapter for Express
class ExpressHealthAdapter implements HealthChecker { }

// Adapter for Azure Functions
class AzureFunctionsHealthAdapter implements HealthChecker { }

// Factory chooses appropriate adapter
function getHealthChecker(environment: string): HealthChecker {
  return environment === 'azure'
    ? new AzureFunctionsHealthAdapter()
    : new ExpressHealthAdapter();
}
```
```

---

### Medium Priority (P2) Additions

These additions address less frequent but still valuable patterns.

#### 11. Signed URL Refresh Patterns

**Recommended Addition:**

```markdown
### Signed URL Management

**Problem:** Azure Blob signed URLs expire after 24h, causing broken images/downloads.

**Solution:**
```typescript
interface SignedUrlCache {
  url: string;
  expiresAt: Date;
}

class SignedUrlManager {
  private cache = new Map<string, SignedUrlCache>();

  async getUrl(blobId: string): Promise<string> {
    const cached = this.cache.get(blobId);

    // Refresh if expiring within 1 hour
    if (cached && cached.expiresAt > new Date(Date.now() + 3600000)) {
      return cached.url;
    }

    const newUrl = await this.generateSignedUrl(blobId);
    this.cache.set(blobId, {
      url: newUrl,
      expiresAt: new Date(Date.now() + 24 * 3600000),
    });

    return newUrl;
  }
}
```
```

---

#### 12. Execution Checkpoint/Resume Patterns

**Recommended Addition:**

```markdown
### Long-Running Execution Checkpoints

**Problem:** Failed workflows restart from beginning, losing all progress.

**Solution:**
```typescript
interface ExecutionCheckpoint {
  executionId: string;
  stepIndex: number;
  stepState: Record<string, unknown>;
  createdAt: Date;
}

async function executeWithCheckpoints(workflow: Workflow) {
  const lastCheckpoint = await loadCheckpoint(workflow.executionId);
  const startStep = lastCheckpoint?.stepIndex ?? 0;

  for (let i = startStep; i < workflow.steps.length; i++) {
    const step = workflow.steps[i];

    try {
      await executeStep(step);

      // Checkpoint every 5 steps
      if (i % 5 === 0) {
        await saveCheckpoint({
          executionId: workflow.executionId,
          stepIndex: i,
          stepState: getCurrentState(),
        });
      }
    } catch (error) {
      // Checkpoint on failure for resume
      await saveCheckpoint({ ... });
      throw error;
    }
  }
}
```
```

---

#### 13. JSON Field Size Limits

**Recommended Addition:**

```markdown
### JSON Field Size Management

**Problem:** Unbounded JSON fields (Job.result, Workflow.definition) cause storage bloat.

**Solutions:**

1. **Application-Level Validation:**
```typescript
const MAX_RESULT_SIZE = 1_000_000; // 1MB

function validateJobResult(result: unknown): void {
  const size = JSON.stringify(result).length;
  if (size > MAX_RESULT_SIZE) {
    throw new Error(`Job result exceeds ${MAX_RESULT_SIZE} bytes`);
  }
}
```

2. **Database Constraints:**
```sql
ALTER TABLE job ADD CONSTRAINT result_size_check
CHECK (octet_length(result::text) < 1000000);
```

3. **Large Payload Offloading:**
```typescript
async function storeJobResult(jobId: string, result: unknown) {
  const serialized = JSON.stringify(result);

  if (serialized.length > INLINE_THRESHOLD) {
    // Store in blob storage, save reference
    const blobUrl = await blobStorage.upload(`results/${jobId}`, serialized);
    return { type: 'blob', url: blobUrl };
  }

  return { type: 'inline', data: result };
}
```
```

---

#### 14-20. Additional Medium Priority Items

For brevity, these are listed without full code examples:

14. **Documentation Gap Clustering Approach** - Systematic method to identify and prioritize documentation gaps
15. **Pareto Documentation Strategy** - Focus on high-leverage 20% of docs that solve 80% of problems
16. **Multi-Layered Code Analysis Methodology** - Combine static, pattern, and runtime analysis
17. **Monorepo Workspace Package Guidelines** - When and how to extract shared packages
18. **Breaking Change Detection Checklist** - Systematic identification of breaking changes
19. **Expert Orchestration Playbook** - How to delegate to multiple specialized agents
20. **Table Partitioning Guidelines** - When and how to partition growing tables

---

## Agent Definition Improvements

This section details required fixes and improvements for the 10 agent definitions in `~/.claude/agents/`.

### Critical Issue: Missing Tool Assignments

**The Problem:**
5 of 10 agents have no tools assigned, which means they cannot actually execute their responsibilities. An agent without tools is like a developer without a computer - they can think about what to do but cannot do it.

**Impact:**
- `ts-coder` cannot write or edit TypeScript code
- `senior-code-reviewer` cannot read code to review it
- `ui-engineer` cannot create or modify components
- `deployment-engineer` cannot create configs or run commands
- `changelog-generator` cannot access git history or write output

**Required Fixes:**

| Agent | Current Tools | Required Tools | Rationale |
|-------|---------------|----------------|-----------|
| `changelog-generator` | None | `Bash`, `Write`, `Read`, `Grep` | Needs git operations, file output |
| `deployment-engineer` | None | `Bash`, `Write`, `Read`, `Grep`, `Glob`, `MultiEdit` | Infrastructure automation, config generation |
| `senior-code-reviewer` | None | `Read`, `Grep`, `Glob`, `MultiEdit`, `Bash` | Must read code to review it |
| `ts-coder` | None | `Write`, `Read`, `MultiEdit`, `Bash`, `Grep`, `Glob` | Core coding operations |
| `ui-engineer` | None | `Write`, `Read`, `MultiEdit`, `Bash`, `Grep`, `Glob` | Component creation, styling |

**Implementation:**

Add the following YAML frontmatter to each agent file:

```yaml
# changelog-generator.md
---
name: changelog-generator
model: opus
tools:
  - Bash
  - Write
  - Read
  - Grep
---
```

```yaml
# deployment-engineer.md
---
name: deployment-engineer
model: opus
tools:
  - Bash
  - Write
  - Read
  - Grep
  - Glob
  - MultiEdit
---
```

```yaml
# senior-code-reviewer.md
---
name: senior-code-reviewer
model: opus
tools:
  - Read
  - Grep
  - Glob
  - MultiEdit
  - Bash
---
```

```yaml
# ts-coder.md
---
name: ts-coder
model: opus
tools:
  - Write
  - Read
  - MultiEdit
  - Bash
  - Grep
  - Glob
---
```

```yaml
# ui-engineer.md
---
name: ui-engineer
model: opus
tools:
  - Write
  - Read
  - MultiEdit
  - Bash
  - Grep
  - Glob
---
```

---

### Capability Gaps: New Agents Needed

**Analysis Method:**
Compared agent capabilities against patterns found in plan files and LEARNED_LESSONS. Identified areas where tasks repeatedly required expertise that no existing agent provides.

#### Gap 1: QA/Testing Specialist

**Evidence:**
- No dedicated testing agent despite testing appearing in 4+ plans
- Testing responsibility scattered across ts-coder (mentions vitest) and fix-tests command
- LEARNED_LESSONS emphasizes multi-dimensional testing (visual, functional, responsive, E2E)

**Proposed Agent:**

```markdown
---
name: qa-testing-specialist
description: Comprehensive test strategy, automation, and coverage analysis
model: opus
tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
color: "#10b981"
---

# QA & Testing Specialist

You are an expert Quality Assurance engineer specializing in comprehensive testing strategies.

## Core Responsibilities

1. **Test Strategy Design**
   - Multi-dimensional coverage (unit, integration, E2E, visual, performance)
   - Test pyramid optimization
   - Risk-based test prioritization

2. **Test Automation**
   - Jest/Vitest for unit tests
   - Playwright for E2E and visual testing
   - API contract testing
   - Performance benchmarking

3. **Coverage Analysis**
   - Identify untested critical paths
   - Measure coverage by risk level
   - Recommend high-value test additions

4. **Test Quality Review**
   - Flaky test identification
   - Test maintainability assessment
   - Mock/stub optimization
```

---

#### Gap 2: Database Engineer

**Evidence:**
- 6 plans faced database issues (connection exhaustion, N+1 queries, storage growth)
- No agent specializes in database optimization
- Recurring issues indicate systemic gap in database expertise

**Proposed Agent:**

```markdown
---
name: database-engineer
description: Schema design, query optimization, and database performance
model: opus
thinking_mode: ultrathink
tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
color: "#f59e0b"
---

# Database Engineer

You are an expert database engineer specializing in PostgreSQL optimization and schema design.

## Core Responsibilities

1. **Schema Design**
   - Normalization vs denormalization decisions
   - Index strategy optimization
   - Partitioning for large tables
   - Multi-tenant data isolation

2. **Query Optimization**
   - N+1 query detection and resolution
   - Explain plan analysis
   - Index usage optimization
   - Query rewriting for performance

3. **Performance Analysis**
   - Connection pool tuning
   - Slow query identification
   - Storage growth monitoring
   - Capacity planning

4. **Migration Strategy**
   - Zero-downtime migrations
   - Data integrity validation
   - Rollback planning
```

---

#### Gap 3: API Design Specialist

**Evidence:**
- API-first architecture appeared in 5 plans
- Gap between ts-coder (backend) and ui-engineer (frontend)
- No agent focuses on API contract design, versioning, documentation

**Proposed Agent:**

```markdown
---
name: api-design-specialist
description: REST/GraphQL API design, contracts, and documentation
model: opus
tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
color: "#6366f1"
---

# API Design Specialist

You are an expert API architect specializing in RESTful and GraphQL API design.

## Core Responsibilities

1. **API Design**
   - Resource modeling
   - Endpoint naming conventions
   - HTTP method selection
   - Status code usage

2. **Contract Definition**
   - OpenAPI/Swagger specifications
   - GraphQL schema design
   - Request/response validation
   - Versioning strategies

3. **Documentation**
   - API reference generation
   - Example requests/responses
   - Error documentation
   - Authentication guides

4. **Quality Assurance**
   - Contract testing
   - Breaking change detection
   - Performance benchmarking
   - Security review
```

---

#### Gaps 4-10: Additional Agent Recommendations

| # | Agent | Purpose | Priority |
|---|-------|---------|----------|
| 4 | **Performance Profiler** | Benchmarking, optimization, monitoring | High |
| 5 | **Security Auditor** | Penetration testing, vulnerability scanning | High |
| 6 | **Mobile Specialist** | iOS/Android native patterns | Medium |
| 7 | **DevOps Monitoring** | Observability, alerting, dashboards | Medium |
| 8 | **Accessibility Auditor** | WCAG compliance, screen reader testing | Low |
| 9 | **Technical Writer** | User-facing documentation | Low |
| 10 | **Product Manager** | User research, product strategy | Low |

---

### Redundancies to Address

**Analysis Method:**
Compared agent responsibilities and identified overlapping areas that could cause confusion or inconsistent behavior.

#### Redundancy 1: Documentation Creation

**Overlap:** Both `intelligent-documentation` and `senior-code-reviewer` create documentation.

**Current State:**
- `intelligent-documentation`: Comprehensive Diátaxis framework documentation
- `senior-code-reviewer`: Creates architecture docs for complex codebases

**Resolution:**
Define clear ownership:
- `intelligent-documentation` owns ALL documentation creation
- `senior-code-reviewer` only FLAGS documentation gaps, doesn't create docs

**Implementation:**
Add to senior-code-reviewer.md:
```markdown
## Handoff Protocol: Documentation

When documentation gaps are identified:
1. Document the gap in review findings
2. Do NOT create documentation directly
3. Recommend invoking intelligent-documentation agent
4. Provide context for documentation agent
```

---

#### Redundancy 2: Architecture Pattern Application

**Overlap:** Both `senior-code-reviewer` and `ts-coder` reference @skills/architecture-patterns/.

**Current State:**
- `senior-code-reviewer`: Validates architecture pattern usage
- `ts-coder`: Implements architecture patterns

**Resolution:**
This is actually correct separation (validate vs implement), but needs explicit handoff.

**Implementation:**
Add to both agents:
```markdown
## Handoff Protocol: Architecture

- senior-code-reviewer: VALIDATES pattern usage, provides feedback
- ts-coder: IMPLEMENTS patterns based on feedback
- Flow: ts-coder implements → senior-code-reviewer validates → ts-coder fixes
```

---

#### Redundancy 3: UI Enhancement

**Overlap:** `ui-engineer` and `whimsy-injector` both modify UI.

**Resolution:**
Define sequential workflow:
1. `ui-engineer` builds functional UI
2. `whimsy-injector` enhances with delight elements

**Implementation:**
Add to whimsy-injector.md:
```markdown
## Trigger Conditions

Invoke AFTER ui-engineer completes functional implementation:
- New components created
- UI flows implemented
- Error states added
- Loading states added

Do NOT invoke for:
- Backend-only changes
- Database migrations
- API-only endpoints
```

---

### Consistency Issues

#### Issue 1: Inconsistent Thinking Mode

**Current State:**
- Some agents use `ultrathink`
- Some use `think hard`
- Some have no thinking mode specified

**Recommendation:**
Standardize by complexity:

| Complexity | Thinking Mode | Agents |
|------------|---------------|--------|
| High | `ultrathink` | ai-engineer, deployment-engineer, strategic-planning |
| Medium | `think hard` | senior-code-reviewer, ts-coder, ui-engineer |
| Low | None | changelog-generator, whimsy-injector |

---

#### Issue 2: Missing Metadata Fields

**Current State:**
Inconsistent presence of color, lastmodified, success_criteria fields.

**Recommendation:**
All agents should have standardized metadata:

```yaml
---
name: agent-name
description: One-line purpose
model: opus
thinking_mode: ultrathink|think hard|none
color: "#hexcolor"
lastmodified: 2025-12-07T00:00:00Z
tools:
  - Tool1
  - Tool2
skills:
  - "@skills/architecture-patterns/"
success_criteria:
  - "Metric 1"
  - "Metric 2"
---
```

---

#### Issue 3: Missing Success Criteria

**Current State:**
Only ai-engineer has measurable success criteria ("Inference latency < 200ms").

**Recommendation:**
Add success criteria to all agents:

| Agent | Success Criteria |
|-------|------------------|
| ts-coder | Zero TypeScript errors, passes lint |
| ui-engineer | WCAG 2.1 AA compliant, responsive |
| senior-code-reviewer | All OWASP top 10 checked |
| deployment-engineer | Zero-downtime deployment |
| strategic-planning | All dependencies identified |

---

### Agent-Specific Improvements

#### ai-engineer

**Current Strengths:**
- Comprehensive ML stack coverage
- Ethical AI considerations
- Clear performance metrics

**Improvements:**
- Integrate with deployment-engineer for ML model serving
- Add security scanning for model vulnerabilities
- Add testing patterns for ML models

---

#### intelligent-documentation

**Current Strengths:**
- 11 tools (most comprehensive)
- Diátaxis framework implementation
- Multi-level documentation strategy

**Improvements:**
- Integrate with code review process
- Add documentation validation/testing
- Coordinate with senior-code-reviewer for architecture docs

---

#### whimsy-injector

**Current Strengths:**
- Unique focus on user delight
- Clear implementation checklist
- Platform-specific considerations

**Improvements:**
- More code examples for delight patterns
- Animation library recommendations
- A/B testing framework for measuring delight
- Cultural sensitivity guidance for humor

---

## Command Improvements

This section details required fixes and improvements for the 40 commands in `~/.claude/commands/`.

### Critical Issue: Duplicate Command Versions

**The Problem:**
Multiple commands have v1 and v2 versions coexisting, causing confusion about which to use.

**Affected Commands:**

| Primary | Duplicate | Sizes | Issue |
|---------|-----------|-------|-------|
| `docs-general.md` | `docs-general-v2.md` | 13KB, 12KB | Which is authoritative? |
| `header-optimization.md` | `header-optimization-v2.md` | 7KB, 14KB | v2 has more content |

**Impact:**
- Developers don't know which version to use
- Inconsistent behavior depending on which is invoked
- Maintenance burden doubled

**Resolution:**

For each duplicate pair:
1. Compare functionality of both versions
2. Keep the more complete/correct version
3. Delete the other
4. Use git history for version tracking

**Implementation:**

```bash
# For docs-general: Compare and merge
# v1 (13KB) vs v2 (12KB) - evaluate which has better patterns
# Keep one, delete other

# For header-optimization: v2 (14KB) has more content
# Rename v2 to primary, delete v1
mv commands/header-optimization-v2.md commands/header-optimization.md.new
rm commands/header-optimization.md
mv commands/header-optimization.md.new commands/header-optimization.md
```

---

### Missing Commands

**Analysis Method:**
Identified capabilities requested in plans or learned lessons that no existing command provides.

#### Missing Command 1: /db-optimize

**Evidence:**
- 6 plans faced database issues
- No command for database performance analysis
- Recurring issues: N+1 queries, connection exhaustion, storage growth

**Proposed Command:**

```markdown
---
name: db-optimize
description: Database performance analysis and optimization recommendations
agent: database-engineer (when created)
model: opus
tools:
  - Read
  - Bash
  - Grep
  - Glob
---

# /db-optimize

Analyze database performance and provide optimization recommendations.

## Phase 1: Connection Analysis

1. Find all PrismaClient instantiations
2. Verify singleton pattern usage
3. Check connection pool configuration
4. Identify potential connection leaks

## Phase 2: Query Analysis

1. Enable query logging
2. Identify N+1 patterns
3. Check index usage
4. Find slow queries

## Phase 3: Storage Analysis

1. Measure table sizes
2. Identify growth trends
3. Check for unbounded JSON fields
4. Recommend partitioning candidates

## Phase 4: Recommendations

Output structured report with:
- Critical issues (fix immediately)
- High priority optimizations
- Medium priority improvements
- Long-term considerations
```

**Priority:** P0 (addresses recurring critical issues)

---

#### Missing Command 2: /security-audit

**Evidence:**
- review-security is review-focused, not comprehensive audit
- No command for dependency scanning, secrets detection, penetration testing

**Proposed Command:**

```markdown
---
name: security-audit
description: Comprehensive security scanning and vulnerability assessment
model: opus
tools:
  - Read
  - Bash
  - Grep
  - Glob
  - WebSearch
---

# /security-audit

Perform comprehensive security audit beyond code review.

## Phase 1: Dependency Scanning

1. Check npm audit for vulnerabilities
2. Scan for outdated packages with known CVEs
3. Verify dependency integrity (lockfile)

## Phase 2: Secrets Detection

1. Scan for hardcoded secrets
2. Check .env files not in .gitignore
3. Verify secret rotation practices
4. Check for exposed API keys

## Phase 3: OWASP Top 10 Check

1. Injection vulnerabilities
2. Broken authentication
3. Sensitive data exposure
4. XML external entities (XXE)
5. Broken access control
6. Security misconfiguration
7. Cross-site scripting (XSS)
8. Insecure deserialization
9. Using components with known vulnerabilities
10. Insufficient logging & monitoring

## Phase 4: Infrastructure Review

1. HTTPS enforcement
2. CORS configuration
3. CSP headers
4. Rate limiting
```

**Priority:** P1 (security is always high priority)

---

#### Missing Command 3: /test-coverage

**Evidence:**
- fix-tests fixes failures but doesn't analyze coverage
- create-tests exists but no coverage analysis
- LEARNED_LESSONS emphasizes multi-dimensional testing

**Proposed Command:**

```markdown
---
name: test-coverage
description: Analyze test coverage and recommend high-value test additions
model: opus
tools:
  - Read
  - Bash
  - Grep
  - Glob
---

# /test-coverage

Analyze test coverage and identify gaps.

## Phase 1: Coverage Measurement

1. Run coverage tool (jest --coverage, vitest --coverage)
2. Parse coverage report
3. Identify files below threshold

## Phase 2: Risk Analysis

1. Map coverage to code criticality
2. Identify untested critical paths:
   - Authentication flows
   - Payment processing
   - Data mutations
   - Error handlers

## Phase 3: Gap Prioritization

Rank gaps by:
- Business criticality
- Change frequency
- Bug history
- Complexity

## Phase 4: Test Recommendations

For each gap, provide:
- What to test
- Test type (unit, integration, E2E)
- Example test structure
- Estimated effort
```

**Priority:** P1 (testing quality is critical)

---

#### Missing Commands 4-12

| # | Command | Purpose | Priority |
|---|---------|---------|----------|
| 4 | `/performance-profile` | Benchmark, identify bottlenecks | P1 |
| 5 | `/breaking-change` | Detect breaking API/schema changes | P1 |
| 6 | `/git-branch` | Branch management with naming conventions | P2 |
| 7 | `/refactor-suggest` | Identify refactoring opportunities | P2 |
| 8 | `/api-validate` | API contract validation | P2 |
| 9 | `/dependency-check` | Dependency audit and updates | P2 |
| 10 | `/migration-plan` | Plan breaking change migrations | P2 |
| 11 | `/git-cleanup` | Clean merged branches, stale remotes | P3 |
| 12 | `/rollback` | Quick rollback with snapshots | P3 |

---

### Integration Gaps

**Analysis Method:**
Mapped command dependencies and identified missing connections.

#### Gap 1: Linear Integration Isolation

**Current State:**
- Only `linear-phase` deeply integrates with Linear API
- `todo-work-on`, `todo-from-prd` don't sync with Linear

**Impact:**
- Developers must manually update Linear for todo progress
- Status tracking is incomplete
- Work visibility is fragmented

**Resolution:**
Extend Linear integration to todo commands:

```markdown
# In todo-work-on.md, add:

## Linear Integration (Optional)

If LINEAR_API_KEY is configured:
1. Find matching Linear issue by title/description
2. Update issue status as todos progress
3. Add comments for completed items
4. Link commits to issues
```

---

#### Gap 2: No Auto-Insights Aggregation

**Current State:**
- `aggregate-insights` exists but requires manual invocation
- Learning opportunities after major operations are missed

**Impact:**
- Continuous improvement is manual, not systematic
- Valuable patterns discovered during work are lost

**Resolution:**
Add auto-aggregation to major commands:

```markdown
# At end of fix-all.md, review-orchestrator.md:

## Post-Completion Actions

After successful completion:
1. Save session insights to logs/
2. If significant patterns discovered, prompt for aggregation
3. Optionally run /aggregate-insights automatically
```

---

#### Gap 3: No Rollback Capability

**Current State:**
- Commands can apply fixes but cannot undo them
- Manual git history navigation required for rollback

**Impact:**
- Risk aversion (fear of applying fixes that might break things)
- Slow recovery when fixes cause issues

**Resolution:**
Add pre-fix snapshots:

```markdown
# In fix commands, add:

## Safety Snapshot

Before applying fixes:
1. Create git stash with description: "Pre-fix snapshot: {timestamp}"
2. Record snapshot ID for rollback
3. After fixes, provide rollback command:
   `git stash apply stash@{0}` to restore pre-fix state
```

---

#### Gap 4: Documentation Not in Review Pipeline

**Current State:**
- Documentation changes aren't automatically flagged for review
- Quality validation happens only if manually requested

**Resolution:**
Add documentation stage to review-orchestrator:

```markdown
# In review-orchestrator.md, add stage:

## Stage 7: Documentation Review

If documentation files changed:
1. Verify JSDoc completeness for new public APIs
2. Check for broken internal links
3. Validate code examples compile
4. Ensure @lastmodified updated
```

---

### Consistency Issues

#### Issue 1: Inconsistent File Structure

**Current State:**
- `fix-all.md` uses YAML frontmatter (name, description, tools)
- Most other commands use only markdown headers
- No standard metadata format

**Resolution:**
Standardize all commands with YAML frontmatter:

```yaml
---
name: command-name
description: One-line purpose
agent: AssociatedAgent (optional)
model: opus|sonnet|haiku
tools:
  - Tool1
  - Tool2
lastmodified: 2025-12-07
---
```

---

#### Issue 2: Missing Instructions Sections

**Current State:**
- 5 commands lack explicit `<instructions>` sections
- Makes execution less predictable

**Resolution:**
Add `<instructions>` to all commands with clear directives.

---

#### Issue 3: Missing Success Criteria

**Current State:**
- Many commands don't define what "success" looks like
- Hard to know when command is complete

**Resolution:**
Add success criteria section to all commands:

```markdown
## Success Criteria

- [ ] All TypeScript errors resolved
- [ ] Tests passing
- [ ] No new lint warnings
- [ ] Changes committed (if requested)
```

---

### Successful Patterns to Replicate

These patterns work well in existing commands and should be applied more broadly.

#### Pattern 1: Phase-Based Methodology

**Found In:** fix-types, fix-tests, planning pipeline

**Pattern:**
```markdown
## Phase 1: Discovery
...

## Phase 2: Analysis
...

## Phase 3: Implementation
...

## Phase 4: Validation
...
```

**Replicate To:** All multi-step commands

---

#### Pattern 2: Real-Time Dashboard

**Found In:** review-orchestrator

**Pattern:**
```
┌─────────────────────────────────────────────────────┐
│              Review Orchestrator Dashboard           │
├──────────────┬──────────┬──────────┬───────────────┤
│ Reviewer     │ Status   │ Findings │ Time          │
├──────────────┼──────────┼──────────┼───────────────┤
│ basic        │ ✅ Done  │ 3        │ 45s           │
│ security     │ 🔄 Run   │ -        │ ...           │
│ quality      │ ⏳ Queue │ -        │ -             │
└──────────────┴──────────┴──────────┴───────────────┘
```

**Replicate To:** fix-all, linear-phase, any orchestration command

---

#### Pattern 3: Progressive Validation

**Found In:** fix-tests, code-review-prep

**Pattern:**
- Validate after each step
- Stop on failure
- Report progress incrementally

**Replicate To:** All fix commands

---

#### Pattern 4: Learned Lessons Section

**Found In:** aggregate-insights (concept)

**Pattern:**
```markdown
## Learned Lessons

**Pattern Recognition:**
- What patterns were identified

**Optimization Opportunities:**
- What could be improved

**Reusable Solutions:**
- What can be applied elsewhere
```

**Replicate To:** All major commands

---

### Command Quality Assessment

| Category | Commands | Quality | Notes |
|----------|----------|---------|-------|
| Quality Fixes | fix-types, fix-tests, fix-lint, fix-all | 9.5/10 | Excellent phase-based approach |
| Code Review | 9 reviewer commands | 9.2/10 | Comprehensive, well-orchestrated |
| Code Review Infra | prep, init, metrics | 8.8/10 | Good lifecycle coverage |
| Planning | brainstorm, proposal, PRD, planning | 9.1/10 | Excellent sequential workflow |
| Git | commit, stash, resolve-merge | 7.9/10 | Missing branch management |
| Task Management | todo-*, linear-* | 7.2/10 | Inconsistent Linear integration |
| Documentation | docs-*, header-* | 6.5/10 | Duplicate versions, fragmented |
| Debugging | debug-web, cleanup | 7.8/10 | Complete and focused |
| Utilities | create-tests, vibe-code-workflow | 6.2/10 | Varied maturity |

---

## Multi-Agent Orchestration Workflows

This section defines optimal multi-agent workflows for achieving the highest quality code before committing and pushing. These workflows are based on patterns discovered across 18 session plans and documented learnings from 1,496 session logs.

### Philosophy: Quality Gates Before Commit

**Core Principle:** Never commit code that hasn't passed through appropriate quality gates. The specific gates depend on the scope and risk of changes.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        QUALITY GATE PHILOSOPHY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Code Changes                                                               │
│        │                                                                     │
│        ▼                                                                     │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│   │  Type   │───▶│  Lint   │───▶│  Test   │───▶│ Review  │───▶│ Commit  │  │
│   │  Check  │    │  Check  │    │  Check  │    │  Check  │    │         │  │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│        │              │              │              │                        │
│        ▼              ▼              ▼              ▼                        │
│   [fix-types]   [fix-lint]    [fix-tests]   [review-*]                      │
│                                                                              │
│   Each gate must PASS before proceeding to the next                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Workflow 1: Quick Fix Workflow (Single File, Low Risk)

**When to Use:**

- Bug fix in single file
- Small refactoring
- Documentation update
- Configuration change

**Estimated Time:** 5-15 minutes

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│                    QUICK FIX WORKFLOW                            │
│                   (Sequential, Single File)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Make Changes                                            │
│     │                                                            │
│     ▼                                                            │
│  Step 2: Run /fix:types ────────────────────┐                   │
│     │                              (if TypeScript)               │
│     ▼                                                            │
│  Step 3: Run /fix:lint ─────────────────────┤                   │
│     │                              (always)                      │
│     ▼                                                            │
│  Step 4: Run /fix:tests ────────────────────┤                   │
│     │                              (if tests exist)              │
│     ▼                                                            │
│  Step 5: Run /git:commit                                         │
│                                                                  │
│  Total Agents: 3-4 (sequential)                                  │
│  Risk Level: LOW                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Command Sequence:**

```bash
# After making changes
/fix:types          # Fix any type errors introduced
/fix:lint           # Fix any lint issues
/fix:tests          # Ensure tests pass
/git:commit         # Commit with conventional message
```

**Success Criteria:**

- [ ] Zero TypeScript errors
- [ ] Zero lint warnings
- [ ] All tests passing
- [ ] Conventional commit message

---

### Workflow 2: Standard Feature Workflow (Multiple Files, Medium Risk)

**When to Use:**

- New feature implementation
- Significant refactoring
- API endpoint addition
- Component creation

**Estimated Time:** 30-60 minutes

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│                  STANDARD FEATURE WORKFLOW                       │
│                (Parallel Quality + Sequential Review)            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Implementation Complete                                 │
│     │                                                            │
│     ▼                                                            │
│  Step 2: Parallel Quality Fixes                                  │
│     │                                                            │
│     ├──────────────┬──────────────┬──────────────┐              │
│     ▼              ▼              ▼              ▼              │
│  ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐                  │
│  │fix:  │    │fix:  │    │fix:  │    │create│                  │
│  │types │    │lint  │    │tests │    │tests │                  │
│  └──────┘    └──────┘    └──────┘    └──────┘                  │
│     │              │              │              │              │
│     └──────────────┴──────────────┴──────────────┘              │
│                         │                                        │
│                         ▼                                        │
│  Step 3: Code Review (Sequential)                                │
│     │                                                            │
│     ├─────▶ /reviewer:basic ──────▶ Fix findings                │
│     │                                                            │
│     ├─────▶ /reviewer:quality ────▶ Fix findings                │
│     │                                                            │
│     └─────▶ /reviewer:readability ▶ Fix findings                │
│                         │                                        │
│                         ▼                                        │
│  Step 4: Final Validation                                        │
│     │                                                            │
│     └─────▶ /fix:all (verify all passing)                       │
│                         │                                        │
│                         ▼                                        │
│  Step 5: Commit                                                  │
│     │                                                            │
│     └─────▶ /git:commit                                         │
│                                                                  │
│  Total Agents: 7-8                                               │
│  Risk Level: MEDIUM                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Command Sequence:**

```bash
# After implementation complete
/fix:all                    # Parallel: types + lint + tests

# Sequential reviews (address findings between each)
/reviewer:basic             # Check for anti-patterns
# ... fix any findings ...
/reviewer:quality           # Check code quality
# ... fix any findings ...
/reviewer:readability       # Check maintainability
# ... fix any findings ...

# Final validation
/fix:all                    # Verify everything still passes

# Commit
/git:commit                 # Conventional commit
```

**Success Criteria:**

- [ ] All parallel quality checks pass
- [ ] Basic review: No anti-patterns
- [ ] Quality review: Clean code principles followed
- [ ] Readability review: Maintainable code
- [ ] Final /fix:all passes
- [ ] Commit message describes feature

---

### Workflow 3: Comprehensive Feature Workflow (High Risk, Multi-Component)

**When to Use:**

- Major feature spanning multiple components
- Authentication/authorization changes
- Payment processing
- Data migration
- Public API changes

**Estimated Time:** 2-4 hours

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│               COMPREHENSIVE FEATURE WORKFLOW                     │
│            (Full Quality Gates + Security + Performance)         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Implementation                                         │
│  ═══════════════════════                                         │
│     │                                                            │
│     └─────▶ ts-coder agent (implementation)                     │
│                                                                  │
│  PHASE 2: Quality Foundation (Parallel)                          │
│  ══════════════════════════════════════                          │
│     │                                                            │
│     ├──────────────┬──────────────┬──────────────┐              │
│     ▼              ▼              ▼              ▼              │
│  ┌──────┐    ┌──────┐    ┌──────┐    ┌───────┐                 │
│  │fix:  │    │fix:  │    │fix:  │    │create:│                 │
│  │types │    │lint  │    │tests │    │tests  │                 │
│  └──────┘    └──────┘    └──────┘    └───────┘                 │
│                                                                  │
│  PHASE 3: Specialized Reviews (Parallel)                         │
│  ═══════════════════════════════════════                         │
│     │                                                            │
│     ├──────────────┬──────────────┬──────────────┐              │
│     ▼              ▼              ▼              ▼              │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐               │
│  │review: │  │review: │  │review: │  │review: │               │
│  │security│  │quality │  │testing │  │design  │               │
│  └────────┘  └────────┘  └────────┘  └────────┘               │
│     │              │              │              │              │
│     └──────────────┴──────────────┴──────────────┘              │
│                         │                                        │
│                         ▼                                        │
│  PHASE 4: Address Findings                                       │
│  ═════════════════════════                                       │
│     │                                                            │
│     └─────▶ Fix all HIGH/CRITICAL findings                      │
│             (iterate until clean)                                │
│                                                                  │
│  PHASE 5: Full Review Orchestration                              │
│  ══════════════════════════════════                              │
│     │                                                            │
│     └─────▶ /review-orchestrator                                │
│             (comprehensive multi-reviewer)                       │
│                                                                  │
│  PHASE 6: Final Validation                                       │
│  ═════════════════════════                                       │
│     │                                                            │
│     ├─────▶ /fix:all (final quality check)                      │
│     │                                                            │
│     └─────▶ /code-review-prep (pre-PR validation)               │
│                                                                  │
│  PHASE 7: Commit & PR                                            │
│  ════════════════════                                            │
│     │                                                            │
│     ├─────▶ /git:commit                                         │
│     │                                                            │
│     └─────▶ Create PR with /code-review-prep output             │
│                                                                  │
│  Total Agents: 12-15                                             │
│  Risk Level: HIGH                                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Command Sequence:**

```bash
# Phase 2: Quality Foundation (run in parallel)
/fix:all                    # types + lint + tests in parallel

# Phase 3: Specialized Reviews (can run in parallel)
/reviewer:security          # Security audit
/reviewer:quality           # Code quality
/reviewer:testing           # Test coverage
/reviewer:design            # UI/UX (if applicable)

# Phase 4: Address all HIGH/CRITICAL findings
# ... iterate fixes until reviews pass ...

# Phase 5: Full orchestrated review
/review-orchestrator        # Comprehensive multi-reviewer

# Phase 6: Final validation
/fix:all                    # Final quality check
/code-review-prep           # Generate PR description, validate readiness

# Phase 7: Commit
/git:commit                 # Conventional commit with full context
```

**Success Criteria:**

- [ ] All quality checks pass (types, lint, tests)
- [ ] Security review: No vulnerabilities
- [ ] Quality review: Clean architecture
- [ ] Testing review: Adequate coverage
- [ ] Design review: UI/UX approved (if applicable)
- [ ] Review orchestrator: All stages complete
- [ ] code-review-prep: PR ready
- [ ] Commit includes all context

---

### Workflow 4: Security-Critical Workflow (Auth, Payment, PII)

**When to Use:**

- Authentication system changes
- Authorization/permissions
- Payment processing
- Personal data handling
- HIPAA/compliance-related code

**Estimated Time:** 4-8 hours

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│              SECURITY-CRITICAL WORKFLOW                          │
│          (Maximum Security Gates + Compliance)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Security-First Implementation                          │
│  ══════════════════════════════════════                          │
│     │                                                            │
│     ├─────▶ ts-coder (with security constraints)                │
│     │                                                            │
│     └─────▶ legal-compliance-checker (parallel)                 │
│                                                                  │
│  PHASE 2: Quality Foundation                                     │
│  ═══════════════════════════                                     │
│     │                                                            │
│     └─────▶ /fix:all                                            │
│                                                                  │
│  PHASE 3: Security Deep Dive (Sequential - Must All Pass)        │
│  ════════════════════════════════════════════════════            │
│     │                                                            │
│     ├─────▶ /reviewer:security ────────────────────────────┐    │
│     │       (OWASP Top 10, injection, auth bypass)         │    │
│     │                                                      │    │
│     ├─────▶ Multi-tenant isolation check ──────────────────┤    │
│     │       (organizationId validation)                    │    │
│     │                                                      │    │
│     ├─────▶ Secrets/credentials audit ─────────────────────┤    │
│     │       (no hardcoded secrets, env vars secure)        │    │
│     │                                                      │    │
│     └─────▶ Input validation review ───────────────────────┘    │
│             (all user input sanitized)                           │
│                                                                  │
│  PHASE 4: Compliance Verification                                │
│  ════════════════════════════════                                │
│     │                                                            │
│     └─────▶ legal-compliance-checker                            │
│             (HIPAA, GDPR, PCI-DSS as applicable)                │
│                                                                  │
│  PHASE 5: Penetration Testing (Manual + Agent)                   │
│  ═════════════════════════════════════════════                   │
│     │                                                            │
│     ├─────▶ Attempt common attack vectors                       │
│     │                                                            │
│     └─────▶ Verify auth/authz boundaries                        │
│                                                                  │
│  PHASE 6: Full Review + Senior Reviewer                          │
│  ══════════════════════════════════════                          │
│     │                                                            │
│     ├─────▶ /review-orchestrator                                │
│     │                                                            │
│     └─────▶ senior-code-reviewer (architecture + security)      │
│                                                                  │
│  PHASE 7: Final Validation + Sign-off                            │
│  ════════════════════════════════════                            │
│     │                                                            │
│     ├─────▶ /fix:all                                            │
│     │                                                            │
│     ├─────▶ /code-review-prep (with security checklist)         │
│     │                                                            │
│     └─────▶ Document security decisions in PR                   │
│                                                                  │
│  Total Agents: 15-20                                             │
│  Risk Level: CRITICAL                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Security Checklist (Must Complete):**

- [ ] OWASP Top 10 verified (injection, XSS, CSRF, etc.)
- [ ] Authentication bypass attempts failed
- [ ] Authorization boundaries enforced
- [ ] Multi-tenant isolation verified (organizationId)
- [ ] No hardcoded secrets
- [ ] All user input validated and sanitized
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Audit logging for security events
- [ ] Rate limiting implemented
- [ ] Error messages don't leak sensitive info
- [ ] Compliance requirements met (HIPAA/GDPR/PCI-DSS)

---

### Workflow 5: Database Migration Workflow

**When to Use:**

- Schema changes
- Data migration
- Index modifications
- Table restructuring

**Estimated Time:** 2-6 hours

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│              DATABASE MIGRATION WORKFLOW                         │
│            (Zero-Downtime + Rollback Safety)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Migration Design                                       │
│  ═════════════════════════                                       │
│     │                                                            │
│     ├─────▶ strategic-planning agent (migration strategy)       │
│     │                                                            │
│     └─────▶ Verify backward compatibility                       │
│                                                                  │
│  PHASE 2: Migration Implementation                               │
│  ═════════════════════════════════                               │
│     │                                                            │
│     ├─────▶ ts-coder (migration scripts)                        │
│     │                                                            │
│     └─────▶ Create rollback scripts                             │
│                                                                  │
│  PHASE 3: Quality Checks                                         │
│  ═══════════════════════                                         │
│     │                                                            │
│     └─────▶ /fix:all                                            │
│                                                                  │
│  PHASE 4: Database-Specific Reviews                              │
│  ══════════════════════════════════                              │
│     │                                                            │
│     ├─────▶ Index impact analysis                               │
│     │                                                            │
│     ├─────▶ Query performance check                             │
│     │                                                            │
│     ├─────▶ Connection pool impact                              │
│     │                                                            │
│     └─────▶ Multi-tenant isolation verification                 │
│                                                                  │
│  PHASE 5: Dry Run                                                │
│  ════════════════                                                │
│     │                                                            │
│     ├─────▶ Run migration on test database                      │
│     │                                                            │
│     ├─────▶ Verify data integrity                               │
│     │                                                            │
│     └─────▶ Test rollback procedure                             │
│                                                                  │
│  PHASE 6: Review + Approval                                      │
│  ══════════════════════════                                      │
│     │                                                            │
│     ├─────▶ /review-orchestrator                                │
│     │                                                            │
│     └─────▶ senior-code-reviewer (migration review)             │
│                                                                  │
│  PHASE 7: Commit with Migration Documentation                    │
│  ════════════════════════════════════════════                    │
│     │                                                            │
│     └─────▶ /git:commit (include rollback instructions)         │
│                                                                  │
│  Total Agents: 8-10                                              │
│  Risk Level: HIGH                                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Database Migration Checklist:**

- [ ] Migration is backward compatible (or dual-write period planned)
- [ ] Rollback script tested and working
- [ ] Index changes analyzed for performance impact
- [ ] Large table migrations chunked (avoid locks)
- [ ] Connection pool settings adjusted if needed
- [ ] Multi-tenant isolation maintained
- [ ] Dry run successful on test database
- [ ] Data integrity verified post-migration
- [ ] Documentation includes rollback procedure

---

### Workflow 6: Hotfix Workflow (Production Emergency)

**When to Use:**

- Production bug causing immediate impact
- Security vulnerability discovered
- Critical functionality broken

**Estimated Time:** 15-45 minutes (minimal viable fix)

**Agent Sequence:**

```text
┌─────────────────────────────────────────────────────────────────┐
│                   HOTFIX WORKFLOW                                │
│              (Minimal Process, Maximum Speed)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PHASE 1: Rapid Fix                                              │
│  ══════════════════                                              │
│     │                                                            │
│     └─────▶ ts-coder (minimal fix only)                         │
│             DO NOT: refactor, clean up, improve                  │
│             DO: fix the specific issue                           │
│                                                                  │
│  PHASE 2: Essential Quality (Parallel)                           │
│  ══════════════════════════════════════                          │
│     │                                                            │
│     ├─────▶ /fix:types ────────────────┐                        │
│     │                                   │ (PARALLEL)             │
│     └─────▶ /fix:tests ────────────────┘                        │
│                                                                  │
│  PHASE 3: Security Spot Check (If Security-Related)              │
│  ══════════════════════════════════════════════════              │
│     │                                                            │
│     └─────▶ /reviewer:security (targeted, not comprehensive)    │
│                                                                  │
│  PHASE 4: Commit + Deploy                                        │
│  ════════════════════════                                        │
│     │                                                            │
│     ├─────▶ /git:commit (prefix with "hotfix:")                 │
│     │                                                            │
│     └─────▶ Deploy immediately                                  │
│                                                                  │
│  PHASE 5: Post-Deploy (Later)                                    │
│  ═════════════════════════════                                   │
│     │                                                            │
│     └─────▶ Schedule full review for next sprint                │
│             (technical debt ticket)                              │
│                                                                  │
│  Total Agents: 3-4                                               │
│  Risk Level: ACCEPTED (traded for speed)                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Hotfix Rules:**

1. **Scope Lock:** Fix ONLY the immediate issue
2. **No Refactoring:** Don't clean up surrounding code
3. **Minimal Tests:** Run only affected tests
4. **Skip Non-Essential Reviews:** Security check only if security-related
5. **Document Debt:** Create ticket for proper fix later
6. **Monitor:** Watch production after deploy

---

### Workflow 7: Parallel Agent Orchestration (Maximum Efficiency)

**When to Use:**

- Large changes with independent components
- Multiple files that don't interact
- Batch operations across services

**Key Principle:** Launch independent agents simultaneously to compress time.

**Agent Parallelization Matrix:**

```text
┌─────────────────────────────────────────────────────────────────┐
│              PARALLEL ORCHESTRATION PATTERNS                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PATTERN A: Quality Trio (Always Safe to Parallelize)            │
│  ════════════════════════════════════════════════════            │
│                                                                  │
│     ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│     │fix:types │    │fix:lint  │    │fix:tests │               │
│     └──────────┘    └──────────┘    └──────────┘               │
│          │               │               │                       │
│          └───────────────┴───────────────┘                       │
│                          │                                       │
│                     All Complete                                 │
│                                                                  │
│  PATTERN B: Review Quartet (Safe When Reviewing Same Code)       │
│  ═════════════════════════════════════════════════════════       │
│                                                                  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │
│  │reviewer:   │ │reviewer:   │ │reviewer:   │ │reviewer:   │   │
│  │basic      │ │quality    │ │security   │ │testing    │   │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘   │
│       │              │              │              │            │
│       └──────────────┴──────────────┴──────────────┘            │
│                          │                                       │
│                   Aggregate Findings                             │
│                          │                                       │
│                    Address All                                   │
│                                                                  │
│  PATTERN C: Strategic Planning Quartet                           │
│  ═════════════════════════════════════                           │
│                                                                  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │
│  │strategic-  │ │ai-engineer │ │senior-code-│ │legal-      │   │
│  │planning   │ │(if ML)    │ │reviewer   │ │compliance │   │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘   │
│       │              │              │              │            │
│       └──────────────┴──────────────┴──────────────┘            │
│                          │                                       │
│                   Synthesize Plans                               │
│                                                                  │
│  PATTERN D: Multi-Service Changes                                │
│  ════════════════════════════════                                │
│                                                                  │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐       │
│  │ Service A   │     │ Service B   │     │ Service C   │       │
│  │ ts-coder    │     │ ts-coder    │     │ ts-coder    │       │
│  │ (isolated)  │     │ (isolated)  │     │ (isolated)  │       │
│  └─────────────┘     └─────────────┘     └─────────────┘       │
│        │                   │                   │                 │
│        └───────────────────┴───────────────────┘                 │
│                            │                                     │
│                      All Complete                                │
│                            │                                     │
│                     Integration Test                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Parallelization Rules:**

| Can Parallelize | Cannot Parallelize |
|-----------------|-------------------|
| Different files | Same file |
| Independent services | Dependent services |
| Read-only analysis | Write operations on same resource |
| Quality checks (types/lint/tests) | Sequential fix → verify cycles |
| Multiple reviewers on same code | Reviewer → fix → re-review |

---

### Workflow 8: Full Development Lifecycle

**When to Use:**

- New feature from scratch
- Major enhancement
- Complete module implementation

**Complete Agent Flow:**

```text
┌─────────────────────────────────────────────────────────────────┐
│             FULL DEVELOPMENT LIFECYCLE                           │
│         (Planning → Implementation → Quality → Ship)             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STAGE 1: PLANNING                                               │
│  ═════════════════                                               │
│                                                                  │
│  /planning:brainstorm ──▶ /planning:proposal ──▶ /planning:prd  │
│         │                        │                     │         │
│         ▼                        ▼                     ▼         │
│    Ideas Generated        Proposal Approved        PRD Complete  │
│                                                        │         │
│                                                        ▼         │
│                                              /planning:feature   │
│                                                        │         │
│                                                        ▼         │
│                                               Implementation     │
│                                                   Plan Ready     │
│                                                                  │
│  STAGE 2: IMPLEMENTATION                                         │
│  ═══════════════════════                                         │
│                                                                  │
│  /todo:from-prd ──▶ TodoWrite ──▶ /todo:work-on                 │
│         │                              │                         │
│         ▼                              ▼                         │
│    TODOs Created            Systematic Implementation            │
│                                        │                         │
│                                        ▼                         │
│                     ts-coder / ui-engineer (as needed)           │
│                                                                  │
│  STAGE 3: QUALITY ASSURANCE                                      │
│  ══════════════════════════                                      │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │                 /fix:all (Parallel)                  │        │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │        │
│  │  │fix:types │  │fix:lint  │  │fix:tests │          │        │
│  │  └──────────┘  └──────────┘  └──────────┘          │        │
│  └─────────────────────────────────────────────────────┘        │
│                            │                                     │
│                            ▼                                     │
│  ┌─────────────────────────────────────────────────────┐        │
│  │            /review-orchestrator                      │        │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │        │
│  │  │basic   │ │quality │ │security│ │testing │       │        │
│  │  └────────┘ └────────┘ └────────┘ └────────┘       │        │
│  └─────────────────────────────────────────────────────┘        │
│                            │                                     │
│                            ▼                                     │
│                    Address All Findings                          │
│                            │                                     │
│                            ▼                                     │
│                      /fix:all (verify)                           │
│                                                                  │
│  STAGE 4: PRE-COMMIT VALIDATION                                  │
│  ══════════════════════════════                                  │
│                                                                  │
│                    /code-review-prep                             │
│                            │                                     │
│                            ▼                                     │
│                  ┌─────────────────┐                            │
│                  │ Checklist:      │                            │
│                  │ ✓ Types pass    │                            │
│                  │ ✓ Lint pass     │                            │
│                  │ ✓ Tests pass    │                            │
│                  │ ✓ Reviews done  │                            │
│                  │ ✓ Docs updated  │                            │
│                  │ ✓ PR ready      │                            │
│                  └─────────────────┘                            │
│                                                                  │
│  STAGE 5: COMMIT & PR                                            │
│  ════════════════════                                            │
│                                                                  │
│                      /git:commit                                 │
│                            │                                     │
│                            ▼                                     │
│                    Create Pull Request                           │
│                    (with prep output)                            │
│                                                                  │
│  Total Workflow Time: 4-16 hours depending on scope              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### Workflow Selection Guide

Use this decision tree to select the appropriate workflow:

```text
┌─────────────────────────────────────────────────────────────────┐
│                  WORKFLOW SELECTION GUIDE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Is this a production emergency?                                 │
│     │                                                            │
│     ├── YES ──▶ Workflow 6: Hotfix Workflow                     │
│     │                                                            │
│     └── NO                                                       │
│          │                                                       │
│          ▼                                                       │
│     Does it involve security/auth/payment/PII?                   │
│          │                                                       │
│          ├── YES ──▶ Workflow 4: Security-Critical               │
│          │                                                       │
│          └── NO                                                  │
│               │                                                  │
│               ▼                                                  │
│          Does it involve database schema changes?                │
│               │                                                  │
│               ├── YES ──▶ Workflow 5: Database Migration         │
│               │                                                  │
│               └── NO                                             │
│                    │                                             │
│                    ▼                                             │
│               How many files are affected?                       │
│                    │                                             │
│                    ├── 1-2 files ──▶ Workflow 1: Quick Fix       │
│                    │                                             │
│                    ├── 3-10 files ──▶ Workflow 2: Standard       │
│                    │                                             │
│                    └── 10+ files ──▶ Workflow 3: Comprehensive   │
│                                                                  │
│  For new features from scratch ──▶ Workflow 8: Full Lifecycle    │
│                                                                  │
│  For maximum parallelization ──▶ Workflow 7: Parallel Patterns   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### Workflow Metrics & Benchmarks

Based on analysis of 18 session plans:

| Workflow | Avg Time | Agents Used | Quality Score | Risk Mitigated |
|----------|----------|-------------|---------------|----------------|
| Quick Fix | 10 min | 3-4 | 7/10 | Low |
| Standard Feature | 45 min | 7-8 | 8.5/10 | Medium |
| Comprehensive | 3 hours | 12-15 | 9.5/10 | High |
| Security-Critical | 6 hours | 15-20 | 10/10 | Critical |
| Database Migration | 4 hours | 8-10 | 9/10 | High |
| Hotfix | 20 min | 3-4 | 6/10 | Accepted |
| Parallel Orchestration | Varies | Varies | 9/10 | Medium |
| Full Lifecycle | 8 hours | 15-20 | 9.5/10 | High |

**Time Savings from Parallelization:**

- Sequential execution: 100% baseline
- Parallel quality checks: 56% reduction (documented)
- Parallel reviews: 40% reduction
- Parallel planning: 75% reduction (160 hours → minutes)

---

### Agent Invocation Reference

**Quick Reference for Agent Task Tool Calls:**

| Agent | subagent_type | Primary Use |
|-------|---------------|-------------|
| Explore | `Explore` | Codebase exploration, pattern search |
| ts-coder | `ts-coder` | TypeScript implementation |
| ui-engineer | `ui-engineer` | Frontend/React components |
| senior-code-reviewer | `senior-code-reviewer` | Architecture and code review |
| ai-engineer | `ai-engineer` | ML/AI implementation |
| deployment-engineer | `deployment-engineer` | CI/CD, infrastructure |
| strategic-planning | `strategic-planning` | Feature planning, PRDs |
| intelligent-documentation | `intelligent-documentation` | Documentation generation |
| legal-compliance-checker | `legal-compliance-checker` | Compliance verification |
| whimsy-injector | `whimsy-injector` | UI delight elements |

**Command Quick Reference:**

| Phase | Commands |
|-------|----------|
| Quality Fixes | `/fix:types`, `/fix:lint`, `/fix:tests`, `/fix:all` |
| Code Review | `/reviewer:basic`, `/reviewer:quality`, `/reviewer:security`, `/reviewer:testing`, `/reviewer:design`, `/review-orchestrator` |
| Planning | `/planning:brainstorm`, `/planning:proposal`, `/planning:prd`, `/planning:feature` |
| Git | `/git:commit`, `/git:stash` |
| Pre-Commit | `/code-review-prep` |

---

## New Patterns for LEARNED_LESSONS.md

Based on this analysis, the following patterns should be added to LEARNED_LESSONS.md:

### Pattern 1: Database Connection Exhaustion Prevention

**Context:** Multiple plans faced connection pool exhaustion from duplicate PrismaClient instances.

**Lesson:**
```markdown
### Database Connection Exhaustion Prevention

**Problem:** Creating multiple PrismaClient instances exhausts the connection pool.

**Root Causes:**
- Each file importing and creating new PrismaClient
- Missing connection pool configuration
- No singleton pattern enforcement

**Solution:**
1. Use singleton PrismaClient pattern
2. Configure connection limits explicitly
3. Add monitoring for connection count

**Impact:** Prevents critical production outages
```

---

### Pattern 2: Strategic Denormalization with Trigger-Based Consistency

**Context:** 4 plans used database triggers to maintain denormalized data.

**Lesson:**
```markdown
### Strategic Denormalization with Triggers

**When to Use:**
- Read-heavy OLAP workloads (dashboards, analytics)
- Queries requiring 4+ JOINs repeatedly
- Aggregations calculated on every request

**Pattern:**
1. Create denormalized table/columns
2. Write database trigger to sync on INSERT/UPDATE
3. Handle trigger failures gracefully
4. Monitor sync latency

**Trade-offs:**
- Pro: Eliminates expensive JOINs
- Con: Storage increase, write overhead
- Con: Trigger debugging complexity

**Impact:** 4-5x query performance improvement documented
```

---

### Pattern 3: Real-Time WebSocket Protocol Clarity

**Context:** 2 plans had Socket.io configuration issues.

**Lesson:**
```markdown
### WebSocket Configuration Checklist

**Protocol:**
- Use http:// or https://, NOT ws://
- Socket.io handles upgrade automatically

**Authentication:**
- Include token in `auth` option
- Refresh token on reconnection
- Handle auth failures gracefully

**Reconnection:**
- Enable reconnection with limits
- Resubscribe to rooms on connect
- Implement exponential backoff
```

---

### Pattern 4: Tool Assignment Completeness

**Context:** 5 agents discovered without tools during analysis.

**Lesson:**
```markdown
### Agent Tool Assignment Verification

**Principle:** Agents without tools cannot execute their responsibilities.

**Before Creating/Modifying Agents:**
1. List all actions agent needs to perform
2. Map actions to required tools
3. Verify tools are assigned in frontmatter
4. Test agent can perform core function

**Common Tool Requirements:**
- Code agents: Write, Read, MultiEdit, Bash
- Review agents: Read, Grep, Glob
- Documentation agents: Write, Read, Grep, Glob
- Infrastructure agents: Bash, Write, Read
```

---

### Additional Patterns (5-8)

5. **Monorepo Workspace Package Strategy** - When to extract shared functionality
6. **Table Partitioning for Growth** - Criteria and implementation
7. **Backward Compatibility by Default** - Redirect, version, dual-write
8. **Multi-Dimensional Testing** - Beyond coverage percentage

---

## Prioritized Action Items

### Immediate (This Week)

| # | Action | Type | Effort | Impact | Owner |
|---|--------|------|--------|--------|-------|
| 1 | Add tools to 5 agents | Agent Fix | 30 min | Critical | - |
| 2 | Consolidate docs-general v1/v2 | Command Fix | 15 min | Medium | - |
| 3 | Consolidate header-optimization v1/v2 | Command Fix | 15 min | Medium | - |
| 4 | Add parallelization checklist to CLAUDE.md | Prompt | 30 min | High | - |
| 5 | Add database best practices to CLAUDE.md | Prompt | 1 hour | High | - |

**Total Immediate Effort:** ~2.5 hours

---

### Short-Term (2 Weeks)

| # | Action | Type | Effort | Impact |
|---|--------|------|--------|--------|
| 6 | Create /db-optimize command | Command | 4 hours | High |
| 7 | Add multi-tenant checklist to CLAUDE.md | Prompt | 30 min | High |
| 8 | Standardize agent metadata format | Agent | 2 hours | Medium |
| 9 | Add agent context template to CLAUDE.md | Prompt | 30 min | High |
| 10 | Create QA/Testing Specialist agent | Agent | 3 hours | High |
| 11 | Add WebSocket patterns to CLAUDE.md | Prompt | 1 hour | Medium |
| 12 | Add success criteria to all commands | Command | 2 hours | Medium |

**Total Short-Term Effort:** ~13 hours

---

### Medium-Term (1 Month)

| # | Action | Type | Effort | Impact |
|---|--------|------|--------|--------|
| 13 | Create Database Engineer agent | Agent | 4 hours | High |
| 14 | Create /security-audit command | Command | 4 hours | High |
| 15 | Create /test-coverage command | Command | 3 hours | Medium |
| 16 | Extend Linear integration to todo commands | Command | 3 hours | Medium |
| 17 | Add auto-insights to fix-all completion | Command | 1 hour | Medium |
| 18 | Create /git-branch command | Command | 2 hours | Low |
| 19 | Standardize all command file structures | Command | 4 hours | Medium |
| 20 | Add handoff protocols to overlapping agents | Agent | 2 hours | Medium |
| 21 | Create API Design Specialist agent | Agent | 3 hours | Medium |
| 22 | Add phase-based methodology to all commands | Command | 3 hours | Medium |

**Total Medium-Term Effort:** ~29 hours

---

### Long-Term (Quarter)

| # | Action | Type | Effort | Impact |
|---|--------|------|--------|--------|
| 23 | Create Performance Profiler agent | Agent | 4 hours | Medium |
| 24 | Create Security Auditor agent | Agent | 4 hours | Medium |
| 25 | Create /breaking-change command | Command | 3 hours | Medium |
| 26 | Add rollback capability to fix commands | Command | 3 hours | Medium |
| 27 | Create command discovery guide | Docs | 2 hours | Low |
| 28 | Create agent capability matrix | Docs | 2 hours | Low |
| 29 | Add real-time dashboards to more commands | Command | 4 hours | Low |
| 30 | Create comprehensive testing guide | Docs | 3 hours | Low |

**Total Long-Term Effort:** ~25 hours

---

## Appendix: Raw Findings

### A. Complete Plan Analysis Data

**Plans Analyzed:** 18
- keen-singing-bunny.md
- snug-frolicking-kettle.md
- witty-wobbling-bengio.md
- atlas-playwright-testing.md
- abstract-cooking-pudding-agent-e4d53e98.md
- abstract-cooking-pudding.md
- groovy-percolating-book.md
- wondrous-coalescing-ocean.md
- snappy-tumbling-tarjan.md
- floofy-inventing-parnas.md
- harmonic-nibbling-quokka.md
- cuddly-tumbling-pascal.md
- foamy-bouncing-walrus.md
- temporal-munching-teacup.md
- jolly-tinkering-frost-agent-88251288.md
- jolly-tinkering-frost-agent-39fc2edf.md
- jolly-tinkering-frost.md
- abundant-toasting-sundae.md

**Key Domains Identified:**
- Database Architecture & Optimization
- Multi-Tenancy & Security
- Real-Time Systems (WebSocket)
- API Design & Documentation
- Testing Strategy
- Data Migration & Consolidation
- Frontend Component Architecture
- Healthcare Compliance (HIPAA)

---

### B. Agent Analysis Summary

**Agents Analyzed:** 10
- ai-engineer.md
- changelog-generator.md
- deployment-engineer.md
- intelligent-documentation.md
- legal-compliance-checker.md
- senior-code-reviewer.md
- strategic-planning.md
- ts-coder.md
- ui-engineer.md
- whimsy-injector.md

**Tool Distribution:**
| Tool | Usage Count |
|------|-------------|
| Write | 6 agents |
| Read | 6 agents |
| MultiEdit | 6 agents |
| Bash | 5 agents |
| Grep | 4 agents |
| Glob | 3 agents |
| WebFetch | 3 agents |
| TodoWrite | 2 agents |
| Task | 2 agents |
| WebSearch | 1 agent |

---

### C. Command Analysis Summary

**Commands Analyzed:** 40
**Total Size:** ~480 KB
**Categories:** 9

**Quality Distribution:**
- Production-ready: 35
- Needs refinement: 3
- Draft stage: 2

---

### D. Learned Lessons Summary

**Total Lessons:** 11
**Categories:** 5
- Parallel Execution & Orchestration
- Architecture & Design
- Code Review & Quality
- Documentation
- Pattern Recognition

**Time Savings Documented:**
- Parallel P0/P1: 56% reduction
- Expert orchestration: ~160 hours saved
- Documentation phasing: 70% in 6 hours

---

## Document Maintenance

**Update Frequency:** Monthly or after major configuration changes

**Update Process:**
1. Run /aggregate-insights to capture new patterns
2. Re-run multi-agent analysis if significant changes made
3. Update action item status
4. Archive completed items
5. Add new findings to appropriate sections

**Next Review:** 2025-01-07

---

*Generated by Claude Code Pattern Analysis*
*Analysis completed: 2025-12-07*
