# Dokumentasi Sistem FO KIMA

Indeks dokumentasi utama untuk setup, operasi, deployment, analisis, dan pengembangan Sistem FO KIMA.

## Quick Start

| Dokumen | Deskripsi |
| --- | --- |
| [README.md](../README.md) | Overview project dan quick start. |
| [DEV_GUIDE.md](../DEV_GUIDE.md) | Panduan development. |
| [guides/QUICK_REFERENCE.md](guides/QUICK_REFERENCE.md) | Referensi command harian. |

## Product Requirements

| Dokumen | Deskripsi |
| --- | --- |
| [prd/PRD-sistem-arsip-kima.md](../prd/PRD-sistem-arsip-kima.md) | Product Requirements Document dan flow bisnis utama. |
| [prd/sequence-diagram-komprehensif.md](../prd/sequence-diagram-komprehensif.md) | Sequence diagram sistem. |
| [prd/business-flow.png](../prd/business-flow.png) | Diagram business flow. |

## Guides

| Dokumen | Deskripsi |
| --- | --- |
| [guides/supabase-setup-guide.md](guides/supabase-setup-guide.md) | Setup Supabase Auth dan RLS. |
| [guides/QUICK_REFERENCE.md](guides/QUICK_REFERENCE.md) | Referensi command dan alur harian. |

## Deployment

| Dokumen | Deskripsi |
| --- | --- |
| [deployment/DEPLOYMENT_GUIDE.md](deployment/DEPLOYMENT_GUIDE.md) | Checklist dan langkah deployment. |
| [deployment/status-koneksi-supabase.md](deployment/status-koneksi-supabase.md) | Status koneksi Supabase dan catatan environment. |

## Operations

| Dokumen | Deskripsi |
| --- | --- |
| [operations/TESTING_CHECKLIST.md](operations/TESTING_CHECKLIST.md) | Checklist pengujian manual. |
| [operations/BUG_TRACKING.md](operations/BUG_TRACKING.md) | Catatan bug dan tracking. |
| [operations/kredensial-admin.md](operations/kredensial-admin.md) | Catatan kredensial admin untuk kebutuhan operasional. |
| [operations/panduan-insert-production.md](operations/panduan-insert-production.md) | Panduan insert data production. |

## Analysis dan Referensi Teknis

| Dokumen | Deskripsi |
| --- | --- |
| [analysis/analisis-mapping-spreadsheet.md](analysis/analisis-mapping-spreadsheet.md) | Analisis mapping spreadsheet. |
| [analysis/document-archiving-tenant-monitoring-system-design.md](analysis/document-archiving-tenant-monitoring-system-design.md) | Desain document archiving dan tenant monitoring. |
| [analysis/field-baru-monitoring.md](analysis/field-baru-monitoring.md) | Catatan field baru monitoring. |
| [analysis/fix-frontend-api-connection.md](analysis/fix-frontend-api-connection.md) | Catatan perbaikan koneksi API frontend. |
| [database/document-schema.sql](database/document-schema.sql) | Referensi schema dokumen lama/pendukung. |

## Scripts

Script operasional tersedia di folder `scripts/` dan diindeks di [scripts/README.md](../scripts/README.md).

| Script | Deskripsi |
| --- | --- |
| [scripts/dev/dev-frontend.sh](../scripts/dev/dev-frontend.sh) | Menjalankan frontend development. |
| [scripts/auth/create-supabase-auth-users.sql](../scripts/auth/create-supabase-auth-users.sql) | Membuat user Supabase Auth. |
| [scripts/auth/create-isp-auth-accounts-from-isps.sql](../scripts/auth/create-isp-auth-accounts-from-isps.sql) | Membuat/memperbarui akun Auth ISP dari credential di data ISP. |
| [scripts/auth/insert-admin-user-production.sql](../scripts/auth/insert-admin-user-production.sql) | Insert user admin legacy/operasional. |
| [scripts/rls/setup-supabase-rls-policies.sql](../scripts/rls/setup-supabase-rls-policies.sql) | Setup Row Level Security policies. |
| [scripts/seed/seed-cendikia-supabase-full.sql](../scripts/seed/seed-cendikia-supabase-full.sql) | Seed data Cendikia/customer demo production. |
| [scripts/seed/rollback-cendikia-supabase.sql](../scripts/seed/rollback-cendikia-supabase.sql) | Rollback seed Cendikia. |
| [scripts/seed/insert-charoen-pokphand-production.sql](../scripts/seed/insert-charoen-pokphand-production.sql) | Insert data PT Charoen Pokphand. |
| [scripts/maintenance/fix-customer-contract-package-data.sql](../scripts/maintenance/fix-customer-contract-package-data.sql) | Koreksi data paket kontrak customer. |
| [scripts/maintenance/clarify-customer-contract-schema.sql](../scripts/maintenance/clarify-customer-contract-schema.sql) | Comment, constraint, dan audit schema kontrak customer. |

## Arsitektur Saat Ini

- Frontend: React + Vite.
- Backend aplikasi utama: Supabase direct access dari frontend.
- Database/Auth/API: Supabase Cloud.
- Keamanan akses data: Supabase Row Level Security.
- Route planner: Valhalla, jika fitur routing lokal digunakan.

## Development Singkat

```bash
npm --prefix frontend run dev
```

Aplikasi development berjalan di `http://localhost:5173`.

## Testing dan Deployment

1. Jalankan lint/build frontend.
2. Ikuti [operations/TESTING_CHECKLIST.md](operations/TESTING_CHECKLIST.md).
3. Ikuti [deployment/DEPLOYMENT_GUIDE.md](deployment/DEPLOYMENT_GUIDE.md) untuk rilis production.
