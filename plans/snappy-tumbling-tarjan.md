# Standardized Error Handling System

## Overview

Create a unified `@tahoma/errors` package with reusable error classes that extend from a base error class, then migrate ALL services to use standardized error handling.

**User Decisions:**
- Clean break (no backward compatibility aliases)
- Migrate all services in this implementation
- Use error-only response format: `{ error: {...} }`

---

## Phase 1: Create `@tahoma/errors` Package

### 1.1 Package Structure

```
packages/errors/
├── src/
│   ├── index.ts                     # Main exports
│   ├── types/
│   │   ├── index.ts
│   │   ├── error-codes.ts           # Hierarchical error codes
│   │   └── interfaces.ts            # Core interfaces
│   ├── core/
│   │   ├── index.ts
│   │   ├── base.error.ts            # TahomaError base class
│   │   └── http-errors.ts           # HTTP status-based errors
│   ├── domains/
│   │   ├── index.ts
│   │   ├── execution.errors.ts      # Workflow execution errors
│   │   ├── recording.errors.ts      # Recording service errors
│   │   ├── database.errors.ts       # Database errors
│   │   └── external.errors.ts       # External service errors
│   ├── sanitization/
│   │   ├── index.ts
│   │   ├── sanitizer.ts             # ErrorSanitizer class
│   │   └── patterns.ts              # Sensitive patterns
│   ├── utils/
│   │   ├── index.ts
│   │   ├── type-guards.ts           # isTahomaError, isOperational, etc.
│   │   ├── zod-converter.ts         # ZodError to ValidationError
│   │   └── response-helpers.ts      # sendErrorResponse, etc.
│   └── adapters/
│       ├── index.ts
│       ├── express.ts               # Express error middleware
│       └── azure-functions.ts       # Azure Functions adapter
├── package.json
├── tsconfig.json
├── tsup.config.ts
└── README.md
```

### 1.2 Files to Create

| File | Description |
|------|-------------|
| `packages/errors/package.json` | Package config following @tahoma/health-checks pattern |
| `packages/errors/tsup.config.ts` | Build config with multi-entry points |
| `packages/errors/tsconfig.json` | TypeScript config |
| `packages/errors/src/types/error-codes.ts` | 60+ hierarchical error codes |
| `packages/errors/src/types/interfaces.ts` | SerializedError, LogFormat, ErrorDetails |
| `packages/errors/src/core/base.error.ts` | TahomaError base class |
| `packages/errors/src/core/http-errors.ts` | ValidationError, AuthenticationError, NotFoundError, etc. |
| `packages/errors/src/domains/execution.errors.ts` | ExecutionError, StepExecutionError |
| `packages/errors/src/domains/recording.errors.ts` | RecordingError |
| `packages/errors/src/domains/database.errors.ts` | DatabaseError, TransactionError |
| `packages/errors/src/sanitization/patterns.ts` | Sensitive data patterns |
| `packages/errors/src/sanitization/sanitizer.ts` | ErrorSanitizer class |
| `packages/errors/src/utils/type-guards.ts` | Type guards and helpers |
| `packages/errors/src/adapters/express.ts` | Express middleware factory |

### 1.3 Base Error Class Design

```typescript
abstract class TahomaError extends Error {
  readonly code: ErrorCode;           // Machine-readable (e.g., 'AUTH_TOKEN_EXPIRED')
  readonly statusCode: number;        // HTTP status (401)
  readonly category: ErrorCategory;   // Category (AUTHENTICATION)
  readonly isOperational: boolean;    // Expected vs programming error
  readonly details?: ErrorDetails;    // Structured context
  readonly correlationId?: string;    // Distributed tracing
  readonly recoverable: boolean;      // Can retry?
  readonly timestamp: string;         // ISO timestamp
  readonly cause?: Error;             // Original error

  toJSON(): SerializedError;          // Safe for clients (no stack)
  toLogFormat(): LogFormat;           // Full details for logging
  withCorrelationId(id: string): this;
  withDetails(details: ErrorDetails): this;
}
```

