# Backend API - Sistem Arsip KIMA

Backend ini dibangun dengan NestJS dan saat ini menggunakan penyimpanan in-memory untuk prototipe domain arsip dokumen dan monitoring tenant.

## Menjalankan Aplikasi

```bash
npm install
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

- Implementasi persistence database (PostgreSQL/ORM) belum diaktifkan.
- Rujukan skema SQL ada di `../docs/document-schema.sql`.
