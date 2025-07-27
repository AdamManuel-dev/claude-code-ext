# Claude Code Documentation Generation Prompt

Generate comprehensive documentation for the specified path (or entire project if no path provided) {path}.

## Setup phase:
1. Determine scope:
   - If path provided: focus on that directory/file
   - If no path: scan entire project (exclude node_modules, dist, build)
   - Create documentation-report.md to track progress

2. Detect documentation standards:
   - Look for existing JSDoc patterns in the codebase
   - Check for .jsdoc.json, typedoc.json, or similar config
   - Identify comment style preferences (/** vs /**, parameter formats)
   - Note any custom JSDoc tags being used (@since, @deprecated, etc.)
   - Infer standards from best-documented files

3. Analyze project structure:
   - Map directory hierarchy
   - Identify module boundaries
   - Detect framework/library usage (React, Express, etc.)
   - Find entry points and main flows
   - Trace dependencies between modules

## Initial scan:
1. Find all JavaScript/TypeScript files in scope
2. For each file, identify:
   - Functions without JSDoc comments
   - Functions with incomplete JSDoc (missing params, returns, etc.)
   - Classes/methods lacking documentation
   - Exported constants and types without descriptions
   - Complex functions that need better examples

## For each undocumented or poorly documented function:

1. Analyze the function:
   - Parse function signature (name, parameters, return type)
   - Analyze function body to understand purpose
   - Track what it calls and what calls it
   - Identify side effects and error cases
   - Check test files for usage examples
   - Look for related functions to understand context

2. Generate comprehensive JSDoc:
   ```javascript
   /**
    * [Descriptive summary of what function does]
    * [Additional context about when/why to use it]
    *
    * @param {Type} paramName - Description of parameter, including:
    *   - Valid values/ranges
    *   - Whether optional and default value
    *   - Example values
    * @returns {Type} Description of return value and possible states
    * @throws {ErrorType} Description of when this error occurs
    * 
    * @example <caption>Basic usage</caption>
    * // Example showing common use case
    * const result = functionName(param1, param2);
    * 
    * @example <caption>Advanced usage</caption>
    * // Example showing edge cases or complex scenarios
    * 
    * @see {@link RelatedFunction} - For alternative approach
    * @since 1.0.0
    */
   ```

## Generate comprehensive markdown documentation:

### 1. Project-level documentation:
   
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

## Auto-generate if tools available:
- `jsdoc -c .jsdoc.json` for HTML docs
- `typedoc --out docs-html` for TypeScript
- `docusaurus` setup if applicable