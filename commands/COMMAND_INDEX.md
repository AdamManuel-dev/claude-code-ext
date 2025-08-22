# Claude Code Command Index

> Quick reference for all available commands with usage patterns and examples

## 🎯 Quick Command Finder

### By Task

#### "I want to fix my code"
- **TypeScript errors**: `/fix-types`
- **Test failures**: `/fix-tests`
- **Linting issues**: `/fix-lint`
- **All quality issues**: `/vibe-code-workflow`

#### "I want to review my code"
- **Quick review**: `/review quick`
- **Comprehensive review**: `/review comprehensive`
- **Security review**: `/reviewer-security`
- **PR review**: `/ofri-pr-review`

#### "I want to improve documentation"
- **Generate docs**: `/generate-docs [path]`
- **Add file headers**: `/header-optimization`

#### "I want to manage tasks"
- **Work on TODOs**: `/work-on-todos`
- **Convert PRD to tasks**: `/generate-todo-from-prd`

#### "I want to debug"
- **Add debug logs**: `/debug-web`
- **Remove debug logs**: `/cleanup-web`

#### "I want to commit changes"
- **Smart commit**: `/git-commit`
- **Stash work**: `/git-stash [description]`

---

## 📋 Complete Command List

### Quality Assurance (7)
```bash
/fix-tests              # Fix failing tests
/fix-lint               # Fix ESLint errors
/fix-types              # Fix TypeScript errors
/reviewer-basic         # Basic code quality review
/reviewer-quality       # Architecture & patterns review
/reviewer-readability   # Code clarity review
/reviewer-security      # Security vulnerability scan
```

### Review & Analysis (10)
```bash
/review [mode] [depth] [target]  # Ultimate review system
/review-orchestrator              # Multi-reviewer coordinator
/ofri-pr-review                   # PR architecture review
/reviewer-design                  # UI/UX review
/reviewer-e2e                     # E2E testing review
/reviewer-testing                 # Test effectiveness review
# Plus basic, quality, readability, security reviewers above
```

### Documentation (2)
```bash
/generate-docs [path]    # Generate comprehensive documentation
/header-optimization     # Add/update file headers
```

### Git Workflow (2)
```bash
/git-commit              # Generate intelligent commits
/git-stash [description] # Advanced stash management
```

### Development Workflow (5)
```bash
/vibe-code-workflow      # Complete dev workflow
/work-on-todos           # Process TODO comments
/generate-todo-from-prd  # PRD to tasks
/debug-web               # Add debug logging
/cleanup-web             # Remove debug artifacts
```

---

## 🔄 Command Workflows

### Standard Development Flow
```bash
1. /generate-todo-from-prd "Feature description"
2. /work-on-todos
3. /vibe-code-workflow
4. /review standard
5. /git-commit
```

### Bug Fix Flow
```bash
1. /debug-web
2. [investigate issue]
3. /cleanup-web
4. /fix-types && /fix-tests
5. /git-commit "Fix: [issue description]"
```

### Code Quality Improvement
```bash
1. /review comprehensive deep
2. /fix-lint
3. /fix-types
4. /fix-tests
5. /review quick  # Verify improvements
```

### Pre-PR Checklist
```bash
1. /vibe-code-workflow
2. /review comprehensive
3. /generate-docs ./src
4. /git-commit
5. /ofri-pr-review
```

---

## ⚡ Command Shortcuts

### Most Used Commands
| Shortcut | Full Command | Purpose |
|----------|--------------|---------|
| `/vibe` | `/vibe-code-workflow` | Complete workflow |
| `/todos` | `/work-on-todos` | Process TODOs |
| `/commit` | `/git-commit` | Smart commit |
| `/review` | `/review standard` | Standard review |

### Power User Combinations
```bash
# Full quality suite
/fix-types && /fix-tests && /fix-lint

# Complete review suite
/review strategic deep

# Debug session
/debug-web && [work] && /cleanup-web

# Documentation suite
/generate-docs . && /header-optimization
```

---

## 🎯 Command Decision Tree

```
Need to write code?
├── New feature → /generate-todo-from-prd
├── Fix bugs → /debug-web → /cleanup-web
└── Implement TODOs → /work-on-todos

Need to review code?
├── Quick check → /review quick
├── Before commit → /review standard
├── Before PR → /review comprehensive
└── Security audit → /reviewer-security

Need to fix issues?
├── Type errors → /fix-types
├── Test failures → /fix-tests
├── Lint errors → /fix-lint
└── All issues → /vibe-code-workflow

Need to document?
├── Generate docs → /generate-docs
└── File headers → /header-optimization

Need version control?
├── Commit → /git-commit
└── Stash → /git-stash
```

---

## 📊 Command Statistics

### Execution Time Estimates
| Command | Quick | Standard | Deep |
|---------|-------|----------|------|
| `/review` | 5 min | 15 min | 60 min |
| `/vibe-code-workflow` | - | 10-20 min | - |
| `/fix-types` | 2-5 min | 5-10 min | - |
| `/fix-tests` | 5-10 min | 10-20 min | - |
| `/generate-docs` | 5 min | 15 min | 30 min |

### Command Complexity
| Simple | Moderate | Complex |
|--------|----------|---------|
| `/git-commit` | `/fix-lint` | `/review strategic` |
| `/cleanup-web` | `/fix-types` | `/vibe-code-workflow` |
| `/debug-web` | `/fix-tests` | `/review-orchestrator` |
| `/header-optimization` | `/work-on-todos` | `/generate-todo-from-prd` |

---

## 🔗 Command Dependencies

### Primary Dependencies
- `/vibe-code-workflow` → Requires: fix-types, fix-tests, fix-lint, git-commit
- `/review-orchestrator` → Requires: All reviewer-* commands
- `/work-on-todos` → May trigger: fix-types, fix-tests, fix-lint
- `/cleanup-web` → Paired with: debug-web

### Command Chains
```bash
# Quality chain
fix-types → fix-tests → fix-lint → git-commit

# Review chain
review → review-orchestrator → reviewer-* (parallel)

# Debug chain
debug-web → [investigation] → cleanup-web → fix-*

# Documentation chain
generate-docs → header-optimization
```

---

## 💡 Pro Tips

### Maximize Efficiency
1. Use `/vibe-code-workflow` for complete automation
2. Run `/review quick` frequently during development
3. Batch similar operations together
4. Use command chains with `&&` for workflows

### Best Practices
1. Always run `/review` before committing
2. Use `/work-on-todos` to prevent technical debt
3. Apply `/fix-types` after refactoring
4. Run `/reviewer-security` on authentication code

### Troubleshooting
1. If commands fail, check prerequisites
2. Run individual commands to isolate issues
3. Use `--debug` flag for verbose output
4. Check command dependencies are available

---

## 📚 Additional Resources

- **Full Documentation**: [README.md](./README.md)
- **Command Templates**: [/commands/templates/](./templates/)
- **Contributing Guide**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Change Log**: [CHANGELOG.md](./CHANGELOG.md)

---

*Quick Reference Card - Keep this handy for rapid command access*
*Last Updated: 2025-08-22*