# Health Check Standardization & Aggregation - Implementation Plan

## Overview

Standardize health checks across all Tahoma AI services using a shared library (`@tahoma-ai/health-checks`) and create an aggregated health monitoring endpoint in orchestration-service.

**Timeline**: 3 weeks (accelerated)
**Approach**: Monorepo workspace package with in-place endpoint replacement
**Scope**: 6 services + 1 aggregator service

---

## Goals

1. **Standardization**: Create shared TypeScript library for consistent health checks
2. **Aggregation**: Add platform-wide health monitoring to orchestration-service
3. **Coverage**: Add health endpoints to services that lack them (Dashboard API, WebRecorder)
4. **Compliance**: Maintain HIPAA requirements for CredentialsManager

---

## Standard Health Check Interface

### Core Response Format

```typescript
interface HealthCheckResponse {
  status: 'healthy' | 'degraded' | 'unhealthy' | 'unavailable';
  timestamp: string;              // ISO 8601
  service: string;                // Service name
  version?: string;               // Service version
  uptime?: number;                // Uptime in seconds
  checks: Record<string, DependencyCheck>;
}

interface DependencyCheck {
  name: string;
  status: 'healthy' | 'degraded' | 'unhealthy' | 'unavailable';
  latencyMs?: number;
  message?: string;
  lastChecked?: string;
}
```

### HTTP Status Code Mapping

- `200`: Service is `healthy` or `degraded` (accepting traffic)
- `503`: Service is `unhealthy` or `unavailable`

---

## Architecture

### 1. Shared Library Structure

**Location**: `packages/health-checks/`

```
packages/health-checks/
├── src/
│   ├── index.ts                          # Main exports
│   ├── types/
│   │   └── index.ts                      # Type definitions
│   ├── core/
│   │   ├── HealthChecker.ts              # Core orchestrator
│   │   └── DependencyChecker.ts          # Base class
│   ├── checkers/
│   │   ├── DatabaseChecker.ts            # PostgreSQL/MongoDB
│   │   ├── CacheChecker.ts               # Redis
│   │   ├── VaultChecker.ts               # Azure Key Vault
│   │   ├── ExternalServiceChecker.ts     # HTTP endpoints
│   │   └── CircuitBreakerChecker.ts      # Circuit breaker status
│   ├── adapters/
│   │   ├── express.ts                    # Express middleware
│   │   └── azure-functions.ts            # Azure Functions handler
│   └── metrics/
│       └── PrometheusHealthMetrics.ts    # Prometheus integration
├── package.json
└── tsconfig.json
```

**Key Classes**:

- **HealthChecker**: Orchestrates multiple dependency checks, manages timeouts, exports metrics
- **DependencyChecker**: Abstract base class with timeout handling
- **Express Adapter**: `createHealthCheckMiddleware(checker)` - drop-in middleware
- **Azure Functions Adapter**: `createHealthCheckHandler(checker)` - HTTP handler factory

### 2. Aggregated Health Service

**Location**: `orchestration-service/src/services/health/aggregator/`

**Components**:
- **HealthAggregator**: Main aggregation logic, caches results
- **ServiceRegistry**: Loads service configuration from JSON
- **ServiceHealthPoller**: Background polling with configurable intervals
- **HealthCache**: In-memory cache with TTL and stale-while-revalidate

**New Endpoints**:
- `GET /api/v1/health/aggregate` - Platform-wide health status
- `GET /api/v1/health/aggregate/:serviceId` - Specific service health
- `POST /api/v1/health/aggregate/refresh` - Force refresh all checks

**Service Registry**: `orchestration-service/config/service-registry.json`

```json
{
  "version": "1.0.0",
  "services": [
    {
      "id": "orchestration-service",
      "name": "Orchestration Service",
      "healthEndpoint": "http://localhost:3000/api/v1/health",
      "critical": true,
      "timeout": 5000,
      "checkInterval": 30
    },
    {
      "id": "credentials-manager",
      "name": "Credentials Manager",
      "healthEndpoint": "http://localhost:3001/health/ready",
      "critical": true,
      "timeout": 5000,
      "checkInterval": 30
    }
  ]
}
```

---

## Implementation Timeline (3 Weeks)

### Week 1: Foundation + Pilot Migration

**Days 1-2: Create Shared Library**
- Set up `packages/health-checks/` workspace package
- Implement core types and HealthChecker orchestrator
- Implement DatabaseChecker, CacheChecker, VaultChecker
- Create Express and Azure Functions adapters
- Write unit tests for core functionality

