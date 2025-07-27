# 1. Follow ESLint & Clean Code

- Enforce .eslintrc.json rules (Airbnb, Prettier, etc.).
- Write concise, readable, and maintainable code.
- Avoid anti-patterns (e.g., nested logic, magic strings).

## 2. TypeScript: Modern & Minimal

- Use modern TS/ES features (async/await, destructuring, arrow functions).
- Avoid unnecessary boilerplate; keep code short and clear.
- Type with interfaces/types; no any unless absolutely needed.

## 3. Documentation

- Add JSDoc for non-trivial functions/components.
- Do **not** include type annotations in JSDoc (TypeScript covers types).
- Keep inline comments minimal and meaningful.

## 4. Backend (AWS Lambda/Node.js)

- **Error Handling**: Use try/catch, custom errors, and structured logs (logger.error).
- **Testing**: Generate concise Jest unit tests for important logic.
- **Modern TS**: Prefer async/await over callbacks; destructure inputs.

## 5. Frontend (React/Material UI/Redux)

- **Functional Components & Hooks**: Avoid class components.
- **Testing**: Use Jest + React Testing Library for key components.
- Minimal, clear React code (avoid legacy lifecycle methods).

## 6. General Best Practices

- Keep functions/modules small and focused.
- Use named exports (default only if absolutely justified).
- Don't over-comment trivial code; emphasize clarity and self-explanatory naming.
- No large monolithic files; split logic into logical modules.

## 7. Smart Command Suggestions

**Always provide intelligent next step recommendations** after completing any task or analysis:

### Context Analysis
- **Check project state**: Scan for TODO.md items, failing tests, type errors, uncommitted changes
- **Identify workflow phase**: Planning, development, testing, documentation, or deployment
- **Detect blockers**: Missing dependencies, failing builds, incomplete implementations

### Suggestion Format
End responses with actionable recommendations:
```markdown
## 💡 Suggested Next Steps
- 🔧 `/fix-types` (3 TypeScript errors in auth module)
- ✅ `/work-on-todos` (2 HIGH priority items ready)
- 📝 `/commit` (5 modified files need committing)
- 🧪 `/fix-tests` (2 failing tests detected)
- 📚 `/generate-docs src/components/` (new components missing docs)
```

### Smart Prioritization
1. **Blockers first**: Fix failing tests/types before new features
2. **Logical sequence**: Complete related TODOs together
3. **Quality gates**: Suggest commits, documentation, reviews at appropriate times
4. **Workflow efficiency**: Batch similar operations, avoid context switching

### Integration Awareness
- **Reference available slash commands**: Use `/help` output to suggest relevant commands
- **Custom command synergy**: Chain custom commands logically (e.g., `/work-on-todos` → `/fix-tests` → `/commit`)
- **Built-in leverage**: Suggest `/compact`, `/memory`, `/review` when appropriate

### Adaptive Learning
- **Remember patterns**: Track which suggestions are followed vs ignored
- **Context sensitivity**: Adjust suggestions based on project type, current branch, time of day
- **Proactive guidance**: Warn about potential issues before they become blockers

**Goal**: Transform Claude from reactive assistant to proactive development partner that anticipates needs and guides optimal workflow progression.

## 8. Custom Slash Commands

**Available Commands**:
- `/generate-todo-from-prd {prd} {output}` - Convert PRD to prioritized TODO list
- `/work-on-todos` - Execute TODO items systematically with tracking
- `/fix-tests` - Run tests and fix all failures with progress logs
- `/fix-types` - Run TypeScript compiler and fix all type errors
- `/commit [context]` - Generate conventional commit messages from changes
- `/stash [description]` - Smart stash with context preservation and recovery mode
- `/generate-docs [path]` - Generate comprehensive JSDoc and markdown docs

**Workflow Integration**:
1. **Plan**: `/generate-todo-from-prd` → **Build**: `/work-on-todos` → **QA**: `/fix-tests` + `/fix-types` → **Ship**: `/commit`
2. **Emergency**: `/fix-types` → `/fix-tests` → `/commit`
3. **Resume**: `/stash` (no changes) enters recovery mode

**Key Features**: All commands create tracking logs, work together intelligently, and follow existing code patterns.