# Product Requirements Document
# Sistem FO KIMA — Document Archiving & Tenant Monitoring System

**Versi:** 1.2  
**Tanggal:** 2026-05-13  
**Status:** Active Development

---

## 1. Latar Belakang

Sistem FO KIMA adalah aplikasi internal untuk mengelola arsip dokumen, monitoring kontrak, monitoring billing, dan data operasional fiber optik antara KIMA, ISP mitra, dan pelanggan/tenant.

Operasional sebelumnya tersebar di dokumen, spreadsheet, dan pencatatan manual. Sistem ini menyatukan data pelanggan, ISP, kontrak, BAK, invoice, dan jalur FO ke dalam satu platform berbasis web agar status kerja sama dan dokumen dapat dipantau dengan konsisten.

---

## 2. Tujuan Produk

- Menyediakan arsip dokumen terpusat untuk pelanggan dan ISP.
- Menampilkan status kontrak, periode berjalan, paket, invoice, dan dokumen secara akurat.
- Mendukung monitoring billing bulanan berbasis data invoice.
- Mendukung pengelolaan proses renewal/perpanjangan kontrak dan follow-up.
- Mendukung perencanaan dan riwayat jalur fiber optik.
- Mengurangi ambiguitas data dengan aturan bisnis kontrak yang jelas.

---

## 3. Pengguna & Peran

| Peran | Deskripsi | Kapabilitas Utama |
| --- | --- | --- |
| **Admin** | Pengelola penuh sistem | CRUD ISP, CRUD pelanggan, kelola kontrak, dokumen, invoice, route, monitoring, tempat sampah |
| **Teknisi** | Staf operasional/lapangan | Melihat data pelanggan, route planner FO, monitoring operasional |
| **ISP** | Mitra ISP | Melihat data terkait ISP dan pelanggan yang relevan secara read-only |

Autentikasi menggunakan Supabase Auth dan akses dibatasi berdasarkan role di frontend serta Supabase Row Level Security.

---

## 4. Flow Bisnis Utama

### 4.1 Hubungan KIMA, ISP, dan Pelanggan

- ISP adalah mitra penyedia jaringan atau pihak yang menaungi pelanggan tertentu.
- Pelanggan/tenant dapat terhubung ke satu atau lebih ISP melalui relasi membership.
- Data pelanggan menjadi pusat untuk kontrak, dokumen, invoice, route, dan timeline aktivitas.

### 4.2 Awal Kerja Sama Pelanggan

- `customers.contract_start_date` menyimpan tanggal pertama kali pelanggan bekerja sama dengan KIMA.
- Tanggal ini ditampilkan sebagai **Periode Awal Kontrak**.
- Nilai ini tidak sama dengan periode berjalan setiap kontrak, dan tidak boleh dihapus dari tampilan karena dipakai untuk mengetahui awal hubungan bisnis.
- Biaya aktivasi hanya dikenakan satu kali di awal kerja sama.
- Biaya aktivasi disimpan di data pelanggan, bukan di setiap kontrak.

### 4.3 Kontrak Pelanggan

- `contracts` merepresentasikan dokumen kontrak/BAK/legal yang nyata.
- Satu row `contracts` dibuat ketika memang ada dokumen kontrak/BAK/amendment/perpanjangan yang nyata.
- Tidak ada pembuatan kontrak otomatis hanya karena pergantian tahun.
- `contracts` adalah sumber kebenaran untuk:
  - nomor kontrak,
  - periode berjalan kontrak,
  - paket pelanggan,
  - jumlah dedicated core,
  - sharing ratio.
- Kontrak terbaru berdasarkan periode adalah **Kontrak Beroperasi**.
- Kontrak lama tetap ditampilkan sebagai **Riwayat Perubahan**.

### 4.4 Versi Kontrak Pelanggan

- `contract_versions` adalah snapshot/revisi/amendment opsional dari sebuah dokumen kontrak.
- `contract_versions` bukan sumber utama untuk baris kontrak normal.
- Jika dipakai, version harus tetap konsisten dengan parent `contracts` untuk versi terbaru.
- Version lama boleh menyimpan histori perubahan dalam satu dokumen kontrak, misalnya perubahan rasio dari `1/32` ke `1/8` dalam kasus amendment yang nyata.

### 4.5 Paket dan Jumlah Core

Paket pelanggan memiliki dua bentuk:

| Paket | Field utama | Aturan |
| --- | --- | --- |
| `core` | `core_total` | `core_total > 0`, ratio kosong |
| `sharing_core` | `sharing_ratio` | ratio terisi seperti `1/32`, `core_total` kosong atau `0` |

Aturan penting:

- Perubahan paket hanya terjadi jika ada dokumen kontrak/BAK/amendment yang nyata.
- Tidak ada asumsi bahwa paket berubah otomatis setiap tahun.
- Tampilan detail pelanggan harus membaca paket dari kontrak berjalan/terbaru.
- Tab Kontrak harus menampilkan paket sesuai masing-masing row `contracts`.

