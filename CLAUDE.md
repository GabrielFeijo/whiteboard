# Claude Code Guidelines — Whiteboard

This repository is a real-time collaborative infinite whiteboard powered by CRDT (Yjs), split into two Git submodules: `backend/` (NestJS 11 dual-entrypoint) and `frontend/` (Next.js 16 + React 19 + Canvas 2D engine).

See [`AGENTS.md`](./AGENTS.md) for full architectural invariants, command reference, and guidelines.

## Quick Commands

- **Full Verification**: `make check` (runs contract check, typecheck, lint, and all 189+ Vitest tests).
- **Fast Verification**: `make check-quick` (skips linter, runs typecheck & tests).
- **Run Unit Tests**: `make test` (or `npm --prefix backend run test` / `npm --prefix frontend run test`).
- **Typecheck**: `make typecheck`.
- **Lint**: `make lint`.
- **Sync Shared Contracts**: `make sync-shared` (then check with `make sync-shared-check`).
- **Start Infrastructure**: `make deps` (PostgreSQL :5442, Redis :6379, MinIO :9000/:9001).
- **Start All Services**: `make up` (or `make dev` for local background services).

## Non-Negotiable Rules

1. **Shared Contract Single Source of Truth**:
   - `backend/src/shared/` is authoritative.
   - **NEVER** edit files inside `frontend/src/shared/` directly.
   - Run `make sync-shared` after modifying `backend/src/shared/`.
2. **Git Submodule Commit Order**:
   - Always commit inside the modified submodule (`backend/` or `frontend/`) first using Conventional Commits (`feat(...)`, `fix(...)`, `docs(...)`, etc.).
   - Then update pointers in root: `git add backend frontend && git commit -m "chore: update submodule pointers"`.
3. **Mandatory Verification**:
   - Always run `make check` before declaring any task finished.
4. **Architectural Separation**:
   - Keep REST API (`main.api.ts` on :3001) strictly stateless.
   - Keep Collab Server (`main.collab.ts` on :3002) dedicated to WebSocket real-time collaboration.
   - Assets are uploaded directly via S3 Presigned URLs, never transmitted over WebSocket.
