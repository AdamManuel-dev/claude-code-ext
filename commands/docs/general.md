# Claude Code Documentation Generation Command

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

Advanced documentation generation system that creates comprehensive JSDoc comments and markdown documentation hierarchies for JavaScript/TypeScript codebases.

<instructions>
You are an expert technical documentation specialist tasked with generating comprehensive documentation for JavaScript/TypeScript codebases. Your PRIMARY OBJECTIVE is to create both inline JSDoc comments and external markdown documentation that follows industry best practices and existing project patterns.

Key requirements:
- Analyze codebase structure and detect existing documentation standards
- Generate JSDoc comments for all undocumented functions, classes, and exports
- Create complete documentation hierarchy with proper cross-linking
- Follow CLAUDE.md file header documentation standards
- Produce professional-grade documentation suitable for teams and open source
</instructions>

<context>
This command operates on JavaScript/TypeScript codebases that need comprehensive documentation. It works with:
- Individual files or directory paths
- Entire project structures (excluding node_modules, dist, build)
- Existing JSDoc patterns and configuration files
- Modern ES6+/TypeScript syntax and patterns
- Various frameworks (React, Express, Node.js, etc.)

The system creates both inline code documentation and external markdown files organized in a logical hierarchy.
</context>

Generate comprehensive documentation for the specified path (or entire project if no path provided) {path}.

<brainstorm>
Documentation generation approaches to consider:
1. **Scope-based**: Single file → directory → entire project analysis
2. **Pattern-driven**: Detect existing JSDoc standards and follow them
3. **Hierarchical**: Generate both inline and external documentation
4. **Framework-aware**: Adapt to React, Express, Node.js patterns
5. **Cross-linked**: Create navigation between all documentation
6. **Standards-compliant**: Follow CLAUDE.md file header requirements
</brainstorm>

<methodology>
Comprehensive 3-phase documentation generation approach:

**Phase 1: Analysis & Standards Detection**
- Scope determination (path-specific vs project-wide)
- Existing JSDoc pattern detection and configuration discovery
- Project structure mapping and framework identification
- Dependency tracing and entry point identification

**Phase 2: Inline Documentation Generation**
- File header documentation (CLAUDE.md compliant)
- Function-level JSDoc with comprehensive examples
- Class and method documentation with usage patterns
- Type definitions and constant documentation

**Phase 3: External Documentation Creation**
- Project-level README and architecture documentation
- Module-specific guides with API references
- Development guides and troubleshooting documentation
- Cross-linked navigation and index structure
</methodology>

<implementation_plan>
<step>1. **Setup Phase**
   - Determine scope: path-specific vs entire project
   - Create documentation-report.md for progress tracking
   - Exclude build artifacts (node_modules, dist, build)
</step>

<step>2. **Standards Detection**
   - Scan for existing JSDoc patterns and configuration files
   - Identify comment style preferences and custom tags
   - Infer standards from best-documented files
</step>

<step>3. **Project Analysis**
   - Map directory hierarchy and module boundaries
   - Detect framework/library usage patterns
   - Trace dependencies and identify entry points
</step>
</implementation_plan>

<step>4. **Initial Scan**
   - Find all JavaScript/TypeScript files in scope
   - Identify undocumented functions, classes, exports
   - Locate incomplete JSDoc (missing params, returns)
   - Flag complex functions needing better examples
</step>

<step>5. **File Header Documentation**
   - Add CLAUDE.md compliant file headers for missing files
   - Update @lastmodified timestamps using system date
   - Include Features, Main APIs, Constraints, Patterns
</step>

<thinking>
For each function analysis, I need to:
1. Understand the function's purpose through signature and body analysis
2. Identify all parameters, return types, and potential errors
3. Find usage examples in test files or related code
4. Generate comprehensive JSDoc with proper formatting
5. Include cross-references to related functions
</thinking>

