# Documentation Router System - Implementation Plan

**Created**: 2025-12-03
**Goal**: Build an intelligent documentation routing system for Claude Code agents
**Approach**: Fully automated, agent-optimized navigation with stable code links

---

## Overview

Create a **master documentation router** (`AGENT_ROUTER.md`) that enables Claude Code agents to efficiently navigate 200-300 high-value docs in the Tahoma AI monorepo without scanning thousands of files.

### Key Features
- **3-dimensional routing**: Task-based, domain-based, and service-based navigation
- **Stable code links**: JSDoc `@anchor` tags instead of brittle line numbers
- **Zero maintenance**: Fully automated extraction and CI/CD updates
- **Token-efficient**: <50KB router file optimized for agent consumption

---

## Architecture

### File Structure
```
tahoma-ai/
├── docs/
│   ├── AGENT_ROUTER.md              # Master routing document (generated)
│   ├── AGENT_METADATA.json          # Machine-readable index (generated)
│   └── AGENT_QUICK_LOOKUP.md        # Token-efficient reference (generated)
│
├── scripts/
│   └── doc-router/
│       ├── package.json             # Dependencies (gray-matter, glob, etc.)
│       ├── tsconfig.json
│       ├── config.json              # Router configuration (paths, exclusions)
│       ├── extract-metadata.ts      # Extract from @fileoverview, frontmatter, git
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
| Fix auth middleware | [@ClerkAuthMiddleware](orchestration-service/src/middleware/auth.middleware.ts@ClerkAuthMiddleware) | Code | Medium |

**Related ADRs**: [ADR-006: Clerk Authentication](docs/architecture/decisions/ADR-006-clerk-authentication.md)

---

## Domain-Based Routing

### Security Domain
- [Security Model](docs/architecture/security-model.md)
- [@ClerkAuthMiddleware](orchestration-service/src/middleware/auth.middleware.ts@ClerkAuthMiddleware)

---

## Service-Based Routing

### orchestration-service
**Purpose**: Cloud workflow execution engine
**Quick Links**:
- [README](orchestration-service/README.md)
- [API Spec](orchestration-service/docs/api/openapi.yaml)
```

---

## Implementation Steps

### Phase 1: Foundation (Week 1)

**1. Set up automation infrastructure**
- Create `scripts/doc-router/` directory with package.json
- Install dependencies: `gray-matter`, `glob`, `js-yaml`, `simple-git`
- Create `config.json` with paths and exclusion patterns

**2. Implement metadata extraction** (`extract-metadata.ts`)
- Parse markdown frontmatter and `@fileoverview` JSDoc headers
- Extract title, domain, keywords, complexity from docs
- Get last modified timestamps from git
- Score documents for "high-value" selection:
  - Mandatory: Service READMEs, ADRs, OpenAPI specs, Diataxis docs
  - Scored: Files with `@fileoverview`, recent activity (<90 days)
  - Excluded: Archive folder, session logs, TODO files

**3. Validate on sample documents**
- Test extraction on 30 representative files
- Tune scoring algorithm to hit ~200-300 documents
- Verify metadata quality

**Critical Files:**
- `scripts/doc-router/extract-metadata.ts` - Core extraction logic
- `scripts/doc-router/config.json` - Configuration

---

### Phase 2: Router Generation (Week 1-2)

**4. Implement router builder** (`build-router.ts`)
- Group documents by task, domain, and service
- Generate markdown tables with consistent formatting
- Create task mappings (e.g., "fix-typescript-errors" → relevant docs)
- Output `AGENT_ROUTER.md`, `AGENT_METADATA.json`, `AGENT_QUICK_LOOKUP.md`

**5. Generate initial router**
- Run extraction and generation scripts
- Manual review for quality and completeness
- Adjust groupings and task mappings

**Critical Files:**
- `scripts/doc-router/build-router.ts` - Router generation engine
- `docs/AGENT_ROUTER.md` - Generated master router (output)
- `docs/AGENT_METADATA.json` - Machine-readable index (output)
- `docs/AGENT_QUICK_LOOKUP.md` - Token-efficient reference (output)

---

### Phase 3: Code Anchors (Week 2)

**6. Define @anchor convention**
- Add to project standards in `CLAUDE.md`
- Naming rules:
  - Classes/Interfaces: `@anchor PascalCase` (e.g., `@anchor WorkflowExecutor`)
  - Functions/Methods: `@anchor camelCase` (e.g., `@anchor executeWorkflow`)
  - Types/Enums: `@anchor PascalCase` (e.g., `@anchor ExecutionContext`)