**Days 3-4: Pilot Migrations (In-Place Replacement)**
- Migrate **orchestration-service**: Replace lines 197-253 in `src/api/server.ts`
  - Create custom SessionPoolChecker for BrowserBase circuit breaker
  - Maintain exact response format for backward compatibility
  - Keep Prometheus metrics integration
- Migrate **CredentialsManager**: Refactor `src/routes/health.ts`
  - Enable HIPAA mode (`hipaaMode: true, detailLevel: 'minimal'`)
  - Preserve liveness `/health` and readiness `/health/ready` separation
  - Maintain 3s vault timeout

**Day 5: Testing & Validation**
- Integration tests for migrated services
- Validate response format matches original
- Load testing (health checks under 1s response time)
- HIPAA compliance review for CredentialsManager

### Week 2: Remaining Services + Azure Functions

**Days 1-2: Express Services**
- Migrate **RagService**: Update `src/server.ts` and `src/routes/search.ts`
  - Replace basic `/health` endpoint
  - Add dependency checks to `/search/health` (Azure OpenAI, Azure Search)
- Migrate **WebAI/backend**: Refactor `src/routes/health.ts`
  - Use shared library for cache, database, broker checks
  - Maintain latency measurements

**Days 3-4: Azure Functions Services**
- Add health endpoint to **Dashboard/api**
  - New file: `src/functions/health.ts`
  - Check MongoDB connectivity
  - Use Azure Functions adapter
- Add health endpoint to **WebRecorder/azure-functions**
  - New file: `src/functions/health.ts`
  - Check Azure Storage connectivity
  - May need custom AzureStorageChecker

**Day 5: Documentation**
- README for `packages/health-checks/`
- Migration guide for Express services
- Migration guide for Azure Functions services
- API documentation for health endpoints

### Week 3: Aggregation Service + Rollout

**Days 1-3: Build Aggregator**
- Implement HealthAggregator, ServiceRegistry, ServiceHealthPoller
- Implement HealthCache with TTL and stale-while-revalidate
- Create health aggregator routes in orchestration-service
- Add service registry configuration
- Start background polling on service startup

**Days 4-5: Testing & Rollout**
- Integration tests for aggregator (simulated service failures)
- Load testing for aggregated endpoint
- Update monitoring dashboards (Grafana)
- Configure Prometheus alerts
- Deploy to staging environment
- Final validation and production rollout

---

## Critical Files

### New Files (Shared Library)

1. **`packages/health-checks/package.json`**
   - Workspace package configuration
   - Dependencies: prom-client, @azure/keyvault-secrets, @azure/identity

2. **`packages/health-checks/src/core/HealthChecker.ts`**
   - Main orchestrator class
   - Parallel check execution with Promise.allSettled()
   - Timeout management, result caching (5s default)
   - Prometheus metrics export

3. **`packages/health-checks/src/adapters/express.ts`**
   - `createHealthCheckMiddleware(checker)` factory
   - Returns Express Router with GET handler
   - Maps status to HTTP codes (200/503)

4. **`packages/health-checks/src/adapters/azure-functions.ts`**
   - `createHealthCheckHandler(checker)` factory
   - Returns Azure Functions HTTP handler
   - Compatible with Functions v4

5. **`packages/health-checks/src/types/index.ts`**
   - All TypeScript interfaces and types
   - HealthCheckResponse, DependencyCheck, HealthCheckConfig, etc.

### New Files (Aggregator)

6. **`orchestration-service/src/services/health/aggregator/HealthAggregator.ts`**
   - Aggregation logic: polls services, caches results, determines platform status
   - Methods: `getAggregatedHealth()`, `getServiceHealth(id)`, `refreshAll()`

7. **`orchestration-service/src/services/health/aggregator/ServiceHealthPoller.ts`**
   - Background polling with intervals per service
   - Handles timeouts and failures gracefully
   - Updates cache on each successful check

8. **`orchestration-service/src/api/routes/health-aggregator.routes.ts`**
   - Express routes for aggregated health
   - GET `/api/v1/health/aggregate` - all services
   - GET `/api/v1/health/aggregate/:serviceId` - specific service
   - POST `/api/v1/health/aggregate/refresh` - force refresh

9. **`orchestration-service/config/service-registry.json`**
   - Service registry configuration
   - Lists all services with endpoints, criticality, timeouts

