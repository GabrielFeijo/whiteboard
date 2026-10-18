# Contributing Guidelines — Whiteboard

Welcome! Whether you are a human software engineer or an autonomous AI agent, please adhere to these standards and protocols when contributing to Whiteboard.

---

## 🧭 Repository Architecture & Submodules Protocol

The codebase is split into two independent Git submodules (`backend/` and `frontend/`) and a root orchestration repository:

```
whiteboard/ (Root Git Repository)
├── backend/ (Git Submodule — NestJS 11 service)
├── frontend/ (Git Submodule — Next.js 16 + React 19)
└── docs/ (Architecture, ADRs, tasks)
```

### ⚠️ Strict Submodule Commit Sequence

Whenever making changes that span submodules:
1. **Commit inside the modified submodule repository first**:
   ```bash
   git -C backend add . && git -C backend commit -m "feat(collab): add delta compression"
   # or
   git -C frontend add . && git -C frontend commit -m "feat(canvas): add diamond shape renderer"
   ```
2. **Update the submodule commit pointer in the root repository**:
   ```bash
   git add backend frontend
   git commit -m "chore: update submodule pointers"
   ```
3. Never push a root commit with submodule pointers referencing unpushed submodule commits.

---

## 📝 Conventional Commits Specification

All commit messages in root and submodules must strictly follow the [Conventional Commits](https://www.conventionalcommits.org/) format, enforced by Husky and Commitlint:

```
<type>(<scope>): <short description in imperative mood>

[optional body]

[optional footer(s)]
```

### Allowed Types
- `feat`: A new feature or capability.
- `fix`: A bug fix.
- `docs`: Documentation changes only.
- `style`: Formatting, missing semi-colons, whitespace (no code change).
- `refactor`: Code change that neither fixes a bug nor adds a feature.
- `perf`: Performance optimization.
- `test`: Adding or correcting tests.
- `chore`: Build tasks, package updates, submodule pointer updates.

### Examples
- `feat(canvas): implement multi-element box selection`
- `fix(auth): prevent race condition during atomic refresh token rotation`
- `refactor(collab): extract shadow doc validator into dedicated service`
- `docs(readme): add 2k architecture preview board to readme`
- `chore: update submodule pointers with architecture preview boards`

---

## 🔒 Contract Change Protocol (Single Source of Truth)

- **`backend/src/shared/` is the authoritative source.**
- **NEVER edit `frontend/src/shared/` directly.**
- When modifying shared types, schemas, or protocols:
  1. Make modifications in `backend/src/shared/`.
  2. If fixtures changed, run `npm --prefix backend run fixtures`.
  3. Propagate to frontend: `make sync-shared`.
  4. Verify parity: `make sync-shared-check`.
  5. Commit in `backend/`, then in `frontend/`, then update root pointers.

---

## 📋 Pre-Completion Checklist

Before opening a pull request or concluding an agent task, verify that:

- [ ] Shared contracts are 100% in sync (`make sync-shared-check`).
- [ ] TypeScript type checks pass with 0 errors in both submodules (`make typecheck`).
- [ ] ESLint passes with 0 warnings or errors in both submodules (`make lint`).
- [ ] Vitest unit and contract tests pass completely (`make test`).
- [ ] Full harness passes: `make check`.
- [ ] Git commit messages follow Conventional Commits.
- [ ] Submodule commits precede root pointer update commit.
