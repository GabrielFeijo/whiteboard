# Epic 5 — Presence and Awareness

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T5.1 | FE | Awareness: cursor in world coordinates, throttled at ~30Hz, LERP interpolation | M | T3.6, T4.2 | ✅ |
| T5.2 | FE | Remote selection highlighting (colored bounds), deterministic color hashing | S | T5.1, T4.7 | ✅ |
| T5.3 | FE | Active participant list with 30s heartbeat timeout | S | T5.1 | ✅ |
| T5.4 | FE | Follow-user mode (smooth camera lock on remote peer viewport) | M | T5.1 | ✅ |
