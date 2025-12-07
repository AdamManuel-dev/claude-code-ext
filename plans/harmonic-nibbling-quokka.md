# Custom Workflow Actions Implementation Plan

**Created:** 2025-12-04
**Status:** Ready for Review
**Scope:** Add `extract`, `validate`, `poll`, and `verify` actions to orchestration service

---

## 📊 Current Architecture Analysis

### Existing Command Pipeline

```
SessionExport (items[])
  ↓
RecordingParser
  ↓
CommandTranslator
  ↓
WorkflowCommand (click, fill, select, navigate, wait)
  ↓
StepExecutor
  ↓
ExecutionResult
```

### Key Files

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `execution.types.ts` | Type definitions | Add 4 new command interfaces |
| `command-translator.ts` | Event → Command translation | Add 4 new CommandTypes |
| `step-executor.ts` | Command execution | Add 4 new execute methods |
| `execution-context.ts` | State tracking | Add extracted data storage |
| `template-replacer.ts` | Template variables | Extend for extracted data |

---

## 🎯 Action Specifications

### 1. Extract Action

**Purpose:** Extract data from page elements and store for later use

**SessionExport Format:**
```json
{
  "id": "extract-001",
  "ts": 1234567890,
  "kind": "extract",
  "page": {"url": "...", "title": "..."},
  "selector": ".patient-name, .patient-dob, .member-id",
  "storeAs": "claimData.patient",
  "sessionId": "session-id",
  "meta": {
    "extractType": "parallel"
  }
}
```

**Command Interface:**
```typescript
export interface ExtractCommand extends BaseWorkflowCommand {
  type: 'extract';
  selectorFallbacks: string[];
  storeAs: string; // Dot-notation path: "claimData.patient.name"
  extractType?: 'text' | 'value' | 'attribute' | 'html';
  attributeName?: string; // For extractType: 'attribute'
  transform?: 'trim' | 'lowercase' | 'uppercase' | 'formatDate';
}
```

**Execution Flow:**
1. Find element(s) using ElementFinder
2. Extract data based on `extractType`
3. Apply optional transform
4. Store in ExecutionContext at path specified by `storeAs`
5. Return ExecutionResult with extracted data in metadata

### 2. Validate Action

**Purpose:** Validate data or page state before proceeding

**SessionExport Format:**
```json
{
  "id": "validate-001",
  "ts": 1234567890,
  "kind": "validate",
  "page": {"url": "...", "title": "..."},
  "selector": "",
  "validations": [
    {"field": "claimData.patient.memberId", "rule": "notEmpty"},
    {"selector": "input[name='DOB']", "rule": "pattern", "pattern": "\\d{2}/\\d{2}/\\d{4}"}
  ],
  "onFailure": "abort",
  "sessionId": "session-id"
}
```

**Command Interface:**
```typescript
export interface ValidateCommand extends BaseWorkflowCommand {
  type: 'validate';
  validations: Array<{
    // Validate extracted data
    field?: string; // Path to extracted data
    // OR validate element on page
    selector?: string;
    // Validation rule
    rule: 'notEmpty' | 'pattern' | 'numeric' | 'equals' | 'range' | 'custom';
    pattern?: string; // For rule: 'pattern'
    value?: any; // For rule: 'equals'
    min?: number; // For rule: 'range'
    max?: number; // For rule: 'range'
    customFn?: string; // JS function for rule: 'custom'
    errorMessage?: string;
  }>;
  onFailure: 'abort' | 'retry' | 'skip' | 'continue';
}
```

**Execution Flow:**
1. Iterate through all validations
2. For each validation:
   - If `field`: Get data from ExecutionContext
   - If `selector`: Find element and get value
   - Apply validation rule
   - Collect failures
3. If any failures:
   - Execute `onFailure` strategy
   - Return appropriate ExecutionResult
4. Return success if all validations pass

### 3. Poll Action

**Purpose:** Poll for a condition with intelligent backoff (replaces blocking waits)

**SessionExport Format:**
```json
{
  "id": "poll-001",
  "ts": 1234567890,
  "kind": "poll",
  "page": {"url": "...", "title": "..."},
  "selector": "text=Receipt, .confirmation, #claimId",
  "pollInterval": 5000,
  "maxDuration": 120000,
  "strategy": "exponentialBackoff",
  "successCondition": {
    "type": "selectorVisible",
    "selector": "text=Claim ID"
  },
  "sessionId": "session-id"
}
```

