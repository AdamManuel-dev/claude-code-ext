# Credential Migration Plan: MongoDB → PostgreSQL

## Problem Summary
- **Dashboard** shows credentials from MongoDB (via Azure Functions)
- **Orchestration Service** looks up credentials in PostgreSQL
- **Result**: Credential ID mismatch → workflow execution fails with "Credential not found"
- **Example**: MongoDB ID `691a87c98990cc6d7a8b3e30` doesn't exist in PostgreSQL

## Solution Overview
1. **Revert** my premature changes to `useCredentials.ts`
2. **Migrate** ALL MongoDB credentials to PostgreSQL with encryption
3. **Update** orchestration service to fetch secrets from PostgreSQL (not Azure Functions)
4. **Switch** Dashboard to use orchestration service API

## User Requirements
- ✅ Generate **new UUIDs** for migrated credentials
- ✅ Store encrypted secrets in **PostgreSQL** (decrypt locally)
- ✅ Keep MongoDB as **backup** (stop using it)

---

## Phase 1: Revert Premature Changes

### 1.1 Revert useCredentials.ts
**File**: `Dashboard/shared/hooks/useCredentials.ts`

Restore the original Azure Functions endpoint (temporary until migration complete):
```typescript
// Line 159: Revert to Azure Functions
const apiBase = useRef<string>(
  import.meta.env.VITE_AZURE_FUNCTIONS_URL || "http://localhost:7071/api",
);

// Line 180: Revert endpoint path
const endpoint = `/credentials-simple${queryString ? `?${queryString}` : ""}`;
```

**Keep**: Prisma schema changes (`payerName`, `portalUrl`, `hasTOTP` fields) - these are correct.

---

## Phase 2: Create Migration Script

### 2.1 New Script
**Create**: `orchestration-service/scripts/migrate-mongodb-credentials-full.ts`

**Functionality**:
1. Connect to MongoDB (`tahoma-dashboard.credentials` collection)
2. Read ALL credentials
3. For each credential:
   - Generate new UUID
   - Encrypt password using `EncryptionService` (AES-256-GCM)
   - Encrypt TOTP secret if present (store as JSON blob)
   - Map `clerkOrgId` → `organizationId`
   - Map `username` → `name`
   - Copy: `payerName`, `portalUrl`, `hasTOTP`, `modifiers`, `payers`, `location`
4. Insert into PostgreSQL `Credential` table
5. Output ID mapping file: `{mongoId, postgresId, username, payerName, organizationId}`

### 2.2 Encrypted Value Format
Store password + TOTP as JSON in `encryptedValue`:
```json
{
  "password": "actualPassword123",
  "totpSecret": "JBSWY3DPEHPK3PXP"
}
```

### 2.3 Field Mapping
| MongoDB Field | PostgreSQL Field | Notes |
|--------------|------------------|-------|
| `id` | (new UUID) | Generate fresh |
| `username` | `name` | Login email/username |
| `password` | `encryptedValue` | AES-256-GCM encrypted JSON |
| `totpSecret` | (in encryptedValue) | Part of encrypted JSON |
| `hasTOTP` | `hasTOTP` | Boolean |
| `payerName` | `payerName` | Direct copy |
| `portalUrl` | `portalUrl` | Direct copy |
| `clerkOrgId` | `organizationId` | Direct copy (org_XXXXX format) |
| `modifiers` | `modifiers` | JSON array |
| `payers` | `payers` | JSON array |
| `location` | `location` | US state code |

---

## Phase 3: Update CredentialFetcherService

### 3.1 Change Data Source
**File**: `orchestration-service/src/services/credentials/credential-fetcher.service.ts`

**Current** (line 63): Fetches from Azure Functions
```typescript
const url = `${this.baseUrl}/api/credentials-secrets/${credentialId}`;
```

**New**: Fetch from PostgreSQL via CredentialService
```typescript
async fetchCredentialSecrets(
  credentialId: string,
  organizationId: string
): Promise<CredentialSecrets> {
  // Get credential from PostgreSQL
  const credential = await this.credentialService.get(credentialId, organizationId, 'system');

  // Decrypt the value (contains password + totpSecret as JSON)
  const decryptedJson = await this.credentialService.getValue(credentialId, organizationId, 'system');
  const secrets = JSON.parse(decryptedJson);

  return {
    username: credential.name,  // PostgreSQL 'name' = login username
    password: secrets.password,
    totpSecret: secrets.totpSecret,
    hasTOTP: credential.hasTOTP || false,
  };
}
```

### 3.2 Update Constructor
Add `PrismaClient` dependency to create `CredentialService` instance.

### 3.3 Update Callers
**File**: `orchestration-service/src/services/execution/workflow-executor.ts`

Update `loadClientCredentials()` to pass `organizationId`:
```typescript
// Line ~380
const secrets = await this.credentialFetcherService.fetchCredentialSecrets(
  credentialId,
  executionOptions.organizationId  // NEW: pass org ID
);
```

---

## Phase 4: Update Dashboard (Final Switch)

### 4.1 Switch to Orchestration Service
**File**: `Dashboard/shared/hooks/useCredentials.ts`

After migration verified, switch back to orchestration service:
```typescript
const apiBase = useRef<string>(
  (import.meta.env.VITE_ORCHESTRATION_API_URL || "http://localhost:3000").trim(),
);
```

### 4.2 Endpoint Mapping
| Operation | New Endpoint |
|-----------|-------------|
| List | `GET /api/v1/credentials` |
| Get | `GET /api/v1/credentials/:id` |
| Create | `POST /api/v1/credentials` |
| Update | `PUT /api/v1/credentials/:id` |
| Delete | `DELETE /api/v1/credentials/:id` |

---

## Files to Modify

| File | Action | Priority |
|------|--------|----------|
| `Dashboard/shared/hooks/useCredentials.ts` | Revert (Phase 1), then switch (Phase 4) | P0 |
| `orchestration-service/scripts/migrate-mongodb-credentials-full.ts` | Create new | P0 |
| `orchestration-service/src/services/credentials/credential-fetcher.service.ts` | Modify to use PostgreSQL | P0 |
| `orchestration-service/src/services/credentials/credential.service.ts` | Add method to get decrypted secrets | P1 |
| `orchestration-service/src/services/execution/workflow-executor.ts` | Pass organizationId to fetcher | P1 |

---

## Execution Order

```
Step 1: Revert useCredentials.ts (restore Azure Functions temporarily)
Step 2: Deploy Dashboard fix → verify credentials display again
Step 3: Create migration script
Step 4: Run migration (dry-run first, then production)
Step 5: Verify migrated credentials can be decrypted
Step 6: Update CredentialFetcherService to use PostgreSQL
Step 7: Test workflow execution with PostgreSQL credentials
Step 8: Switch Dashboard to orchestration service API
Step 9: End-to-end test
Step 10: Mark MongoDB credentials as backup (read-only)
```

---

## Rollback Plan

If anything fails:
1. MongoDB credentials are untouched (backup)
2. Revert `useCredentials.ts` to Azure Functions
3. Revert `CredentialFetcherService` to Azure Functions
4. Delete migrated PostgreSQL credentials

---

## Environment Variables

```bash
# Required for migration
MONGODB_URI=mongodb://...
DATABASE_URL=postgresql://...
ENCRYPTION_KEY=<64-char-hex>  # or AZURE_KEY_VAULT_URL
```
