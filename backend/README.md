# Backend API - Sistem Arsip KIMA

Backend ini dibangun dengan NestJS dan menggunakan Prisma + PostgreSQL untuk domain arsip dokumen dan monitoring tenant.

## Menjalankan Aplikasi

```bash
npm install
npm run prisma:deploy
npm run prisma:seed
npm run start:dev
```

Server berjalan pada:

- `http://localhost:4000`

## Endpoint Inti

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

## Aturan Automasi Dokumen

Upload dokumen akan memicu automasi domain:

- `pemutusan`: status customer menjadi `nonaktif`, kontrak aktif diterminasi.
- `perpanjangan`: kontrak aktif diperpanjang (atau dibuat baru jika belum ada).
- `kontrak`: membuat revisi kontrak aktif.
- `invoice`: membentuk/memperbarui proyeksi invoice untuk monitoring billing.

## Catatan

- `DATABASE_URL` wajib tersedia saat aplikasi dijalankan.
- Seed sekarang aman untuk production-style bootstrap: jika database sudah berisi data, seed akan berhenti kecuali `SEED_FORCE_RESET=true`.
- Rujukan skema SQL ada di `../docs/document-schema.sql`.
