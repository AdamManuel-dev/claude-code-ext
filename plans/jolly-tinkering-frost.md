# Execution Schema Storage Optimization Plan

**Date:** 2025-12-05
**Goal:** Decrease record sizes and improve storage scalability
**Projected Savings:** 3-4 GB/month (~40-50 GB/year)

---

## Storage Growth Analysis

### Current Monthly Growth (at 50K jobs/month scale)

| Table | Records/Month | Size/Record | Monthly Growth | Risk |
|-------|---------------|-------------|----------------|------|
| **ExecutionLog** | 3M | 500 bytes | **1.5 GB** | CRITICAL |
| **PHIAuditLog** | 100K-500K | 1-3 KB | **0.3-1.5 GB** | CRITICAL |
| **ExecutionRAGRules** | 50K | 5-50 KB | **1 GB** | HIGH |
| **Job.result** (JSON) | 50K | 10-50 KB | **0.5 GB** | HIGH |
| **ExecutionMetadata** (denorm) | 50K | 2.5 KB | **125 MB** | MEDIUM |
| **ExecutionScreenshot** | 100K-500K | 200 bytes | **50-100 MB** | MEDIUM |

**Total unoptimized growth: ~4-5 GB/month = 50-60 GB/year**

---

## Optimization Summary

| Priority | Optimization | Monthly Savings | Effort |
|----------|--------------|-----------------|--------|
| 1 | ExecutionLog TTL + partitioning | 1.5 GB | Medium |
| 2 | Normalize ExecutionRAGRules into 3 tables | 800 MB | High |
| 3 | Slim down ExecutionMetadata | 100 MB | Medium |
| 4 | Archive Job.result.output to blob storage | 400 MB | Medium |
| 5 | Add VARCHAR limits to TEXT fields | 50-100 MB | Low |
| 6 | PHIAuditLog compression + archival | 500 MB | Medium |

**Total projected savings: ~3.3 GB/month = 40 GB/year**

---

## Phase 1: Quick Wins (Week 1)

### 1.1 Add VARCHAR Limits to Unbounded TEXT Fields

**Files:** `prisma/schema.prisma`

```prisma
// Job model - add limits
errorMessage  String? @db.VarChar(2000)  // Was unbounded

// ScheduleExecution - add limit
errorStack    String? @db.VarChar(10000)  // Was @db.Text

// HealingAttempt - add limits
reasoning     String  @db.VarChar(2000)   // Was @db.Text

// HealingSuggestion - add limits
errorPattern  String  @db.VarChar(1000)   // Was @db.Text
dismissReason String? @db.VarChar(500)    // Was @db.Text
```

**Application layer:** Truncate before insert in `workflow.processor.ts`.

### 1.2 Remove Redundant Arrays from ExecutionMetadata

**Current (wasteful):**
```prisma
allAccountIds      String[] @default([])  // Duplicates Job.credentialIds
allAccountNames    String[] @default([])  // Computed from Credential
accountCount       Int      @default(0)   // Derivable
```

**Optimized:**
```prisma
// REMOVE these fields - join to Job.credentialIds when needed
// Keep only:
primaryAccountId   String?
primaryAccountName String?
```

**Savings:** ~300 bytes/record × 50K jobs = **15 MB/month**

---

## Phase 2: Normalize RAG Data (Week 2-3)

### 2.1 Split ExecutionRAGRules into Normalized Tables

**Current (bloated JSON):**
```prisma
model ExecutionRAGRules {
  payers    Json @default("[]")   // Array of objects
  modifiers Json @default("[]")   // Array of objects
  rules     Json @default("[]")   // Large array with 10+ fields each
}
```

