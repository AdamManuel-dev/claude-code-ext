Review code readability, developer experience, and maintainability standards.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

## Review Focus Areas

### 1. Naming Conventions
- Variable and function names should be descriptive and self-documenting
- Avoid abbreviations unless widely recognized (e.g., URL, API)
- Use consistent naming patterns throughout the codebase
- Boolean variables should start with is/has/should

### 2. Code Structure
- Functions should have a single, clear purpose
- Complex logic should be extracted into well-named helper functions
- Avoid deeply nested conditions (max 3 levels)
- Early returns for edge cases

### 3. Comments and Documentation
- Code should be self-explanatory; comments explain "why" not "what"
- Complex algorithms need step-by-step explanations
- Document any non-obvious business logic
- Keep comments up-to-date with code changes

### 4. Consistency
- Follow established patterns in the codebase
- Consistent formatting and style
- Predictable file and folder organization
- Similar operations should look similar

### 5. Cognitive Load
- Limit function parameters (max 3-4, use objects for more)
- Avoid magic numbers and strings
- Make dependencies explicit
- Reduce mental context switching

## Review Process

1. Read through the code as if you're new to the project
2. Identify areas that require mental effort to understand
3. Suggest specific improvements with examples
4. Prioritize changes by impact on maintainability
5. Provide rationale for each suggestion

Always provide constructive feedback with specific examples of how to improve the code.