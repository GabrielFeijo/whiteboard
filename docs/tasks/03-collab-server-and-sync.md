# Epic 3 — Collab Server and Synchronization

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T3.1 | BE | `POST /boards/:id/collab-token` ticket acquisition (single-use, TTL 30s, Redis `GETDEL`) | M | T2.1, T0.4 | ✅ |
| T3.2 | BE | WS Gateway (`ws`): `Origin` verification, `maxPayload` 1MB, ping/pong 25s, limits (5/user, 25/room) | L | T3.1 | ✅ |
| T3.3 | BE | `Room`: hydration (snapshot + updates), `handleSync`, `handleAwareness`, viewer write-blocking | L | T3.2, T0.6 | ✅ |
| T3.4 | BE | Persistence Worker: debounced buffer (500ms / 50 updates), snapshot compaction | L | T3.3 | ✅ |
| T3.5 | BE | Snapshot compaction (`encodeStateAsUpdate`) + garbage collection `doc.gc` | M | T3.4 | ✅ |
| T3.6 | FE | Sync Provider (WS client, binary protocol, exponential backoff with jitter 1-30s) | L | T3.2, T0.7 | ✅ |
| T3.7 | FE | `y-indexeddb` local persistence integration, online/offline status, offline reconciliation | M | T3.6 | ✅ |
| T3.8 | BE | `AUTH` and `CONTROL` protocol messages (denial, 4403 revocation, 4429 rate limit) | M | T3.3 | ✅ |
| T3.9 | X | `fast-check` property-based tests verifying deterministic CRDT convergence | M | T3.3, T3.6 | ✅ |
