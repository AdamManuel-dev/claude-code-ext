<!--
@fileoverview Anti-pattern detection and basic code quality review command
@lastmodified 2025-07-28T02:15:34Z

Features: TypeScript smell detection, lint violations, test quality, error handling analysis
Main APIs: pattern scanning, automated detection tools, quality metrics, violation reporting
Constraints: Requires ESLint setup, test framework, generates detection reports
Patterns: Early issue detection, automated scanning, priority-based fixing
-->

Anti-Pattern Detection -- Basic Developer Review Step (catch common issues early)

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

### 1. TypeScript Smell Detection
- **Excessive type aliases**: Flag when type aliases are overused instead of interfaces
- **Any type abuse**: Count and flag all `any` usages - should be near zero
- **Undefined/unknown type handling**: Check for proper null/undefined handling
- **Missing type annotations**: Functions without return types or parameter types
- **Type assertions abuse**: Excessive use of `as` keyword bypassing type safety
- **Empty interfaces**: Interfaces with no properties that should be removed

### 2. Lint Rule Violations
- **Eslint-disable comments**: Count and document all lint rule bypasses
- **TODO/FIXME comments**: Track and prioritize technical debt
- **Console.log statements**: Remove debug logs from production code
- **Unused variables/imports**: Clean up dead code
- **Commented-out code**: Remove old commented code blocks
- **Magic numbers**: Replace with named constants

### 3. Test Quality Issues
- **Skipped tests**: Count `.skip()` and `.only()` test modifiers
- **Failing tests**: Ensure test suite passes completely
- **Low test coverage**: Flag areas with insufficient testing
- **Empty test cases**: Remove placeholder tests without assertions
- **Flaky tests**: Identify inconsistent test behavior
- **Missing test descriptions**: Ensure all tests have clear naming

### 4. Error Handling Negligence
- **Empty catch blocks**: Flag silent error swallowing
- **Unhandled promise rejections**: Check for missing .catch() handlers
- **Missing error boundaries**: React components without error handling
- **Generic error messages**: Replace with specific, actionable errors
- **No error logging**: Missing error tracking and monitoring

### 5. Performance Anti-Patterns
- **Unnecessary re-renders**: React components with missing memoization
- **Memory leaks**: Event listeners not cleaned up
- **Inefficient loops**: Nested loops or O(n²) operations
- **Large bundle sizes**: Unused dependencies or inefficient imports
- **Blocking operations**: Synchronous operations in async contexts

### 6. React/Frontend Specific Issues
- **Missing keys in lists**: React list items without unique keys
- **Direct DOM manipulation**: Using refs to manipulate DOM instead of state
- **Inline styles abuse**: Large style objects in JSX instead of CSS
- **Missing cleanup in useEffect**: No cleanup function for subscriptions/timers
- **Callback hell**: Not using async/await consistently
- **Missing loading states**: No loading indicators for async operations
- **Missing error states**: No error handling in UI components
- **No debouncing**: Search inputs without debouncing causing excessive API calls

### 7. Security and Configuration Issues
- **Hardcoded secrets**: API keys, passwords, or tokens in source code
- **Hardcoded URLs**: Endpoints not using environment variables
- **Missing input validation**: User inputs accepted without sanitization
- **Exposed sensitive data**: Logging or exposing PII in client-side code
- **Missing CORS configuration**: Improper cross-origin request handling
- **Insecure dependencies**: Known vulnerable packages in package.json

### 8. Code Duplication and Organization
- **Copy-paste code blocks**: Identical or near-identical code segments
- **Duplicate utility functions**: Same logic implemented multiple times
- **Inconsistent naming patterns**: Mixed camelCase, snake_case, kebab-case
- **Giant files**: Single files with 1000+ lines that should be split
- **Deeply nested folders**: Over-complicated directory structures
- **Missing barrel exports**: No index.js files for clean imports

### 9. Async/Promise Anti-Patterns
- **Mixed async patterns**: Mixing .then() and async/await in same codebase
- **Missing await keywords**: Async functions not properly awaited
- **Unhandled promise rejections**: Missing try/catch or .catch() handlers
- **Sequential async calls**: Not using Promise.all() for parallel operations
- **Race conditions**: State updates in async functions without proper checks

### 10. Accessibility and UX Issues
- **Missing alt text**: Images without descriptive alt attributes
- **No ARIA labels**: Interactive elements missing accessibility labels
- **Poor color contrast**: Text that doesn't meet WCAG standards
- **Missing focus indicators**: No visible focus states for keyboard navigation
- **No form validation**: Missing client-side validation feedback
- **Broken responsive design**: Components that break on mobile devices

## Automated Detection Tools

