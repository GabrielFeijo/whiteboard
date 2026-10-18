# ADR-003 — CRDT Storage: PostgreSQL Bytea vs S3 Object Storage

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

The Whiteboard system must store both incremental updates and consolidated snapshots for collaborative rooms. Yjs generates compact binary deltas (`Uint8Array`) that accumulate over prolonged sessions.

To ensure fast room initialization times (< 200ms), these deltas must periodically be consolidated into **compacted binary snapshots**.

We needed to decide where to store incremental updates and snapshots:
1. In the PostgreSQL relational database (`bytea` columns).
2. In object storage (MinIO / S3).

---

## Considered Alternatives

### Alternative A: Snapshots Stored Directly in S3
- **Pros**: Lower storage cost per gigabyte for massive files; fully offloads database storage.
- **Cons**:
  - High latency during room initialization (additional HTTP roundtrips to S3 before acknowledging WebSocket connections).
  - Lack of ACID transactional integrity when creating snapshots and truncating consolidated update records.
  - Eventual consistency issues during concurrent compaction passes.

### Alternative B: Snapshots and Deltas in PostgreSQL (`bytea`) (Chosen)
- **Pros**:
  - **Ultra-low latency**: Compacted binary snapshots are retrieved in a single indexed SQL query in < 5ms.
  - **ACID Transactional Safety**: Updating snapshots and clearing compacted delta logs occurs within a single atomic Prisma transaction.
  - **Operational Simplicity**: PostgreSQL already manages user accounts, memberships, and board metadata.
  - A compacted Yjs snapshot for 5,000 nodes typically ranges from 50KB to 200KB, perfectly suited for `bytea` columns.
- **Cons**:
  - Long-term database storage growth; mitigated by automated periodic compaction.

---

## Decision

Store incremental updates (`doc_update` table) and consolidated snapshots (`snapshot` table) directly in **PostgreSQL as binary `bytea` columns**.

S3/MinIO object storage is reserved exclusively for heavy binary user media assets (images and file attachments).

---

## Consequences

- **Positive**:
  - Extremely fast room startup latency (< 50ms database overhead).
  - Strong transactional guarantees ensure zero state corruption or lost deltas.
- **Negative / Mitigations**:
  - Table growth is monitored via Prometheus metrics; cold archiving can be introduced if storage exceeds hundreds of gigabytes.