**Command Interface:**
```typescript
export interface PollCommand extends BaseWorkflowCommand {
  type: 'poll';
  successCondition: {
    type: 'selectorVisible' | 'urlChange' | 'textPresent' | 'custom';
    selector?: string; // For selectorVisible, textPresent
    url?: string; // For urlChange
    text?: string; // For textPresent
    customFn?: string; // JS function for custom
  };
  pollInterval: number; // Initial interval in ms
  maxDuration: number; // Max time to poll in ms
  strategy: 'fixed' | 'exponentialBackoff' | 'linearIncrease';
  backoffMultiplier?: number; // For exponentialBackoff (default: 2)
  maxInterval?: number; // Max interval cap (default: 30000)
}
```

**Execution Flow:**
1. Start timer (track elapsed time)
2. Loop until maxDuration:
   - Check success condition
   - If met: Return success immediately
   - Calculate next interval based on strategy:
     - `fixed`: Same interval
     - `exponentialBackoff`: interval *= backoffMultiplier
     - `linearIncrease`: interval += pollInterval
   - Wait for calculated interval
3. If timeout: Return failure with timeout error
4. Return ExecutionResult with polling stats

### 4. Verify Action

**Purpose:** Verify assertions about page state or extracted data

**SessionExport Format:**
```json
{
  "id": "verify-001",
  "ts": 1234567890,
  "kind": "verify",
  "page": {"url": "...", "title": "..."},
  "selector": "",
  "assertion": {
    "field": "receipt.confirmationNumber",
    "rule": "pattern",
    "pattern": "\\d{13}"
  },
  "onFailure": "retry",
  "sessionId": "session-id"
}
```

**Command Interface:**
```typescript
export interface VerifyCommand extends BaseWorkflowCommand {
  type: 'verify';
  assertion: {
    // What to verify
    field?: string; // Path to extracted data
    selector?: string; // Element to verify
    // Verification rule
    rule: 'exists' | 'visible' | 'pattern' | 'equals' | 'contains' | 'custom';
    pattern?: string;
    value?: any;
    customFn?: string;
    errorMessage?: string;
  };
  onFailure: 'abort' | 'retry' | 'skip' | 'continue';
  retryCount?: number; // For onFailure: 'retry'
  retryDelay?: number; // For onFailure: 'retry'
}
```

**Execution Flow:**
1. Get value to verify:
   - If `field`: Get from ExecutionContext
   - If `selector`: Find element and get value
2. Apply verification rule
3. If verification passes: Return success
4. If verification fails:
   - Execute `onFailure` strategy
   - Return appropriate ExecutionResult
5. Include verification details in result metadata

---

## 🛠️ Implementation Phases

### Phase 1: Type Definitions (2 hours)

**File:** `src/types/execution.types.ts`

**Tasks:**
1. Add 4 new command types to `BaseWorkflowCommand.type` union
2. Define `ExtractCommand` interface
3. Define `ValidateCommand` interface
4. Define `PollCommand` interface
5. Define `VerifyCommand` interface
6. Update `WorkflowCommand` discriminated union
7. Add to `CommandType` type

**Testing:**
- TypeScript compilation passes
- No breaking changes to existing commands

### Phase 2: Execution Context Enhancement (3 hours)

**File:** `src/services/execution/execution-context.ts`

**Tasks:**
1. Add `extractedData: Map<string, any>` property
2. Add `setExtractedData(path: string, value: any)` method
3. Add `getExtractedData(path: string): any` method
4. Add `hasExtractedData(path: string): boolean` method
5. Implement dot-notation path parsing for nested data
6. Add extracted data to execution summary

**Example:**
```typescript
export class ExecutionContext {
  private extractedData = new Map<string, any>();

  setExtractedData(path: string, value: any): void {
    // Support dot notation: "claimData.patient.name"
    const parts = path.split('.');
    if (parts.length === 1) {
      this.extractedData.set(path, value);
    } else {
      // Nested path handling
      const root = parts[0];
      const existing = this.extractedData.get(root) || {};
      setNestedValue(existing, parts.slice(1), value);
      this.extractedData.set(root, existing);
    }
  }

  getExtractedData(path: string): any {
    const parts = path.split('.');
    if (parts.length === 1) {
      return this.extractedData.get(path);
    } else {
      const root = this.extractedData.get(parts[0]);
      return getNestedValue(root, parts.slice(1));
    }
  }
}
```

