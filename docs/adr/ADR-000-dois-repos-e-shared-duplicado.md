# ADR-000 — Dois Repositórios Independentes com Contrato Compartilhado Sincronizado

- **Status:** Aceita
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

O projeto Whiteboard é composto por dois subsistemas com ciclos de vida, runtimes e ecossistemas distintos:
1. **Backend**: Serviço NestJS 11 em Node.js com dual-entrypoint (API REST + Collab WebSocket), persistência com Prisma/PostgreSQL, cache Redis e armazenamento MinIO/S3.
2. **Frontend**: Aplicação web com Next.js 16 (App Router), React 19, Tailwind CSS 4 e uma engine de canvas 2D proprietária.

Ambos os projetos compartilham estruturas de dados críticas: esquemas de elementos (`ElementData`), mensagens de protocolo Yjs (`SyncStep1`, `SyncStep2`, `SyncUpdate`, `Awareness`), dicionários de internacionalização (`i18n`) e códigos de erro.

Precisávamos decidir a topologia de repositório e o mecanismo de compartilhamento de código.

---

## Alternativas Analisadas

### Alternativa A: Monorepo Unificado com Turborepo / Nx e Pacote npm `@whiteboard/shared`
- **Vantagens**: Fonte única de código sem replicação de arquivos; compilação compartilhada.
- **Desvantagens**:
  - Complexidade de setup de CI/CD para Next.js 16 + React 19 e NestJS 11 juntos.
  - Conflitos de dependências e versões de TypeScript/Node/Tailwind.
  - Exige tooling monorepo pesado e overhead de build/package.

### Alternativa B: Dois Repositórios Git Independentes (Submódulos) com Sincronização de Contratos (Escolhida)
- **Vantagens**:
  - Separação total de concerns: cada repositório tem seu próprio `package.json`, TypeScript, ESLint, Vitest e pipeline de deploy.
  - Isolamento de falhas: problemas de compilação ou dependências em um repo não afetam o outro.
  - `backend/src/shared/` atua como **fonte única da verdade**, replicado para `frontend/src/shared/` via script determinístico (`npm run sync:shared` / `make sync-shared`).
  - Verificação automatizada de paridade no CI via `make sync-shared-check` e testes de contrato binários.
- **Desvantagens**:
  - Risco de drift caso um desenvolvedor edite o frontend sem sincronizar o backend. Mitigado por testes de contrato e checks no CI.

---

## Decisão

Adotar **dois repositórios Git independentes estruturados como submódulos** (`backend/` e `frontend/`) sob um repositório orquestrador raiz.

A pasta `backend/src/shared/` é a **autoridade absoluta** para todos os esquemas Zod, interfaces TypeScript e constantes de protocolo. O frontend **nunca** edita `frontend/src/shared/` diretamente. A sincronização é feita pelo script `scripts/sync-shared.mjs`, garantida por testes de contrato (`shared-contract.spec.ts`) e travada no CI pelo comando `make sync-shared-check`.

---

## Consequências

- **Positivas**:
  - Deploy e escalabilidade independentes para backend e frontend.
  - CI extremamente rápido em ambos os repositórios (< 3 segundos para 189 testes).
  - Sem necessidade de gerenciar registry npm privado para pacotes internos.
- **Negativas / Mitigações**:
  - Desenvolvedores precisam lembrar de rodar `make sync-shared`. Mitigado pela regra de pre-commit e verificação mandatória no CI.
