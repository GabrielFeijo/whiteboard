# Architecture Decision Records (ADRs) — Whiteboard

This directory documents all significant architectural and technical design decisions made throughout the evolution of the Whiteboard project.

## Index of ADRs

| ADR | Title | Status | Date | Summary |
| :--- | :--- | :--- | :--- | :--- |
| [ADR-000](./ADR-000-dois-repos-e-shared-duplicado.md) | Dois Repositórios Independentes com Shared Sincronizado | Aceita | 2026-10-12 | Git submodules com `backend/src/shared/` como autoridade única e verificação de paridade no CI. |
| [ADR-001](./ADR-001-servidor-proprio-vs-hocuspocus.md) | Servidor WebSocket Próprio vs Hocuspocus | Aceita | 2026-10-12 | Servidor NestJS nativo com `y-protocols`, shadow document autoritativo e controle fino de segurança. |
| [ADR-002](./ADR-002-canvas2d-vs-webgl.md) | Canvas 2D Proprietária vs WebGL / Konva.js | Aceita | 2026-10-12 | Engine de Canvas 2D própria com 3 camadas, indexação espacial RBush (R-Tree) e renderizadores desacoplados. |
| [ADR-003](./ADR-003-snapshots-postgres-vs-s3.md) | Snapshots CRDT em PostgreSQL vs S3 | Aceita | 2026-10-12 | Armazenamento de deltas e snapshots binários compactados no PostgreSQL (`bytea`) para latência < 5ms e transações ACID. |
| [ADR-004](./ADR-004-redis-pubsub-vs-streams.md) | Mensageria em Cluster: Redis Pub/Sub vs Streams | Aceita | 2026-10-12 | Pub/Sub por sala no Redis para replicação inter-pod ultrarrápida e canal ACL para desconexão instantânea. |
| [ADR-005](./ADR-005-e2ee-opcional.md) | Criptografia de Ponta a Ponta (E2EE) Opcional | Proposta (v2) | 2026-10-12 | Chave simétrica no fragmento da URL (`#key=...`) sem conhecimento do servidor para quadros confidenciais. |
| [ADR-006](./ADR-006-dual-entrypoint-nestjs.md) | Arquitetura Dual-Entrypoint no Backend | Aceita | 2026-10-18 | Separação estrita entre API REST stateless (:3001) e Collab Server WebSocket stateful (:3002). |