**Testing:**
- Unit tests for path parsing
- Unit tests for nested data storage/retrieval
- Integration test with workflow execution

### Phase 3: Template Replacer Enhancement (2 hours)

**File:** `src/utils/template-replacer.ts`

**Tasks:**
1. Add support for extractedData placeholders
2. Extend `replaceTemplatePlaceholders()` to accept ExecutionContext
3. Replace `{{extractedData.path}}` with actual values
4. Add support for transform filters: `{{field | formatDate('MM/DD/YYYY')}}`

**Example:**
```typescript
export function replaceTemplatePlaceholders(
  input: string,
  context?: ExecutionContext
): string {
  let result = input;

  // Existing date placeholders...

  // NEW: Replace extracted data placeholders
  if (context) {
    const extractedDataPattern = /\{\{([a-zA-Z0-9._]+)(?:\s*\|\s*([a-zA-Z]+)(?:\(([^)]+)\))?)?\}\}/g;
    result = result.replace(extractedDataPattern, (match, path, filter, filterArgs) => {
      let value = context.getExtractedData(path);

      // Apply filter if specified
      if (filter && value !== undefined) {
        value = applyFilter(value, filter, filterArgs);
      }

      return value !== undefined ? String(value) : match;
    });
  }

  return result;
}
```

**Testing:**
- Unit tests for each filter type
- Integration test with ExecutionContext

### Phase 4: Command Translator Extension (4 hours)

**File:** `src/services/translator/command-translator.ts`

**Tasks:**
1. Add 4 new types to `CommandType` union
2. Add translation logic for `kind: 'extract'` in `generateCommandsFromGroup()`
3. Add translation logic for `kind: 'validate'`
4. Add translation logic for `kind: 'poll'`
5. Add translation logic for `kind: 'verify'`
6. Update translation statistics

**Example:**
```typescript
private translateItem(item: any): WorkflowCommand | null {
  switch (item.kind) {
    case 'extract':
      return this.translateExtract(item);
    case 'validate':
      return this.translateValidate(item);
    case 'poll':
      return this.translatePoll(item);
    case 'verify':
      return this.translateVerify(item);
    // ... existing cases
  }
}

private translateExtract(item: any): ExtractCommand {
  return {
    id: this.generateCommandId(),
    type: 'extract',
    selectorFallbacks: this.parseSelectors(item.selector),
    storeAs: item.storeAs || `extracted_${this.commandIdCounter}`,
    extractType: item.meta?.extractType || 'text',
    attributeName: item.meta?.attributeName,
    transform: item.meta?.transform,
    description: item.meta?.description,
    metadata: item.meta,
  };
}
```

**Testing:**
- Unit tests for each translation method
- Test with real SessionExport data
- Verify statistics are updated correctly

### Phase 5: Step Executor Implementation (8 hours)

**File:** `src/services/execution/step-executor.ts`

**Tasks:**
1. Update `executeCommand()` switch statement with 4 new cases
2. Implement `executeExtract()` method
3. Implement `executeValidate()` method
4. Implement `executePoll()` method
5. Implement `executeVerify()` method
6. Add template replacement to fill/navigate commands
7. Update error handling for new command types

