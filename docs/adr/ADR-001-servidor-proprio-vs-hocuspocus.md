# ADR-001 — Servidor de Sincronização WebSocket Próprio vs Hocuspocus

- **Status:** Aceita
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

Para habilitar a colaboração multiusuário em tempo real usando CRDT (Yjs), é necessário um servidor WebSocket capaz de:
1. Receber conexões e autenticar participantes por quadro.
2. Intermediar a troca de mensagens de sincronização (`y-protocols`) e consciência de presença (`y-protocols/awareness`).
3. Validar a autoridade das operações (impedir que leitores injetem alterações ou clientes enviem dados corrompidos).
4. Persistir o estado do documento de forma assíncrona sem travar o event loop do WebSocket.
5. Escalar horizontalmente entre múltiplos pods via Redis.

Precisávamos decidir se utilizaríamos um servidor pré-pronto como **Hocuspocus** (da equipe do Tiptap) ou desenvolveríamos um servidor nativo com NestJS e `y-protocols`.

---

## Alternativas Analisadas

### Alternativa A: Hocuspocus Server
- **Vantagens**: Solução pronta, ecossistema estabelecido com suporte nativo a hooks de autenticação e persistência.
- **Desvantagens**:
  - Caixa-preta que limita o controle fino sobre o Shadow Document autoritativo.
  - Dificuldade de integrar de forma nativa com a injeção de dependência do NestJS 11, Prisma e validações Zod customizadas.
  - Menor flexibilidade para implementar regras granulares de RBAC por mensagem binária.

### Alternativa B: Servidor WebSocket Próprio com NestJS e `y-protocols` (Escolhida)
- **Vantagens**:
  - **Controle granular por mensagem**: Validação de deltas no nível de mensagem usando esquemas Zod antes de aplicar no documento canônico.
  - **Shadow Document autoritativo**: O servidor valida a contagem de nós (limite de 5.000 nós) e limites de viewport no backend.
  - **Integração nativa**: Reutiliza serviços de autenticação, Prisma, Redis e observability do NestJS.
  - **Domínio completo do protocolo**: Sem dependências externas proprietárias ou licenciamento restritivo.
- **Desvantagens**:
  - Exige implementação manual do ciclo de vida de salas, handshake e debounce de persistência.

---

## Decisão

Desenvolver o **servidor de colaboração próprio (`src/main.collab.ts`)** utilizando o gateway WebSocket do NestJS integrado diretamente às bibliotecas oficiais de protocolo do Yjs (`y-protocols` e `lib0`).

---

## Consequências

- **Positivas**:
  - Controle estrito de segurança e validação com Shadow Document.
  - Desconexão instantânea de usuários revogados via Redis ACL channel.
  - Persistência otimizada com worker debounced (`Y.mergeUpdates`).
- **Negativas / Mitigações**:
  - Código adicional no backend; mitigado por testes unitários e de integração abrangentes (`collab-gateway.spec.ts`).
