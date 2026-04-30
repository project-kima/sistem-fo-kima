# SQL Import

File di folder ini:

- `import_data_bulanan_excel_1_35.sql`
- `import_data_bulanan_excel_35_71.sql`
- `import_data_bulanan_excel_71_121.sql`
- `import_data_bulanan_excel_121_168.sql`

Asumsi yang dipakai script impor:

- Sumber data: `backend/scripts/data-bulanan-excel-1-35.json`
- Database target: PostgreSQL 16, schema `public`
- Tabel yang diisi: `isps`, `customers`, `customer_isp_memberships`, `contracts`, `contract_versions`, `invoices`
- Jika `nomor_kontrak` kosong, script membuat nomor sintetis `IMP-AUTO-...`
- `pembayaran_bulanan` dipecah menjadi invoice per bulan
- Ada overlap bulan untuk customer yang sama di file sumber; untuk kasus ini script mengambil baris paling akhir di JSON sebagai data yang menang
- `status = 'Lunas'` dipetakan ke `invoice_status.lunas`, selain itu ke `invoice_status.belum_ditagih`
- File `import_data_bulanan_excel_71_121.sql` memakai format sumber yang berbeda: satu baris sumber dipetakan menjadi satu kontrak dan satu invoice representatif

Cara pakai:

```bash
psql "$DATABASE_URL" -f sql/import_data_bulanan_excel_1_35.sql
```

Jika database ingin dikosongkan lebih dulu, jalankan SQL truncate yang sebelumnya sudah saya berikan, lalu baru jalankan file impor ini.