### New Files (Azure Functions)

10. **`Dashboard/api/src/functions/health.ts`**
    - New Azure Function for health check
    - Uses shared library adapter
    - Checks MongoDB connectivity

11. **`WebRecorder/azure-functions/src/functions/health.ts`**
    - New Azure Function for health check
    - Checks Azure Storage connectivity

### Files to Modify (In-Place Replacement)

12. **`orchestration-service/src/api/server.ts`** (lines 197-253)
    - REPLACE existing health endpoint logic with shared library
    - Create custom SessionPoolChecker for circuit breaker integration
    - Maintain exact response format and HTTP status codes

13. **`CredentialsManager/src/routes/health.ts`** (lines 123-170)
    - REPLACE health route handlers with shared library
    - Configure HIPAA mode for minimal responses
    - Preserve liveness/readiness endpoint separation

14. **`RagService/src/server.ts`** (lines 76-83)
    - REPLACE `/health` endpoint with shared library

15. **`RagService/src/routes/search.ts`** (lines 219-248)
    - REPLACE `/search/health` handler with shared library
    - Add dependency checks for Azure services

16. **`WebAI/backend/src/routes/health.ts`** (entire file)
    - REFACTOR to use shared library
    - Maintain existing dependency checks (cache, database, broker)

17. **`orchestration-service/package.json`**
    - Add workspace dependency: `"@tahoma-ai/health-checks": "workspace:*"`

18. **All service package.json files**
    - Add workspace dependency to shared library

---

## Migration Strategy

### In-Place Replacement Pattern

**Before** (orchestration-service example):
```typescript
app.get('/api/v1/health', async (_req, res) => {
  // 50+ lines of manual health check logic
  const uptime = Math.floor((Date.now() - serverStartTime) / 1000);
  // ... database check ...
  // ... session pool check ...
  res.status(statusCode).json(response);
});
```

**After**:
```typescript
import { HealthChecker, createHealthCheckMiddleware } from '@tahoma-ai/health-checks';

const healthChecker = new HealthChecker({
  serviceName: 'orchestration-service',
  version: process.env.npm_package_version || '1.0.0',
  checks: {
    database: { type: 'prisma', client: prisma }
  },
  metrics: { enabled: true }
});

// Register custom checker for session pool
healthChecker.registerChecker('sessionPool', new SessionPoolChecker(sessionPoolRef));

// Replace endpoint
app.use('/api/v1/health', createHealthCheckMiddleware(healthChecker));
```

**Key Points**:
- No transition period - direct replacement
- Response format MUST match exactly for monitoring compatibility
- HTTP status codes MUST remain same (200 vs 503)
- All custom checks (session pool, circuit breaker) preserved via custom checkers

### Custom Checkers for Special Cases

**SessionPoolChecker** (orchestration-service):
```typescript
class SessionPoolChecker extends DependencyChecker {
  constructor(private sessionPool: SessionPool) {
    super('sessionPool', 3000);
  }

  async check(): Promise<DependencyCheck> {
    try {
      const stats = this.sessionPool.getStats();
      const isHealthy = this.sessionPool.isCircuitBreakerHealthy();

      return {
        name: 'sessionPool',
        status: isHealthy ? 'healthy' : 'degraded',
        metadata: {
          poolSize: stats.total,
          available: stats.available,
          circuitBreaker: stats.circuitBreaker
        }
      };
    } catch (error) {
      return {
        name: 'sessionPool',
        status: 'unavailable',
        message: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }
}
```

---

## Aggregated Health Logic

### Status Aggregation Rules

```typescript
function aggregateStatus(services: ServiceHealthStatus[]): HealthStatus {
  // Critical services must be healthy for platform to be healthy
  const criticalServices = services.filter(s => s.critical);
  const hasCriticalUnhealthy = criticalServices.some(s =>
    s.status === 'unhealthy' || s.status === 'unavailable'
  );

  if (hasCriticalUnhealthy) {
    return 'unhealthy'; // Platform unhealthy
  }

  // If critical service degraded, platform is degraded
  const hasCriticalDegraded = criticalServices.some(s => s.status === 'degraded');
  if (hasCriticalDegraded) {
    return 'degraded';
  }

  // Non-critical service failures only cause degraded state
  const hasAnyUnhealthy = services.some(s =>
    s.status === 'unhealthy' || s.status === 'unavailable'
  );

  if (hasAnyUnhealthy) {
    return 'degraded'; // Platform degraded but operational
  }

  return 'healthy'; // All systems operational
}
```

