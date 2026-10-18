# Epic 7 — History, Assets and Export (RF14, RF15, RF18)

Conventions: `[R]` = Repository (**BE** Backend, **FE** Frontend, **INF** Root / Infrastructure, **X** Both). Estimate: **S** ≤ ½ day · **M** 1–2 days · **L** 3–5 days. Status: ⬜ Pending · ✅ Completed.

| ID | R | Task | Est. | Deps | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| T7.1 | BE | Snapshot endpoints (list, manual trigger, restore with `PRE_RESTORE`) | M | T3.4 | ✅ | Fully implemented in SnapshotController / PersistenceService |
| T7.2 | FE | Version history drawer + preview with isolated read-only `Y.Doc` | L | T7.1 | ✅ | Implemented in VersionHistoryDrawer with diffing |
| T7.3 | BE | Presigned upload URL endpoint with Content-Type and size validation (allowlist PNG/JPEG/WebP) | M | T0.4 | ✅ | Implemented in AssetsController & S3StorageService with dual endpoint support |
| T7.4 | BE | Asset post-processing pipeline (magic bytes validation, EXIF stripping via Sharp, signed CDN distribution) | M | T7.3 | ⬜ | Planned for asynchronous worker media pipeline |
| T7.5 | FE | Direct S3 asset upload and canvas rendering (`assetId` + `src`) | L | T7.3, T4.4 | ✅ | Implemented via S3 presigned PUT, LRU image cache and error boundaries |
| T7.6 | FE | PNG and SVG export with XML escaping and element rendering | M | T4.4 | ✅ | Fully verified with sanitization against XSS injection |
| T7.7 | BE | Server-side board export endpoint (`POST /boards/:id/export`) | M | T7.6 | ✅ | Handled server-side when requested |
