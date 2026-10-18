# Local Development Guide — Whiteboard

This guide walks human developers and AI agents through setting up, developing, testing, and debugging the Whiteboard platform locally.

---

## 🛠️ Prerequisites

- **Node.js**: `20.x` or `22.x` (LTS recommended)
- **npm**: `10.x+`
- **Docker & Docker Compose**: v2+ (for PostgreSQL, Redis, MinIO)
- **Make**: Available on Linux, macOS, or WSL2

---

## 🚀 Quickstart

Clone the repository with submodules initialized:

```bash
git clone --recurse-submodules <repo-url> whiteboard
cd whiteboard
```

If already cloned without submodules:
```bash
git submodule update --init --recursive
```

### 1. Start Infrastructure Dependencies

Start PostgreSQL (5442), Redis (6379), and MinIO (9000/9001) in the background:

```bash
make deps
```

### 2. Configure Environment Files

Copy the example environment configurations:

```bash
# Root environment
cp .env.example .env

# Backend environment
cp backend/.env.example backend/.env

# Frontend environment
cp frontend/.env.example frontend/.env.local
```

### 3. Initialize Database & Seed Data

Run database migrations and seed default development data (users, boards, assets):

```bash
npm --prefix backend run prisma:migrate
npm --prefix backend run db:seed
```

### 4. Start Development Servers

You can start both services concurrently or individually:

```bash
# Start all development services
make dev
```

Or run services in dedicated terminal tabs:

```bash
# Terminal 1: Backend (REST API on :3001 and Collab Server on :3002)
cd backend && npm run dev

# Terminal 2: Frontend (Next.js 16 App Router on :3000)
cd frontend && npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🌐 Local Services & Endpoints Reference

| Service | Address | Default Credentials | Description |
| :--- | :--- | :--- | :--- |
| **Frontend Studio** | `http://localhost:3000` | — | Interactive 2D canvas whiteboard |
| **REST API** | `http://localhost:3001` | — | Stateless REST endpoints (`/v1/*`) |
| **Swagger UI** | `http://localhost:3001/v1/docs` | — | Interactive OpenAPI documentation |
| **OpenAPI Spec** | `http://localhost:3001/v1/docs-json` | — | OpenAPI JSON specification |
| **Collab Server** | `ws://localhost:3002/collab` | — | Stateful WebSocket CRDT sync gateway |
| **Health Liveness** | `http://localhost:3001/health/live` | — | Basic HTTP liveness probe |
| **Health Readiness** | `http://localhost:3001/health/ready` | — | PostgreSQL and Redis health check |
| **Prometheus Metrics**| `http://localhost:3001/metrics` | — | Application performance metrics |
| **PostgreSQL** | `localhost:5442` | `whiteboard` / `whiteboard123` | Relational database (`whiteboard_db`) |
| **Redis** | `localhost:6379` | (no password) | Cache, sessions, pub/sub cluster |
| **MinIO API** | `http://localhost:9000` | `minio` / `minio12345` | S3 object storage endpoint |
| **MinIO Console** | `http://localhost:9001` | `minio` / `minio12345` | Web dashboard for managing buckets |

---

## 🔑 Default Test Accounts & Seed Data

When running `npm --prefix backend run db:seed`, the database is provisioned with default accounts:

| Email | Password | Role / Access |
| :--- | :--- | :--- |
| `admin@whiteboard.local` | `Admin123!` | Default Owner of sample boards |
| `editor@whiteboard.local` | `Editor123!` | Collaborator with Editor permissions |
| `viewer@whiteboard.local` | `Viewer123!` | Read-only collaborator |

Sample boards:
- **Quadro de Demonstração Geral** (`boardId: cmvdzbcmv000j2dc41hge5xfx`)

---

## ⚙️ Environment Variables Breakdown

### Backend (`backend/.env`)

```ini
# Application
NODE_ENV=development
API_PORT=3001
COLLAB_PORT=3002
CORS_ORIGIN=http://localhost:3000

# Authentication & Security
JWT_SECRET=super-secret-jwt-key-for-local-dev-min-32-chars
JWT_ACCESS_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d
COOKIE_SECRET=local-dev-cookie-secret-min-32-chars

# Database & Cache
DATABASE_URL=postgresql://whiteboard:whiteboard123@localhost:5442/whiteboard_db?schema=public
REDIS_URL=redis://localhost:6379

# Object Storage (S3 / MinIO)
S3_ENDPOINT=http://localhost:9000
S3_PUBLIC_ENDPOINT=http://localhost:9000
S3_REGION=us-east-1
S3_BUCKET_NAME=whiteboard-assets
S3_ACCESS_KEY=minio
S3_SECRET_KEY=minio12345
```

### Frontend (`frontend/.env.local`)

```ini
# API Connectivity
NEXT_PUBLIC_API_URL=http://localhost:3001
INTERNAL_API_URL=http://localhost:3001

# Collab WebSocket
NEXT_PUBLIC_WS_URL=ws://localhost:3002

# S3 Assets
NEXT_PUBLIC_S3_ENDPOINT=http://localhost:9000
```

---

## 🧩 Common Development Workflows

### 1. Adding a New Shared Element or Protocol Schema
1. Open `backend/src/shared/schema.ts` or `protocol.ts`.
2. Define the Zod schema and export the TypeScript inferred type.
3. If fixtures are affected, run `npm --prefix backend run fixtures`.
4. Run `make sync-shared` from workspace root.
5. Verify parity with `make sync-shared-check`.
6. Run `make test` to verify contract tests pass in both repos.

### 2. Modifying Database Models
1. Edit `backend/prisma/schema.prisma`.
2. Generate client: `npm --prefix backend run prisma:generate`.
3. Create migration: `npm --prefix backend run prisma:migrate`.
4. Update services and DTOs in `backend/src/modules/`.

### 3. Adding a New Canvas Tool
1. Create tool class in `frontend/src/canvas/tools/` extending `BaseTool`.
2. Implement pointer events: `onPointerDown`, `onPointerMove`, `onPointerUp`, `onKeyDown`.
3. Register the tool in `frontend/src/canvas/tool-manager.ts`.
4. Add toolbar action button in `frontend/src/features/studio/components/tool-palette.tsx`.
5. Add unit test in `frontend/tests/unit/`.

---

## 🔍 Troubleshooting & FAQ

### Port 5442 / 6379 / 9000 already in use
- Check running docker containers: `docker ps`.
- Stop conflicting containers or adjust host port mappings in `docker-compose.deps.yml`.

### Shared contracts out of sync
- Run `make sync-shared`. Remember: **never edit `frontend/src/shared/` directly**. All changes originate in `backend/src/shared/`.

### WebSocket connection fails (`401 Unauthorized` or handshake timeout)
- Ensure the Collab Server is running on `:3002`.
- Verify the board ID exists in the database.
- Collab tickets expire in 30 seconds. If a connection drops, the frontend automatically requests a fresh ticket via `POST /v1/boards/:id/collab-token`.

### Git index lock error
- If running commands in isolated or sandboxed environments produces `fatal: Unable to create '.git/index.lock': Read-only file system`, execute the command with bypass permission or verify file permissions on `.git/`.
