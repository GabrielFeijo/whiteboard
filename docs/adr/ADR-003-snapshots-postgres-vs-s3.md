# ADR-003 — Snapshots em Postgres vs S3

- **Status:** Rascunho
- **Data:** 2026-10-12

## Decisão

Iniciar com snapshots em `bytea` no PostgreSQL. Migrar para S3 se o tamanho/custo exigir.