### Caching Strategy

- **TTL**: 30 seconds (configurable per service in registry)
- **Stale-While-Revalidate**: Return stale data immediately, refresh in background
- **Background Polling**: Proactive checks at configured intervals (30-60s)
- **Benefits**: Sub-100ms aggregated health responses, prevents health check storms

---

## Testing Requirements

### Unit Tests
- [ ] HealthChecker executes checks in parallel
- [ ] HealthChecker respects timeouts
- [ ] HealthChecker caches results correctly
- [ ] DatabaseChecker validates PostgreSQL and MongoDB
- [ ] VaultChecker implements 3s timeout
- [ ] Express adapter returns correct HTTP status codes
- [ ] Azure Functions adapter compatible with Functions v4

### Integration Tests
- [ ] Migrated services match original response format exactly
- [ ] HIPAA mode limits information exposure (CredentialsManager)
- [ ] Aggregator polls all registered services
- [ ] Aggregator correctly determines platform status
- [ ] Critical service failure marks platform unhealthy
- [ ] Non-critical service failure marks platform degraded

### Performance Tests
- [ ] Individual health checks respond < 1s (p95)
- [ ] Aggregated health check responds < 2s (p95)
- [ ] Health endpoints handle 100 concurrent requests
- [ ] Cache prevents duplicate checks within TTL

### Backward Compatibility Tests
- [ ] orchestration-service response matches old format
- [ ] HTTP status codes unchanged (200 vs 503)
- [ ] Existing monitoring dashboards work without changes
- [ ] Prometheus metrics continue to export

---

## Prometheus Metrics

**Per-Service Metrics** (exported by all services):
```
tahoma_service_health{service="orchestration-service"} 1
tahoma_dependency_health{service="orchestration-service",dependency="database"} 1
tahoma_health_check_duration_seconds{dependency="database"} 0.045
tahoma_health_checks_total{service="orchestration-service"} 1523
```

**Aggregator Metrics**:
```
tahoma_platform_health{environment="production"} 1
tahoma_services_by_status{status="healthy"} 5
tahoma_aggregator_check_duration_seconds{service="orchestration-service"} 0.123
```

---

## Rollout Checklist

### Pre-Deployment
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Load testing complete (1000 req/s)
- [ ] HIPAA compliance validated for CredentialsManager
- [ ] Documentation complete
- [ ] Service registry configuration reviewed

### Deployment (Per Service)
- [ ] Deploy shared library package
- [ ] Deploy service with updated health endpoint
- [ ] Verify health endpoint responds correctly
- [ ] Verify Prometheus metrics exporting
- [ ] Update monitoring dashboards
- [ ] Validate alerts firing correctly

### Post-Deployment
- [ ] No false positive health alerts
- [ ] All services reporting healthy
- [ ] Aggregated health endpoint accurate
- [ ] Response times within targets (<1s individual, <2s aggregated)
- [ ] Team trained on new health check patterns

---

## Success Criteria

1. **All 6 services** have standardized health endpoints using shared library
2. **Aggregated health endpoint** accurately reflects platform status
3. **Health check performance**: <1s individual, <2s aggregated (p95)
4. **Zero false positives** in health check alerts
5. **HIPAA compliance** maintained for CredentialsManager
6. **Backward compatibility** preserved (existing monitoring works)
7. **Documentation** complete with migration guides

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing monitoring | Exact response format matching, comprehensive testing |
| HIPAA violation | Dedicated HIPAA mode, security review |
| Performance degradation | Caching, load testing, timeout configuration |
| Azure Functions cold start | Accept longer first check, document behavior |
| Service discovery drift | Registry validation on startup, config review |

---

## Next Steps After Plan Approval

1. Set up monorepo workspace for `packages/health-checks/`
2. Implement core HealthChecker and type definitions
3. Implement dependency checkers (Database, Cache, Vault)
4. Create Express and Azure Functions adapters
5. Migrate orchestration-service as pilot (validate approach)
6. Continue with remaining services per timeline
7. Build aggregator service in Week 3
8. Deploy and validate in production

---

**Total Effort**: ~15 engineer days (3 weeks, 1 senior engineer)
**Dependencies**: None (self-contained implementation)
**Deployment Order**: Library → orchestration-service → CredentialsManager → RagService → WebAI → Azure Functions → Aggregator
