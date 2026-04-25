# Backend Structure Guide

Panduan ini jadi patokan saat menambah file, endpoint, atau modul baru di backend.

## 1. Prinsip Utama

- Organisasi utama mengikuti fitur/domain, bukan layer global.
- Controller menangani HTTP boundary saja.
- Business flow diletakkan di service.
- Query dan persistensi database diletakkan di Prisma service.
- DTO request disimpan dekat dengan fitur yang memakainya.
- `shared/` hanya untuk hal yang benar-benar lintas fitur.

## 2. Struktur Folder Dasar

Setiap fitur utama diletakkan di bawah `src/`.

Contoh:

```text
src/
  customers/
  documents/
  isps/
  monitoring/
  prisma/
  config/
  shared/
```

## 3. Template Modul Fitur

Saat membuat fitur baru, gunakan template ini sebagai default:

```text
feature-name/
  dto/
    create-feature-name.dto.ts
    update-feature-name.dto.ts
  feature-name.controller.ts
  feature-name.service.ts
  prisma-feature-name.service.ts
  feature-name.module.ts
```

Jika kebutuhan database kompleks, boleh dipecah lebih jauh:

```text
feature-name/
  dto/
  feature-name.controller.ts
  feature-name.service.ts
  prisma-feature-name-read.service.ts
  prisma-feature-name-write.service.ts
  feature-name.module.ts
```

Pola read/write dipakai hanya jika benar-benar membantu. Jangan dipaksakan ke modul kecil.

## 4. Tanggung Jawab Tiap File

### `*.controller.ts`

Tugas controller:

- menerima `@Param`, `@Body`, `@Query`
- memakai DTO dan pipe untuk validasi
- memanggil service
- mengembalikan hasil

Controller sebaiknya tidak berisi:

- query Prisma
- logika bisnis panjang
- update state bercabang yang kompleks
- mapping database yang berat

### `*.service.ts`

Tugas service:

- mengatur alur bisnis
- memilih langkah apa yang harus dijalankan
- memanggil satu atau lebih Prisma service
- menangani aturan domain

### `prisma-*.service.ts`

Tugas Prisma service:

- query database
- transaksi
- mapping hasil database
- persistensi data

Kalau file ini mulai memuat terlalu banyak alur bisnis lintas use case, pertimbangkan pecah fungsi atau split read/write.

### `dto/*.dto.ts`

DTO dipakai untuk:

- validasi request body
- transform nilai request
- mendefinisikan kontrak input endpoint

Semua request body endpoint baru harus punya DTO sendiri jika payload-nya bukan bentuk yang sangat sederhana.

## 5. Naming Convention

Gunakan nama file yang menjelaskan fungsi secara eksplisit.

### Disarankan

- `create-customer.dto.ts`
- `update-customer.dto.ts`
- `upload-renewal-file.dto.ts`
- `respond-contract-version-renewal.dto.ts`
- `prisma-customers-read.service.ts`
- `prisma-customers-write.service.ts`

### Hindari

- `helper.ts`
- `utils.ts`
- `types.ts`
- `service2.ts`
- `misc.dto.ts`

Kalau nama file terlalu umum, biasanya tanggung jawab file itu juga sedang kabur.

## 6. Kapan Masuk `shared/`

Masukkan ke `shared/` hanya jika dipakai banyak fitur dan tidak dimiliki satu domain tertentu.

Contoh yang cocok:

- enum domain umum
- util formatting umum
- type umum lintas modul

Contoh yang tidak cocok:

- response shape khusus customer
- helper khusus ISP
- DTO khusus document upload

Kalau hanya dipakai satu fitur, taruh di folder fitur itu.

## 7. Kapan Menambah DTO Baru

Tambahkan DTO baru jika endpoint:

- menerima lebih dari satu field body
- punya field optional + required campuran
- butuh validasi angka/string/enum
- menerima payload multipart dengan metadata

Contoh pola:

```text
customers/dto/upload-contract-version-renewal-file.dto.ts
customers/dto/respond-contract-version-renewal.dto.ts
```

## 8. Checklist Saat Menambah Endpoint Baru

Saat membuat endpoint baru, cek urutan ini:

1. Tentukan fitur/domain tempat endpoint berada.
2. Buat DTO request jika payload tidak trivial.
3. Tambahkan method di controller.
4. Pindahkan alur bisnis ke service.
5. Pindahkan query database ke Prisma service.
6. Pastikan nama file dan method jelas.
7. Jalankan `npm run build`.
8. Jalankan `npm test -- --runInBand`.
9. Jalankan `npm run lint`.

## 9. Checklist Review Mandiri

Sebelum menganggap perubahan selesai, tanyakan:

- Apakah controller saya tipis?
- Apakah request body sudah pakai DTO?
- Apakah validasi ada di boundary layer?
- Apakah query database tidak bocor ke controller?
- Apakah file ini punya satu tanggung jawab utama?
- Apakah sesuatu yang saya taruh di `shared/` benar-benar lintas fitur?

## 10. Aturan Praktis Harian

Versi singkatnya:

- fitur masuk folder domain
- request body pakai DTO
- controller tipis
- business logic di service
- query database di Prisma service
- `shared/` jangan jadi gudang campur aduk

Kalau ragu mau taruh file di mana, default-nya taruh dekat fitur yang paling memiliki file itu.