**7. Add anchors to high-value code**
- Identify 50 most-referenced code files from router
- Add `@anchor` tags to file headers and key exports
- Example:
  ```typescript
  /**
   * @fileoverview Workflow executor for orchestrating complete workflow execution
   * @lastmodified 2025-11-30T00:00:00Z
   * @anchor WorkflowExecutor
   */
  export class WorkflowExecutor {
    // ...
  }
  ```

**8. Implement anchor validation** (`validate-anchors.ts`)
- Check for duplicate anchors across codebase
- Validate naming conventions (PascalCase vs camelCase)
- Verify references from docs point to existing anchors
- Run validation and fix any issues

**Critical Files:**
- `scripts/doc-router/validate-anchors.ts` - Anchor validation
- 50+ TypeScript files in high-traffic areas (orchestration-service, packages, etc.)

---

### Phase 4: Automation (Week 2-3)

**9. Create orchestration script** (`update-router.sh`)
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

**10. Set up GitHub Actions** (`update-docs-router.yml`)
- Trigger on: doc changes (`docs/**/*.md`), code changes (`**/*.ts`), README updates
- Steps: checkout, install deps, run update script, commit if changed
- Use `[skip ci]` in commit message to prevent loops

**11. Test automation end-to-end**
- Make a test doc change, verify workflow runs
- Check generated files are committed automatically
- Monitor for errors or broken links

**Critical Files:**
- `scripts/doc-router/update-router.sh` - Orchestration script
- `.github/workflows/update-docs-router.yml` - CI/CD automation

---

### Phase 5: Refinement (Week 3-4)

**12. Optimize for token efficiency**
- Measure router file size (<50KB target)
- Create abbreviated version in `AGENT_QUICK_LOOKUP.md`
- Add semantic summaries for complex domains

**13. Gather usage feedback**
- Use router in 10+ agent tasks (fix types, debug workflows, etc.)
- Track navigation efficiency (hops to find relevant doc)
- Identify missing high-value documents

**14. Iterate on design**
- Add newly discovered important docs to inclusion list
- Refine task mappings based on real usage
- Improve domain groupings

**15. Document the system**
- Add usage instructions for agents to `docs/AGENT_ROUTER.md` header
- Update `CLAUDE.md` with router best practices
- Create quarterly audit process for documentation health

---

## Metadata Schema

### DocumentMetadata (TypeScript)
```typescript
interface DocumentMetadata {
  id: string;                    // Unique identifier (kebab-case)
  path: string;                  // Relative path from repo root
  title: string;                 // Document title
  type: 'adr' | 'api-spec' | 'implementation' | 'tutorial' |
        'how-to' | 'reference' | 'explanation' | 'service-readme' | 'code-reference';
  domain: string[];              // Technical domains (auth, workflow, etc.)
  services: string[];            // Related services (orchestration-service, WebAI, etc.)
  keywords: string[];            // Search keywords
  complexity: 'low' | 'medium' | 'high';
  lastModified: string;          // ISO 8601 timestamp
  routerAnchor: string;          // Internal router link (e.g., "#adr-006")
  codeAnchor?: string;           // @anchor tag if code reference
  description: string;           // Brief description (1-2 sentences)
}
```

### AGENT_METADATA.json (Output)
```json
{
  "version": "1.0.0",
  "generated": "2025-12-03T20:00:00Z",
  "totalDocuments": 247,
  "documents": [ /* array of DocumentMetadata */ ],
  "taskMappings": {
    "fix-typescript-errors": ["ts-patterns", "execution-types"],
    "debug-workflows": ["workflow-exec-model", "code-workflow-exec"],
    "implement-auth": ["adr-006", "security-model", "auth-middleware"]
  }
}
```

---

## Code Linking Convention

### Format
```
SERVICE/src/path/to/file.ts@anchorName
```

### Examples
```markdown
See [@WorkflowExecutor](packages/playwright-executor/src/executor/workflow-executor.ts@WorkflowExecutor)
See [@errorHandlerMiddleware](orchestration-service/src/middleware/error-handler.middleware.ts@errorHandlerMiddleware)
```

### In Code
```typescript
/**
 * @fileoverview Workflow executor for orchestrating complete workflow execution
 * @anchor WorkflowExecutor
 * @lastmodified 2025-11-30T00:00:00Z
 */
export class WorkflowExecutor {
  /**
   * @anchor executeWorkflow
   */
  async executeWorkflow(page: IPage, workflow: Workflow): Promise<WorkflowResult> {
    // Implementation
  }
}
```

---

## High-Value Document Selection

