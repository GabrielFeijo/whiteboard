# ADR-000 — Two Independent Repositories with Synchronized Shared Contract

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

The Whiteboard platform consists of two subsystems with distinct execution lifecycles, runtimes, and ecosystems:
1. **Backend**: NestJS 11 service in Node.js featuring dual entrypoints (REST API on port 3001 and WebSocket Collab Server on port 3002), PostgreSQL persistence via Prisma, Redis caching, and MinIO/S3 object storage.
2. **Frontend**: Web studio built with Next.js 16 (App Router), React 19, Tailwind CSS 4, and a custom 2D Canvas Engine on port 3000.

Both subsystems share critical data structures: element schemas (`ElementData`), Yjs protocol messages (`SyncStep1`, `SyncStep2`, `SyncUpdate`, `Awareness`), internationalization dictionaries (`i18n`), and standard error codes.

We needed to decide on repository topology and the contract sharing mechanism between backend and frontend.

---

## Considered Alternatives

### Alternative A: Unified Monorepo with Turborepo / Nx and `@whiteboard/shared` npm Package
- **Pros**: Single codebase without duplicated files; shared build cache.
- **Cons**:
  - Significant CI/CD setup overhead combining Next.js 16 + React 19 and NestJS 11 in one pipeline.
  - Dependency version conflicts across Node, TypeScript, and Tailwind configurations.
  - Heavy tooling complexity and packaging overhead for simple type definitions.

### Alternative B: Two Independent Git Repositories (Submodules) with Synchronized Contracts (Chosen)
- **Pros**:
  - **Complete separation of concerns**: Each repository maintains its own `package.json`, TypeScript configuration, ESLint rules, Vitest runner, and deployment pipeline.
  - **Fault isolation**: Build or dependency issues in one service never break the other.
  - `backend/src/shared/` acts as the **authoritative single source of truth**, replicated to `frontend/src/shared/` via a deterministic script (`npm run sync:shared` / `make sync-shared`).
  - Automated parity verification in CI via `make sync-shared-check` and binary contract test suites.
- **Cons**:
  - Risk of contract drift if an engineer attempts to edit the frontend directly without syncing backend. Mitigated by CI guard checks and contract tests.

---

## Decision

Adopt **two independent Git repositories managed as Git submodules** (`backend/` and `frontend/`) orchestrated by a root repository.

The `backend/src/shared/` directory is the **authoritative single source of truth** for all Zod schemas, TypeScript interfaces, and protocol constants. The frontend **never** edits `frontend/src/shared/` directly. Synchronization is performed by `scripts/sync-shared.mjs`, verified by binary contract tests (`shared-contract.spec.ts`), and enforced in CI via `make sync-shared-check`.

---

## Consequences

- **Positive**:
  - Independent deployments and horizontal scaling for both backend and frontend.
  - Extremely fast CI pipelines in both repositories (< 3 seconds for 189 tests).
  - No need to maintain a private npm registry for internal contracts.
- **Negative / Mitigations**:
  - Developers and agents must remember to run `make sync-shared`. Enforced automatically via pre-commit hooks and CI gate checks.