**executeExtract Implementation:**
```typescript
private async executeExtract(
  page: Page,
  command: ExtractCommand,
  context: ExecutionContext,
  options: ResolvedExecutionOptions
): Promise<ExecutionResult> {
  const startTime = Date.now();

  // Find element(s)
  const elementResult = await this.elementFinder.findElement(
    page,
    command.selectorFallbacks
  );

  if (!elementResult) {
    throw new ExecutionError(
      'Element not found for extraction',
      ExecutionErrorCode.ELEMENT_NOT_FOUND,
      true
    );
  }

  // Extract data based on type
  let extractedValue: any;
  switch (command.extractType) {
    case 'text':
      extractedValue = await elementResult.locator.textContent();
      break;
    case 'value':
      extractedValue = await elementResult.locator.inputValue();
      break;
    case 'attribute':
      extractedValue = await elementResult.locator.getAttribute(
        command.attributeName || 'value'
      );
      break;
    case 'html':
      extractedValue = await elementResult.locator.innerHTML();
      break;
    default:
      extractedValue = await elementResult.locator.textContent();
  }

  // Apply transform if specified
  if (command.transform && extractedValue) {
    extractedValue = this.applyTransform(extractedValue, command.transform);
  }

  // Store in context
  context.setExtractedData(command.storeAs, extractedValue);

  logger.info('Data extracted', {
    commandId: command.id,
    path: command.storeAs,
    valuePreview: String(extractedValue).substring(0, 100),
  });

  return {
    success: true,
    command: command.id,
    duration: Date.now() - startTime,
    elementFound: true,
    successfulSelector: elementResult.successfulSelector,
    timestamp: new Date().toISOString(),
    retryAttempts: 0,
    metadata: {
      extractedValue: extractedValue,
      storedAt: command.storeAs,
    },
  };
}
```

**executePoll Implementation:**
```typescript
private async executePoll(
  page: Page,
  command: PollCommand,
  options: ResolvedExecutionOptions
): Promise<ExecutionResult> {
  const startTime = Date.now();
  let interval = command.pollInterval;
  let attempts = 0;

  while (Date.now() - startTime < command.maxDuration) {
    attempts++;

    // Check success condition
    const conditionMet = await this.checkPollCondition(
      page,
      command.successCondition
    );

    if (conditionMet) {
      logger.info('Poll condition met', {
        commandId: command.id,
        attempts,
        duration: Date.now() - startTime,
      });

      return {
        success: true,
        command: command.id,
        duration: Date.now() - startTime,
        elementFound: true,
        timestamp: new Date().toISOString(),
        retryAttempts: attempts - 1,
        metadata: {
          pollAttempts: attempts,
          strategyUsed: command.strategy,
        },
      };
    }

    // Calculate next interval based on strategy
    switch (command.strategy) {
      case 'exponentialBackoff':
        interval = Math.min(
          interval * (command.backoffMultiplier || 2),
          command.maxInterval || 30000
        );
        break;
      case 'linearIncrease':
        interval += command.pollInterval;
        break;
      // 'fixed' - no change
    }

    // Wait before next attempt
    await page.waitForTimeout(interval);
  }

  // Timeout
  throw new ExecutionError(
    `Poll timeout after ${command.maxDuration}ms`,
    ExecutionErrorCode.TIMEOUT,
    false,
    {
      attempts,
      maxDuration: command.maxDuration,
    }
  );
}
```

**Testing:**
- Unit tests for each execute method
- Integration tests with real page interactions
- Test all validation rules
- Test all poll strategies
- Test error scenarios

### Phase 6: Integration (3 hours)

**Files:** Multiple

**Tasks:**
1. Update WorkflowExecutor to pass ExecutionContext to StepExecutor
2. Update template replacement in fill/navigate commands
3. Test end-to-end workflow with all 4 new actions
4. Update execution logs to include extracted data
5. Update job results to include extracted data

**Testing:**
- E2E test with optimized OHCA workflow
- Verify extracted data flows through pipeline
- Verify template replacement works
- Verify validation/verification work correctly
- Verify polling works with timeout

### Phase 7: Documentation (2 hours)

**Files:** New documentation files

**Tasks:**
1. Create `CUSTOM_ACTIONS_GUIDE.md`
2. Document each action with examples
3. Update API documentation
4. Add JSDoc comments to all new methods
5. Create migration guide for existing workflows

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] ExtractCommand type definitions
- [ ] ValidateCommand type definitions
- [ ] PollCommand type definitions
- [ ] VerifyCommand type definitions
- [ ] ExecutionContext data storage
- [ ] Template replacer extensions
- [ ] Command translator for each action
- [ ] Step executor for each action

### Integration Tests
- [ ] Extract → Fill workflow (data flows correctly)
- [ ] Validate → abort on failure
- [ ] Poll → success after delay
- [ ] Verify → retry on failure
- [ ] All actions in single workflow

### E2E Tests
- [ ] Optimized OHCA workflow runs successfully
- [ ] Extracted data used in subsequent steps
- [ ] Validation prevents bad data submission
- [ ] Polling replaces long waits
- [ ] Verification catches errors

---

