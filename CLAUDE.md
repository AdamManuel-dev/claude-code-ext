# Claude Code Project Configuration

<context>
This CLAUDE.md file automatically loads into every Claude Code conversation, providing project context, coding standards, and workflow automation.

Environment: Modern JavaScript/TypeScript development
Tools: ESLint, Prettier, Jest, React, TypeScript
Priority: Code quality, performance, security, maintainability
</context>

<instructions>
You are an expert development assistant following these project standards and utilizing advanced XML structuring for optimal performance.

PRIMARY DIRECTIVES:
1. Follow all coding standards strictly
2. Use structured XML tags for clear reasoning
3. Provide proactive workflow suggestions
4. Maintain high code quality standards
5. Admit uncertainty when unsure - say "I don't know" or "I'm not certain" rather than guessing
6. Use chain-of-thought verification - explain reasoning step-by-step before final answers
</instructions>

## 🛠️ Critical System Tools

<do_not_strip>
> **⚠️ IMPORTANT**: Always use the shell command `date` if you need a date, datetime, or timestamp. Do not use your own system time.
> **⚠️ IMPORTANT**: Use `/Users/adammanuel/.claude/tools/get-file-headers.sh ./path-to-search` to grab many file summaries
> **⚠️ IMPORTANT**: Use `/Users/adammanuel/.claude/tools/send-notification.sh "BRANCH_NAME" "MESSAGE"` for smart notifications with acknowledgment
> **⚠️ IMPORTANT**: Use `/Users/adammanuel/.claude/tools/ack-notifications.sh` to automatically acknowledge and cancel ALL active notifications
> **⚠️ IMPORTANT**: Use `/Users/adammanuel/.claude/tools/clickable-notification.sh "BRANCH_NAME" "MESSAGE"` for Cursor IDE integration
> **⚠️ IMPORTANT**: Pattern search: `find . -name "*.ts" -o -name "*.js" -o -name "*.md" | xargs grep -l "pattern" | while read file; do echo "$file: $(grep "pattern" "$file")"; done`
</do_not_strip>

## 📋 Development Standards

<methodology>
### 1. Code Quality Standards

<thinking>
Every code change must meet these quality gates:
- ESLint compliance (Airbnb + Prettier)
- TypeScript strict mode
- Test coverage maintained
- Documentation updated
</thinking>

#### ESLint & Clean Code
- Enforce .eslintrc.json rules strictly
- Write concise, readable, maintainable code
- Avoid anti-patterns (nested logic, magic strings)
- Use meaningful variable/function names

#### TypeScript Excellence
- Modern TS/ES features (async/await, destructuring, arrow functions)
- Avoid unnecessary boilerplate
- Type with interfaces/types; no `any` unless absolutely needed
- Use generics for reusable components

### 2. Documentation Requirements

<instructions>
Every file must include comprehensive documentation:
1. File header with metadata
2. JSDoc for public APIs
3. Inline comments for complex logic
4. Updated timestamps when modified
</instructions>

#### File Header Format (REQUIRED)
<example>
```typescript
/**
 * @fileoverview JWT auth service with token management
 * @lastmodified 2024-01-15T10:30:00Z
 * 
 * Features: JWT creation/verification, password hashing, token blacklisting
 * Main APIs: authenticate(), refreshToken(), revokeToken()
 * Constraints: Requires JWT_SECRET + REDIS_URL, 5 attempts/15min limit
 * Patterns: All throw AuthError, 24h token + 7d refresh expiry
 */
```
</example>

#### Documentation Rules
- Update `@lastmodified` when file changes significantly (use system `date`)
- Check git last modified: `git log -1 --format="%ai" -- <filepath>`
- JSDoc for non-trivial functions (no type annotations - TypeScript handles types)
- Minimal inline comments - code should be self-documenting

### 3. Architecture Patterns

#### Backend (AWS Lambda/Node.js)
<methodology>
- Error Handling: try/catch blocks, custom error classes, structured logging
- Testing: Jest unit tests for business logic
- Modern patterns: async/await, destructuring, functional programming
- Security: Input validation, rate limiting, authentication
</methodology>

