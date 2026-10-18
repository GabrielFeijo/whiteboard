# ADR-004 — Inter-Pod Cluster Replication: Redis Pub/Sub vs Redis Streams

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

To scale the collaboration server (`main.collab.ts`) horizontally across multiple pods, changes made by users connected to Pod A must be broadcast instantaneously to users connected to Pod B on the same board.

Additionally, an immediate mechanism is required to disconnect or revoke access for users whose permissions are revoked in the database.

We needed to decide on the inter-pod message broker mechanism in Redis:
1. Standard Redis Pub/Sub channels per room.
2. Redis Streams with consumer groups and persistent log offsets.

---

## Considered Alternatives

### Alternative A: Redis Streams
- **Pros**: Persistent logs within Redis, consumer acknowledgment (ACK), and message replay capabilities for transient network drops.
- **Cons**:
  - Operational overhead managing stream trimming, consumer offsets, and dead-letter queues across thousands of active rooms.
  - Unnecessary Redis memory consumption, as durable long-term storage is already guaranteed by PostgreSQL.

### Alternative B: Ephemeral Redis Pub/Sub per Room (Chosen)
- **Pros**:
  - **Sub-millisecond Latency**: Pure in-memory distribution without disk write overhead.
  - **Zero Memory Accumulation**: Messages are consumed instantaneously by subscribed pods and automatically evicted.
  - **Clean Topology**:
    - `board:{boardId}:updates`: Broadcasts binary Yjs deltas across pods hosting active sessions of the board.
    - `board:{boardId}:acl`: Propagates immediate member revocation events and kicks sockets across all pods.
  - The CRDT protocol naturally handles packet loss or reconnections through its native `SyncStep1` / `SyncStep2` state vector exchange against the server canonical doc.
- **Cons**:
  - Messages are lost if a pod is temporarily disconnected from Redis during a broadcast. Mitigated by client-side CRDT state reconciliation upon reconnection.

---

## Decision

Adopt **Redis Pub/Sub** with dedicated per-board channels (`board:{id}:updates` and `board:{id}:acl`) for real-time inter-pod collaboration server communication.

---

## Consequences

- **Positive**:
  - Linear horizontal scalability for the Collab Server.
  - Minimal CPU and memory overhead on Redis.
  - Immediate security response for access revocation and member removals.
- **Negative / Mitigations**:
  - Pub/Sub does not guarantee durable delivery; full state recovery is provided by PostgreSQL snapshots.