### TypeScript Analysis
```bash
# Count type-related issues
grep -r "any\b" src/ --include="*.ts" --include="*.tsx" | wc -l
grep -r ": any" src/ --include="*.ts" --include="*.tsx"
grep -r "as any" src/ --include="*.ts" --include="*.tsx"
```

### Lint Bypass Detection
```bash
# Find all lint rule bypasses
grep -r "eslint-disable" src/ --include="*.ts" --include="*.tsx"
grep -r "// @ts-ignore" src/ --include="*.ts" --include="*.tsx"
grep -r "// @ts-expect-error" src/ --include="*.ts" --include="*.tsx"
```

### Test Quality Checks
```bash
# Find test issues
grep -r "\.skip\|\.only" **/*.test.* **/*.spec.*
grep -r "console\.log" src/ --include="*.ts" --include="*.tsx"
grep -r "TODO\|FIXME\|HACK" src/ --include="*.ts" --include="*.tsx"
```

### Security and Configuration Scans
```bash
# Find hardcoded secrets and URLs
grep -r "api_key\|apiKey\|password\|secret\|token" src/ --include="*.ts" --include="*.tsx"
grep -r "http://\|https://" src/ --include="*.ts" --include="*.tsx"
grep -r "localhost\|127\.0\.0\.1" src/ --include="*.ts" --include="*.tsx"
```

### React/Frontend Issue Detection
```bash
# Find React anti-patterns
grep -r "key={index}" src/ --include="*.tsx"
grep -r "style={{" src/ --include="*.tsx"
grep -r "useEffect.*\[\]" src/ --include="*.tsx" # Missing cleanup
grep -r "ref\.current\." src/ --include="*.tsx" # Direct DOM manipulation
```

### Code Quality Scans
```bash
# Find duplication and organization issues
find src/ -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -nr | head -10
grep -r "function.*{$" src/ --include="*.ts" --include="*.tsx" | wc -l # Long functions
grep -r "==" src/ --include="*.ts" --include="*.tsx" # Should use ===
```

### Async Pattern Detection
```bash
# Find async anti-patterns
grep -r "\.then(" src/ --include="*.ts" --include="*.tsx"
grep -r "async.*=>" src/ --include="*.ts" --include="*.tsx"
grep -r "await.*await" src/ --include="*.ts" --include="*.tsx" # Sequential awaits
```

## Review Process

1. **Run Automated Scans**
   - Execute grep commands to find common anti-patterns
   - Generate counts and locations of problematic code
   - Document trends over time

2. **Manual Code Inspection**
   - Review each flagged instance for validity
   - Determine if bypasses are justified with comments
   - Check for patterns of poor practices

3. **Test Suite Validation**
   - Ensure all tests pass without skips
   - Verify no debug code remains
   - Check test coverage reports

4. **Type Safety Audit**
   - Review all `any` types for necessity
   - Ensure proper null/undefined handling
   - Validate type definitions are meaningful

5. **Prioritize Fixes**
   - Critical: Security bypasses, failing tests
   - High: Performance issues, type safety
   - Medium: Code cleanliness, documentation
   - Low: Style consistency

## Red Flags Checklist

### Critical Issues (Fix Immediately)
- [ ] Hardcoded API keys, passwords, or secrets in code
- [ ] Failing tests in main branch
- [ ] Security vulnerabilities in dependencies
- [ ] Unhandled promise rejections in production code
- [ ] Missing input validation on user-facing forms

### High Priority Issues
- [ ] More than 5 `any` types in the codebase
- [ ] Any `eslint-disable` without explanation comments
- [ ] Console.log statements in production code
- [ ] Empty catch blocks or generic error handling
- [ ] Missing keys in React list rendering
- [ ] Direct DOM manipulation in React components
- [ ] Memory leaks from uncleaned useEffect subscriptions

### Medium Priority Issues
- [ ] TODO comments older than 2 sprints
- [ ] Functions longer than 50 lines
- [ ] Files larger than 500 lines
- [ ] Commented-out code blocks
- [ ] Hardcoded URLs not using environment variables
- [ ] Missing loading states for async operations
- [ ] Duplicate code blocks that should be refactored
- [ ] Mixed async/await and .then() patterns

### Low Priority Issues
- [ ] Inconsistent naming conventions across files
- [ ] Missing alt text on images
- [ ] Large inline style objects in JSX
- [ ] Missing barrel exports for clean imports
- [ ] Using == instead of === for comparisons
- [ ] Missing ARIA labels on interactive elements

## Reporting Format

For each violation found, provide:
- **Location**: File and line number
- **Issue**: Specific problem description
- **Impact**: Why this matters (security, performance, maintainability)
- **Fix**: Concrete steps to resolve
- **Priority**: Critical/High/Medium/Low

Generate a "Stupid Mistakes Report" with counts, trends, and actionable remediation steps. 