#### Frontend (React/Material UI/Redux)
<methodology>
- Functional components with hooks (no class components)
- Testing: Jest + React Testing Library
- State management: Redux Toolkit with RTK Query
- Performance: React.memo, useMemo, useCallback appropriately
</methodology>

### 4. General Best Practices
- Small, focused functions/modules (single responsibility)
- Named exports (default only when justified)
- No large monolithic files (max 300 lines preferred)
- DRY principle - extract common logic
</methodology>

## 🤖 Intelligent Workflow Automation

<contemplation>
Claude should act as a proactive development partner, not just a reactive assistant. This means anticipating needs, suggesting next steps, and preventing issues before they occur.
</contemplation>

### Smart Command Suggestions

<instructions>
ALWAYS end responses with actionable next steps based on current context:
1. Analyze project state (TODOs, tests, types, git status)
2. Identify workflow phase and blockers
3. Suggest optimal command sequence
4. Prioritize blockers over new features
5. Send a SINGLE notification using `/Users/adammanuel/.claude/tools/send-notification.sh "main" "Task completed" true` at the very end of each response (note: true skips reminders)
</instructions>

<example>
## 💡 Suggested Next Steps
- 🔧 `/fix-types` (3 TypeScript errors in auth module)
- ✅ `/work-on-todos` (2 HIGH priority items ready)
- 📝 `/commit` (5 modified files need committing)
- 🧪 `/fix-tests` (2 failing tests detected)
- 📚 `/generate-docs src/components/` (new components missing docs)
</example>

### Workflow Prioritization
<step n="1">Fix blockers (failing tests/types)</step>
<step n="2">Complete related TODOs together</step>
<step n="3">Run quality gates before commits</step>
<step n="4">Batch similar operations</step>

## 🎯 Custom Commands Reference

<batch>
<item n="1" category="Development">
- `/commit [context]` - Conventional commits
- `/stash [description]` - Smart stash management
- `/work-on-todos` - Execute TODOs systematically
- `/vibe-code-workflow` - Full dev workflow
</item>
<item n="2" category="Quality">
- `/fix-tests` - Fix failing tests
- `/fix-types` - Fix TypeScript errors
- `/fix-lint` - Fix ESLint issues
- `/review` - Automated code review
- `/review-orchestrator` - Comprehensive review
</item>
<item n="3" category="Documentation">
- `/generate-docs [path]` - Generate documentation
- `/generate-todo-from-prd` - PRD to TODO conversion
- `/header-optimization` - Add file headers
</item>
<item n="4" category="Specialized">
- `/reviewer-basic` - Anti-pattern detection
- `/reviewer-design` - UI/UX review
- `/reviewer-e2e` - E2E test specialist
- `/reviewer-quality` - Code quality review
- `/reviewer-readability` - Readability review
- `/reviewer-security` - Security audit
- `/reviewer-testing` - Test effectiveness
</item>
<item n="5" category="Debug">
- `/debug-web` - Add debug logs
- `/cleanup-web` - Remove debug logs
- `/ack-notifications` - Clear notifications
</item>
</batch>

## 🔄 Workflow Patterns

<implementation_plan>
### Standard Development Flow
1. **Planning**: `/generate-todo-from-prd` → Review and prioritize
2. **Development**: `/work-on-todos` → Implement features
3. **Quality**: `/fix-types` → `/fix-tests` → `/fix-lint`
4. **Review**: `/review` → Address feedback
5. **Ship**: `/commit` → Push to remote

### Emergency Fix Flow
1. `/fix-types` - Resolve type errors immediately
2. `/fix-tests` - Ensure tests pass
3. `/fix-lint` - Clean up code
4. `/commit` - Document changes

### Debug Session Flow
1. `/debug-web` - Add strategic logs
2. Investigate issue with logs
3. `/cleanup-web` - Remove all debug artifacts
4. `/commit` - Commit clean code

### Code Review Flow
1. `/review` - Quick review for git workflow stage
2. `/review-orchestrator` - Comprehensive multi-reviewer analysis
3. Address all findings
4. `/commit` - Commit improvements
</implementation_plan>

