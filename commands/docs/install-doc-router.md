# /install-doc-router

Install the automated documentation routing system for Claude Code agents in the current repository.

## Quick Start

```bash
/install-doc-router
```

Or with custom reference path:
```bash
/install-doc-router --source /path/to/reference/implementation
```

## What This Installs

### 🎯 Core System
- **Documentation Router** - 3-dimensional navigation (task/domain/service)
- **Metadata Extraction** - From @fileoverview tags and markdown frontmatter
- **Auto-Generation** - GitHub Actions updates router on every doc/code change
- **@anchor Convention** - Stable code links without brittle line numbers

### 📦 Files Installed

```
your-repository/
├── scripts/doc-router/
│   ├── extract-metadata.ts      # Metadata extraction engine
│   ├── build-router.ts          # Router generation logic
│   ├── validate-anchors.ts      # Anchor validation
│   ├── types.ts                 # TypeScript definitions
│   ├── config.json              # Repository-specific config
│   ├── package.json             # Dependencies
│   ├── tsconfig.json            # TypeScript config
│   └── update-router.sh         # Orchestration script
├── .github/workflows/
│   └── update-docs-router.yml   # GitHub Actions automation
└── docs/
    ├── AGENT_ROUTER.md          # Generated: Master navigation
    ├── AGENT_METADATA.json      # Generated: Machine-readable index
    └── AGENT_QUICK_LOOKUP.md    # Generated: Top 30 quick reference
```

## Installation Process

The command will:

1. ✅ **Validate environment** - Check Node.js, git, prerequisites
2. 📁 **Detect structure** - Analyze monorepo vs single-service, count docs
3. 📦 **Copy infrastructure** - Install scripts from reference implementation
4. ⚙️ **Generate config** - Create repository-specific configuration
5. 📚 **Install deps** - npm install automation dependencies
6. 🔄 **Setup GitHub Actions** - Auto-update on doc/code changes
7. 🏗️ **Generate router** - Create initial AGENT_ROUTER.md

## Prerequisites

- Node.js 20+ installed
- Git repository initialized (`git init`)
- Some existing documentation (markdown or @fileoverview tags)
- Reference implementation at `~/Projects/tahoma-ai` (or specify path)

## Configuration

After installation, customize `scripts/doc-router/config.json`:

```json
{
  "paths": {
    "docs": "docs/**/*.md",           // Where to find docs
    "code": ["src/**/*.ts"],          // TypeScript files to scan
    "apiSpecs": ["docs/api/*.yaml"]   // OpenAPI/Swagger specs
  },
  "taskMappings": {
    "authentication": ["auth", "jwt", "token"],
    "api": ["api", "endpoint", "rest"]
  },
  "services": ["service-name"]        // Your service names
}
```

## Post-Installation

1. **Review the generated router**:
   ```bash
   cat docs/AGENT_ROUTER.md
   ```

2. **Customize configuration**:
   ```bash
   $EDITOR scripts/doc-router/config.json
   ```

3. **Add @anchor tags to key code files**:
   ```typescript
   /**
    * @fileoverview User authentication service
    * @anchor UserAuthService
    */
   export class UserAuthService { }
   ```

4. **Commit the changes**:
   ```bash
   git add .
   git commit -m "feat(docs): add documentation router for Claude Code agents"
   git push
   ```

5. **Verify GitHub Actions**:
   - Go to Actions tab in GitHub
   - Watch for "Update Documentation Router" workflow
   - Confirms auto-updates are working

## Usage Examples

### For Agents
Claude Code agents will automatically use `docs/AGENT_ROUTER.md` for navigation:

**Agent Task**: "Fix TypeScript errors"
→ Routes to "TypeScript Tasks" section
→ Finds TypeScript audit documentation in 2 hops

**Agent Task**: "Debug authentication flow"
→ Routes to "Security Domain" section
→ Finds auth implementation docs + code references in 1 hop

### Manual Updates
```bash
cd scripts/doc-router
./update-router.sh
```

## Troubleshooting

### "Reference implementation not found"
```bash
# Specify custom path to tahoma-ai (or your reference repo)
/install-doc-router --source /path/to/reference
```

### "No documents found"
- Ensure you have markdown files in `docs/` directory
- Or TypeScript files with `@fileoverview` JSDoc comments
- Adjust `config.json` paths to match your structure

### "Router is empty"
- Check `scripts/doc-router/config.json` paths match your repo
- Run with verbose logging: `cd scripts/doc-router && npm run extract-metadata`
- Verify files aren't excluded by `exclusions` pattern

## Performance

| Metric | Typical Result |
|--------|----------------|
| Installation time | ~30 seconds |
| Initial router generation | ~10-30 seconds |
| Router size | 15-50 KB (token-efficient) |
| Documents indexed | 100-300 (from 1000s) |
| Navigation speed | 1-3 hops to target doc |
| Time savings | 20-30x faster discovery |

## Architecture

```
User/Agent Query
      ↓
AGENT_ROUTER.md (3-dimensional navigation)
      ↓
   ┌──┴──┐
Task │Domain│ Service
   └──┬──┘
      ↓
Relevant Documentation (1-3 hops)
```

## Reference

- **Design Doc**: `~/.claude/plans/abstract-cooking-pudding.md`
- **Reference Implementation**: `~/Projects/tahoma-ai`
- **Test Results**: 4/4 scenarios passed, 100% success rate

## Support

For issues or questions:
1. Check the generated `docs/AGENT_ROUTER.md` quality
2. Review `scripts/doc-router/config.json` configuration
3. Consult reference implementation at tahoma-ai repository
4. See design doc for architectural decisions

---

**Status**: Production-ready
**Last Updated**: 2025-12-03
**Tested**: tahoma-ai monorepo (2,626 docs → 300 high-value)
