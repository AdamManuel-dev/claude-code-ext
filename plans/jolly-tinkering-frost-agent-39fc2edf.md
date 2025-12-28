# Orchestration Service Execution Schema Architecture Analysis

**Created**: 2025-12-05
**Status**: Strategic Planning Complete
**Scope**: Execution-related models in `/orchestration-service/prisma/schema.prisma`

---

## 1. Current State Assessment

### 1.1 Executive Summary

The orchestration-service execution schema represents a **mature, production-ready design** for a healthcare workflow automation system. It employs several sophisticated patterns including denormalization for performance, database triggers for consistency, and pre-computed aggregates for analytics. The architecture demonstrates clear thinking about multi-tenancy, HIPAA compliance, and operational scale.

### 1.2 Architecture Overview

```
+------------------+     +-------------------+     +----------------------+
|      Job         |---->| ExecutionLog      |     | ExecutionMetadata    |
| (Execution Unit) |     | (Step-by-step)    |     | (Denormalized View)  |
+------------------+     +-------------------+     +----------------------+
        |                        |                          ^
        |                        |                          |
        v                        |                   DB Trigger
+------------------+             |                          |
| ExecutionScreen  |             |                 +--------+--------+
| shot             |             |                 |                 |
+------------------+             |          +------+------+   +------+------+
        |                        |          | Aggregate   |   | Execution   |
        v                        |          | Metrics     |   | RAGRules    |
+------------------+             |          +-------------+   +-------------+
| Azure Blob      |<-------------+
| Storage         |
+------------------+
```

### 1.3 Strengths

#### 1.3.1 Denormalization Strategy (ExecutionMetadata)
**Rating: Excellent**

The `ExecutionMetadata` table is a **well-designed denormalization** for the Atlas dashboard:

- **Justified Duplication**: Eliminates 4-5 JOINs per dashboard query (Job -> Workflow -> Client -> Credential)
- **Database Trigger Automation**: Automatic population via `update_execution_metadata()` trigger ensures consistency
- **Graceful Degradation**: Exception handling in triggers allows job processing to continue even if metadata fails
- **Query Optimization**: Composite indexes (`idx_execution_metadata_org_status_created`) align with primary access patterns

```sql
-- Before denormalization: 4 JOINs
SELECT j.*, w.name, c.name, cred.name
FROM Job j
JOIN Workflow w ON j.workflowId = w.id
LEFT JOIN clients c ON j.clientId = c.id
LEFT JOIN Credential cred ON cred.id = j.credentialIds[1]
WHERE j.organizationId = $1;

-- After denormalization: Single table scan
SELECT * FROM execution_metadata WHERE organization_id = $1;
```

#### 1.3.2 Pre-Computed Aggregates (AggregateMetrics)
**Rating: Very Good**

The `AggregateMetrics` table implements **OLAP-style materialized aggregates**:

- **Sentinel Values**: Using `00000000-0000-0000-0000-000000000000` instead of NULL enables unique constraint for UPSERT operations
- **Generated Columns**: `avg_duration_ms` and `success_rate` are database-computed, eliminating race conditions
- **Multi-Dimensional**: Aggregates by period (hourly/daily), workflow, client, and initiator type
- **Trigger-Based Updates**: Real-time aggregate updates on job completion via `update_aggregate_metrics()`

#### 1.3.3 Audit Trail Design
**Rating: Excellent**

- **ExecutionLog**: Comprehensive step-by-step execution history with timing
- **PHIAuditLog**: HIPAA-compliant 6-year retention for PHI access
- **CredentialAuditLog**: Security-focused credential access tracking
- **ScheduleAuditLog**: Schedule modification history

#### 1.3.4 Multi-Tenancy Isolation
**Rating: Excellent**

- Consistent `organizationId` on all relevant tables
- Denormalized from Workflow to Job for query performance
- Composite indexes include `organizationId` for efficient tenant-scoped queries

### 1.4 Weaknesses and Improvement Opportunities

#### 1.4.1 Log Storage Scalability
**Rating: Needs Improvement**

**Current State**: `ExecutionLog` stores individual rows per step per job.

