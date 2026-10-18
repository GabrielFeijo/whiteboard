# Agent Guidelines — Whiteboard

This repository is a real-time collaborative infinite whiteboard powered by CRDT (Yjs), organized into two independent Git submodules.

## Workspace Topology

- `backend/`: NestJS 11 dual-entrypoint service (REST API on port 3001, WebSocket Collab server on port 3002).
- `frontend/`: Next.js 16 (App Router) + React 19 + custom 2D Canvas Engine on port 3000.
- `docs/`: System architecture (`docs/architecture.md`), ADRs (`docs/adr/`), and atomic tasks (`docs/tasks/`).
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

## Core Agent Rules

### 1. Contract Single Source of Truth
- `backend/src/shared/` is the authoritative source for all schemas, data types, and protocol definitions.
- Never edit files in `frontend/src/shared/` directly.
- When changing shared schemas or protocol:
  1. Modify files in `backend/src/shared/`.
  2. Run `make sync-shared` (or `npm --prefix frontend run sync:shared`).
  3. Validate synchronization with `make sync-shared-check`.

### 2. Git Submodules Protocol
- `backend/` and `frontend/` are separate Git repositories.
- Make commits inside the modified submodule repository first.
- Always follow Conventional Commits (`feat(...)`, `fix(...)`, `refactor(...)`, etc.) as husky hooks enforce commitlint.
- Update submodule commit pointers in the root repository:
  `git add backend frontend && git commit -m "chore: update submodule pointers"`

### 3. Mandatory Verification Loop
- Before concluding any task, always execute:
  `make check`
- `make check` runs:
  - Contract synchronization verification (`sync:shared:check`).
  - TypeScript type checking in both submodules (`tsc --noEmit`).
  - ESLint in both submodules.
  - Vitest test suites across backend and frontend.
- For rapid iterations during active coding, use `make check-quick`.

### 4. Backlog & Task Execution
- Consult `docs/tasks/00-index.md` and the relevant epic file in `docs/tasks/` for requirements and dependencies.
- Execute tasks atomically with accompanying test coverage.
- Update task status from `⬜` to `✅` upon successful implementation and verification.

## Command Reference

| Command | Action |
| :--- | :--- |
| `make check` | Run full validation (contract check, typecheck, lint, tests) |
| `make check-quick` | Fast validation (contract check, typecheck, tests) |
| `make test` | Run all unit and contract tests |
| `make typecheck` | Run TypeScript typecheck across both projects |
| `make lint` | Run ESLint across both projects |
| `make sync-shared` | Copy shared contracts from backend to frontend |
| `make sync-shared-check` | Verify shared contract parity |
| `make gen-api` | Generate frontend TypeScript client from backend OpenAPI spec |
| `make deps` | Start infrastructure services (Postgres, Redis, MinIO) |
| `make up` | Build and start all services via Docker Compose |
| `make down` | Stop all Docker containers |
| `make logs` | Tail Docker container logs |