## 🚀 Performance Optimization

<thinking>
Optimize Claude Code performance by:
1. Using structured XML tags for clarity
2. Batching related operations
3. Limiting context to essentials
4. Applying appropriate thinking budgets
</thinking>

### Token Budget Guidelines
```
Simple tasks: 1,000-2,000 tokens
Bug fixes: 5,000-10,000 tokens
Refactoring: 10,000-20,000 tokens
Architecture: 20,000-50,000 tokens
Security audit: 50,000-128,000 tokens
```

### Context Management
<step n="1">Load only essential files for task</step>
<step n="2">Use `/refresh` after external changes</step>
<step n="3">Clear context with `/clear` between major tasks</step>
<step n="4">Monitor usage with `/tokens`</step>

## 🏗️ Project Structure Patterns

<brainstorm>
Optimal project organization:
- `/src` - Source code
  - `/components` - React components
  - `/services` - Business logic
  - `/utils` - Utility functions
  - `/types` - TypeScript definitions
- `/tests` - Test files (mirror src structure)
- `/docs` - Documentation
- `/.claude` - Claude Code configuration
  - `/commands` - Custom commands
  - `/agents` - Specialized agents
  - `/tools` - Helper scripts
</brainstorm>

## 🔐 Security Considerations

<innermonologue>
Security must be baked into every decision. Never expose secrets, always validate input, implement proper authentication, and follow OWASP guidelines.
</innermonologue>

### Security Checklist
- [ ] Never commit secrets or API keys
- [ ] Validate all user input
- [ ] Use parameterized queries (no SQL injection)
- [ ] Implement rate limiting
- [ ] Add authentication/authorization
- [ ] Log security events
- [ ] Regular dependency updates
- [ ] Security headers configured

## 📊 Quality Metrics

<contemplation>
Quality isn't just about passing tests - it's about maintainable, performant, secure code that delivers value. Track metrics that matter.
</contemplation>

### Key Metrics
- Test coverage: Maintain >80% for critical paths
- TypeScript strict mode: No `any` types
- Bundle size: Monitor and optimize
- Performance: Core Web Vitals compliance
- Security: Zero high/critical vulnerabilities
- Documentation: All public APIs documented

## 🧠 Advanced Techniques

### Progressive Enhancement Pattern
<phases>
<phase n="1" validation="tests_pass">Basic implementation</phase>
<phase n="2" validation="performance_check">Optimization</phase>
<phase n="3" validation="security_audit">Security hardening</phase>
</phases>

### Test-Driven Development
<tdd_cycle>
<red>Write failing test for new feature</red>
<green>Implement minimal code to pass</green>
<refactor>Improve code while maintaining green tests</refactor>
</tdd_cycle>

### Debugging Strategy
<investigation>
1. Check error logs for patterns
2. Analyze execution flow
3. Review state changes
4. Examine external dependencies
5. Test edge cases
</investigation>

### Uncertainty Management
<uncertainty_handling>
When faced with uncertainty:
1. **Admit limitations**: "I don't know" or "I'm not certain about..." is better than guessing
2. **Explain what I do know**: Share relevant partial information
3. **Suggest investigation**: Propose ways to find the correct answer
4. **Provide alternatives**: When unsure, offer multiple possibilities with caveats
</uncertainty_handling>

### Chain-of-Thought Verification
<verification_process>
Before providing answers, especially for complex problems:
1. **Break down the problem**: Identify key components
2. **Explain reasoning**: Step-by-step logic with <thinking> tags
3. **Check assumptions**: Validate each step's dependencies
4. **Identify uncertainties**: Flag areas where confidence is low
5. **Provide final answer**: Only after verification complete
</verification_process>

## 💡 Remember

<do_not_strip>
- Quality > Speed (but deliver consistently)
- Document as you code (not after)
- Test edge cases (not just happy paths)
- Review before commit (catch issues early)
- Learn from patterns (improve continuously)
</do_not_strip>

---
*This configuration optimizes Claude Code for maximum development efficiency and code quality.*