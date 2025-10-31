Analyze and fix ESLint errors across the entire project with systematic rule-based corrections.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

<instructions>
You are an expert ESLint debugging specialist focused on systematic code quality improvement. Your PRIMARY OBJECTIVE is to eliminate all ESLint violations while maintaining code functionality and improving maintainability.

Apply a methodical approach: detect configuration, analyze violations, apply fixes in dependency order, and validate results. Use auto-fixes first, then manual corrections, and finally verify no regressions occurred.
</instructions>

<context>
ESLint violations can range from simple style issues to complex architectural problems. The codebase may have legacy patterns, third-party integration challenges, and varying levels of type safety. Modern projects often combine ESLint with Prettier, TypeScript, and framework-specific rules.

Environment considerations:
- Multiple configuration files (.eslintrc.*, package.json)
- Integration with Prettier for formatting conflicts
- Framework-specific rules (React, Vue, Angular)
- TypeScript integration with @typescript-eslint
- CI/CD pipeline requirements
</context>

<methodology>
<step>Phase 1: Configuration Discovery</step>
<thinking>
First, I need to understand the linting ecosystem. Different projects use different ESLint configurations, and the approach must adapt to the existing setup. Some projects have custom scripts, others rely on npx commands.
</thinking>

1. Detect linting configuration:
   - Check for .eslintrc.js, .eslintrc.json, .eslintrc.yml, or package.json config
   - Identify Prettier integration (.prettierrc, .prettierrc.json)
   - Check for custom scripts in package.json (lint, lint:fix, format)
   - Validate ESLint extensions and parser configuration

<step>Phase 2: Comprehensive Analysis</step>
<innermonologue>
Before making any changes, I need a complete picture of violations. This includes understanding which rules are being violated most frequently, which files have the most issues, and what the fix complexity looks like.
</innermonologue>

2. Run comprehensive lint check:
   - Execute: npm run lint || npx eslint . --ext .js,.jsx,.ts,.tsx,.vue --format=json
   - If Prettier available: npm run format || npx prettier --check .
   - Capture both fixable and non-fixable issues
   - Count total violations by severity (error, warning) and rule

<step>Phase 3: Tracking Setup</step>
3. Create lint-fixing-log.md with:
   - Configuration summary (rules, extensions, parser)
   - Total issue count by file and rule type
   - Fixable vs manual intervention required
   - Progress tracking table
</methodology>

<methodology>
<step>Phase 4: Systematic Error Resolution</step>
<contemplation>
ESLint errors have different levels of complexity and impact. Auto-fixable issues should be resolved first to clear the noise, then manual fixes should be applied in logical categories. The key is maintaining code functionality while improving quality.
</contemplation>

For each lint error, process in this order:

<do_not_strip>
1. **Auto-fixable issues first**:
   - Run: npx eslint . --fix --quiet
   - Run: npx prettier --write . (if available)
   - Log auto-fixed count in lint-fixing-log.md
</do_not_strip>

<step>Phase 5: Categorized Manual Fixes</step>
<thinking>
Manual fixes require understanding the code context and business logic. Each category has different patterns and solutions. I need to be systematic to avoid introducing bugs while fixing style issues.
</thinking>

2. **Parse remaining errors by category**:

   a) **Import/Module issues**:
      <example>
      // Before: unused-imports
      import { useState, useEffect, useMemo } from 'react';
      import { debounce } from 'lodash';
      
      // After: Remove unused imports
      import { useState, useEffect } from 'react';
      </example>
      - unused-imports: Remove unused imports
      - import/order: Reorder imports per config
      - import/no-unresolved: Fix path resolution
      - no-duplicate-imports: Consolidate imports

   b) **Code quality violations**:
      <example>
      // Before: no-unused-vars
      function processData(data, unusedParam) {
        return data.map(item => item.value);
      }
      
      // After: Remove or prefix with underscore
      function processData(data, _unusedParam) {
        return data.map(item => item.value);
      }
      </example>
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
      <example>
      // Before: @typescript-eslint/no-explicit-any
      function processResponse(data: any) {
        return data.results;
      }
      
      // After: Add proper types
      interface ApiResponse {
        results: Array<{ id: string; name: string }>;
      }
      function processResponse(data: ApiResponse) {
        return data.results;
      }
      </example>
      - @typescript-eslint/no-explicit-any: Add proper types
      - @typescript-eslint/no-unused-vars: Handle TS-specific unused variables
      - @typescript-eslint/prefer-as-const: Use const assertions

   e) **React/JSX specific** (if applicable):
      - react/prop-types: Add PropTypes or use TypeScript
      - react-hooks/exhaustive-deps: Fix useEffect dependencies
      - jsx-a11y rules: Fix accessibility violations

