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

- ISP adalah vendor/mitra penyedia layanan atau pihak yang menaungi kontrak pelanggan tertentu.
- Pelanggan/tenant adalah klien akhir yang menerima layanan dari ISP/vendor.
- Pelanggan/tenant dapat terhubung ke satu atau lebih ISP melalui relasi membership.
- Data pelanggan menjadi pusat untuk kontrak, dokumen, invoice, route, dan timeline aktivitas.
- Contoh mapping yang benar: `PT Cendikia Global Solusi` adalah ISP/vendor, sedangkan `PT Bank Tabungan Negara (Persero)` dan `PT Karya Teknik Mulia (PT Wastec International)` adalah pelanggan/tenant.

### 4.2 Awal Kerja Sama Pelanggan

- `customers.contract_start_date` menyimpan tanggal pertama kali pelanggan bekerja sama dengan KIMA.
- Tanggal ini ditampilkan sebagai **Periode Awal Kontrak**.
- Nilai ini tidak sama dengan periode berjalan setiap kontrak, dan tidak boleh dihapus dari tampilan karena dipakai untuk mengetahui awal hubungan bisnis.
- Biaya aktivasi hanya dikenakan satu kali di awal kerja sama.
- Biaya aktivasi disimpan di data pelanggan, bukan di setiap kontrak.
- Jika satu ISP/vendor memiliki beberapa pelanggan, biaya aktivasi dicatat per pelanggan yang memang dikenakan biaya aktivasi.

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

- Invoice dibuat per periode tagihan berdasarkan pembayaran bulanan pada kontrak pelanggan.
- Monitoring billing menampilkan status invoice per pelanggan dan bulan.
- Status invoice yang digunakan:
  - `lunas`,
  - `belum_bayar`,
  - `terlambat`,
  - `belum_ditagih`.
- Follow-up invoice digunakan untuk mencatat proses penagihan.

#### Contoh dataset PT Cendikia Global Solusi

Data PT Cendikia Global Solusi digunakan sebagai contoh flow bisnis aktual:

| Komponen | Nilai |
| --- | --- |
| ISP/vendor | PT Cendikia Global Solusi |
| Total pelanggan | 2 |
| Pelanggan 1 | PT Bank Tabungan Negara (Persero) |
| Pelanggan 2 | PT Karya Teknik Mulia (PT Wastec International) |
| Total kontrak | 8 |
| Total invoice | 96 |
| Nilai invoice bulanan | Rp 250.000 per kontrak |
| Grand total invoice | Rp 24.000.000 |
| Total biaya aktivasi | Rp 5.000.000 |
| Status invoice | Semua lunas |

Periode invoice untuk contoh tersebut:

| Pelanggan | Periode invoice pertama | Periode invoice terakhir | Jumlah invoice |
| --- | --- | --- | --- |
| PT Bank Tabungan Negara (Persero) | Juli 2022 | Juni 2026 | 48 |
| PT Karya Teknik Mulia (PT Wastec International) | Agustus 2022 | Juli 2026 | 48 |

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
| `isps` | Data ISP mitra, paket, periode, status, dan metadata billing |
| `isp_contract_rows` | Baris kontrak/periode ISP bila tersedia |
| `isp_renewal_follow_ups` | Follow-up renewal kontrak ISP |
| `customers` | Data pelanggan, status, kode unik, awal kerja sama, biaya aktivasi, dan catatan |
| `customer_isp_memberships` | Relasi many-to-many pelanggan dengan ISP |
| `contracts` | Dokumen kontrak/BAK/legal pelanggan; sumber kebenaran nomor kontrak, periode, dan paket |
| `contract_versions` | Snapshot/revisi/amendment opsional dari kontrak; dipakai juga untuk nominal bulanan/tahunan yang tampil di monitoring |
| `contract_version_renewal_follow_ups` | Follow-up renewal kontrak pelanggan |
| `documents` | Arsip dokumen pelanggan/kontrak/versi kontrak/invoice |
| `invoices` | Invoice per periode tagihan dan sumber status monitoring billing |
| `invoice_follow_ups` | Follow-up penagihan invoice |
| `customer_route_versions` | Versi jalur FO pelanggan |
| `customer_route_points` | Titik awal/transit/tujuan jalur FO |
| `customer_route_history` | Riwayat perubahan jalur FO |

### 6.1 Aturan Schema Supabase Aktual

Bagian ini mendokumentasikan aturan database production yang harus diikuti oleh script insert/update manual.

