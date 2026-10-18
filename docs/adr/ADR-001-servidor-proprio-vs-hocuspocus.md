# ADR-001 — Custom WebSocket Collab Server vs Hocuspocus

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

To enable real-time multi-user collaboration using CRDTs (Yjs), a WebSocket server is required to:
1. Accept connections and authenticate participants per room.
2. Mediate the exchange of synchronization messages (`y-protocols`) and live awareness/presence states (`y-protocols/awareness`).
3. Enforce operational authority (preventing read-only viewers from injecting modifications and blocking malformed payloads).
4. Persist document state asynchronously without blocking the event loop or increasing WebSocket latency.
5. Scale horizontally across multiple pods via Redis Pub/Sub.

We needed to decide whether to adopt a pre-built server solution such as **Hocuspocus** (by the Tiptap team) or build a native WebSocket server using NestJS and `y-protocols`.

---

## Considered Alternatives

### Alternative A: Hocuspocus Server
- **Pros**: Turnkey solution, established ecosystem with built-in hooks for authentication and persistence.
- **Cons**:
  - Black-box abstractions that limit fine-grained control over authoritative Shadow Document validation.
  - Awkward integration with NestJS 11 dependency injection, Prisma ORM, and custom Zod validation pipes.
  - Less flexibility for implementing custom RBAC rules per binary message frame.

### Alternative B: Native WebSocket Server with NestJS and `y-protocols` (Chosen)
- **Pros**:
  - **Granular Message-Level Control**: Deltas are validated using Zod schemas before being applied to the canonical document.
  - **Authoritative Server Shadow Document**: Server enforces room node limits (max 5,000 elements) and spatial boundary checks.
  - **Native Framework Integration**: Reuses NestJS authentication, guards, Prisma services, Redis clusters, and Prometheus metrics seamlessly.
  - **Full Protocol Ownership**: Zero external proprietary dependencies or restrictive licensing.
- **Cons**:
  - Requires custom implementation of room lifecycles, connection handshakes, and debounced persistence workers.

---

## Decision

Build a **custom collaboration server (`src/main.collab.ts`)** utilizing NestJS WebSocket gateways integrated directly with the official Yjs protocol libraries (`y-protocols` and `lib0`).

---

## Consequences

- **Positive**:
  - Strict security controls with authoritative Shadow Document validation.
  - Instant disconnection of revoked users via Redis ACL channels.
  - Optimized persistence using debounced update batching (`Y.mergeUpdates`).
- **Negative / Mitigations**:
  - Additional codebase to maintain; thoroughly covered by unit and contract test suites (`collab-gateway.spec.ts`).
