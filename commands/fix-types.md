Run tsc --noEmit --pretty and capture the full output. Create type-fixing-log.md to track progress.

Initial analysis:
1. Run tsc --noEmit --listFiles | wc -l to see total files being checked
2. Group errors by:
   - Error code (TS2345, TS2322, etc.)
   - File/module pattern (e.g., all test files, all API routes)
   - Root cause category (missing types, incorrect usage, strict mode issues)

For each type error, in order of dependencies (fix deepest dependencies first):
1. Parse the error to extract:
   - Error code and full message
   - File path, line, and column
   - The problematic code snippet
   - Related type information (expected vs actual)

2. Investigate the context:
   - Open the file and understand the surrounding code
   - Check if this is a symptom of a deeper issue (e.g., incorrect interface)
   - Look for similar patterns in other files
   - Trace type definitions back to their source
   - Check if third-party @types packages are outdated

3. Categorize and fix appropriately:
   a) Missing type imports:
      - Add proper import statements
      - Check if types need to be exported from source
   
   b) Incorrect type assignments:
      - Fix at the source of truth (interfaces/types)
      - Update all usages if interface changed
      - Use proper generics instead of any
   
   c) Null/undefined issues:
      - Add proper null checks
      - Use optional chaining (?.) and nullish coalescing (??)
      - Update types to include | null | undefined where appropriate
   
   d) Third-party library issues:
      - Check for @types package updates
      - Create ambient declarations in types/ directory if needed
      - Use module augmentation for extending types
   
   e) Generic constraint violations:
      - Fix generic parameters
      - Add proper extends constraints

4. Verify the fix:
   - Run tsc --noEmit --incremental on just the fixed file
   - Check that no new errors were introduced
   - Log the fix in type-fixing-log.md with before/after snippets

5. Special handling:
   - For any/unknown usage:
     * Create a TODO_TYPES.md file
     * Document each any with justification and proper type to add later
   - For @ts-ignore/@ts-expect-error:
     * Only use with detailed comment explaining why
     * Add to TECH_DEBT.md with plan to remove
   - For complex type errors:
     * Break down union/intersection types
     * Use type aliases for readability
     * Add JSDoc comments explaining complex types

Progressive verification:
1. After every 10 fixes, run tsc --noEmit to ensure no regressions
2. Use tsc --generateTrace trace to identify slow type checking if performance degrades
3. Check specific modules: tsc --noEmit src/modules/specific/**/*

Advanced checks after all errors are fixed:
1. Run with stricter settings temporarily:
   - tsc --noEmit --strict
   - tsc --noEmit --noImplicitAny --strictNullChecks
   - Document any new errors found for future improvement

2. Validate type coverage:
   - Count remaining any types: grep -r "any" --include="*.ts" --include="*.tsx" | wc -l
   - Check for implicit any in functions
   - Look for assertion usage (as keyword)

3. Performance check:
   - tsc --noEmit --diagnostics
   - If slow, consider using Project References

Final output:
- Summary in type-fixing-log.md including:
  * Total errors fixed by category
  * Common patterns found and solutions applied
  * Any architectural issues discovered
  * Performance metrics (before/after compilation time)
- TODO_TYPES.md with remaining type improvements
- TECH_DEBT.md with any temporary suppressions
- Recommendations for tsconfig.json improvements