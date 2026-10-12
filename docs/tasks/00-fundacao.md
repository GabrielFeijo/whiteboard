# Épico 0 — Fundação (esta execução)

Convenção: `[R]` = repositório (**BE** backend, **FE** frontend, **INF** raiz/infra, **X** ambos). Estimativa: **S** ≤ ½ dia · **M** 1–2 dias · **L** 3–5 dias. Status: ⬜ pendente · ✅ concluída.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T0.1 | INF | Estrutura de pastas raiz, README, `.env.example`, Makefile | S | — | ✅ |
| T0.2 | BE | `git init`, scaffold NestJS (dual entrypoint), tsconfig strict, ESLint/Prettier, husky+commitlint | M | T0.1 | ✅ |
| T0.3 | FE | `git init`, scaffold Next.js App Router + Tailwind, TS strict, ESLint/Prettier, husky+commitlint | M | T0.1 | ✅ |
| T0.4 | BE | `config` com validação Zod de env, módulos Prisma/Redis, health live/ready, Swagger | M | T0.2 | ✅ |
| T0.5 | BE | `prisma/schema.prisma` completo (§10.1 + `User`, `RefreshToken`) + migration inicial | M | T0.4 | ✅ |
| T0.6 | BE | `shared/` (schema.ts, protocol.ts, version.ts) + fixtures + testes de contrato | M | T0.2 | ✅ |
| T0.7 | FE | `shared/` copiado + `sync:shared` + testes de contrato + `gen:api` | M | T0.3, T0.6 | ✅ |
| T0.8 | BE | Dockerfile multi-stage (api/collab) + `.dockerignore` | M | T0.4 | ✅ |
| T0.9 | FE | Dockerfile standalone + rota `/api/health` + CSP/headers base | M | T0.3 | ✅ |
| T0.10 | INF | `docker-compose.yml` + `deps.yml` (postgres, redis, minio, migrate, api, collab, frontend) | M | T0.8, T0.9 | ✅ |
| T0.11 | X | CI base em cada repo (lint, typecheck, test, build imagem, gitleaks) | M | T0.2, T0.3 | ✅ |
| T0.12 | INF | `docs/architecture.md`, ADR-000…005 rascunhos, `docs/tasks/*` | M | T0.1 | ✅ |