**Scale Analysis** (projected at 1000 jobs/day with 50 steps average):
- Daily log entries: ~50,000 rows
- Monthly log entries: ~1.5M rows
- Annual log entries: ~18M rows

**Issues**:
1. No partitioning strategy for time-series data
2. No archival or tiering mechanism
3. PostgreSQL sequential scans on large tables will degrade
4. No compression for older data

#### 1.4.2 Screenshot Storage Pattern
**Rating: Adequate but Could Improve**

**Current State**: `ExecutionScreenshot` stores blob URLs and metadata in PostgreSQL.

**Issues**:
1. No lifecycle management (retention/cleanup policies)
2. `signedUrl` and `expiresAt` tracked in DB but no automated refresh
3. Missing `deletedAt` for soft-delete consistency with other tables
4. No relationship to specific log entries (only to stepIndex)

#### 1.4.3 Missing Execution Checkpoints
**Rating: Gap**

**Current State**: No checkpoint/resumption capability for long-running workflows.

**Impact**:
1. Failed workflows must restart from beginning
2. No partial completion state preservation
3. Browser crashes lose all progress

#### 1.4.4 Step-Level Metrics Gap
**Rating: Minor Gap**

**Current State**: `ExecutionLog.duration` captures per-step timing, but:
1. No aggregated step-level performance metrics
2. `ExecutionAnalyticsRepository.getStepDurationStats()` calculates on-the-fly (expensive)
3. No pre-computed step performance data

---

## 2. Strategic Recommendations

### 2.1 Priority Matrix

| Recommendation | Priority | Effort | Impact | Timeline |
|---------------|----------|--------|--------|----------|
| Log Table Partitioning | HIGH | Medium | High | Q1 2026 |
| Archive/Retention System | HIGH | Medium | High | Q1 2026 |
| Execution Checkpoints | MEDIUM | High | High | Q2 2026 |
| Screenshot Lifecycle | MEDIUM | Low | Medium | Q1 2026 |
| Step-Level Aggregates | LOW | Medium | Medium | Q2 2026 |
| Event Sourcing Pattern | LOW | Very High | High | Future |

### 2.2 Detailed Recommendations

---

#### 2.2.1 [HIGH] Log Table Partitioning Strategy

**Problem**: `ExecutionLog` will grow unbounded, causing query degradation.

**Solution**: Implement PostgreSQL native partitioning by timestamp.

**Schema Changes**:

```sql
-- Convert ExecutionLog to partitioned table
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

-- Create monthly partitions
CREATE TABLE execution_log_2025_12 PARTITION OF execution_log_partitioned
  FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');
CREATE TABLE execution_log_2026_01 PARTITION OF execution_log_partitioned
  FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
-- ... additional partitions

-- Automated partition creation via pg_partman extension
SELECT partman.create_parent('public.execution_log_partitioned', 'timestamp', 'native', 'monthly');
```

**Prisma Compatibility**:
- Prisma doesn't natively support partitioned tables
- Use `@@map("execution_log_partitioned")` with raw SQL migrations
- Queries work transparently with partitioned tables

**Migration Path**:
1. Create new partitioned table structure
2. Migrate existing data in batches (off-peak hours)
3. Switch table names atomically
4. Drop old table after validation

---

#### 2.2.2 [HIGH] Archive and Retention System

**Problem**: Historical logs consume expensive hot storage; no cleanup mechanism.

**Solution**: Implement tiered storage with automated archival.

**Architecture**:

```
+----------------+     30 days     +----------------+     1 year      +----------------+
|  PostgreSQL    | -------------> | Azure Archive  | -------------> | Delete/        |
|  (Hot Storage) |   Archive Job  | Blob Storage   |   Cleanup Job  | Long-term Cold |
+----------------+                +----------------+                +----------------+
```

**Schema Additions**:

