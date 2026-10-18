# Guia de Desenvolvimento Agêntico — Whiteboard

Este documento estabelece as regras, convenções, modelo mental e comandos essenciais para agentes de IA operando no repositório **Whiteboard**. Siga rigorosamente estas instruções para garantir autonomia segura, consistência e evitar regressões.

---

## 🗺️ Visão Geral e Topologia do Workspace

O projeto é um quadro branco infinito colaborativo em tempo real baseado em **CRDT (Yjs)**, dividido em dois repositórios Git gerenciados como **Git Submodules**:

```text
whiteboard/ (Repositório Raiz / Orquestrador)
├── backend/                  # Git Submodule: API REST + Collab WebSocket Server (NestJS 11)
├── frontend/                 # Git Submodule: Aplicação Web + Engine Canvas 2D (Next.js 16 + React 19)
├── docs/                     # Backlog atômico (docs/tasks/), ADRs (docs/adr/) e arquitetura
├── docker-compose.yml        # Orquestração completa local (Apps + Infraestrutura)
├── docker-compose.deps.yml   # Apenas serviços de infraestrutura (Postgres, Redis, MinIO)
└── Makefile                  # Comandos unificados de build, teste e verificação
```

### Serviços e Portas Locais
| Serviço | Porta | Descrição |
| :--- | :--- | :--- |
| **Frontend** | `3000` | Next.js 16 App Router + Canvas Engine |
| **API REST** | `3001` | NestJS REST API (`/v1/*`), OpenAPI Swagger em `/v1/docs` |
| **Collab Server** | `3002` | NestJS WebSocket Server por sala (`ws://localhost:3002`) |
| **PostgreSQL** | `5442` (host) → `5432` | Banco relacional persistido via Prisma |
| **Redis** | `6379` | Cache, controle de sessões e canais pub/sub |
| **MinIO Console** | `9001` | Dashboard S3 (usuário/senha padrão: `minio` / `minio12345`) |
| **MinIO API** | `9000` | Object Storage compatível com S3 (bucket: `whiteboard-assets`) |

---

## ⚡ Regras de Ouro para Agentes

### 1. Fonte da Verdade dos Contratos (`shared/`)
- **Regra:** O diretório `backend/src/shared/` é a **única fonte da verdade** para schemas Zod, tipos de dados e protocolo de WebSocket (conforme [ADR-000](docs/adr/ADR-000-dois-repos-e-shared-duplicado.md)).
- **Nunca edite diretamente** os arquivos dentro de `frontend/src/shared/`.
- Ao alterar ou estender contratos:
  1. Edite `backend/src/shared/` (ex: `schema.ts`, `protocol.ts` ou `version.ts`).
  2. Execute `make sync-shared` (ou `npm --prefix frontend run sync:shared`).
  3. Valide a sincronização com `make sync-shared:check`.

### 2. Fluxo com Git Submodules
- `backend/` e `frontend/` são repositórios Git independentes.
- Ao fazer alterações que afetem os subprojetos:
  1. Faça o commit dentro do submodule correspondente (`backend/` ou `frontend/`).
  2. Use sempre commits convencionais (`feat(...)`, `fix(...)`, `refactor(...)`, etc.), pois há hooks de `husky` e `commitlint` ativos.
  3. No repositório raiz (`whiteboard/`), faça o commit atualizando o ponteiro dos submódulos afetados:
     ```bash
     git add backend frontend
     git commit -m "chore: update submodule pointers"
     ```

### 3. Ciclo de Verificação Obrigatório (Feedback Loop)
- **Antes de concluir qualquer tarefa ou dar resposta final ao usuário**, execute:
  ```bash
  make check
  ```
  Este comando executa em lote:
  - Verificação estática de tipos (`tsc --noEmit`) no backend e frontend.
  - Linters (`eslint`) no backend e frontend.
  - Testes unitários e de contrato (`vitest run`) no backend e frontend.
  - Checagem de integridade de sincronização dos contratos (`sync:shared:check`).

### 4. Backlog e Ciclo de Vida de Tarefas
- Consulte [`docs/tasks/00-index.md`](docs/tasks/00-index.md) e o arquivo de épico correspondente em `docs/tasks/` para entender requisitos e dependências.
- Siga a abordagem atômica: uma tarefa por ciclo, mantendo cobertura de testes correspondente.
- Atualize o status na tabela do documento de tasks de `⬜` para `✅` ao concluir a implementação e testes.

---

## 🛠️ Comandos Mais Usados

| Ação | Comando |
| :--- | :--- |
| **Verificação Completa** | `make check` |
| **Verificação Rápida (sem lint)** | `make check:quick` |
| **Testes Unitários Backend + Frontend** | `make test` |
| **Sincronizar Contratos** | `make sync-shared` |
| **Conferir Drift de Contratos** | `make sync-shared:check` |
| **Subir Infraestrutura Local** | `make deps` |
| **Subir Todos os Containers** | `make up` |
| **Ver Logs da Infraestrutura** | `make logs` |
| **Gerar Cliente TypeScript OpenAPI** | `make gen-api` |

---

## 🧠 Arquitetura Técnica em Poucas Linhas

1. **Separação Stateless vs Stateful:**
   - A API REST (`main.api.ts`) é totalmente stateless. Trata autenticação, gerenciamento de quadros, permissões RBAC e geração de URLs assinadas para S3.
   - O Collab Server (`main.collab.ts`) é stateful em memória por sala de quadro. Mantém instâncias de `Y.Doc` ativas enquanto houver conexões, recebe updates binários do Yjs, valida quotas/schemas e descarrega snapshots no Postgres periodicamente.
2. **CRDT no Frontend:**
   - O canvas aplica transformações otimistas no cliente usando um `Y.Doc` local e persistência em IndexedDB (`y-indexeddb`), enviando deltas compactados via WebSocket.
   - O servidor atua como autoridade para broadcasting e validação.
3. **Desacoplamento e Segurança:**
   - Tokens JWT curtos (15 min) + Refresh tokens em cookie HttpOnly com rotação opaca.
   - Handshake do WebSocket usa tickets efêmeros de uso único (`wsTicket`) obtidos via endpoint REST seguro.
