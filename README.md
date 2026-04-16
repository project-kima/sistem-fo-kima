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

- Data backend saat ini disimpan in-memory untuk mempercepat iterasi domain.
- Rujukan desain sistem: `docs/document-archiving-tenant-monitoring-system-design.md`
- Rujukan skema database: `docs/document-schema.sql`