**Optimized (normalized):**
```prisma
model ExecutionRAGRules {
  id                    String   @id @default(uuid())
  jobId                 String   @unique @map("job_id")
  organizationId        String   @map("organization_id")
  ragRetrievalTimeMs    Int      @map("rag_retrieval_time_ms")
  totalRulesRetrieved   Int      @map("total_rules_retrieved")
  totalRulesUsed        Int      @default(0) @map("total_rules_used")
  averageRetrievalScore Decimal? @map("average_retrieval_score") @db.Decimal(5, 4)
  retrievedAt           DateTime @default(now()) @map("retrieved_at")

  // Relations to normalized tables
  payers    ExecutionRAGPayer[]
  modifiers ExecutionRAGModifier[]
  rules     ExecutionRAGRule[]

  job Job @relation(fields: [jobId], references: [id], onDelete: Cascade)

  @@index([jobId])
  @@index([organizationId])
  @@map("execution_rag_context")
}

model ExecutionRAGPayer {
  id          String @id @default(uuid())
  contextId   String @map("context_id")
  payerName   String @map("payer_name") @db.VarChar(200)
  payerId     String @map("payer_id") @db.VarChar(100)
  scenario    String @db.VarChar(500)

  context ExecutionRAGRules @relation(fields: [contextId], references: [id], onDelete: Cascade)

  @@index([contextId])
  @@map("execution_rag_payers")
}

model ExecutionRAGModifier {
  id        String @id @default(uuid())
  contextId String @map("context_id")
  code      String @db.VarChar(20)
  scenario  String @db.VarChar(500)

  context ExecutionRAGRules @relation(fields: [contextId], references: [id], onDelete: Cascade)

  @@index([contextId])
  @@map("execution_rag_modifiers")
}

model ExecutionRAGRule {
  id              String   @id @default(uuid())
  contextId       String   @map("context_id")
  ruleId          String?  @map("rule_id") @db.VarChar(100)
  ruleType        String   @map("rule_type") @db.VarChar(50)
  condition       String   @db.VarChar(1000)
  action          String   @db.VarChar(1000)
  wasUsed         Boolean  @default(false) @map("was_used")
  usedAtStepIndex Int?     @map("used_at_step_index")
  usedAtTimestamp DateTime? @map("used_at_timestamp")
  usageReason     String?  @map("usage_reason") @db.VarChar(500)
  retrievalScore  Decimal? @map("retrieval_score") @db.Decimal(5, 4)

  context ExecutionRAGRules @relation(fields: [contextId], references: [id], onDelete: Cascade)

  @@index([contextId])
  @@index([contextId, wasUsed])
  @@map("execution_rag_rules")
}
```

**Benefits:**
- Individual record size: 5-50 KB → 200 bytes (context) + small normalized rows
- Better queryability (find all uses of a specific rule)
- Deduplication possible for common rules
- **Savings: ~800 MB/month**

---

## Phase 3: ExecutionLog Scalability (Week 3-4)

### 3.1 Implement Table Partitioning

**Current:** Single unbounded table growing 1.5 GB/month

**Solution:** PostgreSQL native monthly partitioning

```sql
-- Migration: Create partitioned table
CREATE TABLE execution_log_partitioned (
  id TEXT NOT NULL,
  job_id TEXT NOT NULL,
  step_index INT NOT NULL,
  step_name VARCHAR(500),
  level VARCHAR(10) NOT NULL,
  message TEXT NOT NULL,
  metadata JSONB,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  duration INT,
  PRIMARY KEY (id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Create partitions (automated via pg_partman)
SELECT partman.create_parent(
  'public.execution_log_partitioned',
  'timestamp',
  'native',
  'monthly'
);
```

### 3.2 Implement Retention & Archival

```prisma
model ExecutionLogArchive {
  id             String   @id @default(uuid())
  jobId          String   @map("job_id")
  archiveBlobUrl String   @map("archive_blob_url")
  recordCount    Int      @map("record_count")
  compressedSize Int      @map("compressed_size")
  startDate      DateTime @map("start_date")
  endDate        DateTime @map("end_date")
  archivedAt     DateTime @default(now()) @map("archived_at")

  @@index([jobId])
  @@index([archivedAt])
  @@map("execution_log_archives")
}
```

**Retention Policy:**
- Hot storage: 30 days
- Archive to Azure Blob (gzip compressed): 30-365 days
- Delete after 1 year (configurable per org)

**Savings: ~1.2 GB/month (keeping only 30 days hot)**

---

## Phase 4: Job.result Optimization (Week 4-5)

### 4.1 Extract Screenshots to Separate Relation

**Current (in Job.result JSON):**
```typescript
result: {
  screenshots: [
    { stepIndex, url, width, height, capturedAt },
    // ... potentially 50+ entries
  ]
}
```

**Solution:** Already have `ExecutionScreenshot` table - ensure `Job.result` only stores summary:

```typescript
// In workflow.processor.ts
result: {
  success: boolean,
  stats: { totalSteps, successfulSteps, failedSteps, duration },
  screenshotCount: number,  // Reference count only
  // Remove: screenshots array
  // Remove: full stepResults (archive separately)
}
```

### 4.2 Archive Detailed Output to Blob Storage

```prisma
model JobResultArchive {
  id          String   @id @default(uuid())
  jobId       String   @unique @map("job_id")
  blobUrl     String   @map("blob_url")
  size        Int      // Compressed size
  archivedAt  DateTime @default(now()) @map("archived_at")

  job Job @relation(fields: [jobId], references: [id], onDelete: Cascade)

  @@map("job_result_archives")
}
```

**Savings: ~400 MB/month**

---

## Phase 5: ExecutionMetadata Slim-Down (Week 5)

### 5.1 Remove Duplicated String Fields