### Mandatory Inclusion (83 docs)
- Service READMEs: 8 files (Dashboard, orchestration-service, TahomaAI, etc.)
- Architecture Decision Records: 23 files (docs/architecture/decisions/ADR-*.md)
- OpenAPI/Swagger specs: 4 files (orchestration-service, WebAI, CredentialsManager)
- Diataxis framework docs: ~25 files (tutorials, how-to, reference, explanation)
- Implementation guides: ~15 high-traffic files (auth, workflows, observability)
- Architecture overview: ~8 files (security model, data flow, etc.)

### Scored Inclusion (~120-150 docs)
- **Files with @fileoverview**: +10 points (indicates maintained code)
- **Recent git activity (<90 days)**: +5 points
- **Referenced in other docs**: +5 points per reference
- **OpenAPI endpoints**: +3 points
- **In docs/implementation/**: +3 points
- **Threshold**: Top 150 scores included

### Exclusions
- `docs/archive/**` - Historical documents (200+ files)
- `docs/progress/**` - Temporal session logs
- `**/*-TODO.md` - Work-in-progress
- Files <100 characters (stubs)

---

## Success Criteria

### Quantitative
- ✅ 200-300 high-value docs indexed in router
- ✅ 90% of queries resolved in ≤3 navigation hops
- ✅ Router file size <50KB (token-efficient)
- ✅ <5% broken anchor links (validation passing)
- ✅ <1 hour/week manual maintenance (full automation)
- ✅ 50+ code files with `@anchor` tags

### Qualitative
- ✅ Claude Code agents can find relevant docs for common tasks (auth, workflows, types)
- ✅ Navigation is faster than searching 2,626 files directly
- ✅ Code links work reliably without line number brittleness
- ✅ Router stays up-to-date automatically via CI/CD

---

## Design Trade-Offs

### Single Router vs. Multiple Sub-Routers
**Choice**: Single `AGENT_ROUTER.md`
**Rationale**: Simpler navigation, easier search, better for agents
**Fallback**: Split into domain-specific routers if exceeds 50KB

### @anchor Tags vs. Line Numbers
**Choice**: `@anchor` JSDoc tags
**Rationale**: Stable across refactoring, semantic, IDE-friendly
**Overhead**: Manual annotation of ~50 high-value code files (one-time)

### Fully Automated vs. Manual Curation
**Choice**: Fully automated extraction with scoring
**Rationale**: Zero maintenance burden, always up-to-date
**Risk**: May miss some important docs or include irrelevant ones
**Mitigation**: Use scoring algorithm + quarterly manual audits

---

## Critical Files to Modify/Create

### New Files (Scripts)
1. `scripts/doc-router/package.json` - Dependencies
2. `scripts/doc-router/tsconfig.json` - TypeScript config
3. `scripts/doc-router/config.json` - Router configuration
4. `scripts/doc-router/extract-metadata.ts` - Metadata extraction logic
5. `scripts/doc-router/build-router.ts` - Router generation logic
6. `scripts/doc-router/validate-anchors.ts` - Anchor validation logic
7. `scripts/doc-router/update-router.sh` - Orchestration script

### New Files (CI/CD)
8. `.github/workflows/update-docs-router.yml` - GitHub Actions workflow

### Generated Files (Outputs)
9. `docs/AGENT_ROUTER.md` - Master routing document (generated)
10. `docs/AGENT_METADATA.json` - Machine-readable index (generated)
11. `docs/AGENT_QUICK_LOOKUP.md` - Token-efficient reference (generated)

### Modified Files (Code Anchors)
12-61. ~50 TypeScript files with `@anchor` tags added to headers (e.g., orchestration-service/src/middleware/*.ts, packages/*/src/**/*.ts)

### Modified Files (Documentation)
62. `CLAUDE.md` - Add @anchor convention to documentation standards

---

## Estimated Timeline

- **Week 1**: Foundation + Router Generation (Steps 1-5)
- **Week 2**: Code Anchors + Validation (Steps 6-8)
- **Week 2-3**: Automation + Testing (Steps 9-11)
- **Week 3-4**: Refinement + Documentation (Steps 12-15)

**Total**: 3-4 weeks for full implementation

---

## Next Steps

1. **Implement foundation scripts** (extract-metadata.ts, build-router.ts)
2. **Generate initial router** and validate with 10 agent tasks
3. **Add @anchor tags** to top 50 code files
4. **Set up CI/CD automation** for zero-maintenance updates
5. **Iterate based on usage** feedback from Claude Code agents

---

**Status**: Ready for implementation
**Last Updated**: 2025-12-03