```prisma
// Add to schema.prisma
model ExecutionLogArchive {
  id            String   @id @default(uuid())
  jobId         String
  archiveBlobUrl String  // Azure Archive tier blob
  archiveDate   DateTime @default(now())
  recordCount   Int
  compressedSize Int     // bytes
  startDate     DateTime // earliest log timestamp
  endDate       DateTime // latest log timestamp

  @@index([jobId])
  @@index([archiveDate])
  @@map("execution_log_archive")
}

// Add retention policy settings
model RetentionPolicy {
  id              String   @id @default(uuid())
  organizationId  String
  resourceType    String   // 'execution_log', 'screenshot', 'job'
  hotRetentionDays Int     @default(30)
  archiveRetentionDays Int @default(365)
  deleteAfterDays Int?     // null = never delete

  @@unique([organizationId, resourceType])
  @@map("retention_policies")
}
```

**Implementation Scripts**:

```typescript
// Archive job (run daily)
async function archiveOldLogs(prisma: PrismaClient, blobService: BlobService) {
  const cutoffDate = subDays(new Date(), 30);

  // Find jobs with logs older than retention period
  const jobsToArchive = await prisma.$queryRaw<{jobId: string}[]>`
    SELECT DISTINCT job_id as "jobId"
    FROM "ExecutionLog"
    WHERE timestamp < ${cutoffDate}
    AND job_id NOT IN (SELECT job_id FROM execution_log_archive)
    LIMIT 100
  `;

  for (const { jobId } of jobsToArchive) {
    // Fetch all logs for job
    const logs = await prisma.executionLog.findMany({
      where: { jobId },
      orderBy: { timestamp: 'asc' }
    });

    // Compress and upload to archive
    const compressed = await gzip(JSON.stringify(logs));
    const blobUrl = await blobService.uploadToArchive(
      `logs/${jobId}.json.gz`,
      compressed
    );

    // Create archive record
    await prisma.$transaction([
      prisma.executionLogArchive.create({
        data: {
          jobId,
          archiveBlobUrl: blobUrl,
          recordCount: logs.length,
          compressedSize: compressed.length,
          startDate: logs[0].timestamp,
          endDate: logs[logs.length - 1].timestamp
        }
      }),
      prisma.executionLog.deleteMany({ where: { jobId } })
    ]);
  }
}
```

---

#### 2.2.3 [MEDIUM] Execution Checkpoint System

**Problem**: Long-running workflows cannot resume from failure points.

**Solution**: Add checkpoint model for resumable execution.

**Schema Additions**:

```prisma
model ExecutionCheckpoint {
  id            String   @id @default(uuid())
  jobId         String   @unique
  job           Job      @relation(fields: [jobId], references: [id], onDelete: Cascade)

  // Progress state
  lastCompletedStep Int
  stepStates        Json    // { stepIndex: { status, result, metadata } }
  browserState      Json?   // Serialized browser context (cookies, localStorage)

  // Recovery context
  pageUrl           String?
  pageTitle         String?
  screenshotBlobUrl String? // Last good state screenshot

  // Timing
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt
  expiresAt         DateTime // Checkpoints expire after 24h

  @@index([jobId])
  @@index([expiresAt])
  @@map("execution_checkpoints")
}
```

**Workflow Executor Changes**:

```typescript
// In workflow-executor.ts
async function executeWorkflow(options: WorkflowExecutionOptions) {
  let startStep = 0;
  let browserState = null;

  // Check for existing checkpoint
  const checkpoint = await this.prisma.executionCheckpoint.findUnique({
    where: { jobId: options.jobId }
  });

  if (checkpoint && checkpoint.expiresAt > new Date()) {
    startStep = checkpoint.lastCompletedStep + 1;
    browserState = checkpoint.browserState;
    logger.info(`Resuming job ${options.jobId} from step ${startStep}`);
  }

  // Execute from startStep
  for (let i = startStep; i < commands.length; i++) {
    try {
      await this.executeStep(commands[i], context);

      // Save checkpoint every 5 steps
      if (i % 5 === 0) {
        await this.saveCheckpoint(options.jobId, i, context);
      }
    } catch (error) {
      // Save final checkpoint before failing
      await this.saveCheckpoint(options.jobId, i - 1, context);
      throw error;
    }
  }

  // Delete checkpoint on success
  await this.prisma.executionCheckpoint.delete({
    where: { jobId: options.jobId }
  });
}
```

---

#### 2.2.4 [MEDIUM] Screenshot Lifecycle Management

**Problem**: Screenshots accumulate without cleanup; missing soft-delete.

