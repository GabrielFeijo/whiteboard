# Epic 0 — Foundation

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T0.1 | INF | Root workspace folder structure, README, `.env.example`, Makefile | S | — | ✅ |
| T0.2 | BE | `git init`, scaffold NestJS (dual entrypoint), strict tsconfig, ESLint/Prettier, husky+commitlint | M | T0.1 | ✅ |
| T0.3 | FE | `git init`, scaffold Next.js App Router + Tailwind, strict TS, ESLint/Prettier, husky+commitlint | M | T0.1 | ✅ |
| T0.4 | BE | `config` with Zod env validation, Prisma/Redis modules, health live/ready probes, Swagger | M | T0.2 | ✅ |
| T0.5 | BE | Complete `prisma/schema.prisma` (`User`, `RefreshToken`, models) + initial migration | M | T0.4 | ✅ |
| T0.6 | BE | `shared/` (schema.ts, protocol.ts, version.ts) + fixtures + contract tests | M | T0.2 | ✅ |
| T0.7 | FE | Synchronized `shared/` + `sync:shared` + contract tests + `gen:api` | M | T0.3, T0.6 | ✅ |
| T0.8 | BE | Multi-stage Dockerfile (api/collab) + `.dockerignore` | M | T0.4 | ✅ |
| T0.9 | FE | Standalone Dockerfile + `/api/health` route + security headers | M | T0.3 | ✅ |
| T0.10 | INF | `docker-compose.yml` + `deps.yml` (postgres, redis, minio, migrate, api, collab, frontend) | M | T0.8, T0.9 | ✅ |
| T0.11 | X | Base CI in each repository (lint, typecheck, test, image build, gitleaks) | M | T0.2, T0.3 | ✅ |
| T0.12 | INF | `docs/architecture.md`, ADR drafts, `docs/tasks/*` | M | T0.1 | ✅ |