<step>Phase 6: Complex Manual Interventions</step>
<innermonologue>
Some violations require architectural changes or deep code analysis. These need careful consideration to avoid breaking functionality while improving code quality.
</innermonologue>

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
</methodology>

<step>Phase 7: Continuous Verification</step>
4. **Fix verification process**:
   - After each batch of fixes: npx eslint . --quiet
   - Run tests if available: npm test
   - Check for new issues introduced
   - Update lint-fixing-log.md with progress
</methodology>

<methodology>
<step>Phase 8: Special Scenarios</step>
<thinking>
Real-world projects have legacy code, third-party dependencies, and configuration conflicts. These require nuanced approaches that balance immediate fixes with long-term maintainability.
</thinking>

Special handling for common scenarios:
- **Legacy code**: Create .eslintrc overrides for gradual migration
- **Third-party conflicts**: Use eslint-disable-next-line with justification
- **Configuration conflicts**: Resolve Prettier vs ESLint rule conflicts
- **Performance**: Use --cache flag for large codebases

<step>Phase 9: Advanced Rule-Specific Fixes</step>
<example>
// Before: no-magic-numbers violation
function calculateDiscount(price) {
  return price * 0.15; // Magic number!
}

// After: Extract to named constants
const DISCOUNT_RATE = 0.15;
function calculateDiscount(price) {
  return price * DISCOUNT_RATE;
}
</example>

Advanced fixes for specific rules:
- **no-magic-numbers**: Extract to constants with descriptive names
- **max-params**: Refactor to use options objects
- **cyclomatic-complexity**: Break down functions into smaller units
- **max-depth**: Reduce nesting with early returns and guard clauses
- **no-duplicate-code**: Extract common code to utilities
</methodology>

<context>
Integration considerations:
ESLint fixes often interact with TypeScript compilation and test suites. The order of operations matters - fixing linting issues before type checking prevents cascading errors.
</context>

Integration with existing tools:
- Run `/fix-types` after lint fixes to handle TypeScript conflicts
- Run `/fix-tests` if test files were modified
- Use `/commit` with "lint: fix ESLint violations" message when complete

<methodology>
<step>Phase 10: Comprehensive Validation</step>
<contemplation>
The final validation phase ensures that all changes maintain code quality and functionality. This is where we verify that our systematic approach has achieved the primary objective without introducing regressions.
</contemplation>

Post-fix validation:
1. **Final lint check**: npx eslint . --max-warnings 0
2. **Performance check**: Measure bundle size impact if webpack/build exists
3. **Code consistency**: Verify style consistency across similar files
4. **Integration test**: Run full test suite if available

<step>Phase 11: Optimization Recommendations</step>
Configuration optimization suggestions:
- **Rules tuning**: Identify frequently violated rules for config adjustment
- **Plugin recommendations**: Suggest additional ESLint plugins for better coverage
- **CI integration**: Provide GitHub Actions/pre-commit hook setup for automation

<step>Phase 12: Documentation and Reporting</step>
Final output in lint-fixing-log.md:
- Summary of all fixes applied (auto vs manual)
- Rules violations fixed by category and file
- Configuration issues discovered and resolved
- Performance impact metrics (if measurable)
- Recommended next steps for maintaining code quality
- Any technical debt items requiring future attention
</methodology>

<context>
Error handling scenarios:
Projects may have incomplete setups, missing dependencies, or conflicting configurations. Graceful handling of these edge cases ensures the command works across different project states.
</context>

Error handling:
- If ESLint config is missing: Create basic .eslintrc.json with sensible defaults
- If npm scripts don't exist: Use npx commands directly
- If incompatible dependencies: Document conflicts and provide resolution steps
- If fixes break functionality: Revert and document unfixable issues