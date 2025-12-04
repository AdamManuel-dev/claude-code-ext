# Install Documentation Router

Install the automated documentation routing system for Claude Code agents in the current repository.

## What This Does

Installs a fully automated, self-maintaining documentation navigation system that:
- Routes Claude Code agents to relevant docs in 1-3 hops instead of searching thousands of files
- Provides 3-dimensional routing: task-based, domain-based, and service-based
- Auto-updates via GitHub Actions whenever docs or code changes
- Achieves 20-30x speedup in information discovery

## Installation Process

1. **Copy infrastructure from tahoma-ai reference implementation**
2. **Adapt configuration to current repository structure**
3. **Set up GitHub Actions CI/CD**
4. **Add @anchor convention to CLAUDE.md (if exists)**
5. **Generate initial router**
6. **Provide usage instructions**

## What Gets Installed

### Scripts (`scripts/doc-router/`)
- `extract-metadata.ts` - Extracts metadata from @fileoverview tags and frontmatter
- `build-router.ts` - Generates 3D navigation structure
- `validate-anchors.ts` - Validates @anchor tag conventions
- `update-router.sh` - Orchestrates complete pipeline
- `config.json` - Repository-specific configuration
- `types.ts` - TypeScript type definitions
- `package.json` - Dependencies

### Automation (`.github/workflows/`)
- `update-docs-router.yml` - Auto-updates router on doc/code changes

### Generated Output (`docs/`)
- `AGENT_ROUTER.md` - Master routing document
- `AGENT_METADATA.json` - Machine-readable index
- `AGENT_QUICK_LOOKUP.md` - Token-efficient quick reference

## Prerequisites

- Node.js 20+ installed
- Git repository initialized
- Some existing documentation (markdown files or code with @fileoverview tags)

## Post-Installation

After installation completes:
1. Review `docs/AGENT_ROUTER.md` for quality
2. Customize `scripts/doc-router/config.json` for your project
3. Add @anchor tags to frequently-referenced code files
4. Commit changes: `git add . && git commit -m "feat(docs): add documentation router"`
5. Push to trigger first GitHub Actions auto-update

## Configuration Options

The installer will ask:
- Project type (monorepo, single service, library)
- Main service/package names
- Documentation structure (Diataxis, custom, none)
- Auto-commit generated files? (yes/no)

---

**Reference Implementation:** https://github.com/tahoma-ai/tahoma-ai
**Router Design:** See `~/.claude/plans/abstract-cooking-pudding.md`