#### `isps`

- `name` adalah nama ISP/vendor.
- `status` menggunakan status operasional seperti `aktif`, `nonaktif`, `expired`, atau `berhenti` sesuai kebutuhan tampilan.
- `paket` bertipe enum `isp_package_type`, sehingga nilai string harus di-cast eksplisit saat dipakai di SQL manual. Nilai yang digunakan script saat ini antara lain:
  - `core`
  - `shared`
- `billing_period_mode` digunakan untuk pola billing ISP, misalnya `monthly`.
- `activation_fee_amount` pada ISP bukan sumber utama biaya aktivasi pelanggan; biaya aktivasi operasional pelanggan tetap disimpan di `customers.activation_fee_amount`.

#### `customers`

- `customer_code` dipakai sebagai kode unik operasional untuk seed/upsert data produksi.
- `name` adalah nama pelanggan/tenant. Jika spreadsheet berisi nilai seperti `Core` pada kolom pelanggan, nilai tersebut diperlakukan sebagai nama pelanggan selama posisinya memang berada di kolom pelanggan.
- `isp_name` dipertahankan sebagai denormalisasi nama ISP untuk kompatibilitas tampilan, tetapi relasi utama pelanggan-ISP tetap melalui `customer_isp_memberships`.
- `contract_start_date` menyimpan awal kerja sama pertama pelanggan dengan KIMA.
- `activation_fee_amount` menyimpan biaya aktivasi pelanggan dan hanya diisi pada awal kerja sama atau ketika data aktivasi memang tersedia.

#### `customer_isp_memberships`

- Relasi pelanggan ke ISP bersifat many-to-many.
- Script produksi harus membuat membership jika belum ada, bukan hanya mengisi `customers.isp_name`.

#### `contracts`

- `contracts` adalah sumber utama untuk nomor kontrak, periode kontrak, status kontrak, dan paket kontrak.
- Kolom penting yang dipakai aplikasi dan script:
  - `customer_id`
  - `contract_number`
  - `start_date`
  - `end_date`
  - `core_type`
  - `core_total`
  - `sharing_ratio`
  - `status`
  - `billing_every`
  - `billing_unit`
- `status` bertipe enum `contract_status`; script manual harus cast nilai seperti `aktif` atau `expired` ke `contract_status` bila diperlukan.
- `core_type` bertipe enum/constraint `core_allocation_type` dengan nilai utama:
  - `core`
  - `sharing_core`
- Bentuk paket wajib konsisten:
  - Jika `core_type = 'core'`, maka `core_total > 0` dan `sharing_ratio` harus kosong/null.
  - Jika `core_type = 'sharing_core'`, maka `sharing_ratio` wajib terisi dan `core_total` kosong/null atau `0`.
- Paket kontrak baru boleh diwariskan dari kontrak sebelumnya hanya jika secara bisnis dikonfirmasi; secara default tidak boleh diasumsikan dari tahun sebelumnya.

#### `contract_versions`

- `contract_versions` adalah snapshot/amendment opsional, tetapi aplikasi monitoring membaca nominal dari versi kontrak terbaru bila tersedia.
- Kolom penting yang dipakai aplikasi dan script:
  - `contract_id`
  - `customer_id`
  - `version_number`
  - `start_date`
  - `end_date`
  - `core_type`
  - `core_total`
  - `shared_core_ratio`
  - `monthly_amount`
  - `yearly_amount`
  - `remarks`
- `monthly_amount` dan `yearly_amount` pada database production wajib terisi (`NOT NULL`). Script import tidak boleh mengirim `NULL` ke dua kolom ini.
- Jika spreadsheet tidak menyediakan nilai bulanan, script harus menghitung fallback yang eksplisit, misalnya `yearly_amount / jumlah_bulan_invoice` atau nominal representatif yang disepakati untuk kontrak campuran.
- Jika spreadsheet tidak menyediakan nilai tahunan, script harus menghitung fallback yang eksplisit, misalnya:
  - total nominal invoice yang dibuat untuk kontrak tersebut; atau
  - `monthly_amount * jumlah_bulan_invoice`; atau
  - `monthly_amount * 12` bila kontrak memang mewakili satu tahun billing penuh.
- `monthly_amount` juga harus diisi ketika data kontrak dipakai untuk monitoring nilai billing.
- Bentuk paket di versi kontrak harus konsisten dengan `contracts`, menggunakan `shared_core_ratio` untuk paket `sharing_core`.

