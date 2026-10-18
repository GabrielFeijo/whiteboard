# ADR-005 — Optional End-to-End Encryption (E2EE) per Board

- **Status:** Proposed (Scheduled for v2 / Epic 11)
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

For enterprise environments with strict confidentiality and regulatory compliance requirements (e.g., healthcare data, trade secrets, sensitive legal documents), users may require that even the server hosting the Whiteboard service cannot inspect or decrypt board drawings or text.

We needed to establish the feasibility and architecture for supporting optional End-to-End Encryption (E2EE) without breaking CRDT convergence.

---

## Considered Alternatives

### Alternative A: Mandatory Global E2EE for All Boards
- **Cons**:
  - Breaks core server capabilities: authoritative Shadow Document validation, server-side thumbnail generation, full-text search, and compliance auditing.
  - Irreversible data loss if a user loses their encryption key or link.

### Alternative B: Optional Per-Board E2EE with Key in URL Hash Fragment (Chosen for v2)
- **Pros**:
  - **Zero Server Knowledge**: The symmetric key (AES-GCM 256-bit) is placed in the URL hash fragment (`#key=...`), which is **never transmitted to the server** in HTTP or WebSocket requests.
  - Clients encrypt binary Yjs updates locally before transmission over WebSockets.
  - The server acts as a blind relay of encrypted binary blobs and stores opaque data in PostgreSQL.
  - Standard non-E2EE boards retain full server-side validation, search, and export capabilities.
- **Cons / Accepted Trade-offs for E2EE Boards**:
  - The server cannot perform Zod schema validation on encrypted deltas.
  - Image exports (PNG/SVG) must be performed strictly within the client browser.

---

## Decision

Adopt **optional per-board E2EE** as an architectural capability scheduled for the v2 roadmap (Epic 11). For E2EE-enabled boards, the symmetric encryption key is preserved exclusively in the client's URL fragment (`#key=...`), ensuring absolute zero-knowledge confidentiality.
