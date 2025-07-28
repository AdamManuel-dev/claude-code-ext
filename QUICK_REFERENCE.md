# Review Orchestrator - Quick Reference

## 🚀 Two Ways to Use

| Method | Setup Required | Usage | Best For |
|--------|----------------|-------|----------|
| **Slash Command** | ❌ None | `/review [git-command]` | Instant use in Claude/Cursor |
| **Global Command** | ✅ Installation | `review [git-command]` | System-wide development tool |

## ⚡ Instant Use (Slash Command)

No setup required - use immediately:

```
/review add               # Basic validation before git add
/review commit            # Quality check before git commit
/review push              # Full validation before git push
/review merge             # Complete review before merge to main
```

**Features:**
- 7 specialized AI reviewers in 3 staged phases
- Early failure detection saves time
- **Unified dashboard** showing all reviewers simultaneously
- Automatic code fixes applied
- Real-time progress in chat
- No installation needed

## 🔧 Global Installation

One-time setup for system-wide access:

```bash
./install-review-orchestrator.sh
```

**Then use anywhere:**
```bash
review add                 # Basic validation (before git add)
review commit              # Quality check (before git commit)
review push                # Full validation (before git push)
review merge               # Complete review (before merge)

# Short aliases
ro add                     # Quick basic validation
review commit              # Quality check shortcut
```

**Additional Features:**
- Shell aliases and helpers
- Claude CLI integration
- Persistent configuration
- CI/CD integration support

## 🎯 What Both Methods Do

### 7 Specialized Reviewers
- 🔵 **Quality**: TypeScript, logic, patterns, code organization
- 🔴 **Security**: Vulnerabilities, auth, data protection  
- 🟢 **Readability**: Naming, structure, documentation
- 🟣 **Design**: UI/UX, accessibility (with visual testing)
- 🟡 **Basic**: Anti-patterns, common mistakes
- 🧪 **Testing**: Test effectiveness, coverage, mock analysis
- 🔵 **E2E**: Integration testing, user flows (Stage 4 - merge only)

### Git-Workflow Integration
1. **`add`**: Stage 1 only → `git add .` (if passed)
2. **`commit`**: Stages 1-2 → `git commit -m "message"` (if passed)
3. **`push`**: Stages 1-3 → `git push origin branch` (if passed)
4. **`merge`**: All stages → Manual merge approval (if passed)
5. **Each Stage**: Analyze → Fix → Validate → Report
6. **Auto-Execute**: Runs git command automatically when stages pass

## 📊 Expected Results

### Git-Command Workflow Examples

#### `/review add` - Basic Validation
```
╔══════════════════════════════════════════════════════════════════════════╗
║                     🎯 Review Orchestrator - Add Mode                   ║
╚══════════════════════════════════════════════════════════════════════════╝

🟡 Stage 1: Basic Review                                            [COMPLETE]
├─ Issues Found: 5 critical errors                                       ✅
├─ Fixes Applied: 5/5 automated                                          ✅
└─ Status: PASSED                                                        ✅

✅ Stage 1 passed! Executing: git add .
🎯 Files staged successfully - ready for commit
```

#### `/review push` - Full Validation  
```
╔══════════════════════════════════════════════════════════════════════════╗
║                     🎯 Review Orchestrator - Push Mode                  ║
╚══════════════════════════════════════════════════════════════════════════╝

📊 PROGRESS: Stages 1-3 (100%) | Files Modified: 8 | Issues Fixed: 22

🔄 REVIEWER STATUS (All Complete)
├─ ✅ Basic (5/5) | ✅ Readability (8/8) | ✅ Quality (6/6) | ✅ Security (2/2)
└─ ✅ Design (3/3) | ✅ Testing (2/2)

✅ All stages passed! Executing: git push origin feature-branch
🚀 Code pushed successfully - ready for PR/merge
```

### Traditional Summary View
```
Review & Fix Summary:
────────────────────
basic: Fixed 15 issues, Remaining 0
readability: Fixed 12 issues, Remaining 0
quality: Fixed 7 issues, Remaining 1
security: Fixed 3 critical, Remaining 0  
design: Fixed 5 UI issues, Remaining 0
testing: Fixed 8 test issues, Added 5 test files
e2e: Fixed 4 integration issues, Remaining 0
```

## 🤔 Which Method to Choose?

### Use Slash Command (`/review`) If:
- ✅ You want instant access without setup
- ✅ You're working in Claude/Cursor regularly
- ✅ You prefer conversational interaction
- ✅ You want to see real-time progress

### Use Global Installation If:
- ✅ You want a permanent development tool
- ✅ You need CI/CD integration
- ✅ You work across multiple IDEs/terminals
- ✅ You want shell aliases and helpers
- ✅ Your team needs consistent tooling

## 🔄 Can Use Both!

The slash command and global installation work independently:
- Use `/review` for quick ad-hoc reviews
- Use `review` for automated workflows
- Both provide the same comprehensive improvement cycle

---

**Start improving your code in seconds!** 🎯 