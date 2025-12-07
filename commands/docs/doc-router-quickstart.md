# Documentation Router - Quick Start Guide

5-minute guide to understanding and using the documentation router in any repository.

## 🎯 What Is It?

An automated navigation system that routes Claude Code agents to relevant documentation in **1-3 hops** instead of searching through thousands of files.

**Without Router**: Agent searches 2,626 files for 10-15 minutes
**With Router**: Agent finds exact doc in 30 seconds (20-30x faster!)

## 🚀 Installation (2 commands)

```bash
# 1. Install the router in your current repository
/install-doc-router

# 2. That's it! The router is now active.
```

## 📖 How Agents Use It

When a Claude Code agent gets a task, it:

1. Reads `docs/AGENT_ROUTER.md`
2. Finds relevant section (task/domain/service)
3. Clicks link to target documentation
4. **Total time: 30 seconds** (vs 10-15 minutes searching)

## 🧭 Navigation Dimensions

### 1. Task-Based Routing
**Best for**: "Fix X", "Implement Y", "Debug Z"

Example tasks:
- Authentication Tasks
- TypeScript Tasks
- Workflow Tasks
- Database Tasks
- Testing Tasks
- API Tasks

### 2. Domain-Based Routing
**Best for**: "Understand X architecture", "Learn about Y"

Example domains:
- Security Domain
- Workflow Execution Domain
- API Layer Domain
- Data Layer Domain
- Frontend Domain

### 3. Service-Based Routing
**Best for**: "Work on Service X", "Modify Package Y"

Example services:
- orchestration-service
- Dashboard
- RagService
- CredentialsManager

## 💡 Real Examples

### Example 1: "Fix TypeScript errors"
```
Agent → AGENT_ROUTER.md → TypeScript Tasks → TypeScript Audit Doc
Result: Found 50+ files to fix with specific locations
Time: 30 seconds (2 hops)
```

### Example 2: "Debug workflow not triggering"
```
Agent → AGENT_ROUTER.md → Workflows Tasks → Master Index → Issue Doc → Fix Summary
Result: Found root cause (SessionPool not started) + fix implementation
Time: 2 minutes (4 hops)
```

## ⚙️ Customization (Optional)

After installation, customize for your project:

```bash
# 1. Edit configuration
vim scripts/doc-router/config.json

# 2. Add your services
"services": ["your-service-name", "another-service"]

# 3. Add custom task mappings
"taskMappings": {
  "your-task": ["keyword1", "keyword2"]
}

# 4. Regenerate router
cd scripts/doc-router && ./update-router.sh
```

## 🏷️ Adding @anchor Tags (Optional but Recommended)

Make code links more stable by adding @anchor tags to frequently-referenced code:

```typescript
/**
 * @fileoverview User authentication service
 * @anchor UserAuthService
 */
export class UserAuthService {
  /**
   * @anchor authenticateUser
   */
  async authenticateUser(creds: Credentials): Promise<User> {
    // Implementation
  }
}
```

Then link from docs:
```markdown
See the [@UserAuthService](src/services/UserAuthService.ts@UserAuthService) implementation.
```

## 🔄 Auto-Updates

The router automatically updates via GitHub Actions when you:
- Change any `docs/**/*.md` file
- Modify any `**/*.ts` file
- Update any `**/README.md`

No manual intervention needed! Just push and the router refreshes.

## 📊 Files Installed

```
your-repo/
├── scripts/doc-router/          # Automation scripts
│   ├── extract-metadata.ts      # Extracts doc metadata
│   ├── build-router.ts          # Generates navigation
│   ├── validate-anchors.ts      # Validates @anchor tags
│   ├── config.json              # Your configuration
│   └── update-router.sh         # Manual update script
├── .github/workflows/
│   └── update-docs-router.yml   # GitHub Actions automation
└── docs/
    ├── AGENT_ROUTER.md          # Master navigation (generated)
    ├── AGENT_METADATA.json      # Machine-readable index (generated)
    └── AGENT_QUICK_LOOKUP.md    # Top 30 docs (generated)
```

## ❓ FAQ

**Q: Will this work in my repo?**
A: Yes! Works with any repository that has markdown docs or TypeScript code with @fileoverview tags.

**Q: How many docs does it index?**
A: Automatically selects top 200-300 high-value docs based on scoring (READMEs, ADRs, API specs, recent files, etc.)

**Q: Does it require manual maintenance?**
A: No! GitHub Actions auto-updates on every push. Zero maintenance.

**Q: What if I don't have many docs yet?**
A: Router still works! It will index whatever you have (even just READMEs) and grow as you add more docs.

**Q: Can I customize the routing?**
A: Yes! Edit `scripts/doc-router/config.json` to add custom task mappings, domains, and services.

## 🎓 Learn More

- **Full Documentation**: `scripts/doc-router/README.md`
- **Design Document**: `~/.claude/plans/abstract-cooking-pudding.md`
- **Reference Implementation**: tahoma-ai repository
- **Command Documentation**: `~/.claude/commands/docs/install-doc-router.md`

---

**Installation Time**: ~30 seconds
**Setup Effort**: Minimal (auto-configured)
**Maintenance**: Zero (fully automated)
**Speedup**: 20-30x faster doc discovery
