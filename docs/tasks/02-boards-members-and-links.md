# Epic 2 — Boards, Members, and Links

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status |
| --- | --- | --- | --- | --- | --- |
| T2.1 | BE | Boards CRUD (`/v1/boards`), soft deletion, cursor pagination, RFC 7807 error responses | L | T1.4 | ✅ |
| T2.2 | BE | Duplicate board functionality | S | T2.1 | ✅ |
| T2.3 | BE | Members and roles management; strict "exactly one owner" invariant | M | T2.1 | ✅ |
| T2.4 | BE | ShareLink: creation (high-entropy SHA-256 tokens), expiration, revocation, default `VIEWER` | M | T2.1 | ✅ |
| T2.5 | BE | Purge job: soft-deleted board permanent cleanup after 30 days | S | T2.1 | ✅ |
| T2.6 | FE | Boards dashboard (list/create/rename/duplicate/delete) | L | T2.1, T1.5 | ✅ |
| T2.7 | FE | Share modal (links, roles, expiration, revocation) | M | T2.4 | ✅ |
| T2.8 | BE | Anonymous guest collaboration via share links (ephemeral identity) | M | T2.4 | ✅ |