### 4.6 Dokumen

- Dokumen selalu terikat ke pelanggan.
- Dokumen dapat opsional terikat ke kontrak, versi kontrak, atau invoice.
- Jenis dokumen utama:
  - `permohonan`,
  - `penawaran`,
  - `tanggapan`,
  - `hasil_nego`,
  - `BAK`,
  - `kontrak`,
  - `invoice`,
  - `perpanjangan`,
  - `pemutusan`,
  - `lainnya`.
- Dokumen kontrak/BAK menjadi bukti legal untuk row `contracts`.
- Dokumen invoice menjadi dasar monitoring billing.

### 4.7 Invoice dan Monitoring Billing

- Invoice dibuat per periode tagihan.
- Monitoring billing menampilkan status invoice per pelanggan dan bulan.
- Status invoice yang digunakan:
  - `lunas`,
  - `belum_bayar`,
  - `terlambat`,
  - `belum_ditagih`.
- Follow-up invoice digunakan untuk mencatat proses penagihan.

### 4.8 Renewal dan Pemutusan

- Renewal/perpanjangan hanya membuat kontrak baru jika ada dokumen kontrak/BAK/perpanjangan yang nyata.
- Follow-up renewal mencatat proses administratif sebelum keputusan lanjut atau berhenti.
- Dokumen `pemutusan` menandai layanan/kontrak sebagai berhenti atau nonaktif sesuai konteks bisnis.

---

## 5. Modul & Fitur

### 5.1 Dashboard

- Ringkasan jumlah pelanggan, ISP, invoice, dan kontrak.
- Alert operasional untuk invoice belum ditagih, kontrak mendekati akhir periode, dan dokumen yang perlu ditindaklanjuti.

### 5.2 Manajemen ISP

- Daftar ISP dengan status: `aktif`, `nonaktif`, `expired`, `berhenti`.
- Detail ISP menampilkan informasi umum, paket, jumlah, periode kontrak, logo, file kontrak, customer terkait, dan renewal follow-up.
- Admin dapat membuat, mengedit, dan menghapus ISP.
- Teknisi/ISP dapat melihat sesuai hak akses.

### 5.3 Manajemen Pelanggan

Detail pelanggan terdiri dari tab:

- **Overview**: informasi umum, status, paket berjalan, biaya aktivasi, periode awal kontrak, periode berjalan.
- **Kontrak**: daftar dokumen kontrak dari `contracts`, status BAK, periode, paket, jumlah, renewal follow-up.
- **Invoice**: daftar invoice dan status pembayaran.
- **Dokumen**: arsip dokumen pelanggan.
- **Jalur**: perencanaan dan riwayat jalur FO.
- **Timeline**: riwayat aktivitas pelanggan.

### 5.4 Monitoring Billing

- Tampilan spreadsheet per tahun dan ISP.
- Baris mewakili pelanggan; kolom mewakili bulan.
- Data diperbarui berdasarkan invoice dan status pembayaran.

### 5.5 Route Planner FO

- Perencanaan jalur berbasis peta menggunakan Valhalla.
- Setiap pelanggan dapat memiliki versi jalur dan titik route.
- Riwayat perubahan jalur disimpan agar perubahan teknis dapat diaudit.

### 5.6 Tempat Sampah

- Pelanggan dan ISP yang dihapus masuk ke soft delete.
- Admin dapat memulihkan atau menghapus permanen jika diperlukan.

---

## 6. Model Data Utama

| Entitas | Deskripsi |
| --- | --- |
| `users` / Supabase Auth | Akun pengguna dan role akses |
| `isps` | Data ISP mitra, paket, periode, dan status |
| `isp_contract_rows` | Baris kontrak/periode ISP bila tersedia |
| `isp_renewal_follow_ups` | Follow-up renewal kontrak ISP |
| `customers` | Data pelanggan, status, kode unik, awal kerja sama, biaya aktivasi |
| `customer_isp_memberships` | Relasi pelanggan dengan ISP |
| `contracts` | Dokumen kontrak/BAK/legal pelanggan; sumber kebenaran periode dan paket |
| `contract_versions` | Snapshot/revisi/amendment opsional dari kontrak |
| `contract_version_renewal_follow_ups` | Follow-up renewal kontrak pelanggan |
| `documents` | Arsip dokumen pelanggan/kontrak/invoice |
| `invoices` | Invoice per periode tagihan |
| `invoice_follow_ups` | Follow-up penagihan invoice |
| `customer_route_versions` | Versi jalur FO pelanggan |
| `customer_route_points` | Titik awal/transit/tujuan jalur FO |
| `customer_route_history` | Riwayat perubahan jalur FO |

---

## 7. Arsitektur Teknis

### 7.1 Arsitektur Saat Ini

Alur utama sistem saat ini:

