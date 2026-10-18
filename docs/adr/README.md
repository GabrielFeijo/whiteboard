# Architecture Decision Records (ADRs) — Whiteboard

This directory documents all significant architectural and technical design decisions made throughout the lifecycle of the Whiteboard project.

## Index of ADRs

| ADR | Title | Status | Date | Summary |
| :--- | :--- | :--- | :--- | :--- |
| [ADR-000](./ADR-000-dois-repos-e-shared-duplicado.md) | Two Independent Repositories with Synchronized Shared Contract | Accepted | 2026-10-12 | Git submodules with `backend/src/shared/` as single source of truth and automated parity verification in CI. |
| [ADR-001](./ADR-001-servidor-proprio-vs-hocuspocus.md) | Custom WebSocket Collab Server vs Hocuspocus | Accepted | 2026-10-12 | Native NestJS server using `y-protocols`, authoritative Shadow Document validation, and granular security control. |
| [ADR-002](./ADR-002-canvas2d-vs-webgl.md) | Proprietary 2D Canvas Engine vs WebGL / Konva.js | Accepted | 2026-10-12 | Custom 3-layer 2D Canvas engine with RBush (R-Tree) spatial indexing and decoupled renderers. |
| [ADR-003](./ADR-003-snapshots-postgres-vs-s3.md) | CRDT Snapshots in PostgreSQL vs S3 | Accepted | 2026-10-12 | Compact binary delta and snapshot storage in PostgreSQL (`bytea`) for < 5ms room load latency and ACID safety. |
| [ADR-004](./ADR-004-redis-pubsub-vs-streams.md) | Cluster Messaging: Redis Pub/Sub vs Streams | Accepted | 2026-10-12 | Per-room Redis Pub/Sub for sub-millisecond inter-pod delta replication and instant ACL revocation kicks. |
| [ADR-005](./ADR-005-e2ee-opcional.md) | Optional End-to-End Encryption (E2EE) per Board | Proposed (v2) | 2026-10-12 | Symmetric encryption key stored in URL hash fragment (`#key=...`) with zero server knowledge for confidential boards. |
| [ADR-006](./ADR-006-dual-entrypoint-nestjs.md) | Dual-Entrypoint Backend Architecture | Accepted | 2026-10-18 | Strict separation between stateless REST API (:3001) and stateful Collab WebSocket server (:3002). |
