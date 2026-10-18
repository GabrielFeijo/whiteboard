# ADR-004 — Mensageria em Cluster: Redis Pub/Sub vs Redis Streams

- **Status:** Aceita
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

Para escalar o servidor de colaboração (`main.collab.ts`) horizontalmente em múltiplos pods ou réplicas, os usuários conectados ao pod A que alteram um quadro precisam que suas alterações sejam propagadas instantaneamente para os usuários conectados ao pod B no mesmo quadro.

Além disso, é necessário um mecanismo para desautenticar ou desconectar imediatamente usuários cujas permissões tenham sido revogadas no banco de dados.

Precisávamos decidir o mecanismo de replicação inter-pod no Redis:
1. Redis Pub/Sub tradicional por sala.
2. Redis Streams com grupos de consumidores e retenção de log.

---

## Alternativas Analisadas

### Alternativa A: Redis Streams
- **Vantagens**: Persistência no Redis, confirmação de entrega (ACK) e capacidade de replay de mensagens após desconexões breves.
- **Desvantagens**:
  - Complexidade acrescida de gerenciamento de offsets, dead-letter queues e expiração/trim de streams para milhares de salas ativas.
  - Sobrecarga de memória desnecessária no Redis, uma vez que o histórico canônico e durável já é mantido no PostgreSQL.

### Alternativa B: Redis Pub/Sub Efêmero por Sala (Escolhida)
- **Vantagens**:
  - **Latência ultrabaixa** (< 1ms): Distribuição broadcast instantânea na memória do Redis sem escrita em disco.
  - **Zero retenção de memória**: Mensagens são consumidas instantaneamente pelos pods inscritos e não acumulam volume no Redis.
  - **Simplicidade**: Topologia de canal direto:
    - `board:{boardId}:updates`: Propaga deltas binários para todos os pods com sessões ativas do quadro.
    - `board:{boardId}:acl`: Propaga eventos de revogação de acesso e expulsão imediata de sockets.
  - O protocolo CRDT (Yjs) já é resiliente a perdas de pacotes durante reconexões através do handshake `SyncStep1`/`SyncStep2` contra o servidor canônico.
- **Desvantagens**:
  - Mensagens são perdidas se um pod estiver temporariamente sem conexão com o Redis. Mitigado pela reconciliação de estado nativa do Yjs no handshake do cliente.

---

## Decisão

Adotar **Redis Pub/Sub** com canais dedicados por quadro (`board:{id}:updates` e `board:{id}:acl`) para comunicação em tempo real entre pods do Collab Server.

---

## Consequências

- **Positivas**:
  - Escalabilidade horizontal linear do Collab Server.
  - Consumo mínimo de memória e CPU no Redis.
  - Resposta instantânea de segurança para alterações de permissão e exclusão de membros.
- **Negativas / Mitigações**:
  - O Redis Pub/Sub não garante durabilidade caso todos os pods caiam; a persistência no PostgreSQL garante a recuperação completa do estado canônico.
