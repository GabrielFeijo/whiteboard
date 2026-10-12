# Whiteboard Colaborativo em Tempo Real

Quadro branco infinito multiusuário com sincronização por CRDT (Yjs). Especificação completa em
[`Whiteboard Colaborativo em Tempo Real — Documentação Funcional e Técnica.md`](./Whiteboard%20Colaborativo%20em%20Tempo%20Real%20%E2%80%94%20Documenta%C3%A7%C3%A3o%20Funcional%20e%20T%C3%A9cnica.md).

## Estrutura (dois repositórios Git independentes)

| Pasta | Conteúdo | Git |
| --- | --- | --- |
| [`backend/`](./backend) | NestJS: API REST + Collab Server (WebSocket) | repo próprio |
| [`frontend/`](./frontend) | Next.js + Canvas Engine | repo próprio |
| raiz | docker-compose de dev, documentação, backlog | **sem git** |

Contrato entre os repos: `backend/src/shared` (fonte da verdade) → cópia em `frontend/src/shared`
por `npm run sync:shared`. Veja [`docs/architecture.md`](./docs/architecture.md) e
[`docs/adr/`](./docs/adr).

## Subir tudo com Docker
```bash
make env     # cria .env a partir de .env.example
make up      # postgres, redis, minio, migrate, api, collab, frontend
make ps
```
| Serviço | URL |
| --- | --- |
| Frontend | http://localhost:3000 |
| API (Swagger) | http://localhost:3001/v1/docs |
| Collab (WS) | ws://localhost:3002 |
| MinIO console | http://localhost:9001 (`minio` / `minio12345`) |
| Postgres | `localhost:5442` (`wb` / `wb`) |

## Desenvolvimento com hot reload
```bash
make deps                              # só Postgres, Redis e MinIO
(cd backend  && npm ci && npx prisma migrate dev && npm run start:api:dev)
(cd backend  && npm run start:collab:dev)
(cd frontend && npm ci && npm run dev)
```

## Backlog
Tasks completas por épico em [`docs/tasks/`](./docs/tasks/00-index.md).