**Current (2.5 KB/record with duplication):**
```prisma
model ExecutionMetadata {
  workflowName    String    // Duplicates Workflow.name
  clientName      String?   // Duplicates Client.name
  clientNpi       String?   // Duplicates Client.npi
  insureeName     String?   // Duplicates ClaimSubmission.patientName
  insureeId       String?   // Duplicates ClaimSubmission.patientId
  allAccountIds   String[]  // Duplicates Job.credentialIds
  allAccountNames String[]  // Computed from Credential table
}
```

**Optimized (500 bytes/record):**
```prisma
model ExecutionMetadata {
  id             String   @id @default(uuid())
  jobId          String   @unique @map("job_id")
  organizationId String   @map("organization_id")

  // Keep only IDs - join for names when needed
  workflowId     String   @map("workflow_id")
  clientId       String?  @map("client_id")
  claimId        String?  @map("claim_submission_id")

  // Keep denormalized for dashboard speed (minimal data)
  status          String   @map("status")
  progressPercent Decimal  @map("progress_percent") @db.Decimal(5, 2)
  totalSteps      Int      @map("total_steps")
  completedSteps  Int      @default(0) @map("completed_steps")

  // Timing (essential for dashboard)
  createdAt   DateTime  @map("created_at")
  startedAt   DateTime? @map("started_at")
  completedAt DateTime? @map("completed_at")
  durationMs  Int?      @map("duration_ms")

  // Error info (keep for quick filtering)
  errorCode    String? @map("error_code") @db.VarChar(50)
  errorMessage String? @map("error_message") @db.VarChar(500)

  // Primary account only (not array)
  primaryAccountId   String? @map("primary_account_id")

  job Job @relation(fields: [jobId], references: [id], onDelete: Cascade)

  @@index([organizationId, status, createdAt(sort: Desc)])
  @@map("execution_metadata")
}
```

**Trade-off:** Dashboard queries need 1-2 extra JOINs for names, but:
- Record size: 2.5 KB → 500 bytes (80% reduction)
- **Savings: ~100 MB/month**

---

## Files to Modify

### Schema Changes
- `orchestration-service/prisma/schema.prisma`
  - Lines 877-942: ExecutionMetadata slim-down
  - Lines 950-983: ExecutionRAGRules normalization
  - Lines 118, 505, 1374, 1435: Add VARCHAR limits
  - Add new models: ExecutionLogArchive, JobResultArchive

### Code Changes
- `src/queue/processors/workflow.processor.ts:512-534`
  - Slim down Job.result population
  - Archive detailed output to blob storage

- `src/database/repositories/execution-metadata.repository.ts`
  - Update to handle slim schema
  - Add JOINs for name lookups when needed

- `src/services/rag/rag-context.service.ts` (or equivalent)
  - Update to write normalized RAG tables

### New Files Needed
- `src/jobs/execution-log-archival.job.ts`
- `src/jobs/job-result-archival.job.ts`
- `src/services/archival/archival.service.ts`

### Migrations
1. `add_varchar_limits` - Phase 1
2. `normalize_rag_rules` - Phase 2
3. `partition_execution_logs` - Phase 3
4. `add_archival_tables` - Phase 3-4
5. `slim_execution_metadata` - Phase 5

---

## Implementation Timeline

```
Week 1:  VARCHAR limits + remove redundant arrays (Quick wins)
Week 2:  Design normalized RAG tables, create migration
Week 3:  Implement RAG normalization + update application code
Week 4:  ExecutionLog partitioning + archival job
Week 5:  ExecutionMetadata slim-down + dashboard updates
Week 6:  Job.result archival + testing
Week 7:  Production deployment + monitoring
```

---

## Success Metrics

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| Monthly storage growth | 4-5 GB | 1-2 GB | **60% reduction** |
| ExecutionMetadata record size | 2.5 KB | 500 bytes | **80% reduction** |
| ExecutionRAGRules record size | 5-50 KB | 200 bytes | **95% reduction** |
| Job.result avg size | 10-50 KB | 1-2 KB | **90% reduction** |
| ExecutionLog hot storage | Unbounded | 30 days | **Capped** |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Dashboard performance with JOINs | Create materialized view for common queries |
| RAG normalization breaks existing code | Feature flag + dual-write during transition |
| Partition migration downtime | Use pg_partman online migration |
| Archive retrieval latency | Add LRU cache for recently archived data |

---

## Questions for Confirmation

1. **Retention period:** Is 30 days hot + 365 days archive acceptable for ExecutionLog?
2. **Dashboard trade-off:** Accept 1-2 extra JOINs for smaller ExecutionMetadata?
3. **RAG normalization scope:** Full normalization or just remove large arrays?
