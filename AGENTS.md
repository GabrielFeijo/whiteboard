# Agent Guidelines — Whiteboard

This repository is a real-time collaborative infinite whiteboard powered by CRDT (Yjs), organized into two independent Git submodules.

## Workspace Topology

- `backend/`: NestJS 11 dual-entrypoint service (REST API on port 3001, WebSocket Collab server on port 3002).
- `frontend/`: Next.js 16 (App Router) + React 19 + custom 2D Canvas Engine on port 3000.
- `docs/`: System architecture (`docs/architecture.md`), development guide (`docs/DEVELOPMENT.md`), testing guide (`docs/TESTING.md`), protocol spec (`docs/PROTOCOL.md`), ADRs (`docs/adr/`), and atomic tasks (`docs/tasks/`).
- `docker-compose.deps.yml`: Infrastructure services (PostgreSQL on 5442, Redis on 6379, MinIO on 9000/9001).
- `Makefile`: Unified task execution and verification harness.

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

## Core Agent Rules & Invariants

### 1. Contract Single Source of Truth
- `backend/src/shared/` is the authoritative source for all schemas, data types, and protocol definitions.
- **NEVER edit files in `frontend/src/shared/` directly.**
- When changing shared schemas or protocol:
  1. Modify files in `backend/src/shared/`.
  2. If fixtures changed, regenerate with `npm --prefix backend run fixtures` (or `npx tsx scripts/gen-fixtures.ts`).
  3. Run `make sync-shared` (or `npm --prefix frontend run sync:shared`).
  4. Validate synchronization with `make sync-shared-check`.

### 2. Git Submodules Protocol
- `backend/` and `frontend/` are separate Git repositories.
- **Always make commits inside the modified submodule repository first.**
- Always follow Conventional Commits (`feat(...)`, `fix(...)`, `refactor(...)`, `docs(...)`, etc.) as husky hooks enforce commitlint.
- Update submodule commit pointers in the root repository:
  `git add backend frontend && git commit -m "chore: update submodule pointers"`

### 3. Mandatory Verification Loop
- Before concluding any task, always execute:
  `make check`
- `make check` runs:
  - Contract synchronization verification (`sync:shared:check`).
  - TypeScript type checking in both submodules (`tsc --noEmit`).
  - ESLint in both submodules.
  - Vitest test suites across backend and frontend (189+ tests).
- For rapid iterations during active coding, use `make check-quick`.

### 4. Backlog & Task Execution
- Consult `docs/tasks/00-index.md` and the relevant epic file in `docs/tasks/` for requirements and dependencies.
- Execute tasks atomically with accompanying test coverage.
- Update task status from `⬜` to `✅` upon successful implementation and verification.

---

## Architectural Invariants (Must Never Violate)

| Area | Invariant Rule | Rationale |
| :--- | :--- | :--- |
| **Backend API** | Never hold in-memory board state in `main.api.ts` | The REST API must remain strictly stateless and horizontally scalable behind load balancers. |
| **Collab Server** | Never expose HTTP REST endpoints on `main.collab.ts` | The Collab Server is exclusively a stateful WebSocket server (`ws://localhost:3002/collab`). |
| **CRDT Schema** | Every element MUST contain valid `createdBy`, `id`, `type`, `x`, `y`, `w`, `h`, `z`, and `style` (`fill`, `stroke`, `strokeWidth`, `opacity`) | The Collab Server maintains a Zod shadow doc validator. Incomplete elements will be rejected and dropped. |
| **Transactions** | Always tag local CRDT edits with distinct origin (e.g. `store.localOrigin`) | Prevents infinite loop echoes between local UndoManager, WebSocket updates, and persistence worker. |
| **Canvas Coordinates** | Strictly separate Screen Coordinates (pixels relative to canvas element) from World Coordinates (infinite space) | Rendering and hit testing require explicit transformation through `viewport.screenToWorld()` and `viewport.worldToScreen()`. |
| **Spatial Index** | Any addition, deletion, or geometry modification of an element MUST update `SpatialIndex` (RBush) | Culling and hit-testing rely on the R-Tree index staying synchronized with `repository.getAllElements()`. |
| **File Storage** | Assets (images/files) MUST be uploaded directly via S3 Presigned PUT URLs | Binary asset payloads must never be transferred across the real-time WebSocket collab channel. |

---

## Command Reference

| Command | Action |
| :--- | :--- |
| `make check` | Run full validation (contract check, typecheck, lint, tests) |
| `make check-quick` | Fast validation (contract check, typecheck, tests) |
| `make test` | Run all unit and contract tests across backend and frontend |
| `make typecheck` | Run TypeScript typecheck across both projects |
| `make lint` | Run ESLint across both projects |
| `make sync-shared` | Copy shared contracts from backend to frontend |
| `make sync-shared-check` | Verify shared contract parity |
| `make gen-api` | Generate frontend TypeScript client from backend OpenAPI spec |
| `make deps` | Start infrastructure services (Postgres, Redis, MinIO) |
| `make up` | Build and start all services via Docker Compose |
| `make down` | Stop all Docker containers |
| `make logs` | Tail Docker container logs |

---

## Agent Troubleshooting & Diagnostics

- **Sandbox Read-Only `/index.lock`**:
  If a git command in root fails with `Unable to create '.git/index.lock': Read-only file system`, retry that specific git command outside the sandbox (`BypassSandbox: true`).
- **Prisma Schema Drift**:
  If backend queries fail or type errors occur regarding Prisma models, run `npm --prefix backend run prisma:generate`. If PostgreSQL migrations are needed, run `npm --prefix backend run prisma:migrate`.
- **Contract Drift (`sync:shared:check` fails)**:
  Run `make sync-shared`. Remember: edit in `backend/src/shared/`, never in `frontend/src/shared/`.
- **WebSocket Ticket Rejected / 401**:
  WebSocket handshakes require an ephemeral ticket acquired via `POST /v1/boards/:id/collab-token`. Tickets expire after 30 seconds.
- **Detached HEAD in Submodules**:
  Ensure submodules are on branch `main`: `git -C frontend checkout main && git -C backend checkout main`.

---

## Documentation Index

- **System Architecture**: [`docs/architecture.md`](file:///docs/architecture.md)
- **Local Development Guide**: [`docs/DEVELOPMENT.md`](file:///docs/DEVELOPMENT.md)
- **Testing Handbook**: [`docs/TESTING.md`](file:///docs/TESTING.md)
- **CRDT & Collab Protocol**: [`docs/PROTOCOL.md`](file:///docs/PROTOCOL.md)
- **Contributing & Submodule Guidelines**: [`docs/CONTRIBUTING.md`](file:///docs/CONTRIBUTING.md)
- **Architecture Decisions (ADRs)**: [`docs/adr/`](file:///docs/adr/)
- **Task Backlog**: [`docs/tasks/00-index.md`](file:///docs/tasks/00-index.md)
