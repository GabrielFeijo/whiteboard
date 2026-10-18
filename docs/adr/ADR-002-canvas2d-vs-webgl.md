# ADR-002 — Proprietary 2D Canvas Engine vs WebGL / Konva.js

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision Makers:** Whiteboard Architecture Team

---

## Context & Problem

Whiteboard requires a graphics engine capable of rendering thousands of geometric shapes, smoothed freehand ink strokes, sticky notes, dynamic connectors, and typography at a sustained 60 FPS, while offering seamless infinite panning and zooming.

We needed to select the underlying graphics rendering architecture:
1. High-level 2D canvas libraries (e.g. Konva.js, Fabric.js).
2. Direct WebGL / WebGPU custom pipeline.
3. Proprietary engine built directly on the native HTML5 2D Canvas API (`CanvasRenderingContext2D`).

---

## Considered Alternatives

### Alternative A: Konva.js or Fabric.js
- **Pros**: Pre-built scene graph, integrated event handling, built-in transformation gizmos.
- **Cons**:
  - Heavy node abstractions that cause significant garbage collection pauses with thousands of active elements.
  - Tight coupling between library-specific node trees and the shared CRDT `Y.Doc`.
  - Restricted control over spatial viewport culling and custom batch rendering passes.

### Alternative B: Native WebGL / WebGPU
- **Pros**: Maximum raw GPU throughput for massive particle counts.
- **Cons**:
  - Immense complexity for typography rendering, anti-aliased Bézier curves, and complex stroke styling.
  - Inconsistent performance or driver bugs across legacy mobile browsers and low-power devices.
  - Prohibitive development timeline for MVP and v1 delivery.

### Alternative C: Proprietary 2D Canvas Engine with RBush and Perfect-Freehand (Chosen)
- **Pros**:
  - **High Performance**: The native `CanvasRenderingContext2D` API is heavily optimized across modern browser engines.
  - **Spatial Indexing with R-Tree (RBush)**: $O(\log N)$ spatial queries enable viewport culling; only elements intersecting the visible camera bounding box are drawn.
  - **3-Layer Architecture**: Background Layer (infinite vector grid), Content Layer (visible elements), and Overlay Layer (cursors, selections, magnetic snap guides).
  - **Zero External Scene Graph**: Direct binding to the Yjs element repository and Zustand stores without redundant object hierarchies.
  - Precision freehand ink strokes using `perfect-freehand` with velocity and pressure smoothing.
- **Cons**:
  - Requires custom implementation of hit-testing and bounding box mathematics; fully covered by tests in `frontend/tests/unit/`.

---

## Decision

Build a **custom 2D Canvas Engine** organized into 3 decoupled layers, with **RBush R-Tree spatial indexing** for viewport culling and dedicated renderers per element type.

---

## Consequences

- **Positive**:
  - Consistent 60 FPS rendering with 5,000+ elements on the canvas.
  - Frame rendering time < 2ms during active pan and zoom interactions.
  - Clean, extensible architecture for adding new shape types and tools.
- **Negative / Mitigations**:
  - Custom geometric hit-testing math; validated through exhaustive unit test coverage in `frontend/tests/unit/`.
