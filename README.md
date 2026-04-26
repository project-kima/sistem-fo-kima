# sistem-arsip-kima

Sistem arsip dokumen dan monitoring tenant berbasis web dengan arsitektur terpisah:

- `frontend/`: React + Vite + Tailwind
- `backend/`: NestJS API (prototipe in-memory)
- `docs/`: desain sistem dan referensi skema SQL

## Menjalankan Frontend

```bash
cd frontend
npm install
npm run dev
```

Secara default frontend mengakses backend ke `http://localhost:4000`.
Jika perlu override, gunakan environment variable `VITE_API_BASE_URL`.

## Menjalankan Backend

```bash
cd backend
npm install
npm run start:dev
```

Backend sekarang wajib memakai PostgreSQL lewat `DATABASE_URL`. Untuk bootstrap data contoh:

```bash
cd backend
npm run prisma:deploy
npm run prisma:seed
```

Jika database sudah berisi data dan Anda memang ingin mengganti seluruh isi bootstrap, jalankan:

```bash
cd backend
SEED_FORCE_RESET=true npm run prisma:seed
```

## Endpoint Utama API

- `GET /api/health`
- `GET /api/customers`
- `GET /api/customers/:customerId`
- `GET /api/customers/:customerId/compliance-status`
- `GET /api/customers/:customerId/timeline`
- `GET /api/customers/:customerId/documents`
- `POST /api/customers/:customerId/documents`
- `GET /api/customers/:customerId/documents/:documentId`
- `DELETE /api/customers/:customerId/documents/:documentId`
- `GET /api/monitoring/billing?year=&isp=&status=`
- `GET /api/monitoring/alerts?year=`

## Catatan Implementasi

- Backend memakai Prisma + PostgreSQL sebagai source of truth.
- Rujukan desain sistem: `docs/document-archiving-tenant-monitoring-system-design.md`
- Rujukan skema database: `docs/document-schema.sql`