### 1.4 Error Code Categories

| Category | HTTP | Examples |
|----------|------|----------|
| VALIDATION | 400 | VALIDATION_ERROR, VALIDATION_FIELD_REQUIRED |
| AUTHENTICATION | 401 | AUTH_TOKEN_MISSING, AUTH_TOKEN_EXPIRED |
| AUTHORIZATION | 403 | FORBIDDEN, FORBIDDEN_TENANT_ISOLATION |
| NOT_FOUND | 404 | NOT_FOUND_WORKFLOW, NOT_FOUND_JOB |
| CONFLICT | 409 | CONFLICT_DUPLICATE, CONFLICT_LOCKED |
| RATE_LIMIT | 429 | RATE_LIMIT_EXCEEDED |
| INTERNAL | 500 | INTERNAL_ERROR |
| DATABASE | 500 | DATABASE_ERROR, DATABASE_TRANSACTION |
| EXTERNAL_SERVICE | 503 | EXTERNAL_SERVICE_UNAVAILABLE |
| EXECUTION | 500 | EXECUTION_ELEMENT_NOT_FOUND, EXECUTION_TIMEOUT |
| RECORDING | 400/500 | RECORDING_UPLOAD_FAILED |

### 1.5 HTTP Error Classes

```typescript
class ValidationError extends TahomaError { }     // 400
class AuthenticationError extends TahomaError { } // 401
class AuthorizationError extends TahomaError { }  // 403
class NotFoundError extends TahomaError { }       // 404
class ConflictError extends TahomaError { }       // 409
class RateLimitError extends TahomaError { }      // 429
class InternalServerError extends TahomaError { } // 500
class ServiceUnavailableError extends TahomaError { } // 503
```

### 1.6 Standard Response Format

```json
{
  "error": {
    "name": "ValidationError",
    "code": "VALIDATION_FIELD_REQUIRED",
    "message": "Missing required field: email",
    "statusCode": 400,
    "category": "VALIDATION",
    "details": { "field": "email" },
    "correlationId": "abc-123",
    "timestamp": "2025-12-04T10:30:00.000Z"
  }
}
```

---

## Phase 2: Migrate Services

### 2.1 orchestration-service

**Files to modify:**
- `orchestration-service/src/errors/base.error.ts` → DELETE (use @tahoma/errors)
- `orchestration-service/src/errors/service.errors.ts` → DELETE or slim down
- `orchestration-service/src/utils/error-sanitizer.ts` → DELETE (moved to package)
- `orchestration-service/src/api/utils/error-response.ts` → SIMPLIFY (use package helpers)
- `orchestration-service/src/api/middleware/error-handler.ts` → USE adapter
- `orchestration-service/src/middleware/error-handler.middleware.ts` → USE adapter
- `orchestration-service/package.json` → Add @tahoma/errors dependency
- All controllers throwing errors → Update imports

**Key changes:**
```typescript
// Before
import { DomainError, ValidationError } from '../../errors/base.error';

// After
import { ValidationError, NotFoundError } from '@tahoma/errors';
```

### 2.2 WebAI/backend

**Files to modify:**
- `WebAI/backend/src/errors/index.ts` → DELETE
- `WebAI/backend/src/middleware/errorHandler.ts` → USE adapter
- `WebAI/backend/package.json` → Add dependency
- All files importing from `./errors` → Update imports

**Note:** Remove `success: false` from responses to match new standard.

### 2.3 CredentialsManager

**Files to modify:**
- `CredentialsManager/src/middleware/errorHandler.ts` → USE adapter
- `CredentialsManager/src/middleware/inputValidation.ts` → Use ValidationError
- `CredentialsManager/package.json` → Add dependency

### 2.4 RagService