<example>
**File Header Documentation (CLAUDE.md Standard):**
```typescript
/**
 * @fileoverview JWT authentication service with token management
 * @lastmodified 2025-08-22T10:30:00Z
 * 
 * Features: JWT creation/verification, password hashing, token blacklisting
 * Main APIs: authenticate(), refreshToken(), revokeToken()
 * Constraints: Requires JWT_SECRET + REDIS_URL, 5 attempts/15min limit
 * Patterns: All throw AuthError, 24h token + 7d refresh expiry
 */
```
</example>

<example>
**Comprehensive JSDoc Documentation:**
```javascript
/**
 * Authenticates a user using JWT token and returns user data
 * Validates token signature, expiration, and checks blacklist status
 *
 * @param {string} token - JWT token from Authorization header
 * @param {Object} options - Authentication options
 * @param {boolean} [options.skipBlacklist=false] - Skip blacklist check
 * @returns {Promise<User>} Authenticated user object with permissions
 * @throws {InvalidTokenError} When token is malformed or invalid
 * @throws {ExpiredTokenError} When token has expired
 * @throws {BlacklistedTokenError} When token is blacklisted
 * 
 * @example <caption>Basic authentication</caption>
 * const user = await authenticate(req.headers.authorization);
 * console.log('User:', user.email);
 * 
 * @example <caption>Skip blacklist check</caption>
 * const user = await authenticate(token, { skipBlacklist: true });
 * 
 * @see {@link refreshToken} - For token renewal
 * @since 1.0.0
 */
```
</example>

<step>6. **Comprehensive Markdown Documentation Generation**
   - Create project-level documentation (README, ARCHITECTURE)
   - Generate module-specific documentation with API references
   - Build development guides and troubleshooting docs
   - Create cross-linked navigation structure
</step>

<contemplation>
The documentation structure should be hierarchical and discoverable:
1. Entry point (README) with clear navigation
2. Architecture overview for system understanding
3. Module documentation for specific functionality
4. API reference for implementation details
5. Guides for common development tasks
6. Troubleshooting for issue resolution

Each document should link to related sections and maintain consistency in format and depth.
</contemplation>

### 1. Project-level Documentation:
   
#### a) README.md (or enhance existing):
```markdown
# Project Name

Brief description of what the project does.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Modules](#modules)
- [API Reference](#api-reference)
- [Contributing](#contributing)

## Overview
Detailed project description, purpose, and key features.

## Architecture
High-level architecture overview with ASCII diagrams.
Link to detailed ARCHITECTURE.md.

## Modules
- [Auth Module](./docs/modules/auth.md) - Authentication and authorization
- [API Module](./docs/modules/api.md) - REST API endpoints
- [Database Module](./docs/modules/database.md) - Data persistence layer
```

#### b) ARCHITECTURE.md:
```markdown
# System Architecture

## Overview
System design philosophy and patterns used.

## Component Diagram
```
┌─────────────┐     ┌─────────────┐
│   Frontend  │────▶│   API       │
└─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Database  │
                    └─────────────┘
```

## Data Flow
Detailed explanation of how data moves through the system.

## Technology Stack
- Runtime: Node.js version
- Framework: Express/Fastify/etc
- Database: PostgreSQL/MongoDB/etc
```

### 2. Module-level documentation (for each major module):
   
Create docs/modules/[module-name].md:
```markdown
# Module Name

## Purpose
What this module is responsible for.

## Dependencies
- Internal: List of other modules this depends on
- External: npm packages used

## Key Components

### ComponentName
Description and purpose.

#### Public API
- `functionName(params)` - Brief description
- `className` - Brief description

## Usage Examples

### Basic Usage
```javascript
import { authenticate } from './auth';

const user = await authenticate(token);
```

### Advanced Patterns
More complex usage scenarios.

## Configuration
Environment variables and config options.

## Error Handling
Common errors and how to handle them.

## Security Considerations
Important security notes for this module.
```

### 3. API documentation:
   
Create docs/API.md:
```markdown
# API Reference

## Authentication Module

### authenticate(token: string): Promise<User>
Verifies a JWT token and returns the associated user.

**Parameters:**
- `token` (string): JWT token to verify

**Returns:** Promise resolving to User object

**Throws:**
- `InvalidTokenError`: When token is malformed
- `ExpiredTokenError`: When token has expired

**Example:**
```javascript
try {
  const user = await authenticate(req.headers.authorization);
  console.log('Authenticated user:', user.id);
} catch (error) {
  if (error instanceof InvalidTokenError) {
    res.status(401).send('Invalid token');
  }
}
```

### createUser(userData: CreateUserDTO): Promise<User>
[Similar detailed documentation]
```