**Solution**: Add lifecycle fields and cleanup automation.

**Schema Changes**:

```prisma
model ExecutionScreenshot {
  // ... existing fields ...

  // Add lifecycle management
  deletedAt    DateTime?  // Soft delete support
  retainUntil  DateTime?  // Computed: capturedAt + retention period
  isArchived   Boolean    @default(false)
  archiveBlobUrl String?  // Cold storage URL after archival

  // Add relationship to execution log
  executionLogId String?
  executionLog   ExecutionLog? @relation(fields: [executionLogId], references: [id])

  @@index([retainUntil])
  @@index([isArchived])
  @@index([deletedAt])
}
```

**Cleanup Job**:

```typescript
// Run weekly
async function cleanupScreenshots(prisma: PrismaClient, blobService: BlobService) {
  const expiredScreenshots = await prisma.executionScreenshot.findMany({
    where: {
      retainUntil: { lt: new Date() },
      deletedAt: null
    },
    take: 500
  });

  for (const screenshot of expiredScreenshots) {
    // Delete from blob storage
    await blobService.delete(screenshot.blobUrl);

    // Soft delete record
    await prisma.executionScreenshot.update({
      where: { id: screenshot.id },
      data: { deletedAt: new Date() }
    });
  }
}
```

---

#### 2.2.5 [LOW] Step-Level Aggregate Metrics

**Problem**: Step performance queries require expensive on-the-fly calculation.

**Solution**: Add pre-computed step-level aggregates.

**Schema Additions**:

```prisma
model StepMetrics {
  id              String   @id @default(uuid())

  // Dimensions
  organizationId  String
  workflowId      String
  stepIndex       Int
  stepName        String?
  stepType        String   // click, fill, navigate, etc.

  // Metrics
  totalExecutions    Int      @default(0)
  successfulExecutions Int    @default(0)
  failedExecutions   Int      @default(0)
  totalDurationMs    BigInt   @default(0)
  avgDurationMs      Int?     // Generated column
  p50DurationMs      Int?
  p95DurationMs      Int?

  // Common failure reasons
  topErrors          Json     @default("[]") // [{code, message, count}]

  // Time window
  periodStart        DateTime
  periodEnd          DateTime
  aggregationPeriod  String   // 'daily', 'weekly'

  updatedAt          DateTime @updatedAt

  @@unique([organizationId, workflowId, stepIndex, aggregationPeriod, periodStart])
  @@index([organizationId, workflowId])
  @@index([periodStart(sort: Desc)])
  @@map("step_metrics")
}
```

---

#### 2.2.6 [FUTURE] Event Sourcing Pattern

**Problem**: Current mutable state makes audit reconstruction difficult.

**Solution**: Implement event sourcing for execution state changes.

**Concept** (not immediate priority):

```prisma
model ExecutionEvent {
  id            String   @id @default(uuid())
  jobId         String
  sequenceNum   Int      // Monotonically increasing per job

  eventType     String   // 'STEP_STARTED', 'STEP_COMPLETED', 'STEP_FAILED', etc.
  eventData     Json     // Event-specific payload

  timestamp     DateTime @default(now())

  @@unique([jobId, sequenceNum])
  @@index([jobId, sequenceNum])
  @@map("execution_events")
}
```

**Benefits**:
- Complete audit reconstruction at any point in time
- Enables time-travel debugging
- Supports event replay for testing

**Trade-offs**:
- Significant storage increase
- Complexity in reading current state
- Migration effort from current model

---

## 3. Trade-off Analysis

### 3.1 Denormalization vs. Normalization

| Aspect | Current (Denormalized) | Alternative (Normalized) |
|--------|----------------------|-------------------------|
| **Query Performance** | Excellent (single table scan) | Poor (4-5 JOINs) |
| **Storage** | ~2x for metadata | Minimal duplication |
| **Consistency** | Trigger-maintained | Always consistent |
| **Schema Evolution** | Must update triggers | Automatically reflected |
| **Write Performance** | Slightly slower (trigger overhead) | Faster writes |

**Verdict**: Current denormalization is justified for read-heavy dashboard workloads.

