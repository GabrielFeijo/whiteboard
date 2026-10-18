# Epic 6 — Undo/Redo and Offline Resilience

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T6.1 | FE | `Y.UndoManager` configured with `trackedOrigins`, `captureTimeout`, and `stopCapturing` | M | T4.7 | ✅ |
| T6.2 | FE | Offline revoked access flow with graceful read-only local export fallback | M | T3.7, T3.8 | ✅ |
