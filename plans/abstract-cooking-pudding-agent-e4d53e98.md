# Documentation Router Skill - Implementation Plan

**Created**: 2025-12-03
**Objective**: Design a reusable Claude Code Skill for building AI agent documentation routing systems
**Approach**: Create generalized skill with Tahoma AI as reference implementation

---

## Skill Overview

### Purpose
Create a **documentation-router** skill that enables Claude Code agents to:
1. Build intelligent documentation routing systems for any codebase
2. Extract metadata from existing documentation patterns
3. Generate machine-optimized navigation indexes
4. Implement stable code linking with anchor tags
5. Automate maintenance via CI/CD

### Target Audience
- Development teams with 100+ documentation files
- Monorepo projects with multiple services
- Projects using Claude Code agents for development
- Teams wanting zero-maintenance documentation systems

### Prerequisites
- Existing documentation (markdown, JSDoc, OpenAPI, etc.)
- Git repository
- Node.js/TypeScript toolchain (for automation scripts)
- (Optional) CI/CD pipeline (GitHub Actions, GitLab CI, etc.)

---

## Skill Structure

### Skill File Location
`~/.claude/skills/documentation-router.md`

### Skill Invocation
```
Use the documentation-router skill to design and implement an AI agent documentation routing system
```

### Skill Phases

**Phase 1: Discovery** (Explore existing documentation patterns)
- Scan codebase for documentation files
- Identify existing patterns (@fileoverview, frontmatter, etc.)
- Analyze documentation organization (Diataxis, custom, etc.)
- Estimate high-value document count

**Phase 2: Design** (Design router architecture)
- Define routing strategies (task-based, domain-based, service-based)
- Design metadata schema
- Plan code anchor convention
- Choose automation approach

**Phase 3: Implementation** (Build automation scripts)
- Metadata extraction script
- Router generation script
- Anchor validation script
- Orchestration script

**Phase 4: Integration** (Set up CI/CD automation)
- GitHub Actions / GitLab CI workflow
- Auto-update triggers
- Validation gates

**Phase 5: Refinement** (Optimize based on usage)
- Token efficiency optimization
- Navigation pattern analysis
- Documentation health metrics

---

## Generalized Skill Implementation

### Key Abstractions

1. **Documentation Sources**
   - Markdown files (with/without frontmatter)
   - Source code (JSDoc, Python docstrings, Go docs, etc.)
   - API specifications (OpenAPI, GraphQL schemas, etc.)
   - README files
   - Architecture Decision Records (ADRs)

2. **Routing Dimensions**
   - **Task-based**: Route by development task type (fix bugs, add features, etc.)
   - **Domain-based**: Route by technical domain (auth, database, API, etc.)
   - **Service-based**: Route by microservice/module (for monorepos)
   - **Technology-based**: Route by tech stack (React, TypeScript, PostgreSQL, etc.)

3. **Metadata Extraction Patterns**
   - Frontmatter parsing (YAML, TOML)
   - JSDoc @fileoverview parsing
   - Git metadata (last modified, commit count, contributors)
   - Path-based inference (directory structure → domains)
   - Content analysis (keyword extraction, complexity scoring)