**Files to modify:**
- `RagService/src/errors/AuthenticationError.ts` → DELETE (use AuthenticationError from package)
- `RagService/src/server.ts` → Update error handlers
- `RagService/package.json` → Add dependency

### 2.5 Dashboard/api

**Files to modify:**
- `Dashboard/api/` → Update Azure Functions error handling
- Use `@tahoma/errors/adapters/azure-functions`

### 2.6 WebRecorder/azure-functions

**Files to modify:**
- Update to use Azure Functions adapter

### 2.7 packages/extension-services

**Files to modify:**
- `packages/extension-services/src/recording/errors.ts` → Extend RecordingError from package

### 2.8 packages/playwright-executor

**Files to modify:**
- `packages/playwright-executor/src/types/execution.types.ts` → Use ExecutionError from package
- Keep StepErrorCode enum but map to ErrorCodes

---

## Phase 3: Testing & Documentation

### 3.1 Tests to Add

- `packages/errors/src/__tests__/base.error.test.ts`
- `packages/errors/src/__tests__/http-errors.test.ts`
- `packages/errors/src/__tests__/sanitizer.test.ts`
- `packages/errors/src/__tests__/type-guards.test.ts`
- `packages/errors/src/__tests__/express-adapter.test.ts`

### 3.2 Documentation

- `packages/errors/README.md` - Usage guide
- Update service READMEs with new error patterns

---

## Critical Files Reference

### Source Files (to read patterns from):
| File | Purpose |
|------|---------|
| `orchestration-service/src/errors/base.error.ts` | DomainError base pattern |
| `WebAI/backend/src/errors/index.ts` | AppError with isOperational |
| `orchestration-service/src/utils/error-sanitizer.ts` | Sanitization patterns |
| `orchestration-service/src/api/utils/error-response.ts` | ErrorCodes, response helpers |
| `packages/extension-services/src/recording/errors.ts` | RecordingServiceError |
| `packages/playwright-executor/src/types/execution.types.ts` | StepErrorCode, StepExecutionError |
| `packages/health-checks/package.json` | Package structure template |
| `packages/health-checks/tsup.config.ts` | Build config template |

### Files to Delete After Migration:
- `orchestration-service/src/errors/base.error.ts`
- `orchestration-service/src/errors/service.errors.ts`
- `orchestration-service/src/utils/error-sanitizer.ts`
- `WebAI/backend/src/errors/index.ts`
- `RagService/src/errors/AuthenticationError.ts`

---

## Implementation Order

1. **Create package structure** - package.json, tsconfig, tsup.config
2. **Implement types** - error-codes.ts, interfaces.ts
3. **Implement core** - base.error.ts, http-errors.ts
4. **Implement domains** - execution.errors.ts, recording.errors.ts, database.errors.ts
5. **Implement sanitization** - patterns.ts, sanitizer.ts
6. **Implement utils** - type-guards.ts, zod-converter.ts
7. **Implement adapters** - express.ts, azure-functions.ts
8. **Write tests** - For all modules
9. **Build and verify** - npm run build, type-check
10. **Migrate orchestration-service** - Largest service, most error usage
11. **Migrate WebAI/backend** - Second largest
12. **Migrate remaining services** - CredentialsManager, RagService, Dashboard, WebRecorder
13. **Migrate packages** - extension-services, playwright-executor
14. **Clean up** - Delete old error files
15. **Final testing** - Run all service tests

---

## Estimated Scope

| Component | New Files | Modified Files | Deleted Files |
|-----------|-----------|----------------|---------------|
| packages/errors | ~15 | 0 | 0 |
| orchestration-service | 0 | ~25 | 3 |
| WebAI/backend | 0 | ~10 | 1 |
| CredentialsManager | 0 | ~5 | 0 |
| RagService | 0 | ~5 | 1 |
| Dashboard/api | 0 | ~3 | 0 |
| WebRecorder | 0 | ~2 | 0 |
| packages/* | 0 | ~4 | 0 |
| **Total** | **~15** | **~54** | **5** |
