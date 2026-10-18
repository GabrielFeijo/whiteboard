# ADR-006 — Arquitetura de Inicialização Dupla (Dual-Entrypoint) no Backend

- **Status:** Aceita
- **Data:** 2026-10-18
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

O backend do Whiteboard lida com duas cargas de trabalho com características de execução e escalabilidade fundamentalmente divergentes:

1. **API REST (`main.api.ts` na porta 3001)**:
   - Requisições HTTP curtas e sem estado (Stateless): registro, login, CRUD de quadros, controle de permissões RBAC, geração de URLs pré-assinadas S3 e health checks.
   - Ideal para escalonamento horizontal automático (HPA) baseado em requisições/segundo ou CPU, sem necessidade de afinidade de sessão.
2. **Servidor Collab (`main.collab.ts` na porta 3002)**:
   - Conexões WebSocket de longa duração e com estado (Stateful): mantém instâncias `Y.Doc` ativas na memória de cada sala, gerencia subscrições Redis Pub/Sub e valida deltas binários contínuos.
   - Ideal para dimensionamento baseado em contagem de conexões ativas e memória alocada por sala, operando de forma independente do tráfego HTTP.

Precisávamos decidir se manteríamos ambos os serviços no mesmo processo Node.js ou se os separaríamos em microsserviços distintos com codebases separados ou dual-entrypoint.

---

## Alternativas Analisadas

### Alternativa A: Monólito em Processo Único (REST e WebSocket juntos)
- **Desvantagens**:
  - Picos de tráfego HTTP degradam o event-loop compartilhado, introduzindo jitter e latência na sincronização em tempo real de desenho e cursores.
  - Impossibilidade de escalar as réplicas do WebSocket de forma independente do tráfego de API.
  - Reinicializações de deploy de rotas REST derrubam todas as conexões WebSocket ativas de usuários desenhando.

### Alternativa B: Repositórios Separados para API REST e Collab Server
- **Desvantagens**:
  - Duplicação de código de banco de dados (Prisma), entidades, autenticação e contratos.
  - Overhead de manter dois repositórios, dois `package.json` e dois pipelines para o mesmo domínio backend.

### Alternativa C: Repositório Único com Dual-Entrypoint NestJS (Escolhida)
- **Vantagens**:
  - **Codebase único**: Compartilha modelos Prisma, serviços de infraestrutura (Redis, S3, Config), schemas Zod e módulos utilitários sem duplicação.
  - **Binários e containers independentes**:
    - `npm run start:api`: Inicializa apenas os módulos REST (`src/main.api.ts`).
    - `npm run start:collab`: Inicializa apenas o gateway e os serviços de tempo real (`src/main.collab.ts`).
  - **Escala e deploy desacoplados**: No Docker Compose e Kubernetes, são gerados containers distintos com alocações de recursos e health checks próprios.
  - **Isolamento de falhas**: Uma falha ou pico de tráfego na API REST não afeta a estabilidade dos usuários ativos desenhando no Collab Server.

---

## Decisão

Adotar a **Arquitetura Dual-Entrypoint** dentro do repositório `backend/`, com pontos de entrada estritamente separados:
- `src/main.api.ts` para a API REST na porta 3001.
- `src/main.collab.ts` para o servidor WebSocket na porta 3002.

---

## Invariantes Decorrentes

1. **Nunca** adicionar estado de salas ou instâncias em memória de `Y.Doc` ao `main.api.ts`.
2. **Nunca** expor rotas HTTP REST em `main.collab.ts`.
3. Manter a API REST 100% stateless e o Collab Server escalável via Redis Pub/Sub.
