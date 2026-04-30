BEGIN;

SET search_path TO public;

DROP TABLE IF EXISTS tmp_import_raw;
CREATE TEMP TABLE tmp_import_raw AS
WITH source_json AS (
  SELECT t.item, t.ordinality
  FROM jsonb_array_elements(
$json$
[
  {
    "no": 1,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Bank Tabungan Negara (Persero)",
    "periode_awal_kontrak": "25-Jul-22",
    "periode_berjalan": {
      "awal": "08-Jul-25",
      "akhir": "07-Jul-26"
    },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": null,
    "nomor_invoice": "065/INV.FO/XII/2022",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": {
      "bulanan": 250000,
      "tahunan": 3000000
    },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2022": { "Jan": 0, "Feb": 0, "Mar": 0, "Apr": 0, "May": 0, "Jun": 0, "Jul": 0, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2023": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 2,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Bank Tabungan Negara (Persero)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-42/DBO/FO/IX/2023",
    "nomor_invoice": "187/INV.FO/XI/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2023": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 3,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Bank Tabungan Negara (Persero)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-38/DBO/FO/VI/2024",
    "nomor_invoice": "INV-065/KIMA/FO/VII/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Bank Tabungan Negara (Persero)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA-BAK-32/DBO/FO/VII/2025",
    "nomor_invoice": "087/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 4,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Karya Teknik Mulia (PT Wastec International)",
    "periode_awal_kontrak": "15-Aug-22",
    "periode_berjalan": { "awal": "18-Aug-25", "akhir": "17-Aug-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": null,
    "nomor_invoice": "067/INV.FO/XII/2022",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2022": { "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2023": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 5,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Karya Teknik Mulia (PT Wastec International)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-43/DBO/FO/IX/2023",
    "nomor_invoice": "188/INV.FO/XI/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2023": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 6,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Karya Teknik Mulia (PT Wastec International)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-54/DBO/FO/IX/2024",
    "nomor_invoice": "INV-016/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Karya Teknik Mulia (PT Wastec International)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-46/DBO/FO/X/2025",
    "nomor_invoice": "090/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 13,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Charoen Pokphand Indonesia",
    "periode_awal_kontrak": "01-Jan-24",
    "periode_berjalan": { "awal": "01-Jan-26", "akhir": "31-Dec-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-54/DBO/FO/XII/2023",
    "nomor_invoice": "INV-024/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 14,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Charoen Pokphand Indonesia",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-70/DBO/FO/XII/2024",
    "nomor_invoice": "INV-027/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Charoen Pokphand Indonesia",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": "1/8",
    "nomor_kontrak": "KIMA.BAK-60/DBO/FO/XII/2025",
    "nomor_invoice": "009/FO/1/26",
    "status": "-",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 1000000, "tahunan": 12000000 },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2026": { "Jan": 1000000, "Feb": 1000000, "Mar": 1000000, "Apr": 1000000, "May": 1000000, "Jun": 1000000, "Jul": 1000000, "Aug": 1000000, "Sep": 1000000, "Oct": 1000000, "Nov": 1000000, "Dec": 1000000 }
    }
  },
  {
    "no": 15,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Enseval Putra Megatrading Tbk",
    "periode_awal_kontrak": "15-Mar-23",
    "periode_berjalan": { "awal": "15-Mar-25", "akhir": "14-Mar-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-18/DBO/FO/V/2023",
    "nomor_invoice": "120/INV.FO/VI/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2023": { "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 16,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Enseval Putra Megatrading Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-23/DBO/FO/VI/2024",
    "nomor_invoice": "INV-029/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Enseval Putra Megatrading Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-61/DBO/FO/X/2025",
    "nomor_invoice": "010/FO/1/26",
    "status": "-",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 17,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Gajah Tunggal Tbk",
    "periode_awal_kontrak": "21-Aug-23",
    "periode_berjalan": { "awal": "21-Aug-25", "akhir": "20-Aug-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-62/DBO/FO/VIII/2023",
    "nomor_invoice": "168/INV.FO/IX/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2023": { "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 18,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Gajah Tunggal Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-71/DBO/FO/XII/2024",
    "nomor_invoice": "INV-028/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Gajah Tunggal Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-67/DBO/FO/XII/2025",
    "nomor_invoice": "011/FO/1/26",
    "status": "-",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 19,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT HM Sampoerna Tbk",
    "periode_awal_kontrak": "02-Dec-24",
    "periode_berjalan": { "awal": "02-Dec-25", "akhir": "01-Dec-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-44/DBO/FO/XII/2024",
    "nomor_invoice": "INV-022/KIMA/FO/XII/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT HM Sampoerna Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-59/DBO/FO/XII/2025",
    "nomor_invoice": "103/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000 }
    }
  },
  {
    "no": 20,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Indomarco Prismatama (Indomaret)",
    "periode_awal_kontrak": "01-Apr-23",
    "periode_berjalan": { "awal": "01-Apr-25", "akhir": "31-Mar-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-40/DBO/FO/III/2023",
    "nomor_invoice": "122/INV.FO/VI/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2023": { "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 21,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Indomarco Prismatama (Indomaret)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-34/DBO/FO/IV/2024",
    "nomor_invoice": "INV-032/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Indomarco Prismatama (Indomaret)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-58/DBO/FO/XII/2025",
    "nomor_invoice": "102/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000 }
    }
  },
  {
    "no": 23,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Manggala Kiat Ananda",
    "periode_awal_kontrak": "14-Jun-24",
    "periode_berjalan": { "awal": "14-Jun-25", "akhir": "13-Jun-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-26/DBO/FO/VI/2024",
    "nomor_invoice": "INV-033/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Manggala Kiat Ananda",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-36/DBO/FO/VII/2025",
    "nomor_invoice": "092/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000 }
    }
  },
  {
    "no": 24,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT MC PET Film Indonesia",
    "periode_awal_kontrak": "06-Mar-24",
    "periode_berjalan": { "awal": "06-Mar-25", "akhir": "05-Mar-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-08/DBO/FO/III/2024",
    "nomor_invoice": "INV-034/KIMA/FO/III/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT MC PET Film Indonesia",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-37/DBO/FO/VII/2025",
    "nomor_invoice": "093/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000 }
    }
  },
  {
    "no": 25,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Multi Bintang Indonesia Tbk",
    "periode_awal_kontrak": "31-Jul-23",
    "periode_berjalan": { "awal": "31-Jul-25", "akhir": "30-Jul-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-57/DBO/FO/VIII/2023",
    "nomor_invoice": "129/INV.FO/VII/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2023": { "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 27,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Multi Bintang Indonesia Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-65/DBO/FO/X/2024",
    "nomor_invoice": "INV-021/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2024": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Multi Bintang Indonesia Tbk",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-57/DBO/FO/XI/2025",
    "nomor_invoice": "100/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000 }
    }
  },
  {
    "no": 28,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT So Good Food",
    "periode_awal_kontrak": "16-Sep-22",
    "periode_berjalan": { "awal": "16-Sep-25", "akhir": "15-Sep-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": null,
    "nomor_invoice": "068/INV.FO/XII/2022",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2022": { "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2023": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 29,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT So Good Food",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-64/DBO/FO/X/2024",
    "nomor_invoice": "INV-019/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2024": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT So Good Food",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-56/DBO/FO/XI/2025",
    "nomor_invoice": "101/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000 }
    }
  },
  {
    "no": 30,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Wastec International (Kima Raya 1)",
    "periode_awal_kontrak": "02-Oct-23",
    "periode_berjalan": { "awal": "02-Oct-25", "akhir": "01-Oct-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-17/DBO/FO/X/2023",
    "nomor_invoice": "181/INV.FO/X/2023",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2023": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2024": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": 31,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Wastec International (Kima Raya 1)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-63/DBO/FO/X/2024",
    "nomor_invoice": "INV-020/KIMA/FO/I/2025",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2024": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Wastec International (Kima Raya 1)",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-50/DBO/FO/XI/2025",
    "nomor_invoice": "104/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000 }
    }
  },
  {
    "no": 34,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Maruki International",
    "periode_awal_kontrak": "14-Jun-24",
    "periode_berjalan": { "awal": "14-Jun-25", "akhir": "13-Jun-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-24/DBO/FO/VI/2024",
    "nomor_invoice": "INV-030/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Maruki International",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-34/DBO/FO/VII/2025",
    "nomor_invoice": "091/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000 }
    }
  },
  {
    "no": 35,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Traktor Nusantara",
    "periode_awal_kontrak": "14-Jun-24",
    "periode_berjalan": { "awal": "14-Jun-25", "akhir": "13-Jun-26" },
    "core": "-",
    "sharing_core": "1/32",
    "nomor_kontrak": "KIMA.BAK-25/DBO/FO/VI/2024",
    "nomor_invoice": "INV-031/KIMA/FO/VI/2024",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": 250000, "tahunan": 3000000 },
    "biaya_aktivasi": 2500000,
    "pembayaran_bulanan": {
      "2024": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2025": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 }
    }
  },
  {
    "no": null,
    "nama_isp": "PT Cendikia Global Solusi",
    "nama_pelanggan": "PT Traktor Nusantara",
    "periode_awal_kontrak": null,
    "periode_berjalan": { "awal": null, "akhir": null },
    "core": null,
    "sharing_core": null,
    "nomor_kontrak": "KIMA.BAK-35/DBO/FO/VII/2025",
    "nomor_invoice": "089/FO/11/25",
    "status": "Lunas",
    "keterangan": null,
    "nilai_kontrak": { "bulanan": null, "tahunan": null },
    "biaya_aktivasi": null,
    "pembayaran_bulanan": {
      "2025": { "Jun": 250000, "Jul": 250000, "Aug": 250000, "Sep": 250000, "Oct": 250000, "Nov": 250000, "Dec": 250000 },
      "2026": { "Jan": 250000, "Feb": 250000, "Mar": 250000, "Apr": 250000, "May": 250000, "Jun": 250000 }
    }
  }
]
$json$::jsonb
  ) WITH ORDINALITY AS t(item, ordinality)
)
SELECT
  ordinality::int AS source_row_id,
  NULLIF(trim(item ->> 'nama_isp'), '') AS nama_isp,
  NULLIF(trim(item ->> 'nama_pelanggan'), '') AS nama_pelanggan,
  NULLIF(trim(item ->> 'periode_awal_kontrak'), '') AS periode_awal_kontrak,
  NULLIF(trim(item #>> '{periode_berjalan,awal}'), '') AS periode_berjalan_awal,
  NULLIF(trim(item #>> '{periode_berjalan,akhir}'), '') AS periode_berjalan_akhir,
  NULLIF(trim(item ->> 'core'), '') AS core_raw,
  NULLIF(trim(item ->> 'sharing_core'), '') AS sharing_core_raw,
  NULLIF(trim(item ->> 'nomor_kontrak'), '') AS nomor_kontrak,
  NULLIF(trim(item ->> 'nomor_invoice'), '') AS nomor_invoice,
  NULLIF(trim(item ->> 'status'), '') AS status_raw,
  NULLIF(trim(item ->> 'keterangan'), '') AS keterangan,
  NULLIF(item #>> '{nilai_kontrak,bulanan}', '')::numeric(18,2) AS nilai_bulanan,
  NULLIF(item #>> '{nilai_kontrak,tahunan}', '')::numeric(18,2) AS nilai_tahunan,
  NULLIF(item ->> 'biaya_aktivasi', '')::numeric(18,2) AS biaya_aktivasi,
  COALESCE(item -> 'pembayaran_bulanan', '{}'::jsonb) AS pembayaran_bulanan
FROM source_json;

DROP TABLE IF EXISTS tmp_import_payments;
CREATE TEMP TABLE tmp_import_payments AS
SELECT
  r.source_row_id,
  r.nama_pelanggan,
  r.nomor_kontrak,
  r.nomor_invoice,
  r.status_raw,
  yr.key::int AS period_year,
  CASE mn.key
    WHEN 'Jan' THEN 1
    WHEN 'Feb' THEN 2
    WHEN 'Mar' THEN 3
    WHEN 'Apr' THEN 4
    WHEN 'May' THEN 5
    WHEN 'Jun' THEN 6
    WHEN 'Jul' THEN 7
    WHEN 'Aug' THEN 8
    WHEN 'Sep' THEN 9
    WHEN 'Oct' THEN 10
    WHEN 'Nov' THEN 11
    WHEN 'Dec' THEN 12
  END AS period_month,
  NULLIF(mn.value, '')::numeric(18,2) AS amount
FROM tmp_import_raw r
CROSS JOIN LATERAL jsonb_each(r.pembayaran_bulanan) AS yr(key, value)
CROSS JOIN LATERAL jsonb_each_text(yr.value) AS mn(key, value)
WHERE NULLIF(mn.value, '')::numeric(18,2) > 0;

DROP TABLE IF EXISTS tmp_import_contract_dates;
CREATE TEMP TABLE tmp_import_contract_dates AS
SELECT
  source_row_id,
  MIN(make_date(period_year, period_month, 1)) AS first_payment_date,
  MAX((date_trunc('month', make_date(period_year, period_month, 1)) + interval '1 month - 1 day')::date) AS last_payment_date
FROM tmp_import_payments
GROUP BY source_row_id;

DROP TABLE IF EXISTS tmp_import_contracts;
CREATE TEMP TABLE tmp_import_contracts AS
SELECT
  r.source_row_id,
  r.nama_isp,
  r.nama_pelanggan,
  COALESCE(
    r.nomor_kontrak,
    format(
      'IMP-AUTO-%s-%s',
      to_char(
        COALESCE(
          to_date(r.periode_awal_kontrak, 'DD-Mon-YY'),
          to_date(r.periode_berjalan_awal, 'DD-Mon-YY'),
          d.first_payment_date,
          CURRENT_DATE
        ),
        'YYYYMMDD'
      ),
      lpad(r.source_row_id::text, 4, '0')
    )
  ) AS resolved_contract_number,
  COALESCE(
    to_date(r.periode_awal_kontrak, 'DD-Mon-YY'),
    to_date(r.periode_berjalan_awal, 'DD-Mon-YY'),
    d.first_payment_date,
    CURRENT_DATE
  ) AS contract_start_date,
  COALESCE(
    to_date(r.periode_berjalan_akhir, 'DD-Mon-YY'),
    d.last_payment_date,
    COALESCE(
      to_date(r.periode_awal_kontrak, 'DD-Mon-YY'),
      to_date(r.periode_berjalan_awal, 'DD-Mon-YY'),
      CURRENT_DATE
    )
  ) AS contract_end_date,
  CASE
    WHEN NULLIF(regexp_replace(COALESCE(r.core_raw, ''), '[^0-9]', '', 'g'), '') IS NOT NULL
      THEN 'core'::core_allocation_type
    ELSE 'sharing_core'::core_allocation_type
  END AS core_type,
  COALESCE(NULLIF(regexp_replace(COALESCE(r.core_raw, ''), '[^0-9]', '', 'g'), '')::int, 0) AS core_total,
  CASE
    WHEN r.sharing_core_raw IN ('-', '') THEN NULL
    ELSE r.sharing_core_raw
  END AS sharing_ratio,
  COALESCE(r.nilai_bulanan, 0)::numeric(18,2) AS nilai_bulanan,
  COALESCE(r.nilai_tahunan, 0)::numeric(18,2) AS nilai_tahunan,
  COALESCE(r.biaya_aktivasi, 0)::numeric(18,2) AS biaya_aktivasi
FROM tmp_import_raw r
LEFT JOIN tmp_import_contract_dates d
  ON d.source_row_id = r.source_row_id;

DROP TABLE IF EXISTS tmp_customer_seed;
CREATE TEMP TABLE tmp_customer_seed AS
WITH ranked_customers AS (
  SELECT
    nama_pelanggan,
    MIN(nama_isp) AS nama_isp,
    MAX(biaya_aktivasi) AS activation_fee_amount,
    MIN(
      CASE
        WHEN biaya_aktivasi IS NOT NULL AND biaya_aktivasi > 0 AND periode_awal_kontrak IS NOT NULL
          THEN to_date(periode_awal_kontrak, 'DD-Mon-YY')
      END
    ) AS activation_fee_paid_at,
    ROW_NUMBER() OVER (ORDER BY nama_pelanggan) AS customer_seq
  FROM tmp_import_raw
  GROUP BY nama_pelanggan
)
SELECT
  nama_pelanggan,
  nama_isp,
  format('CUST-IMP-%s', lpad(customer_seq::text, 4, '0')) AS customer_code,
  activation_fee_amount::numeric(18,2),
  activation_fee_paid_at
FROM ranked_customers;

INSERT INTO isps (
  name,
  status,
  paket,
  jumlah,
  created_at,
  updated_at
)
SELECT
  nama_isp,
  'aktif'::isp_status,
  CASE
    WHEN COUNT(*) FILTER (
      WHERE NULLIF(regexp_replace(COALESCE(core_raw, ''), '[^0-9]', '', 'g'), '') IS NOT NULL
    ) > 0 THEN 'core'::isp_package_type
    ELSE 'shared'::isp_package_type
  END,
  GREATEST(
    1,
    COALESCE(
      MAX(NULLIF(regexp_replace(COALESCE(core_raw, ''), '[^0-9]', '', 'g'), '')::int),
      1
    )
  ),
  NOW(),
  NOW()
FROM tmp_import_raw
GROUP BY nama_isp
ON CONFLICT (name) DO UPDATE
SET
  status = EXCLUDED.status,
  paket = EXCLUDED.paket,
  jumlah = EXCLUDED.jumlah,
  updated_at = NOW();

UPDATE customers AS c
SET
  customer_code = s.customer_code,
  isp_name = s.nama_isp,
  status = 'aktif'::customer_status,
  activation_fee_amount = COALESCE(s.activation_fee_amount, 0),
  activation_fee_paid_at = s.activation_fee_paid_at,
  updated_at = NOW()
FROM tmp_customer_seed AS s
WHERE c.name = s.nama_pelanggan;

INSERT INTO customers (
  customer_code,
  isp_name,
  name,
  status,
  activation_fee_amount,
  activation_fee_paid_at,
  created_at,
  updated_at
)
SELECT
  s.customer_code,
  s.nama_isp,
  s.nama_pelanggan,
  'aktif'::customer_status,
  COALESCE(s.activation_fee_amount, 0),
  s.activation_fee_paid_at,
  NOW(),
  NOW()
FROM tmp_customer_seed AS s
WHERE NOT EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.name = s.nama_pelanggan
);

INSERT INTO customer_isp_memberships (
  customer_id,
  isp_id,
  created_at,
  updated_at
)
SELECT
  c.id,
  i.id,
  NOW(),
  NOW()
FROM tmp_customer_seed AS s
JOIN customers AS c
  ON c.name = s.nama_pelanggan
JOIN isps AS i
  ON i.name = s.nama_isp
WHERE NOT EXISTS (
  SELECT 1
  FROM customer_isp_memberships AS m
  WHERE m.customer_id = c.id
    AND m.isp_id = i.id
);

INSERT INTO contracts (
  customer_id,
  contract_number,
  start_date,
  end_date,
  core_type,
  core_total,
  sharing_ratio,
  status,
  billing_every,
  billing_unit,
  created_at,
  updated_at
)
SELECT
  c.id,
  ic.resolved_contract_number,
  ic.contract_start_date,
  ic.contract_end_date,
  ic.core_type,
  ic.core_total,
  ic.sharing_ratio,
  CASE
    WHEN ic.contract_end_date < CURRENT_DATE THEN 'expired'::contract_status
    ELSE 'aktif'::contract_status
  END,
  1,
  'bulan'::billing_unit,
  NOW(),
  NOW()
FROM tmp_import_contracts AS ic
JOIN customers AS c
  ON c.name = ic.nama_pelanggan
ON CONFLICT (contract_number) DO UPDATE
SET
  customer_id = EXCLUDED.customer_id,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  core_type = EXCLUDED.core_type,
  core_total = EXCLUDED.core_total,
  sharing_ratio = EXCLUDED.sharing_ratio,
  status = EXCLUDED.status,
  billing_every = EXCLUDED.billing_every,
  billing_unit = EXCLUDED.billing_unit,
  updated_at = NOW();

INSERT INTO contract_versions (
  contract_id,
  customer_id,
  version_number,
  start_date,
  end_date,
  core_type,
  core_total,
  shared_core_ratio,
  created_at,
  updated_at
)
SELECT
  ct.id,
  c.id,
  1,
  ic.contract_start_date,
  ic.contract_end_date,
  ic.core_type,
  ic.core_total,
  ic.sharing_ratio,
  NOW(),
  NOW()
FROM tmp_import_contracts AS ic
JOIN customers AS c
  ON c.name = ic.nama_pelanggan
JOIN contracts AS ct
  ON ct.contract_number = ic.resolved_contract_number
ON CONFLICT (contract_id, version_number) DO UPDATE
SET
  customer_id = EXCLUDED.customer_id,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  core_type = EXCLUDED.core_type,
  core_total = EXCLUDED.core_total,
  shared_core_ratio = EXCLUDED.shared_core_ratio,
  updated_at = NOW();

DROP TABLE IF EXISTS tmp_invoice_seed;
CREATE TEMP TABLE tmp_invoice_seed AS
WITH ranked AS (
  SELECT
    p.source_row_id,
    p.nama_pelanggan,
    p.nomor_kontrak,
    p.nomor_invoice,
    p.status_raw,
    p.period_year,
    p.period_month,
    p.amount,
    ROW_NUMBER() OVER (
      PARTITION BY p.nama_pelanggan, p.period_year, p.period_month
      ORDER BY p.source_row_id DESC
    ) AS rn
  FROM tmp_import_payments AS p
)
SELECT
  r.source_row_id,
  r.nama_pelanggan,
  r.nomor_invoice,
  r.status_raw,
  r.period_year,
  r.period_month,
  r.amount,
  ic.resolved_contract_number
FROM ranked AS r
JOIN tmp_import_contracts AS ic
  ON ic.source_row_id = r.source_row_id
WHERE r.rn = 1;

INSERT INTO invoices (
  customer_id,
  invoice_number,
  contract_id,
  contract_version_id,
  contract_number,
  period_month,
  period_year,
  period_start_date,
  period_end_date,
  due_date,
  amount,
  status,
  paid_at,
  created_at,
  updated_at
)
SELECT
  c.id,
  CASE
    WHEN s.nomor_invoice IS NULL OR s.nomor_invoice = '-' THEN NULL
    ELSE s.nomor_invoice
  END,
  ct.id,
  cv.id,
  ct.contract_number,
  s.period_month,
  s.period_year,
  make_date(s.period_year, s.period_month, 1),
  (date_trunc('month', make_date(s.period_year, s.period_month, 1)) + interval '1 month - 1 day')::date,
  (date_trunc('month', make_date(s.period_year, s.period_month, 1)) + interval '1 month - 1 day')::date,
  s.amount,
  CASE
    WHEN s.status_raw = 'Lunas' THEN 'lunas'::invoice_status
    ELSE 'belum_ditagih'::invoice_status
  END,
  CASE
    WHEN s.status_raw = 'Lunas'
      THEN (date_trunc('month', make_date(s.period_year, s.period_month, 1)) + interval '1 month - 1 day')::timestamp
    ELSE NULL
  END,
  NOW(),
  NOW()
FROM tmp_invoice_seed AS s
JOIN customers AS c
  ON c.name = s.nama_pelanggan
JOIN contracts AS ct
  ON ct.contract_number = s.resolved_contract_number
JOIN contract_versions AS cv
  ON cv.contract_id = ct.id
 AND cv.version_number = 1
WHERE NOT EXISTS (
  SELECT 1
  FROM invoices AS i
  WHERE i.customer_id = c.id
    AND COALESCE(i.contract_id, 0) = ct.id
    AND i.period_year = s.period_year
    AND i.period_month = s.period_month
    AND i.amount = s.amount
);

COMMIT;
