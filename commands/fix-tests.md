Run yarn test --verbose and capture the full output. Create a test-fixing-log.md to track progress.

For each failing test:
1. Parse the failure to extract:
   - Exact test name and describe block hierarchy
   - Test file path and line number
   - Error type (assertion, timeout, syntax, import, etc.)
   - Stack trace and actual vs expected values
   
2. Before making changes:
   - Check if this test has dependencies on other tests (shared state, test order issues)
   - Look for related tests that might fail for the same reason
   - Run the specific test in isolation: yarn test <file> -t "<full test name>"
   - If it passes in isolation but fails in the suite, investigate test pollution

3. Diagnose systematically:
   - For assertion failures: Check if the implementation changed or test is outdated
   - For timeouts: Look for missing awaits, incorrect async handling, or slow operations
   - For import errors: Verify file paths, circular dependencies, and module resolution
   - For setup/teardown issues: Check beforeEach/afterEach hooks
   
4. Apply the fix:
   - Make the minimal change needed
   - Add comments explaining non-obvious fixes
   - If fixing source code, ensure the fix doesn't break other functionality
   
5. Verify the fix:
   - Run the specific test: yarn test <file> -t "<test name>"
   - Run all tests in that file: yarn test <file>
   - If both pass, mark as complete in test-fixing-log.md

Special handling:
- If a test is flaky (passes sometimes), add retry logic or fix the root cause
- If a test cannot be fixed and must be skipped:
  - Use test.skip() with a TODO comment explaining why
  - Add to MISSING_TESTS.md with:
    * Full test path and name
    * Reason it can't be fixed
    * What functionality is no longer tested
    * Link to issue/ticket if applicable
    * The complete test code
- If removing a test entirely, commit it to MISSING_TESTS.md first

After all individual fixes:
1. Run the full suite: yarn test
2. If new failures appear, check test-fixing-log.md for patterns
3. Run tests in different orders to catch order dependencies: yarn test --randomize
4. Generate coverage report to ensure no regression: yarn test --coverage

Final output:
- Summary of all fixes in test-fixing-log.md
- Count of tests fixed vs skipped/removed
- Coverage delta if available
- Any patterns noticed (e.g., "All MongoDB mock tests were outdated")