Review code quality, best practices, and maintainable patterns following industry standards.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

## Coding Style (Code Quality) Review Areas

### 1. TypeScript Best Practices
- Prefer interfaces over type aliases for object shapes
- Use strict mode and enable all strict checks
- Avoid `any` type; use `unknown` or generic types
- Leverage utility types (Partial, Required, Pick, Omit)
- Consistent use of readonly modifiers

### 2. Code Organization
- One component/class per file
- Consistent file naming (kebab-case or PascalCase)
- Logical folder structure by feature/domain
- Barrel exports for clean imports
- Separation of concerns

### 3. Modern JavaScript/TypeScript
- Use ES6+ features appropriately
- Prefer const over let, avoid var
- Destructuring for cleaner code
- Template literals over string concatenation
- Arrow functions for callbacks

### 4. React/Framework Patterns (if applicable)
- Functional components with hooks
- Custom hooks for reusable logic
- Proper dependency arrays in hooks
- Memoization where beneficial
- Consistent prop typing

### 5. Code Patterns and Architecture
- SOLID principles adherence
- Design pattern implementation
- Dependency injection patterns
- Clean architecture principles
- Separation of concerns

### 6. Logic Review and Analysis
- Carefully examine complex code blocks for logical correctness
- Verify conditional statements and edge case handling
- Check for off-by-one errors and boundary conditions
- Analyze algorithm efficiency and time complexity
- Validate state management and data flow logic
- Review error handling paths and fallback scenarios
- Ensure business logic aligns with requirements
- Check for race conditions in async operations
- Verify proper null/undefined handling
- Analyze loop conditions and termination logic

## Automated Checks

Run these linting tools and analyze results:
- ESLint with TypeScript rules
- Prettier for formatting consistency
- Custom project-specific rules

## Review Process

1. Check for ESLint/Prettier violations
2. Verify naming conventions are followed
3. Ensure consistent patterns across similar code
4. Look for opportunities to use modern syntax
5. Validate architectural patterns and design principles
6. **Logic Analysis**: Step through complex code blocks line by line, trace execution paths, and verify logical correctness

Provide specific examples showing current code vs. recommended approach.