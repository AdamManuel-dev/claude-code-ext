Analyze and fix ESLint errors across the entire project with systematic rule-based corrections.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

Initial setup and analysis:
1. Detect linting configuration:
   - Check for .eslintrc.js, .eslintrc.json, .eslintrc.yml, or package.json config
   - Identify Prettier integration (.prettierrc, .prettierrc.json)
   - Check for custom scripts in package.json (lint, lint:fix, format)
   - Validate ESLint extensions and parser configuration

2. Run comprehensive lint check:
   - Execute: npm run lint || npx eslint . --ext .js,.jsx,.ts,.tsx,.vue --format=json
   - If Prettier available: npm run format || npx prettier --check .
   - Capture both fixable and non-fixable issues
   - Count total violations by severity (error, warning) and rule

3. Create lint-fixing-log.md with:
   - Configuration summary (rules, extensions, parser)
   - Total issue count by file and rule type
   - Fixable vs manual intervention required
   - Progress tracking table

For each lint error, process in this order:
1. **Auto-fixable issues first**:
   - Run: npx eslint . --fix --quiet
   - Run: npx prettier --write . (if available)
   - Log auto-fixed count in lint-fixing-log.md

2. **Parse remaining errors by category**:
   a) **Import/Module issues**:
      - unused-imports: Remove unused imports
      - import/order: Reorder imports per config
      - import/no-unresolved: Fix path resolution
      - no-duplicate-imports: Consolidate imports

   b) **Code quality violations**:
      - no-unused-vars: Remove or prefix with underscore
      - no-console: Replace with proper logging or remove
      - prefer-const: Convert let to const where appropriate
      - no-var: Convert var to let/const

   c) **Style and formatting**:
      - quotes: Enforce single/double quote consistency
      - semi: Add/remove semicolons per config
      - comma-dangle: Fix trailing commas
      - indent: Fix indentation (defer to Prettier if available)

   d) **TypeScript specific** (if applicable):
      - @typescript-eslint/no-explicit-any: Add proper types
      - @typescript-eslint/no-unused-vars: Handle TS-specific unused variables
      - @typescript-eslint/prefer-as-const: Use const assertions

   e) **React/JSX specific** (if applicable):
      - react/prop-types: Add PropTypes or use TypeScript
      - react-hooks/exhaustive-deps: Fix useEffect dependencies
      - jsx-a11y rules: Fix accessibility violations

3. **Manual intervention strategies**:
   - For complex logic errors (no-unreachable-code, no-constant-condition):
     * Analyze code flow and fix logical issues
     * Add comments explaining complex conditions
   - For architectural violations (max-lines, complexity):
     * Extract functions or split files
     * Refactor to reduce complexity
   - For security issues (no-eval, no-implied-eval):
     * Replace with safer alternatives
     * Add to SECURITY_REVIEW.md if changes are significant

4. **Fix verification process**:
   - After each batch of fixes: npx eslint . --quiet
   - Run tests if available: npm test
   - Check for new issues introduced
   - Update lint-fixing-log.md with progress

Special handling for common scenarios:
- **Legacy code**: Create .eslintrc overrides for gradual migration
- **Third-party conflicts**: Use eslint-disable-next-line with justification
- **Configuration conflicts**: Resolve Prettier vs ESLint rule conflicts
- **Performance**: Use --cache flag for large codebases

Advanced fixes for specific rules:
- **no-magic-numbers**: Extract to constants with descriptive names
- **max-params**: Refactor to use options objects
- **cyclomatic-complexity**: Break down functions into smaller units
- **max-depth**: Reduce nesting with early returns and guard clauses
- **no-duplicate-code**: Extract common code to utilities

Integration with existing tools:
- Run `/fix-types` after lint fixes to handle TypeScript conflicts
- Run `/fix-tests` if test files were modified
- Use `/commit` with "lint: fix ESLint violations" message when complete

Post-fix validation:
1. **Final lint check**: npx eslint . --max-warnings 0
2. **Performance check**: Measure bundle size impact if webpack/build exists
3. **Code consistency**: Verify style consistency across similar files
4. **Integration test**: Run full test suite if available

Configuration optimization suggestions:
- **Rules tuning**: Identify frequently violated rules for config adjustment
- **Plugin recommendations**: Suggest additional ESLint plugins for better coverage
- **CI integration**: Provide GitHub Actions/pre-commit hook setup for automation

Final output in lint-fixing-log.md:
- Summary of all fixes applied (auto vs manual)
- Rules violations fixed by category and file
- Configuration issues discovered and resolved
- Performance impact metrics (if measurable)
- Recommended next steps for maintaining code quality
- Any technical debt items requiring future attention

Error handling:
- If ESLint config is missing: Create basic .eslintrc.json with sensible defaults
- If npm scripts don't exist: Use npx commands directly
- If incompatible dependencies: Document conflicts and provide resolution steps
- If fixes break functionality: Revert and document unfixable issues