### 4. File-level documentation:
   
For complex files, create docs/files/[filename].md:
```markdown
# Filename.js Documentation

## Overview
Purpose of this file in the system.

## Exports
List of all exported functions/classes/constants.

## Internal Functions
Documentation for important internal functions.

## State Management
How state is managed in this file.

## Side Effects
Any side effects when importing this file.
```

### 5. Development guides:
   
#### a) docs/guides/GETTING_STARTED.md:
```markdown
# Getting Started

## Prerequisites
- Node.js >= 14.0.0
- PostgreSQL >= 12

## Installation
Step-by-step setup instructions.

## Running Locally
How to run the development server.

## Common Tasks
- Adding a new endpoint
- Creating a migration
- Running tests
```
   
#### b) docs/guides/TESTING.md:
```markdown
# Testing Guide

## Test Structure
How tests are organized.

## Running Tests
- `npm test` - Run all tests
- `npm test:unit` - Run unit tests only

## Writing Tests
Best practices and examples.
```

### 6. Troubleshooting documentation:
   
Create docs/TROUBLESHOOTING.md:
```markdown
# Troubleshooting Guide

## Common Issues

### Authentication Errors
**Problem:** Getting 401 errors
**Solution:** Check token expiration...

### Database Connection
**Problem:** Cannot connect to database
**Solution:** Verify connection string...
```

## Special documentation for different patterns:

### For REST APIs - generate OpenAPI/Swagger:
- Extract route definitions
- Document request/response schemas
- Include authentication requirements
- Generate curl examples

### For GraphQL APIs:
- Document schema with descriptions
- Include query/mutation examples
- Show subscription patterns

### For React components:
- Generate Storybook stories
- Document props with examples
- Show state management

### For CLI tools:
- Generate man page format
- Include command examples
- Document all flags/options

## Quality improvements:
1. Cross-link between documents
2. Generate table of contents for long files
3. Include diagrams where helpful (ASCII or Mermaid)
4. Add code coverage badges
5. Include performance benchmarks

## Validation phase:
1. Check all links work (internal and external)
2. Verify code examples compile/run
3. Ensure consistent formatting
4. Validate against markdown linters
5. Check for outdated information

## Generate navigation structure:
Create docs/INDEX.md:
```markdown
# Documentation Index

## Getting Started
- [README](../README.md)
- [Getting Started Guide](./guides/GETTING_STARTED.md)
- [Architecture Overview](./ARCHITECTURE.md)

## API Reference
- [Complete API](./API.md)
- [REST Endpoints](./api/REST.md)
- [WebSocket Events](./api/WEBSOCKET.md)

## Modules
- [Authentication](./modules/auth.md)
- [Database](./modules/database.md)
- [API](./modules/api.md)

## Development
- [Contributing](./CONTRIBUTING.md)
- [Testing](./guides/TESTING.md)
- [Deployment](./guides/DEPLOYMENT.md)
```

## Final output:
- Updated source files with JSDoc comments
- Complete docs/ directory structure:
  ```
  docs/
  ├── INDEX.md
  ├── API.md
  ├── ARCHITECTURE.md
  ├── TROUBLESHOOTING.md
  ├── modules/
  │   ├── auth.md
  │   ├── api.md
  │   └── database.md
  ├── guides/
  │   ├── GETTING_STARTED.md
  │   ├── TESTING.md
  │   └── DEPLOYMENT.md
  └── files/
      └── [complex-file-docs].md
  ```
- documentation-report.md with metrics and recommendations
- Updated README.md with proper links to documentation
- Notify the user of the result

## Auto-generate if tools available:
- `jsdoc -c .jsdoc.json` for HTML docs
- `typedoc --out docs-html` for TypeScript
- `docusaurus` setup if applicable