4. **Code Linking Strategies**
   - Anchor tags (JSDoc @anchor, Python # anchor, etc.)
   - Language server protocol (LSP) references
   - Symbol-based linking (class names, function names)
   - Line number fallback (with staleness warnings)

---

## Tahoma AI Reference Implementation

### Context
- **Codebase**: Monorepo with 8 services (TypeScript, React, Node.js)
- **Docs**: 2,626 markdown files, Diataxis framework, 130+ READMEs, 23 ADRs
- **Patterns**: Mandatory @fileoverview headers, JSDoc comments, git timestamps
- **Goal**: Route agents to ~200-300 high-value docs efficiently

### Discovery Phase Results

**Documentation Inventory**:
- Service READMEs: 8 files
- Architecture Decision Records: 23 files
- OpenAPI/Swagger specs: 4 files
- Diataxis framework docs: 25 files (tutorials, how-to, reference, explanation)
- Implementation guides: 67 files (in docs/implementation/*)
- Architecture docs: 15 files
- Code with @fileoverview: 100+ TypeScript files

**High-Value Selection Criteria**:
1. Mandatory: Service READMEs, ADRs, API specs, Diataxis docs
2. Score-based: Files with @fileoverview, recent git activity (<90 days)
3. Exclusions: Archive folder, TODO/session docs, temporal status reports

**Existing Patterns**:
- ✅ @fileoverview JSDoc headers (mandatory in project)
- ✅ Diataxis framework organization
- ✅ Consistent git timestamps
- ❌ No code anchors yet (need to add)
- ❌ No centralized router (need to build)

---

## Implementation Plan for Tahoma AI

### File Structure
```
/Users/adammanuel/Projects/tahoma-ai/
├── docs/
│   ├── AGENT_ROUTER.md              # Master routing document
│   ├── AGENT_METADATA.json          # Machine-readable index
│   └── AGENT_QUICK_LOOKUP.md        # Token-efficient reference
│
├── scripts/
│   └── doc-router/
│       ├── package.json
│       ├── tsconfig.json
│       ├── config.json              # Router configuration
│       ├── extract-metadata.ts      # Extract from docs/code
│       ├── build-router.ts          # Generate AGENT_ROUTER.md
│       ├── validate-anchors.ts      # Validate @anchor tags
│       └── update-router.sh         # Orchestration script
│
└── .github/
    └── workflows/
        └── update-docs-router.yml   # CI/CD automation
```

### Router Structure (AGENT_ROUTER.md)

```markdown
# Tahoma AI Documentation Router
**For**: Claude Code Agents  
**Last Updated**: [AUTO-GENERATED]  
**Coverage**: 247 documents

## Quick Navigation
- [Task-Based Routing](#task-based-routing) - Route by development task
- [Domain-Based Routing](#domain-based-routing) - Route by technical domain  
- [Service-Based Routing](#service-based-routing) - Route by service/module

---

## Task-Based Routing

### Authentication & Authorization Tasks
**Keywords**: auth, clerk, jwt, token, permission

| Task | Document | Type | Complexity |
|------|----------|------|------------|
| Implement Clerk auth | [Clerk Integration](docs/implementation/auth/clerk-integration.md) | Implementation | Medium |
| Understand auth flow | [Security Model](docs/diataxis/explanation/security.md) | Explanation | High |
| Fix auth middleware | [@ClerkAuthMiddleware](orchestration-service/src/middleware/auth.middleware.ts@ClerkAuthMiddleware) | Code | Medium |

**Related ADRs**: [ADR-006: Clerk Authentication](docs/architecture/decisions/ADR-006-clerk-authentication.md)
**Related APIs**: [OpenAPI: /auth/*](orchestration-service/docs/api/openapi.yaml#auth-endpoints)

---

### TypeScript & Type System Tasks
**Keywords**: typescript, types, interface, generic, type-error

| Task | Document | Type | Complexity |
|------|----------|------|------------|
| Fix type errors | [TypeScript Patterns](docs/reference/typescript-patterns.md) | Reference | Medium |
| Understand execution types | [@ExecutionContext](packages/playwright-executor/src/types/execution.types.ts@ExecutionContext) | Code | High |

---

## Domain-Based Routing

### Security Domain
**Scope**: Authentication, authorization, encryption, auditing

- [Security Model](docs/architecture/security-model.md) - Architecture overview
- [ADR-006: Clerk Authentication](docs/architecture/decisions/ADR-006-clerk-authentication.md) - Auth decision
- [ADR-011: Encryption Key Management](docs/architecture/decisions/ADR-011-encryption-key-management.md) - Key management
- [@ClerkAuthMiddleware](orchestration-service/src/middleware/auth.middleware.ts@ClerkAuthMiddleware) - Auth implementation

**Related Domains**: Credentials Management, Multi-Tenancy

---

### Workflow Execution Domain
**Scope**: Playwright, Browserbase, job queue, orchestration

- [Workflow Execution Model](docs/diataxis/explanation/workflow-execution.md) - Conceptual model
- [ADR-003: Playwright Browser Automation](docs/architecture/decisions/ADR-003-playwright-browser-automation.md) - Why Playwright
- [@WorkflowExecutor](packages/playwright-executor/src/executor/workflow-executor.ts@WorkflowExecutor) - Main executor
- [@StepExecutor](packages/playwright-executor/src/executor/step-executor.ts@StepExecutor) - Step execution

---

## Service-Based Routing

### orchestration-service
**Purpose**: Cloud workflow execution engine  
**Stack**: Node.js, Express, Prisma, PostgreSQL, BullMQ

**Quick Links**:
- [README](orchestration-service/README.md)
- [API Spec](orchestration-service/docs/api/openapi.yaml)
- [Modular Monolith Architecture](docs/architecture/decisions/ADR-001-modular-monolith-architecture.md)

**Key Areas**:
- Error Handling: [@errorHandlerMiddleware](orchestration-service/src/middleware/error-handler.middleware.ts@errorHandlerMiddleware)
- Job Queue: [docs/implementation/workflows/job-queue.md](docs/implementation/workflows/job-queue.md)
- Database: [docs/diataxis/reference/database-schema.md](docs/diataxis/reference/database-schema.md)

---

### WebAI (Chrome Extension)
**Purpose**: AI-powered browser automation  
**Stack**: React, TypeScript, Chrome APIs

**Quick Links**:
- [README](WebAI/README.md)
- [Extension Unification](docs/implementation/extensions/unification-strategy.md)

**Key Areas**:
- Message Routing: [@MessageRouter](packages/extension-services/src/messaging/MessageRouter.ts@MessageRouter)
- Recording: [@RecordingService](packages/extension-services/src/recording/RecordingService.ts@RecordingService)
```

### Metadata Schema (AGENT_METADATA.json)

```json
{
  "version": "1.0.0",
  "generated": "2025-12-03T20:00:00Z",
  "totalDocuments": 247,
  "documents": [
    {
      "id": "adr-006",
      "path": "docs/architecture/decisions/ADR-006-clerk-authentication.md",
      "title": "ADR-006: Clerk Authentication",
      "type": "adr",
      "domain": ["security", "authentication"],
      "services": ["orchestration-service", "Dashboard"],
      "keywords": ["clerk", "auth", "jwt"],
      "complexity": "medium",
      "lastModified": "2024-02-15T10:00:00Z",
      "routerAnchor": "#adr-006",
      "description": "Decision to adopt Clerk for authentication"
    },
    {
      "id": "code-workflow-exec",
      "path": "packages/playwright-executor/src/executor/workflow-executor.ts",
      "title": "WorkflowExecutor Class",
      "type": "code-reference",
      "domain": ["workflow-execution"],
      "codeAnchor": "@WorkflowExecutor",
      "fileoverview": {
        "features": "Complete workflow orchestration",
        "mainAPIs": "executeWorkflow()",
        "constraints": "IPage interface, environment-agnostic"
      }
    }
  ],
  "taskMappings": {
    "fix-typescript-errors": ["ts-patterns", "execution-types"],
    "debug-workflows": ["workflow-exec-model", "code-workflow-exec"],
    "implement-auth": ["adr-006", "security-model", "auth-middleware"]
  }
}
```

### Code Anchor Convention

**@anchor JSDoc Tag**:
```typescript
/**
 * @fileoverview Workflow executor for orchestrating complete workflow execution
 * @lastmodified 2025-11-30T00:00:00Z
 * @anchor WorkflowExecutor
 */
export class WorkflowExecutor {
  /**
   * @anchor executeWorkflow
   */
  async executeWorkflow(page: IPage, ...): Promise<WorkflowResult> {
    // ...
  }
}
```

**Naming Rules**:
- Classes/Interfaces: PascalCase (`@anchor WorkflowExecutor`)
- Functions/Methods: camelCase (`@anchor executeWorkflow`)
- Types/Enums: PascalCase (`@anchor ExecutionContext`)

**Linking from Docs**:
```markdown
See [@WorkflowExecutor](packages/playwright-executor/src/executor/workflow-executor.ts@WorkflowExecutor)
```

---

## Automation Scripts

### extract-metadata.ts (Simplified)

```typescript
/**
 * Extract metadata from documentation and code
 */
interface DocumentMetadata {
  id: string;
  path: string;
  title: string;
  type: 'adr' | 'api-spec' | 'implementation' | 'tutorial' | 'how-to' | 
        'reference' | 'explanation' | 'service-readme' | 'code-reference';
  domain: string[];
  services: string[];
  keywords: string[];
  complexity: 'low' | 'medium' | 'high';
  lastModified: string; // ISO 8601
  routerAnchor: string;
  codeAnchor?: string;
  description: string;
}

class MetadataExtractor {
  async extractAll(): Promise<DocumentMetadata[]> {
    return [
      ...await this.extractMarkdownDocs(),
      ...await this.extractCodeReferences(),
      ...await this.extractAPISpecs()
    ];
  }

  private async extractMarkdownDocs(): Promise<DocumentMetadata[]> {
    // Parse frontmatter, extract title from H1, infer domain from path
  }

  private async extractCodeReferences(): Promise<DocumentMetadata[]> {
    // Parse @fileoverview, extract @anchor tags, get git timestamps
  }

  private async extractAPISpecs(): Promise<DocumentMetadata[]> {
    // Parse OpenAPI/Swagger YAML files
  }
}
```

### build-router.ts (Simplified)

```typescript
/**
 * Generate AGENT_ROUTER.md from metadata
 */
class RouterBuilder {
  buildRouter(metadata: DocumentMetadata[]): string {
    return [
      this.buildHeader(metadata),
      this.buildQuickNavigation(),
      this.buildTaskBasedRouting(metadata),
      this.buildDomainBasedRouting(metadata),
      this.buildServiceBasedRouting(metadata)
    ].join('\n\n---\n\n');
  }

  private buildTaskBasedRouting(metadata: DocumentMetadata[]): string {
    const tasks = this.groupByTask(metadata);
    return tasks.map(task => this.renderTaskGroup(task)).join('\n\n');
  }

  private groupByTask(metadata: DocumentMetadata[]): TaskGroup[] {
    // Group docs by predefined task patterns
    return [
      {
        name: 'Authentication Tasks',
        keywords: ['auth', 'jwt', 'clerk'],
        docs: metadata.filter(d => d.domain.includes('authentication'))
      },
      // ... more task groups
    ];
  }
}
```

### validate-anchors.ts (Simplified)

```typescript
/**
 * Validate @anchor tags in codebase
 */
class AnchorValidator {
  async validate(): Promise<{ valid: boolean; errors: string[] }> {
    const anchors = await this.collectAnchors();
    const errors: string[] = [];

    // Check duplicates
    this.checkDuplicates(anchors, errors);

    // Check naming conventions
    this.checkNaming(anchors, errors);

    // Check references from docs
    await this.checkReferences(anchors, errors);

    return { valid: errors.length === 0, errors };
  }
}
```

### update-router.sh (Orchestration)

```bash
#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "🔄 Updating documentation router..."

npm run extract-metadata
npm run validate-anchors
npm run build-router
npm run build-metadata

echo "✅ Router updated!"
```

### GitHub Actions Workflow

```yaml
name: Update Documentation Router

on:
  push:
    paths: ['docs/**/*.md', '**/*.ts', '**/README.md']
  workflow_dispatch:

jobs:
  update-router:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: cd scripts/doc-router && npm ci
      
      - name: Update router
        run: ./scripts/doc-router/update-router.sh
      
      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/AGENT_*.md docs/AGENT_METADATA.json
          git diff --staged --quiet || git commit -m "docs: update router [skip ci]"
          git push
```

---

## Critical Implementation Steps

### Priority 1: Foundation (Week 1)
1. Create `scripts/doc-router/` structure
2. Implement `extract-metadata.ts` (markdown, code, API specs)
3. Validate on 30 sample documents
4. Tune extraction rules and exclusion patterns

### Priority 2: Router Generation (Week 1-2)
5. Implement `build-router.ts` (task, domain, service routing)
6. Generate initial `AGENT_ROUTER.md`
7. Create `AGENT_QUICK_LOOKUP.md` for token efficiency
8. Manual review and quality check

### Priority 3: Code Anchors (Week 2)
9. Document `@anchor` convention in project docs
10. Add anchors to top 50 most-referenced code files
11. Implement `validate-anchors.ts`
12. Run validation, fix issues

### Priority 4: Automation (Week 2-3)
13. Create `update-router.sh` orchestration script
14. Set up GitHub Actions workflow
15. Test end-to-end automation
16. Monitor first auto-update

### Priority 5: Refinement (Week 3-4)
17. Gather usage feedback from agent tasks
18. Optimize router for token efficiency (<50KB)
19. Add advanced features (semantic search, recommendations)
20. Quarterly documentation audit process

---

## Success Metrics

### Quantitative
- **Coverage**: 200-300 high-value docs indexed
- **Navigation**: 90% queries resolved in ≤3 hops
- **Link Stability**: <5% broken anchor links
- **Token Efficiency**: Router <50KB
- **Maintenance**: <1 hour/week manual work

### Qualitative
- Agent task success rate ≥90%
- Easy to find relevant docs (agent feedback)
- Code anchors useful (used in 50%+ of tasks)

---

## Design Trade-Offs

### Single Router vs. Multiple Sub-Routers
**Choice**: Single `AGENT_ROUTER.md`  
**Rationale**: Simpler for agents, easier to maintain, better searchability  
**Fallback**: Split if >50KB

### @anchor Tags vs. Line Numbers
**Choice**: `@anchor` JSDoc tags  
**Rationale**: Stable across changes, semantic, IDE-friendly  
**Overhead**: Manual annotation of high-value code

### Centralized JSON vs. Distributed Frontmatter
**Choice**: Both (`AGENT_METADATA.json` + frontmatter)  
**Rationale**: JSON for queries, frontmatter for self-documenting

### Automation vs. Manual Curation
**Choice**: Automated extraction + manual quality gates  
**Rationale**: Balance efficiency with quality control

---

## Risk Mitigation

### Risk: Metadata Extraction Inaccuracies
- Mitigation: Manual review of first batch, spot-check audits, agent feedback
- Fallback: Manual curation for critical docs

### Risk: Router File Size Exceeds Limits
- Mitigation: Monitor size, create quick lookup, split if >50KB
- Fallback: Domain-specific sub-routers

### Risk: @anchor Tag Adoption Lag
- Mitigation: Document convention, PR checklist, bot suggestions
- Fallback: Auto-generate from names

### Risk: Stale Documentation
- Mitigation: Track timestamps, flag old docs, quarterly audits
- Fallback: Staleness warnings in router

---

## Future Enhancements

1. **Semantic Search**: Embed docs, vector search for concept-based navigation
2. **Usage Analytics**: Track agent access patterns, optimize high-traffic paths
3. **Interactive Updates**: Agents suggest router improvements
4. **Multi-Language**: Extend to Python, Go, Rust docstrings

---

## Deliverables

**For Tahoma AI Project**:
- ✅ `docs/AGENT_ROUTER.md` - Master routing document
- ✅ `docs/AGENT_METADATA.json` - Machine-readable index
- ✅ `docs/AGENT_QUICK_LOOKUP.md` - Token-efficient reference
- ✅ `scripts/doc-router/` - Automation scripts
- ✅ `.github/workflows/update-docs-router.yml` - CI/CD automation
- ✅ 50+ code files with `@anchor` tags

**For documentation-router Skill**:
- ✅ `~/.claude/skills/documentation-router.md` - Reusable skill
- ✅ Reference templates for common patterns
- ✅ Examples from Tahoma AI implementation

---

## Next Steps

1. **Implement Skill File**: Create `documentation-router.md` in `~/.claude/skills/`
2. **Execute Phase 1**: Run discovery on Tahoma AI codebase
3. **Build Foundation**: Implement metadata extraction
4. **Generate Router**: Create initial AGENT_ROUTER.md
5. **Iterate**: Refine based on real agent usage

**Estimated Timeline**: 3-4 weeks for full implementation

---

**Last Updated**: 2025-12-03  
**Status**: Ready for Skill Creation  
**Next Action**: Create `documentation-router.md` skill file
