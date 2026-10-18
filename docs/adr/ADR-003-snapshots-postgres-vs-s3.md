# ADR-003 — Armazenamento de Snapshots CRDT: PostgreSQL vs S3

- **Status:** Aceita
- **Data:** 2026-10-12
- **Decisores:** Time de Arquitetura Whiteboard

---

## Contexto & Problema

O Whiteboard precisa armazenar o histórico e o estado consolidado dos quadros colaborativos. O Yjs produz deltas binários (`Uint8Array`) incrementais que, com o tempo, acumulam dezenas de milhares de operações.

Para garantir tempos de inicialização de sala rápidos (< 200ms), é necessário consolidar periodicamente esses deltas em **snapshots binários compactados**.

Precisávamos decidir onde armazenar os snapshots binários e as atualizações incrementais:
1. No banco relacional PostgreSQL (`bytea`).
2. Em armazenamento de objetos (MinIO / S3).

---

## Alternativas Analisadas

### Alternativa A: Snapshots Direto no S3
- **Vantagens**: Custo de armazenamento menor por gigabyte para arquivos gigantes; desacoplamento total do banco de dados.
- **Desvantagens**:
  - Latência de leitura no handshake inicial da sala (latência de rede HTTP para o S3 adicional antes de responder ao WebSocket).
  - Impossibilidade de realizar transações atômicas ACID vinculando a criação de snapshots com a deleção/consolidação de linhas na tabela de deltas.
  - Complexidade de consistência eventual em operações concorrentes.

### Alternativa B: Snapshots em PostgreSQL (`bytea`) com Snapshots Compactados (Escolhida)
- **Vantagens**:
  - **Latência ultrabaixa**: O snapshot compactado é recuperado em uma única query SQL com índice por `boardId`, em menos de 5ms.
  - **Atomicidade e Integridade Transacional**: A gravação do novo snapshot e o truncate de deltas consolidados são realizados em uma transação ACID com Prisma.
  - **Simplicidade operacional**: O PostgreSQL já armazena usuários, membros e metadados de quadros.
  - O volume de um snapshot Yjs de 5.000 nós compactado fica em torno de 50KB a 200KB, perfeitamente comportado em colunas `bytea`.
- **Desvantagens**:
  - Crescimento do banco de dados em longo prazo; mitigado por compaction periódica.

---

## Decisão

Armazenar as atualizações incrementais (`BoardUpdate`) e os snapshots consolidados (`BoardSnapshot`) diretamente no **PostgreSQL em colunas binárias `bytea`**.

O armazenamento S3 (MinIO) é reservado exclusivamente para arquivos binários pesados de mídia (imagens e assets anexados aos quadros).

---

## Consequências

- **Positivas**:
  - Abertura de salas extremamente rápida (< 50ms de overhead de banco de dados).
  - Transações atômicas garantem que nunca haja estado corrompido ou perda de deltas.
- **Negativas / Mitigações**:
  - Monitorar o tamanho da tabela `BoardSnapshot` via métricas Prometheus; implementar arquivamento frio se o volume ultrapassar centenas de gigabytes.
