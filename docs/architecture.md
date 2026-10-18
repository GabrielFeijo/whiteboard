# System Architecture — Whiteboard

```mermaid
flowchart LR
  subgraph Frontend["Frontend (Next.js 16 + React 19)"]
    UI["Web Studio & 2D Canvas Engine"]
    BFF["Next.js Route Handlers / BFF Proxy"]
    YD["Y.Doc + y-indexeddb"]
    SP["WebSocket Sync Provider"]
  end

  subgraph Backend["Backend (NestJS 11 Dual-Entrypoint)"]
    API["Stateless REST API (/v1/*)"]
    COL["Stateful Collab Server (/collab)"]
    PW["Persistence Service"]
  end

  PG[("PostgreSQL 16")]
  RD[("Redis 7")]
  S3[("MinIO / AWS S3")]

  UI -->|HTTP| BFF
  BFF -->|INTERNAL_API_URL (Docker) / NEXT_PUBLIC_API_URL| API
  SP <-->|WSS + Ticket| COL
  API --> PG
  API --> RD
  API --> S3
  COL --> RD
  COL --> PW --> PG
  UI -->|Presigned PUT (S3_PUBLIC_ENDPOINT)| S3
```

## Core Design Principles

1. **Stateless API & Stateful Collab Isolation**
   - The REST API (`/v1/*`) is completely stateless, scaling horizontally behind load balancers with JWT authentication.
   - The Collab Server is stateful per active board, maintaining in-memory CRDT `Y.Doc` sessions and broadcasting delta updates in real-time.

2. **CRDT (Yjs) Convergence with Authoritative Server Shadow Doc**
   - Conflict-free collaborative editing is guaranteed via Yjs CRDTs.
   - The Collab Server maintains a shadow document validating every incoming delta against structural constraints, bounding boxes, element counts (max 5,000), and permission roles (viewers cannot inject update ops).
   - Snapshot loading uses origin tag `'init'` to avoid circular persistence loops back into `DocUpdate` and Redis Pub/Sub channels.

3. **Two Autonomous Repositories with Strict Single-Source Contract**
   - `backend/` and `frontend/` are isolated Git submodules.
   - `backend/src/shared/` is the single source of truth for protocol constants, element schemas, Zod validators, and error codes.
   - `make sync-shared` synchronizes types to `frontend/src/shared/`, verified via `make sync-shared-check` in CI.

## Networking & Dual-Endpoint Topology

### Container Networking (`INTERNAL_API_URL`)
- In containerized environments (Docker Compose / Kubernetes), server-side Next.js components (RSC and Route Handlers) connect directly via internal DNS:
  - `INTERNAL_API_URL=http://api:3001`
- Client browsers connect via public address:
  - `NEXT_PUBLIC_API_URL=http://localhost:3001`

### S3 Presigned URL Dual Endpoint (`S3_PUBLIC_ENDPOINT`)
- The backend communicates with MinIO/S3 via internal network (`S3_ENDPOINT=http://minio:9000`).
- Generated presigned upload and asset retrieval URLs rewrite the hostname to the publicly accessible browser endpoint (`S3_PUBLIC_ENDPOINT=http://localhost:9000`).
- Images are uploaded directly from the browser to object storage using presigned PUT requests, keeping heavy binary payloads off the WebSocket collaborative channel.

## Security & Concurrency Boundaries

- **Atomic Refresh Token Rotation**: Implemented via atomic SQL update conditions (`WHERE id = :id AND usedAt IS NULL AND revokedAt IS NULL`), eliminating race-condition false-positive family revocations.
- **Network-Scoped Brute-Force Lockout**: Failed authentication tracking is composite-keyed by `(email, ip)`, mitigating distributed denial-of-service against legitimate user accounts.
- **WebSocket Connection Lifecycle Safety**: Guarded gateway connection handlers clean up pending socket contexts and connection counters on unexpected connection termination.
- **SVG XML Sanitization**: All exported attributes and styles undergo XML character escaping to prevent stored XSS attacks.

## Local Ports & Services

| Service | Address | Purpose |
| :--- | :--- | :--- |
| Frontend | `http://localhost:3000` | Web studio & interactive 2D canvas |
| REST API | `http://localhost:3001` | Stateless REST API (`/v1/*`), OpenAPI Swagger (`/v1/docs`) |
| Collab Server | `ws://localhost:3002` | Stateful WebSocket server managing active room docs |
| PostgreSQL | `localhost:5442` (host) -> 5432 | Relational storage via Prisma |
| Redis | `localhost:6379` | Sessions, cache, pub/sub channels |
| MinIO Console | `http://localhost:9001` | S3 dashboard (`minio` / `minio12345`) |
| MinIO API | `http://localhost:9000` | S3 object storage endpoint |