```text
Frontend React/Vite
        |
        v
Supabase Auth + Supabase Database/REST + Supabase Storage
        |
        v
PostgreSQL + Row Level Security
```

Komponen pendukung:

- **Frontend**: React + Vite.
- **Backend utama**: Supabase direct access dari frontend.
- **Database**: Supabase PostgreSQL.
- **Auth**: Supabase Auth.
- **Storage/File URL**: Supabase Storage atau URL file eksternal sesuai data.
- **Route planner**: Valhalla untuk kebutuhan peta/jalur FO.

Tidak ada service NestJS yang menjadi alur utama aplikasi saat ini.

### 7.2 Struktur Project

```text
sistem-fo-kima/
├── frontend/              # React + Vite application
├── docs/                  # Dokumentasi teknis, operasional, deployment, analisis
├── prd/                   # Product requirements dan diagram bisnis
├── scripts/               # Script operasional Supabase/SQL/dev
└── infra/                 # Konfigurasi infrastruktur pendukung seperti Valhalla
```

### 7.3 Struktur Frontend

```text
frontend/src/
├── app/                   # Utilities dan shared app logic
├── components/            # Shared UI components
├── features/              # Feature pages: pelanggan, monitoring, dashboard, login
├── lib/                   # API/Supabase access layer
└── roles/                 # Route/menu per role
```

---

## 8. Persyaratan Non-Fungsional

| Aspek | Ketentuan |
| --- | --- |
| Pengguna | Dirancang untuk penggunaan internal oleh operator/tim kecil |
| Keamanan | Login wajib, role-based access, Supabase RLS |
| Integritas Data | Relasi kontrak, dokumen, invoice, dan customer harus konsisten |
| Keterlacakan | Dokumen dan timeline menyimpan histori aktivitas penting |
| Performa | Monitoring tahunan harus tetap responsif untuk data operasional aktif |
| Operasional | Script production dijalankan manual dan hati-hati melalui Supabase SQL Editor |

---

## 9. Batasan & Asumsi

- Sistem digunakan internal oleh KIMA.
- Data production berada di Supabase.
- Dokumen/file dapat berupa URL eksternal atau storage yang dapat dibuka dari aplikasi.
- Tidak semua ISP harus memiliki data kontrak detail jika data belum tersedia.
- Perubahan data production harus melalui script/audit yang jelas.
- Valhalla hanya diperlukan untuk fitur route planner.

---

## 10. Deployment & Operations

### 10.1 Local Development

```bash
npm --prefix frontend install
npm --prefix frontend run dev
```

Frontend berjalan di:

```text
http://localhost:5173
```

### 10.2 Production

- Frontend dapat dideploy ke Netlify atau hosting static lain.
- Backend/data menggunakan Supabase.
- Script SQL production dijalankan manual melalui Supabase SQL Editor setelah direview.

### 10.3 Verifikasi Umum

```bash
npm --prefix frontend run lint
npm --prefix frontend run build
```

---

## 11. Roadmap Implementasi

### Fase 1 — Core Operasional

- [x] Login berbasis role.
- [x] CRUD pelanggan dan ISP.
- [x] Arsip dokumen pelanggan.
- [x] Monitoring billing.
- [x] Soft delete/tempat sampah.

### Fase 2 — Kontrak, Invoice, dan Route

- [x] Detail kontrak pelanggan berbasis dokumen kontrak.
- [x] Follow-up invoice dan renewal.
- [x] Route planner FO.
- [x] Mapping Supabase direct access.

### Fase 3 — Penyempurnaan Operasional

- [ ] Alert dashboard yang lebih lengkap.
- [ ] Timeline aktivitas yang lebih detail.
- [ ] Laporan/analitik dokumen dan billing.
- [ ] Notifikasi terjadwal bila dibutuhkan.

---

## 12. Glosarium

| Istilah | Definisi |
| --- | --- |
| ISP | Internet Service Provider / mitra penyedia jaringan |
| Pelanggan / Tenant | Pengguna layanan fiber optik |
| BAK | Berita Acara Kesepakatan/serah terima sesuai konteks dokumen |
| Core | Alokasi fiber dedicated |
| Sharing Core | Alokasi fiber berbagi, misalnya `1/32` |
| Periode Awal Kontrak | Tanggal awal kerja sama pertama pelanggan |
| Periode Berjalan | Periode kontrak aktif/terbaru |
| Contract | Dokumen kontrak/BAK/legal nyata pelanggan |
| Contract Version | Snapshot/revisi/amendment opsional dari kontrak |
| Renewal | Proses perpanjangan/kelanjutan kontrak |
| Pemutusan | Terminasi layanan/kontrak |
| FO | Fiber Optik |
| Valhalla | Routing engine berbasis OSM |
| Supabase | Platform backend untuk database, auth, storage, dan REST API |

---

**Dokumen ini terakhir diperbarui:** 2026-05-13  
**Versi:** 1.2  
**Status:** Active Development