## 📊 Success Criteria

1. ✅ All 4 custom actions compile without TypeScript errors
2. ✅ All unit tests pass (>95% coverage)
3. ✅ Integration tests pass
4. ✅ Optimized OHCA workflow executes successfully
5. ✅ Extracted data flows through workflow correctly
6. ✅ Template replacement works for extracted data
7. ✅ Validation aborts on failure as expected
8. ✅ Polling reduces wait time (16 min → <2 min)
9. ✅ Verification catches invalid confirmations
10. ✅ Documentation is complete and accurate

---

## ⚠️ Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking changes to existing workflows | High | Careful type extensions, backward compatibility |
| Template replacement performance | Medium | Cache extracted data, lazy evaluation |
| Poll timeout tuning | Medium | Make intervals configurable, add monitoring |
| Extracted data not found | High | Graceful degradation, clear error messages |
| Validation rules too strict | Medium | Make rules configurable, add bypass option |

---

## 📅 Estimated Timeline

| Phase | Effort | Dependencies |
|-------|--------|--------------|
| Phase 1: Types | 2 hours | None |
| Phase 2: Context | 3 hours | Phase 1 |
| Phase 3: Templates | 2 hours | Phase 2 |
| Phase 4: Translator | 4 hours | Phase 1 |
| Phase 5: Executor | 8 hours | Phase 2, 3, 4 |
| Phase 6: Integration | 3 hours | Phase 5 |
| Phase 7: Docs | 2 hours | All phases |
| **Total** | **24 hours** | **~3 days** |

---

## 🔄 Alternative Approaches

### Approach 1: Minimal Extension (Recommended)
**What:** Add custom actions as first-class command types
**Pros:**
- Clean architecture, follows existing patterns
- Type-safe with TypeScript
- Easy to test and maintain
- Full IDE support

**Cons:**
- Requires changes to 5 files
- 24 hours implementation time

### Approach 2: Meta-based Implementation
**What:** Use existing `wait` command with `meta` field to encode custom behavior
**Pros:**
- No schema changes needed
- Works immediately with existing code
- Faster to implement (8 hours)

**Cons:**
- Less type-safe
- Harder to maintain
- Complex logic hidden in meta parsing
- Poor IDE support

### Approach 3: Plugin System
**What:** Create plugin architecture for custom actions
**Pros:**
- Extensible for future actions
- Clean separation of concerns
- Can add actions without core changes

**Cons:**
- Over-engineered for 4 actions
- 40+ hours implementation time
- Added complexity

**Recommendation:** Approach 1 (Minimal Extension) - Best balance of clean architecture and implementation time

---

## 🎯 Critical Implementation Details

### Switch Statement Location
**File:** `step-executor.ts:242`

```typescript
// Add new cases to existing switch:
switch (command.type) {
  case 'click':
    return await this.executeClick(page, command, opts);
  case 'fill':
    return await this.executeFill(page, command, opts);
  case 'select':
    return await this.executeSelect(page, command, opts);
  case 'navigate':
    return await this.executeNavigate(page, command, opts);
  case 'wait':
    return await this.executeWait(page, command, opts);
  // NEW CASES:
  case 'extract':
    return await this.executeExtract(page, command, context, opts);
  case 'validate':
    return await this.executeValidate(page, command, context, opts);
  case 'poll':
    return await this.executePoll(page, command, opts);
  case 'verify':
    return await this.executeVerify(page, command, context, opts);
  default:
    throw new ExecutionError(
      `Unknown command type: ${(command as any).type}`,
      ExecutionErrorCode.UNKNOWN_COMMAND_TYPE,
      false
    );
}
```

### Passing ExecutionContext
**File:** `workflow-executor.ts:1548`

Currently:
```typescript
return this.stepExecutor.executeCommand(page, executionCommand, options);
```

Needs to become:
```typescript
return this.stepExecutor.executeCommand(page, executionCommand, context, options);
```

**Impact:** Changes signature of `executeCommand()` - must update all callers

### Error Codes to Add
**File:** `execution.types.ts:219`