#### `documents`

- Dokumen wajib memiliki `customer_id`, `jenis_dokumen`, `tanggal_dokumen`, dan `file_url`.
- Dokumen dapat terhubung ke:
  - `contract_id`
  - `contract_version_id`
  - `contract_number`
  - invoice melalui `document_id` di `invoices`
- `jenis_dokumen` bertipe enum `document_type` dengan nilai:
  - `permohonan`
  - `penawaran`
  - `tanggapan`
  - `hasil_nego`
  - `BAK`
  - `kontrak`
  - `invoice`
  - `perpanjangan`
  - `pemutusan`
  - `lainnya`
- Untuk seed production, file dokumen boleh berupa placeholder URL hanya jika file asli belum tersedia dan kebutuhan import memang untuk metadata monitoring.

#### `invoices`

- Invoice adalah sumber kebenaran status monitoring bulanan.
- Kolom penting yang dipakai aplikasi dan script:
  - `customer_id`
  - `contract_id`
  - `contract_version_id`
  - `contract_number`
  - `invoice_number`
  - `period_year`
  - `period_month`
  - `period_start_date`
  - `period_end_date`
  - `amount`
  - `status`
  - `schedule_version`
  - `schedule_status`
  - `document_id`
  - `paid_at`
- `period_month` harus berada di rentang `1` sampai `12`.
- `amount` tidak boleh kosong untuk invoice yang dibuat.
- Status invoice yang dipakai aplikasi:
  - `lunas`
  - `belum_bayar`
  - `terlambat`
  - `belum_ditagih`
- Status spreadsheet `-` dan `BT` dipetakan ke `belum_ditagih` untuk import monitoring.
- `schedule_status = 'active'` digunakan frontend untuk monitoring billing; invoice nonaktif tidak dihitung di spreadsheet monitoring aktif.
- Jika data spreadsheet memecah tagihan tahun berikutnya tetapi memakai nomor kontrak yang sama, invoice dibuat pada kontrak yang sama dan tidak membuat row `contracts` baru.
- Untuk kontrak campuran dengan nominal bulanan berbeda per periode, `invoices.amount` menyimpan nominal aktual per bulan, sedangkan `contract_versions.monthly_amount` menyimpan nominal representatif/fallback yang disepakati dan `contract_versions.yearly_amount` harus konsisten dengan total invoice yang dibuat.
- Karena production memiliki constraint unik global pada `contracts.contract_number`, nomor kontrak yang bentrok lintas customer boleh diberi suffix teknis pada `contracts.contract_number`. Nomor dokumen asli tetap harus disimpan di `documents.nomor_dokumen`.

#### Follow-up dan Route

- `invoice_follow_ups` menyimpan follow-up penagihan invoice, termasuk metadata split invoice, file invoice, bukti bayar, dan tanggal bayar bila tersedia.
- `contract_version_renewal_follow_ups` menyimpan follow-up renewal pada level versi kontrak pelanggan.
- `isp_contract_rows` dan `isp_renewal_follow_ups` menyimpan data kontrak/renewal di level ISP jika tersedia.
- `customer_route_versions`, `customer_route_points`, dan `customer_route_history` menyimpan versi jalur, titik jalur, status flow, dan riwayat perubahan route FO.

### 6.2 Aturan Script Production

- Script production harus idempotent: aman dijalankan ulang tanpa membuat duplikasi customer, membership, kontrak, dokumen, atau invoice.
- Upsert customer sebaiknya menggunakan `customer_code`.
- Upsert kontrak sebaiknya menggunakan kombinasi `customer_id` dan `contract_number`.
- Upsert invoice sebaiknya menggunakan kombinasi `customer_id` dan `invoice_number`.
- Semua nilai enum di SQL manual harus di-cast eksplisit bila PostgreSQL tidak bisa infer tipe, misalnya `::isp_package_type`, `::contract_status`, atau `::core_allocation_type`.
- Nilai wajib database, terutama `contract_versions.yearly_amount`, harus selalu diisi. Jika spreadsheet kosong, script harus menghitung fallback dan mencantumkan asumsi perhitungannya.
- Perubahan data production harus disertai verification query di akhir script untuk membandingkan jumlah kontrak, jumlah invoice, total nominal, dan periode invoice pertama/terakhir.

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

**Dokumen ini terakhir diperbarui:** 2026-05-15  
**Versi:** 1.2  
**Status:** Active Development
