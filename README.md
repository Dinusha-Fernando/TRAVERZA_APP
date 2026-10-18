# TRAVERZA: Connected Travel Operating Platform for Sri Lanka

> **Product Thesis:** One trip. Connected services. A journey that adapts.  
> **Architecture:** Flutter mobile + Next.js web + FastAPI modular monolith + PostgreSQL/PostGIS + Redis/Celery worker.

---

## Monorepo Layout

```
traverza/
├── apps/
│   ├── mobile/             # Flutter traveller mobile app (iOS & Android)
│   └── web/                # Next.js web application (Public, Provider Portal, Admin Ops)
├── backend/
│   ├── app/
│   │   ├── api/v1/         # Versioned REST API endpoints
│   │   ├── core/           # Config, Security, DB Engine, Base Models, Exceptions
│   │   ├── modules/        # Domain modules (Identity, Compliance, Catalogue, TripGraph, etc.)
│   │   └── worker/         # Celery tasks and background processors
│   ├── migrations/         # Alembic database migrations
│   └── tests/              # Pytest unit, integration, and security test suites
├── packages/
│   └── api-client-ts/      # OpenAPI-generated TypeScript client
├── infra/
│   └── docker/             # Docker Compose setup (PostGIS, Redis, MinIO, Mailpit)
└── docs/
    ├── adr/                # Architecture Decision Records
    └── compliance/         # Regulatory checklists (SLTDA, PDPA 2027)
```

## Prerequisites

- **Python:** 3.12+ (or 3.14)
- **Node.js:** 20+ (LTS)
- **Flutter:** 3.24+ (Dart 3.5+)
- **Docker & Docker Compose** (for local PostGIS, Redis, and MinIO)

## Quick Start

### 1. Local Infrastructure
```bash
cd infra/docker
docker compose up -d
```

### 2. Backend API
```bash
cd backend
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Linux/macOS:
source .venv/bin/activate

pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

API documentation will be available at `http://localhost:8000/docs`.

### 3. Web Application (Provider Portal & Operations)
```bash
cd apps/web
npm install
npm run dev
```

Web interface will be available at `http://localhost:3000`.

### 4. Mobile Application (Traveller App)
```bash
cd apps/mobile
flutter pub get
flutter run
```

## Key Documentation
- [Master Implementation Plan](file:///C:/Users/Dinusha/.gemini/antigravity-ide/brain/e5e2783d-def8-4f4a-bad1-4d37662d5313/master_implementation_plan.md)
- [Architecture Decision Records (ADRs)](file:///c:/Users/Dinusha/Desktop/TRAVERZA/docs/adr/)