```typescript
export enum ExecutionErrorCode {
  // ... existing codes ...

  // NEW: Extraction errors
  EXTRACTION_FAILED = 'EXTRACTION_FAILED',
  EXTRACTION_NO_DATA = 'EXTRACTION_NO_DATA',

  // NEW: Validation errors
  VALIDATION_FAILED = 'VALIDATION_FAILED',
  VALIDATION_RULE_INVALID = 'VALIDATION_RULE_INVALID',

  // NEW: Polling errors
  POLL_TIMEOUT = 'POLL_TIMEOUT',
  POLL_CONDITION_INVALID = 'POLL_CONDITION_INVALID',

  // NEW: Verification errors
  VERIFICATION_FAILED = 'VERIFICATION_FAILED',
  ASSERTION_FAILED = 'ASSERTION_FAILED',
}
```

---

## 🧪 Test Plan

### Unit Tests (16 total)

**execution-context.test.ts** (4 tests)
- ✅ Should set extracted data with simple path
- ✅ Should set extracted data with nested path
- ✅ Should get extracted data correctly
- ✅ Should return undefined for missing data

**template-replacer.test.ts** (4 tests)
- ✅ Should replace extracted data placeholders
- ✅ Should apply formatDate filter
- ✅ Should handle missing data gracefully
- ✅ Should support nested paths

**command-translator.test.ts** (4 tests)
- ✅ Should translate extract action
- ✅ Should translate validate action
- ✅ Should translate poll action
- ✅ Should translate verify action

**step-executor.test.ts** (4 tests)
- ✅ Should execute extract command
- ✅ Should execute validate command
- ✅ Should execute poll command
- ✅ Should execute verify command

### Integration Tests (4 total)

**custom-actions.integration.test.ts** (4 tests)
- ✅ Extract → Fill workflow
- ✅ Validate → Abort on failure
- ✅ Poll → Success after delay
- ✅ Verify → Retry on failure

### E2E Test (1 test)

**ohca-optimized-workflow.e2e.test.ts** (1 test)
- ✅ Complete OHCA workflow with all custom actions

---

## 🎯 Next Steps

1. **Review this plan** and provide feedback
2. **Clarify approach preference** (Approach 1 recommended)
3. **Approve plan** to proceed with implementation
4. **Begin Phase 1** (Type Definitions)
5. **Iterative development** with testing at each phase
6. **Deploy to staging** for E2E testing
7. **Production deployment** after validation

---

## 🔗 Related Files

### Core Implementation
- Type definitions: `src/types/execution.types.ts` (line 58, 121, 219)
- Translator: `src/services/translator/command-translator.ts`
- Executor: `src/services/execution/step-executor.ts` (line 242 - switch statement)
- Context: `src/services/execution/execution-context.ts`
- Templates: `src/utils/template-replacer.ts`

### Testing
- Step executor tests: `src/services/execution/__tests__/step-executor.test.ts`
- Translator tests: `src/services/translator/__tests__/command-translator.test.ts`
- Context tests: `src/services/execution/__tests__/execution-context.test.ts`

### Workflow Files
- Optimized workflow: `downloads/recordings/recording-18mb-dec3-12-49am/optimized-workflow-sessionexport.json`
- Field mappings: `downloads/recordings/recording-18mb-dec3-12-49am/field-mappings.json`
- Schema guide: `downloads/recordings/recording-18mb-dec3-12-49am/SCHEMA_COMPATIBILITY.md`

---

## 📊 Implementation Checklist

### Before Starting
- [ ] Review and approve plan
- [ ] Clarify any questions
- [ ] Create feature branch: `feature/custom-workflow-actions`
- [ ] Set up test environment

### During Implementation
- [ ] Phase 1: Type definitions (2h)
- [ ] Phase 2: Context enhancement (3h)
- [ ] Phase 3: Template replacer (2h)
- [ ] Phase 4: Translator extension (4h)
- [ ] Phase 5: Executor implementation (8h)
- [ ] Phase 6: Integration (3h)
- [ ] Phase 7: Documentation (2h)

### After Implementation
- [ ] All unit tests pass (100% coverage for new code)
- [ ] Integration tests pass
- [ ] E2E test with OHCA workflow succeeds
- [ ] Code review completed
- [ ] Documentation reviewed
- [ ] Staging deployment successful
- [ ] Production deployment approved

---

**Status:** ✅ Ready for review and approval
**Timeline:** 24 hours (~3 business days)
**Risk Level:** Low (extends existing patterns)
**Recommended Approach:** Approach 1 (Minimal Extension)
