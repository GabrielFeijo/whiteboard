# ADR-006 — Dual-Entrypoint Architecture in Backend

- **Status:** Accepted
- **Date:** 2026-10-18
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

The backend of the Whiteboard platform manages two operational workloads with fundamentally diverging execution characteristics and scaling requirements:

1. **REST API (`main.api.ts` on port 3001)**:
   - Short-lived, stateless HTTP request/response cycles: registration, authentication, board CRUD, RBAC permission checks, S3 presigned URL generation, and health checks.
   - Best suited for Horizontal Pod Autoscaling (HPA) driven by request volume or CPU utilization, with zero session stickiness.
2. **Collab Server (`main.collab.ts` on port 3002)**:
   - Long-lived, stateful WebSocket connections: maintains in-memory active `Y.Doc` instances per room, coordinates Redis Pub/Sub cluster channels, and validates continuous binary deltas.
   - Best scaled based on connection count and active room memory consumption, independently of HTTP web traffic.

We needed to decide whether to host both workloads in a single Node.js process, separate them into entirely separate repositories, or use a dual-entrypoint design within a single repository.

---

## Considered Alternatives

### Alternative A: Single Monolithic Process (REST and WebSocket together)
- **Cons**:
  - High HTTP traffic spikes saturate the shared event loop, causing jitter and latency spikes in real-time drawing and cursor synchronization.
  - Inability to scale WebSocket replicas independently of REST API instances.
  - Deployments or restarts for API route fixes drop all active collaborative drawing sessions.

### Alternative B: Separate Repositories for REST API and Collab Server
- **Cons**:
  - Duplication of Prisma database models, entities, authentication logic, and shared schemas.
  - Unnecessary overhead maintaining two repositories, two `package.json` files, and duplicate CI pipelines for a cohesive backend domain.

### Alternative C: Single Repository with Dual NestJS Entrypoints (Chosen)
- **Pros**:
  - **Single Codebase**: Reuses Prisma schemas, infrastructure clients (Redis, S3, Config), Zod schemas, and utility modules without duplication.
  - **Independent Binaries & Containers**:
    - `npm run start:api`: Boots only the REST API modules (`src/main.api.ts`).
    - `npm run start:collab`: Boots only the collaboration gateway and real-time synchronization services (`src/main.collab.ts`).
  - **Decoupled Scaling & Deployment**: In Docker Compose and Kubernetes, separate deployments run with customized resource limits and dedicated health probes.
  - **Fault Isolation**: A spike in REST traffic or a failure in an API endpoint cannot crash active collaboration rooms.

---

## Decision

Adopt the **Dual-Entrypoint Architecture** within the `backend/` repository, maintaining strictly isolated execution entrypoints:
- `src/main.api.ts` for the REST API on port 3001.
- `src/main.collab.ts` for the WebSocket Collab Server on port 3002.

---

## Resulting Invariants

1. **Never** add in-memory room state or `Y.Doc` instances to `main.api.ts`.
2. **Never** expose HTTP REST endpoints on `main.collab.ts`.
3. Keep the REST API 100% stateless, and replicate Collab Server rooms across pods via Redis Pub/Sub.
