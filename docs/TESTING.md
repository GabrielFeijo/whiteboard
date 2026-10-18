# Testing Handbook — Whiteboard

This document establishes the testing strategy, standards, and execution workflows for the Whiteboard platform.

---

## 🏛️ Testing Pyramid & Philosophy

The test suite is structured for high speed, reliability, and contract integrity across distributed boundaries:

```
          / \
         / E2E \       Playwright (Critical user journeys: auth, drawing, live sync)
        /-------\
       / Integr. \     Testcontainers (Real PostgreSQL, Redis, and S3 in Docker)
      /-----------\
     /  Contract   \   Vitest (Binary protocol fixtures, schema serialization parity)
    /---------------\
   /   Unit Tests    \ Vitest (Canvas math, spatial index, tool FSM, auth, RBAC)
  /-------------------\
```

### Core Testing Goals
1. **Zero Flakiness**: Deterministic tests with isolated state and explicit teardown.
2. **Sub-second Feedback**: Unit test suites execute in < 2 seconds via Vitest.
3. **Cross-Submodule Contract Parity**: Schema drift is caught at build-time through binary contract fixtures.

---

## 🏃 Running Tests

### Complete Verification (Full Harness)
Runs contract validation, TypeScript type checks, ESLint, and all unit/contract tests across both submodules:

```bash
make check
```

For faster iterations during active coding (skips linting):
```bash
make check-quick
```

### Unit & Contract Tests Only
```bash
# Run all tests across backend and frontend
make test

# Run backend tests only (15 suites, 71 tests)
npm --prefix backend run test

# Run frontend tests only (21 suites, 118 tests)
npm --prefix frontend run test
```

### Targeted Test Execution
Run a specific test file or pattern:

```bash
# Backend single file
npm --prefix backend run test -- test/unit/auth.service.spec.ts

# Frontend single file
npm --prefix frontend run test -- tests/unit/element-resize.spec.ts

# Filter by test name
npm --prefix frontend run test -- -t "should snap to grid"
```

### Integration Tests (Backend Testcontainers)
Integration tests spin up lightweight ephemeral Docker containers for PostgreSQL, Redis, and MinIO:

```bash
npm --prefix backend run test:int
```
> *Note: Requires a running Docker daemon.*

### End-to-End Tests (Frontend Playwright)
Playwright tests simulate real browser sessions interacting with the live studio:

```bash
# Headless run
npm --prefix frontend run test:e2e

# Interactive UI mode
npm --prefix frontend run test:e2e -- --ui
```

---

## 🔬 Contract Testing & Fixtures

Because `backend/` and `frontend/` are isolated Git submodules, binary contract tests prevent silent breakage between the server and web client.

### How Contract Tests Work:
1. `backend/src/shared/` defines Zod schemas and protocol constants.
2. `backend/scripts/gen-fixtures.ts` generates deterministic binary and JSON fixtures:
   - Complete element structures (rectangles, diamonds, connectors, sticky notes, images).
   - Binary Yjs sync step messages encoded via `lib0`.
3. Contract test suites run in **both** repositories:
   - `backend/test/contract/shared-contract.spec.ts`
   - `frontend/tests/contract/shared-contract.spec.ts`
4. Both sides validate:
   - Every fixture parses without schema errors.
   - Unknown fields are strictly rejected where `strict()` is enforced.
   - Serialization and deserialization are idempotent.

---

## 📐 Writing Unit Tests

### Backend Unit Tests
- Use Vitest and standard NestJS testing utilities (`Test.createTestingModule`).
- Mock Prisma repositories using typed in-memory stores.
- Mock Redis client using event emitter stubs.
- Example structure:
  ```ts
  describe('BoardsService', () => {
    let service: BoardsService;
    let prismaMock: MockPrismaService;

    beforeEach(async () => {
      const module = await Test.createTestingModule({
        providers: [BoardsService, { provide: PrismaService, useValue: prismaMock }],
      }).compile();
      service = module.get(BoardsService);
    });

    it('should enforce OWNER permission on board deletion', async () => {
      await expect(service.deleteBoard('board-1', 'viewer-id')).rejects.toThrow(ForbiddenException);
    });
  });
  ```

### Frontend Canvas Unit Tests
- Test canvas math independently of DOM rendering where possible.
- Verify `SpatialIndex` (RBush) updates alongside element geometry changes.
- Verify screen-to-world and world-to-screen conversions under different zoom levels.
- Example structure:
  ```ts
  describe('Viewport Transformations', () => {
    it('should transform screen coordinates correctly with 1.5x zoom and pan offset', () => {
      const viewport = new Viewport();
      viewport.zoom = 1.5;
      viewport.pan = { x: 100, y: 50 };

      const world = viewport.screenToWorld(250, 200);
      expect(world).toEqual({ x: 100, y: 100 });
    });
  });
  ```

---

## ✅ Pre-Commit & CI Test Gate

Husky pre-commit hooks ensure that commits cannot be made with:
- Failing TypeScript type checks (`tsc --noEmit`).
- ESLint syntax or style violations.
- Out-of-sync shared contracts (`npm run sync:shared:check`).

Always run `make check` before opening a pull request or completing an agent task.
