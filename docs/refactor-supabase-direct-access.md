# Refactor Supabase Direct Access

Dokumen ini merangkum status migrasi frontend dari backend NestJS/custom API ke akses langsung Supabase.

## Status terakhir

- **Tanggal:** 2026-05-13
- **Status:** Core migration selesai; manual end-to-end testing masih perlu dilanjutkan.
- **Arsitektur:** React + Vite terhubung langsung ke Supabase Auth, PostgreSQL, REST API, dan RLS.

## Perubahan utama

### Authentication

- Login berpindah dari `username/password` ke `email/password` melalui Supabase Auth.
- Session dikelola oleh Supabase client dengan refresh token otomatis.
- Role dibaca dari metadata user Supabase.

### API frontend

- Frontend menggunakan service layer `frontend/src/lib/api.js`.
- Supabase client berada di `frontend/src/lib/supabase.js`.
- Pemanggilan legacy `fetchJson`/`API_BASE_URL` pada alur utama sudah diganti dengan API Supabase langsung.

### Database dan keamanan

- SQL setup user auth tersedia di `../scripts/auth/create-supabase-auth-users.sql`.
- SQL setup RLS tersedia di `../scripts/rls/setup-supabase-rls-policies.sql`.
- RLS berbasis role sudah disiapkan untuk admin, teknisi, dan ISP.

## Yang sudah diverifikasi

- `npm run lint` lulus tanpa error/warning.
- `npm run build` berhasil.
- Login admin berhasil.
- Data customer dan ISP berhasil dimuat.
- Grouping customer-ISP sudah sesuai bentuk response Supabase.
- Detail page utama sudah tidak memakai legacy `fetchJson/API_BASE_URL` untuk operasi yang sudah direfactor.

## Yang masih perlu diuji manual

- Login teknisi dan ISP.
- Role-based access untuk admin, teknisi, dan ISP.
- Monitoring billing end-to-end.
- Operasi detail customer dan detail ISP.
- Create/edit/delete data pada browser production.

## Keterbatasan yang diketahui

- Timeline/recent activity belum menjadi prioritas utama.
- Beberapa kebijakan RLS masih berbasis role sederhana; pembatasan ISP per kepemilikan data perlu validasi tambahan.
- Operasi upload/file perlu diuji langsung di browser karena bergantung pada konfigurasi storage dan policy Supabase.

## Dokumen terkait

- [Supabase Setup Guide](guides/supabase-setup-guide.md)
- [Testing Checklist](operations/TESTING_CHECKLIST.md)
- [Deployment Guide](deployment/DEPLOYMENT_GUIDE.md)
- [Documentation Index](INDEX.md)
