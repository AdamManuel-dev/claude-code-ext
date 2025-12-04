# Documentation Router - Complete Installation Guide

Comprehensive guide for installing the automated documentation router in any repository.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Installation Methods](#installation-methods)
3. [Post-Installation Configuration](#post-installation-configuration)
4. [Testing & Validation](#testing--validation)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)

---

## Overview

The Documentation Router is a self-maintaining navigation system that routes Claude Code agents to relevant documentation in 1-3 hops instead of searching through thousands of files.

**Key Benefits:**
- 20-30x faster information discovery
- 3-dimensional routing (task/domain/service)
- Zero maintenance (GitHub Actions auto-updates)
- Token-efficient (<50KB router)

**Reference Implementation:** tahoma-ai monorepo
- 2,626 total docs → 300 high-value indexed
- 26.59 KB router size
- 4/4 test scenarios passed (100% success rate)

---

## Installation Methods

### Method 1: Claude Code Command (Recommended)

**Use this in any repository where you want the router:**

```bash
/install-doc-router
```

Claude Code will:
1. Validate environment (Node.js, git, prerequisites)
2. Copy infrastructure from reference implementation
3. Generate repository-specific configuration
4. Install dependencies
5. Set up GitHub Actions
6. Generate initial router
7. Update repository CLAUDE.md (if exists)

**Installation Time**: ~30-60 seconds

---

### Method 2: Manual Script Execution

If you prefer to run the installation script directly:

```bash
# From any repository
~/.claude/tools/install-doc-router.sh

# With custom reference path
~/.claude/tools/install-doc-router.sh /path/to/reference-repo
```

---

### Method 3: Manual Installation (Advanced)

If you want full control:

1. **Copy scripts**:
   ```bash
   cp -r ~/Projects/tahoma-ai/scripts/doc-router scripts/
   ```

2. **Copy GitHub Actions**:
   ```bash
   mkdir -p .github/workflows
   cp ~/Projects/tahoma-ai/.github/workflows/update-docs-router.yml .github/workflows/
   ```

3. **Customize config**:
   ```bash
   vim scripts/doc-router/config.json
   # Adjust paths, services, task mappings for your repo
   ```

4. **Install dependencies**:
   ```bash
   cd scripts/doc-router && npm install
   ```

5. **Generate router**:
   ```bash
   ./update-router.sh
   ```

---

## Post-Installation Configuration

### Step 1: Review Generated Router

Check the quality of the initial router:

```bash
cat docs/AGENT_ROUTER.md | less
```

**Look for:**
- ✅ Are the right documents indexed? (READMEs, ADRs, guides)
- ✅ Are task mappings relevant? (authentication, api, database, etc.)
- ✅ Are services detected correctly?

### Step 2: Customize Configuration

Edit `scripts/doc-router/config.json`:

```bash
vim scripts/doc-router/config.json
```

**Key sections to customize:**

#### A. Paths (Required)
```json
{
  "paths": {
    "docs": "docs/**/*.md",              // Adjust for your docs location
    "code": [
      "src/**/*.ts",                     // Your source code location
      "packages/*/src/**/*.ts"           // For monorepos
    ],
    "serviceReadmes": [
      "README.md",                       // Main README
      "packages/service-a/README.md"     // Service READMEs for monorepos
    ],
    "apiSpecs": [
      "docs/api/openapi.yaml",           // OpenAPI specs
      "src/api/swagger.json"             // Swagger files
    ]
  }
}
```

#### B. Services (For Monorepos)
```json
{
  "services": [
    "service-a",
    "service-b",
    "packages/shared-lib"
  ]
}
```

#### C. Task Mappings (Optional)
Add project-specific tasks:
```json
{
  "taskMappings": {
    "deployment": ["deploy", "docker", "kubernetes", "ci-cd"],
    "graphql": ["graphql", "apollo", "schema", "resolver"],
    "your-custom-task": ["keyword1", "keyword2"]
  }
}
```

#### D. Exclusions (Recommended)
Exclude irrelevant directories:
```json
{
  "exclusions": [
    "**/node_modules/**",
    "**/dist/**",
    "**/build/**",
    "docs/archive/**",           // Old docs
    "docs/drafts/**",           // Work in progress
    "**/*.test.ts",             // Test files
    "**/*.spec.ts"
  ]
}
```

### Step 3: Regenerate Router

After customizing config:

```bash
cd scripts/doc-router
./update-router.sh
```

Check the updated router:
```bash
cat ../../docs/AGENT_ROUTER.md
```

---

## Testing & Validation

### Test 1: Verify Metadata Extraction

```bash
cd scripts/doc-router
npm run extract-metadata
```

**Expected output:**
```
🔍 Extracting metadata from documentation...
✅ Extracted 800 documents, selected top 300
   - Markdown docs: 150
   - Code references: 145
   - API specs: 5

📝 Metadata saved to: /path/to/repo/docs/AGENT_METADATA.json

🎯 Top 10 documents by score:
   1. [1000] Main README (service-readme)
   2. [1000] ADR-001: Architecture Decisions (adr)
   ...
```

### Test 2: Verify Router Generation

```bash
npm run build-router
```

**Expected output:**
```
📚 Building documentation router...
✅ Router generated successfully!
   📄 AGENT_ROUTER.md: /path/to/repo/docs/AGENT_ROUTER.md
   📊 Task mappings: 8 tasks

📏 File sizes:
   AGENT_ROUTER.md: 22.45 KB
```

### Test 3: Verify Anchor Validation

```bash
npm run validate-anchors
```

**Expected output (before adding anchors):**
```
🔍 Validating @anchor tags...

📊 Validation Summary:
   Total anchors: 0
   Duplicates: 0
   Naming violations: 0

✅ All @anchor tags are valid!
```

### Test 4: Test Complete Pipeline

```bash
./update-router.sh
```

**Expected**: All 3 steps complete successfully.

---

## Customization

### Adding @anchor Tags to Code

Identify your 10-20 most frequently referenced code files and add anchors:

```typescript
/**
 * @fileoverview Main application entry point
 * @lastmodified 2025-12-03T00:00:00Z
 * @anchor App
 */
export class App {
  /**
   * Initialize application
   * @anchor initialize
   */
  async initialize(): Promise<void> {
    // Implementation
  }
}
```

**Finding frequently referenced files:**
```bash
# Search for file references in docs
rg -o --no-filename 'src/[^)]+\.ts' docs/ | sort | uniq -c | sort -rn | head -20
```

### Customizing Task Mappings

Add project-specific tasks to `config.json`:

```json
{
  "taskMappings": {
    "your-feature": ["feature-keyword", "related-tech"],
    "performance": ["performance", "optimization", "cache", "lazy-load"]
  }
}
```

### Adjusting Document Scoring

Fine-tune which docs get prioritized:

```json
{
  "scoring": {
    "mandatory": {
      "serviceReadme": 1000,      // Always include
      "adr": 1000,
      "apiSpec": 1000,
      "diataxis": 1000
    },
    "fileoverview": 10,            // Code with @fileoverview
    "recentActivity": 5,           // Modified <90 days
    "threshold": 200,              // Minimum score to include
    "maxDocuments": 300,           // Max documents to index
    "recentActivityDays": 90       // "Recent" threshold
  }
}
```

---

## Troubleshooting

### Problem: "No such file or directory: docs/AGENT_METADATA.json"

**Cause**: Output directory doesn't exist
**Solution**:
```bash
mkdir -p docs
cd scripts/doc-router && npm run extract-metadata
```

### Problem: "Extracted 0 documents"

**Cause**: Paths in config.json don't match your repository structure
**Solution**:
```bash
# Find your docs
find . -name "*.md" -type f | grep -v node_modules | head -20

# Find your TypeScript files with @fileoverview
find . -name "*.ts" -type f | xargs grep -l "@fileoverview" | head -20

# Update config.json paths accordingly
vim scripts/doc-router/config.json
```

### Problem: "Router is too large (>50KB)"

**Cause**: Too many documents indexed
**Solution**:
```json
{
  "scoring": {
    "maxDocuments": 200,          // Reduce from 300
    "threshold": 250               // Increase threshold
  }
}
```

### Problem: "Duplicate @anchor errors"

**Cause**: Same anchor name used in multiple files
**Solution**:
```bash
# Find duplicates
npm run validate-anchors

# Rename anchors to be unique (add file/module prefix)
@anchor UserServiceAuthenticateUser  # Instead of just @anchor authenticateUser
```

### Problem: "GitHub Actions workflow not triggering"

**Cause**: Workflow file not committed or permissions issue
**Solution**:
```bash
# Ensure workflow is committed
git add .github/workflows/update-docs-router.yml
git commit -m "ci: add doc router workflow"
git push

# Check GitHub Actions permissions (repo Settings → Actions)
```

---

## Advanced Usage

### Running Extraction with Filters

```bash
# Extract only recent docs (<30 days)
RECENT_DAYS=30 npm run extract-metadata

# Extract with debug logging
DEBUG=1 npm run extract-metadata
```

### Custom Router Templates

Modify `build-router.ts` to change router format:

```typescript
// Add custom sections
function buildRouter(docs: DocumentMetadata[]): string {
  return [
    buildHeader(docs),
    buildQuickNavigation(),
    buildTaskBasedRouting(docs),
    buildDomainBasedRouting(docs),
    buildServiceBasedRouting(docs),
    buildCustomSection(docs),        // Your custom section
  ].join('\n\n---\n\n');
}
```

### Integrating with Documentation Sites

The router can power documentation websites:

```javascript
// Import metadata in Docusaurus/Next.js
import metadata from './docs/AGENT_METADATA.json';

// Build dynamic navigation from metadata
const nav = metadata.documents.map(doc => ({
  label: doc.title,
  to: doc.path,
  keywords: doc.keywords
}));
```

---

## Maintenance

### Quarterly Audit (Recommended)

Every 3 months:

1. **Review indexed documents**:
   ```bash
   jq '.documents[] | {title, score, lastModified}' docs/AGENT_METADATA.json | less
   ```

2. **Check for stale docs**:
   ```bash
   # Find docs not modified in 6+ months
   jq '.documents[] | select(.lastModified < "2024-06-01") | .title' docs/AGENT_METADATA.json
   ```

3. **Update task mappings**:
   - Review which tasks agents request most
   - Add new task mappings to config.json
   - Regenerate router

4. **Add new @anchor tags**:
   - Identify frequently referenced code
   - Add anchors to those files
   - Re-run validation

### Manual Updates

If you need to regenerate the router outside of GitHub Actions:

```bash
cd scripts/doc-router
./update-router.sh
```

Then commit the changes:
```bash
git add docs/AGENT_*.md docs/AGENT_METADATA.json
git commit -m "docs: update router"
git push
```

---

## Migration Guide

### From Manual Documentation

**Before**: Docs scattered across repo, agents search manually
**After**: Centralized router with intelligent navigation

**Steps**:
1. Install router: `/install-doc-router`
2. Keep existing docs in place (router indexes them)
3. Add @anchor tags to frequently-referenced code
4. Update internal doc links to use @anchor format
5. Archive old, outdated documentation

### From Other Doc Systems

**From Docusaurus/GitBook/etc:**
- Keep your existing site for human users
- Add router for AI agents
- Both can coexist (router is lightweight overlay)

**From TypeDoc/JSDoc:**
- Router complements existing API docs
- Extracts metadata from @fileoverview
- Provides task-based navigation TypeDoc doesn't offer

---

## Best Practices

### 1. Documentation Standards

Ensure consistency for best extraction:

```markdown
---
title: Authentication Guide
description: Guide to implementing authentication
keywords: [auth, jwt, clerk]
---

# Authentication Guide

[Content]
```

### 2. @fileoverview Format

Use consistent @fileoverview headers:

```typescript
/**
 * @fileoverview Brief description of what this file does
 * @lastmodified 2025-12-03T00:00:00Z
 * @anchor PrimaryExportName
 *
 * Features: Key capabilities
 * Main APIs: primaryFunction(), secondaryFunction()
 * Constraints: Requirements and limitations
 */
```

### 3. Directory Structure

Organize docs for better domain/service inference:

```
docs/
├── architecture/        # ADRs, system design
├── api/                # API documentation
├── guides/             # How-to guides
├── tutorials/          # Learning-oriented
├── reference/          # API reference
└── implementation/     # Implementation details
    ├── auth/
    ├── database/
    └── workflows/
```

---

## Examples by Project Type

### Single-Service Application

```json
{
  "paths": {
    "docs": "docs/**/*.md",
    "code": ["src/**/*.ts"],
    "apiSpecs": ["docs/api/openapi.yaml"]
  },
  "services": ["main"],
  "taskMappings": {
    "api": ["api", "endpoint", "rest"],
    "database": ["prisma", "postgres", "schema"]
  }
}
```

### Monorepo (Multiple Services)

```json
{
  "paths": {
    "docs": "docs/**/*.md",
    "code": [
      "services/*/src/**/*.ts",
      "packages/*/src/**/*.ts"
    ],
    "serviceReadmes": [
      "services/api/README.md",
      "services/web/README.md",
      "services/worker/README.md"
    ]
  },
  "services": ["api", "web", "worker"],
  "taskMappings": {
    "microservices": ["service", "grpc", "message-queue"],
    "graphql": ["graphql", "schema", "resolver"]
  }
}
```

### Library/Package

```json
{
  "paths": {
    "docs": "docs/**/*.md",
    "code": ["src/**/*.ts"],
    "apiSpecs": []
  },
  "services": ["library-name"],
  "taskMappings": {
    "api-usage": ["api", "usage", "example"],
    "types": ["typescript", "types", "interface"]
  }
}
```

---

## CI/CD Integration

### GitHub Actions

The workflow automatically runs when:
- Docs change (`docs/**/*.md`)
- Code changes (`**/*.ts`)
- READMEs update (`**/README.md`)
- Manual trigger (workflow_dispatch)

**Workflow file**: `.github/workflows/update-docs-router.yml`

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
      - uses: actions/setup-node@v4
      - run: cd scripts/doc-router && npm ci && ./update-router.sh
      - run: git add docs/AGENT_* && git commit -m "docs: update router [skip ci]" && git push
```

### GitLab CI

Adapt for GitLab:

```yaml
# .gitlab-ci.yml
update-router:
  stage: docs
  only:
    changes:
      - docs/**/*.md
      - "**/*.ts"
      - "**/README.md"
  script:
    - cd scripts/doc-router
    - npm ci
    - ./update-router.sh
    - git add docs/AGENT_*
    - git commit -m "docs: update router [skip ci]" || true
    - git push origin HEAD:$CI_COMMIT_REF_NAME
```

---

## Metrics & Analytics

### Router Health Metrics

Check router quality after installation:

```bash
# Total documents indexed
jq '.totalDocuments' docs/AGENT_METADATA.json

# Document type distribution
jq '.documents | group_by(.type) | map({type: .[0].type, count: length})' docs/AGENT_METADATA.json

# Top domains
jq '.documents[].domain[]' docs/AGENT_METADATA.json | sort | uniq -c | sort -rn | head -10

# Average complexity
jq '.documents | map(select(.complexity == "high")) | length' docs/AGENT_METADATA.json

# Recent vs stale docs
jq '.documents | map(select(.lastModified > "2024-09-01")) | length' docs/AGENT_METADATA.json
```

### Usage Analytics

Track agent navigation patterns:

```bash
# Add logging to track which docs agents access
# (Implement in future enhancement)
```

---

## Next Steps After Installation

1. **Test the router** - Ask Claude Code to navigate it for different tasks
2. **Add @anchor tags** - Annotate your 10-20 most important code files
3. **Customize task mappings** - Add project-specific tasks to config.json
4. **Commit and push** - Trigger first GitHub Actions auto-update
5. **Monitor usage** - See which docs agents reference most
6. **Iterate** - Refine configuration based on real usage

---

## Reference Documentation

- **Quick Start**: `~/.claude/commands/docs/doc-router-quickstart.md`
- **Command Docs**: `~/.claude/commands/docs/install-doc-router.md`
- **Design Doc**: `~/.claude/plans/abstract-cooking-pudding.md`
- **Implementation**: `scripts/doc-router/README.md`
- **Installation Script**: `~/.claude/tools/install-doc-router.sh`

---

**Status**: Production-ready
**Last Updated**: 2025-12-03
**Reference**: tahoma-ai monorepo
**Success Rate**: 100% (4/4 test scenarios)