### 3.2 Sentinel Values vs. NULL

| Aspect | Current (Sentinel Values) | Alternative (NULL) |
|--------|--------------------------|-------------------|
| **Unique Constraints** | Works with composite unique | Requires partial indexes |
| **Query Semantics** | Explicit "all" dimension | Implicit absence |
| **Storage** | Marginally more | Marginally less |
| **Code Clarity** | Magic values need documentation | Standard NULL handling |

**Verdict**: Sentinel values are the correct choice for UPSERT-heavy aggregates.

### 3.3 Partitioning vs. Single Table

| Aspect | Partitioned | Single Table |
|--------|-------------|--------------|
| **Query Performance** | Excellent with partition pruning | Degrades over time |
| **Maintenance** | Partition management needed | Simpler |
| **Vacuuming** | Per-partition (faster) | Whole table (slower) |
| **Archival** | Drop old partitions | DELETE + VACUUM |
| **Prisma Support** | Requires raw SQL | Native support |

**Verdict**: Partitioning is essential for `ExecutionLog` at scale.

---

## 4. Migration Path

### 4.1 Phase 1: Log Partitioning (Q1 2026)

**Week 1-2: Preparation**
- Set up pg_partman extension
- Create partitioned table structure
- Create automated partition creation job

**Week 3-4: Migration**
- Migrate data in batches during off-peak hours
- Validate data integrity
- Switch table names
- Update Prisma schema with `@@map`

**Week 5: Validation**
- Performance testing
- Monitor query patterns
- Fine-tune partition boundaries

### 4.2 Phase 2: Archive System (Q1 2026)

**Week 1: Schema**
- Add `ExecutionLogArchive` model
- Add `RetentionPolicy` model
- Deploy schema changes

**Week 2-3: Implementation**
- Implement archive job
- Configure Azure Archive tier
- Set up scheduling (Azure Functions timer trigger)

**Week 4: Testing**
- Test archive/restore workflow
- Validate compression ratios
- Document recovery procedures

### 4.3 Phase 3: Checkpoints (Q2 2026)

**Week 1-2: Schema & Core**
- Add `ExecutionCheckpoint` model
- Implement checkpoint save/load in executor
- Add checkpoint expiration cleanup

**Week 3-4: Integration**
- Integrate with browser crash recovery
- Test resume scenarios
- Performance validation

### 4.4 Phase 4: Screenshot Lifecycle (Q1 2026)

**Week 1: Schema**
- Add lifecycle fields to `ExecutionScreenshot`
- Deploy migration

**Week 2: Implementation**
- Implement cleanup job
- Configure retention policies
- Set up scheduling

---

## 5. Key Implementation Notes

### 5.1 Prisma Limitations to Consider

1. **No native partitioning support**: Use raw SQL migrations
2. **No generated columns in schema**: Define in SQL, mark as `@ignore` or use views
3. **No database triggers**: Maintain in separate migration files
4. **Limited JSON querying**: Use `$queryRaw` for complex JSONB operations

### 5.2 Performance Benchmarks to Establish

Before implementing changes, benchmark:
- Dashboard load time (ExecutionMetadata queries)
- Log query performance by job (ExecutionLog)
- Aggregate query performance (AggregateMetrics)
- Write throughput for high-volume log insertion

### 5.3 Monitoring Recommendations

Add observability for:
- Partition sizes and growth rates
- Archive job success/failure rates
- Checkpoint utilization rates
- Screenshot storage costs
- Query performance percentiles (p50, p95, p99)

---

## 6. Summary

The orchestration-service execution schema is **well-designed for its current scale** with thoughtful denormalization and aggregate patterns. The primary improvements needed are:

1. **Log Partitioning** - Essential for scalability
2. **Archive System** - Required for cost management
3. **Checkpoints** - Valuable for reliability
4. **Screenshot Lifecycle** - Important for storage hygiene

The denormalization in `ExecutionMetadata` and sentinel value pattern in `AggregateMetrics` are **correct architectural decisions** that should be retained. The database trigger approach for maintaining consistency is robust and well-implemented with proper error handling.

Estimated total effort for all recommendations: **3-4 months** of development time, spread across Q1-Q2 2026.
