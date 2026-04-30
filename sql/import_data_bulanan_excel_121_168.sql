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
    "no": 122,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Cargill Indonesia",
    "tanggal_mulai": "8-Jul-22",
    "tanggal_berakhir_1": "8-Jul-23",
    "tanggal_berakhir_2": "7-Jul-24",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "076/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": 123,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Cargill Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-29/DBO/FO/VI/2023",
    "no_invoice": "156/INV.FO/VII/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 124,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Charoen Pokphand Indonesia",
    "tanggal_mulai": "15-Mar-23",
    "tanggal_berakhir_1": "15-Mar-23",
    "tanggal_berakhir_2": "14-Mar-24",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-11/DBO/FO/III/2023",
    "no_invoice": "106/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": null
  },
  {
    "no": 125,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars Symbioscience Indonesia 1",
    "tanggal_mulai": "13-Mar-23",
    "tanggal_berakhir_1": "13-Mar-23",
    "tanggal_berakhir_2": "12-Mar-24",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-08/DBO/FO/III/2023",
    "no_invoice": "103/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": null
  },
  {
    "no": 126,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Merapi Utama Pharma",
    "tanggal_mulai": "15-Mar-22",
    "tanggal_berakhir_1": "15-Mar-22",
    "tanggal_berakhir_2": "14-Mar-23",
    "slot": "1/16",
    "no_bak": null,
    "no_invoice": null,
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": null
  },
  {
    "no": 127,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Utomodeck Metal Works",
    "tanggal_mulai": "13-Jul-23",
    "tanggal_berakhir_1": "13-Jul-25",
    "tanggal_berakhir_2": "12-Jul-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-30/DBO/FO/VII/2023",
    "no_invoice": "155/INV.FO/VII/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Utomodeck Metal Works",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-14/DBO/FO/V/2025",
    "no_invoice": "INV-058/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Utomodeck Metal Works",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-48/DBO/FO/X/2025",
    "no_invoice": "082/FO/10/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 129,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Merapi Utama Pharma",
    "tanggal_mulai": "26-Jan-23",
    "tanggal_berakhir_1": "26-Jan-25",
    "tanggal_berakhir_2": "25-Jan-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-01/DBO/FO/I/2023",
    "no_invoice": "092/INV.FO/II/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": 130,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Merapi Utama Pharma",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-42/DBO/FO/VII/2024",
    "no_invoice": "INV-076/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Merapi Utama Pharma",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-13/DBO/FO/V/2025",
    "no_invoice": "INV-057/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Sinotrans Overseas Indonesia (Juni)",
    "tanggal_mulai": "4-Jun-25",
    "tanggal_berakhir_1": "4-Jun-25",
    "tanggal_berakhir_2": "3-Jun-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-17/DBO/FO/VI/2025",
    "no_invoice": "084/FO/10/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Sinotrans Overseas Indonesia (Sept)",
    "tanggal_mulai": "10-Sep-25",
    "tanggal_berakhir_1": "10-Sep-25",
    "tanggal_berakhir_2": "9-Sep-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-06/DBO/FO/IX/2025",
    "no_invoice": "083/FO/10/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 133,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Andiarta Muzizat (Ninja Express)",
    "tanggal_mulai": "18-Sep-23",
    "tanggal_berakhir_1": "18-Sep-25",
    "tanggal_berakhir_2": "17-Sep-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-44/DBO/FO/VII/2024",
    "no_invoice": "INV-078/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Andiarta Muzizat (Ninja Express)",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-16/DBO/FO/2025",
    "no_invoice": "INV-060/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Andiarta Muzizat (Ninja Express)",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/32",
    "no_bak": "KIMA0BAK44/DBO/FO/VIII/2025",
    "no_invoice": "083/FO/10/25",
    "status_bayar": "-",
    "keterangan": "Downgrade",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": 132,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Sukses Gatuga Timur",
    "tanggal_mulai": "11-Aug-23",
    "tanggal_berakhir_1": "11-Aug-24",
    "tanggal_berakhir_2": "10-Aug-25",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-43/DBO/FO/VII/2024",
    "no_invoice": "INV-077/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Sukses Gatuga Timur",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-15/DBO/FO/V/2025",
    "no_invoice": "INV-059/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 134,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Globallink",
    "tanggal_mulai": "24-Apr-24",
    "tanggal_berakhir_1": "24-Apr-24",
    "tanggal_berakhir_2": "23-Apr-25",
    "slot": "1/32",
    "no_bak": "KIMA.45/DBO/FO/VII/2024",
    "no_invoice": "INV-079/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": 126,
    "provider": "PT Medialink Global Mandiri",
    "customer": "Shunda Plafon",
    "tanggal_mulai": "29-Apr-22",
    "tanggal_berakhir_1": "29-Apr-24",
    "tanggal_berakhir_2": "28-Apr-25",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-39/DBO/FO/VII/2024",
    "no_invoice": "INV-073/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": 127,
    "provider": "PT Medialink Global Mandiri",
    "customer": "Shunda Plafon",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-40/DBO/FO/VII/2024",
    "no_invoice": "INV-074/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 128,
    "provider": "PT Medialink Global Mandiri",
    "customer": "Shunda Plafon",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-41/DBO/FO/VII/2024",
    "no_invoice": "INV-075/KIMA/FO/IX/2024",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 136,
    "provider": "PT Medialink Global Mandiri",
    "customer": "PT Pakde Solution Digital",
    "tanggal_mulai": "25-Jul-23",
    "tanggal_berakhir_1": "25-Jul-23",
    "tanggal_berakhir_2": "24-Jul-24",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-33/DBO/FO/VII/2023",
    "no_invoice": "159/INV.FO/VII/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 137,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 1",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-06/DBO/FO/IV/2024",
    "no_invoice": "INV-048/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 138,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 1",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-72/DBO/FO/XII/2024",
    "no_invoice": "INV-007/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 1",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-22/DBO/FO/VI/2025 dan 003/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 063/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 139,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 2",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-07/DBO/FO/IV/2024",
    "no_invoice": "INV-049/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 140,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 2",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-73/DBO/FO/XII/2024 dan 014/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-008/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 2",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-23/DBO/FO/VI/2025 dan 004/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 064/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 141,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 3",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-08/DBO/FO/IV/2024",
    "no_invoice": "INV-050/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 142,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 3",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-74/DBO/FO/XII/2024 dan 015/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-009/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 3",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-24/DBO/FO/VI/2025 dan 005/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 065/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 143,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 4",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-09/DBO/FO/IV/2024",
    "no_invoice": "INV-051/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 144,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 4",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-75/DBO/FO/XII/2024 dan 016/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-010/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 4",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-25/DBO/FO/VI/2025 dan 006/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 066/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 145,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 5",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-10/DBO/FO/IV/2024",
    "no_invoice": "INV-052/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 146,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 5",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-76/DBO/FO/XII/2024 dan 017/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-011/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 5",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-26/DBO/FO/VI/2025 dan 007/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 067/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 147,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 7",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-11/DBO/FO/IV/2024",
    "no_invoice": "INV-053/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 148,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 7",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-77/DBO/FO/XII/2024 dan 018/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-012/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 7",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-27/DBO/FO/VI/2025 dan 008/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 068/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 149,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 8",
    "tanggal_mulai": "29-Dec-23",
    "tanggal_berakhir_1": "29-Jul-25",
    "tanggal_berakhir_2": "28-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-12/DBO/FO/IV/2024",
    "no_invoice": "INV-054/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 1750000,
    "uang_muka": null
  },
  {
    "no": 150,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 8",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-78/DBO/FO/XII/2024 dan 019/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-013/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 8",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-28/DBO/FO/VI/2025 dan 009/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 069/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 151,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 10",
    "tanggal_mulai": "20-May-24",
    "tanggal_berakhir_1": "20-May-25",
    "tanggal_berakhir_2": "19-Dec-26",
    "slot": "1/8",
    "no_bak": "KIMA.BAK-79/DBO/FO/XII/2024 dan 020/BAK.FO.LTPK-KIMA/LTPK/XII/2024",
    "no_invoice": "INV-015/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Lado Tekno Parkir",
    "customer": "POS 10",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-29/DBO/FO/VI/2025 dan 010/BAK.FO.LTPK-KIMA/LTPK/VI/2025",
    "no_invoice": "INV. 070/FO/7/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": "1-Jun-24",
    "tanggal_berakhir_1": "1-Jun-25",
    "tanggal_berakhir_2": "31-May-27",
    "jumlah_core": 35,
    "slot": null,
    "no_bak": "KIMA.PERU-069/DIU/X/2024 Nomor: 0366000000",
    "no_invoice": "INV-096/KIMA/FO/XII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 73500000,
    "total_kontrak": 882000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.PERU-029/DIU/VI/2025 Nomor: 0366A01000",
    "no_invoice": "073/FO/7/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 73500000,
    "total_kontrak": 882000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.PERU-029/DIU/VI/2025 Nomor: 0366A01000",
    "no_invoice": null,
    "status_bayar": null,
    "keterangan": "2027 ditagihkan",
    "harga_per_bulan": 77875000,
    "total_kontrak": 934500000,
    "uang_muka": null
  },
  {
    "no": 152,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": "25-Apr-23",
    "tanggal_berakhir_1": "25-Apr-25",
    "tanggal_berakhir_2": "24-Apr-27",
    "jumlah_core": 15,
    "slot": null,
    "no_bak": "KIMA.PERU-084/DU/IV/2023",
    "no_invoice": "112/INV.FO/V/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 42750000,
    "total_kontrak": 513000000,
    "uang_muka": null
  },
  {
    "no": 153,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK- 169/DIU/VI/2024",
    "no_invoice": "INV-035/KIMA/FO/VI/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 31500000,
    "total_kontrak": 378000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA-PERU-030/DIU/VI/2025 Nomor: 0087A03000",
    "no_invoice": "072/FO/7/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 31500000,
    "total_kontrak": 378000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA-PERU-030/DIU/VI/2025 Nomor: 0087A03000",
    "no_invoice": null,
    "status_bayar": null,
    "keterangan": "2027 ditagihkan",
    "harga_per_bulan": 33375000,
    "total_kontrak": 400500000,
    "uang_muka": null
  },
  {
    "no": 154,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "PT Paragon Technology And Innovation",
    "tanggal_mulai": "1-Aug-23",
    "tanggal_berakhir_1": "1-Aug-25",
    "tanggal_berakhir_2": "31-Jul-26",
    "jumlah_core": 1,
    "slot": null,
    "no_bak": "KIMA.BAK-32/DBO/FO/VII/2023",
    "no_invoice": "161/INV.FO/VIII/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 2100000,
    "total_kontrak": 25200000,
    "uang_muka": null
  },
  {
    "no": 155,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "PT Paragon Technology And Innovation",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-53/DBO/FO/VIII/2024",
    "no_invoice": "INV-094/KIMA/FO/XI/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 2100000,
    "total_kontrak": 25200000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Indonesian Satellite Corporation (PT Indosat Tbk)",
    "customer": "PT Paragon Technology And Innovation",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-19/DBO/FO/IV/2025",
    "no_invoice": "110/FO/12/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 2100000,
    "total_kontrak": 25200000,
    "uang_muka": null
  },
  {
    "no": 156,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Bumi Sarana Beton",
    "tanggal_mulai": "1-Oct-24",
    "tanggal_berakhir_1": "1-Oct-25",
    "tanggal_berakhir_2": "30-Jun-26",
    "jumlah_core": 1,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-61/DBO/FO/X/2024",
    "no_invoice": "INV-082/KIMA/FO/X/2024",
    "status_bayar": "-",
    "keterangan": "Tahap 1 lunas",
    "harga_per_bulan": 6000000,
    "total_kontrak": 72000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Bumi Sarana Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-53/DBO/FO/XI/2025",
    "no_invoice": "107/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": "Okt 25 - Nov 25 (1 Core) Des 25- Jun 26 (1/32)",
    "harga_per_bulan": null,
    "total_kontrak": 25650000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Sinar Sejahtera Sentosa",
    "tanggal_mulai": "14-May-25",
    "tanggal_berakhir_1": "14-May-25",
    "tanggal_berakhir_2": "13-May-26",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-09/DBO/FO/V/2025",
    "no_invoice": "INV-044/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Bumi Menara Internusa 1",
    "tanggal_mulai": "14-May-25",
    "tanggal_berakhir_1": "14-May-25",
    "tanggal_berakhir_2": "13-May-26",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-10/DBO/FO/V/2025",
    "no_invoice": "INV-045/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Bumi Menara Internusa 2",
    "tanggal_mulai": "14-May-25",
    "tanggal_berakhir_1": "14-May-25",
    "tanggal_berakhir_2": "13-May-26",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-12/DBO/FO/V/2025",
    "no_invoice": "INV-047/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Makassar Kulina Utama",
    "tanggal_mulai": "14-May-25",
    "tanggal_berakhir_1": "14-May-25",
    "tanggal_berakhir_2": "13-May-26",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-11/DBO/FO/V/2025",
    "no_invoice": "INV-046/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Grand Kakao Indonesia",
    "tanggal_mulai": "29-Sep-25",
    "tanggal_berakhir_1": "29-Sep-25",
    "tanggal_berakhir_2": "28-Sep-26",
    "jumlah_core": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-06/DBO/FO/IX/2025",
    "no_invoice": "078/FO/10/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 1200000,
    "total_kontrak": 14400000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Fiber Networks Indonesia",
    "customer": "PT Wahyu Pradana Binamulia",
    "tanggal_mulai": "1-Mar-26",
    "tanggal_berakhir_1": "1-Mar-26",
    "tanggal_berakhir_2": "28-Feb-27",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-14/DBO/FO/III/2026",
    "no_invoice": null,
    "status_bayar": "BT",
    "keterangan": null,
    "harga_per_bulan": 300000,
    "total_kontrak": 3600000,
    "uang_muka": 2500000
  },
  {
    "no": 157,
    "provider": "PT Citra Prima Media",
    "customer": "Core",
    "tanggal_mulai": "13-Sep-24",
    "tanggal_berakhir_1": "13-Sep-24",
    "tanggal_berakhir_2": "12-Sep-25",
    "jumlah_core": 2,
    "slot": null,
    "no_bak": "KIMA.BAK-60/DOP/FO/IX/2024",
    "no_invoice": "INV-083/KIMA/FO/X/2024, INV-099/KIMA/FO/XII/2024, INV-036/KIMA/FO/IV/2025",
    "status_bayar": "-",
    "keterangan": "Tahap 1 & 2 lunas",
    "harga_per_bulan": 11500000,
    "total_kontrak": 138000000,
    "uang_muka": 2500000
  },
  {
    "no": 158,
    "provider": "PT XL Axiata Tbk",
    "customer": "Core",
    "tanggal_mulai": "1-Jul-24",
    "tanggal_berakhir_1": "1-Jul-24",
    "tanggal_berakhir_2": "30-Jun-26",
    "jumlah_core": 134,
    "slot": null,
    "no_bak": "KIMA.BAK-170A/DOP/VII/2024",
    "no_invoice": "INV-069/KIMA/FO/VIII/2024",
    "status_bayar": "Lunas",
    "keterangan": "Tahap 1",
    "harga_per_bulan": 167500000,
    "total_kontrak": 2010000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT XL Axiata Tbk",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA. PERU.042/DIU/VII/2024 & 030/XL/VII/2024",
    "no_invoice": "INV.062/KIMA/FO/VII/2025",
    "status_bayar": "Lunas",
    "keterangan": "Tahap 2",
    "harga_per_bulan": 201000000,
    "total_kontrak": 2412000000,
    "uang_muka": null
  },
  {
    "no": 159,
    "provider": "PT XL Axiata Tbk",
    "customer": "Core",
    "tanggal_mulai": "5-Dec-24",
    "tanggal_berakhir_1": "5-Dec-25",
    "tanggal_berakhir_2": "4-Dec-26",
    "jumlah_core": 2,
    "slot": null,
    "no_bak": "KIMA.BAK-68/DBO/FO/XI/2024",
    "no_invoice": "INV.101/KIMA/FO/XII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 2500000,
    "total_kontrak": 30000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT XL Axiata Tbk",
    "customer": "Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-03/DBO/FO/I/2026 & 32/FOIN-XLSMART/II/2026",
    "no_invoice": "015/FO/3/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 3000000,
    "total_kontrak": 36000000,
    "uang_muka": null
  },
  {
    "no": 159,
    "provider": "PT XL Axiata Tbk",
    "customer": "PT Xlsmart Telecom Sejahtera Tbk",
    "tanggal_mulai": "8-Sep-25",
    "tanggal_berakhir_1": "8-Sep-25",
    "tanggal_berakhir_2": "7-Dec-25",
    "jumlah_core": 2,
    "slot": null,
    "no_bak": "KIMA.BAK-31/DBO/FO/VII/2025 dan 107/FOIN-XLSMART/X/2025",
    "no_invoice": "085/FO/10/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 3000000,
    "total_kontrak": 9000000,
    "uang_muka": 2500000
  },
  {
    "no": 160,
    "provider": "PT Iforte Solusi Infotek",
    "customer": "Wika Beton- Makassar",
    "tanggal_mulai": "2-Oct-24",
    "tanggal_berakhir_1": "2-Oct-25",
    "tanggal_berakhir_2": "1-Oct-26",
    "jumlah_core": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-62/DBO/FO/X/2024",
    "no_invoice": "INV-095/KIMA/FO/XI/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 1000000,
    "total_kontrak": 12000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Iforte Solusi Infotek",
    "customer": "Wika Beton- Makassar",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-59/DBO/FO/XII/2025",
    "no_invoice": "115/FO/12/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 161,
    "provider": "PT Iforte Solusi Infotek",
    "customer": "PT Kemasan Cipta Nusantara",
    "tanggal_mulai": "3-Feb-25",
    "tanggal_berakhir_1": "3-Feb-25",
    "tanggal_berakhir_2": "2-Feb-26",
    "jumlah_core": null,
    "slot": "1/32",
    "no_bak": "KIMA.BAK-03/DBO/FO/II/2025 dan 20/PROC-LL/II/2025",
    "no_invoice": "INV-035/KIMA/FO/III/2025",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Iforte Solusi Infotek",
    "customer": "PT Enseval Putra Megatrading",
    "tanggal_mulai": "25-Jun-25",
    "tanggal_berakhir_1": "25-Jun-25",
    "tanggal_berakhir_2": "24-Jun-26",
    "jumlah_core": null,
    "slot": "1/16",
    "no_bak": "KIMA.BAK-18/DBO/FO/VII/2025",
    "no_invoice": "108/FO/11/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000,
    "uang_muka": 2500000
  },
  {
    "no": 162,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "12 Core",
    "tanggal_mulai": "1-Jan-24",
    "tanggal_berakhir_1": "1-Jan-26",
    "tanggal_berakhir_2": "31-Dec-26",
    "jumlah_core": 12,
    "slot": null,
    "no_bak": "KIMA.PERU-012/DOP/III/2024 dan K.TEL.684/HK.810/DR7-10000000/2024",
    "no_invoice": "INV-093/KIMA/FO/XI/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 17400000,
    "total_kontrak": 208800000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "12 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.PERU-012A/DIU/III/2025 dan 001/HK.810/T5W-0A000000/2025",
    "no_invoice": "075/FO/8/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 18000000,
    "total_kontrak": 216000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "12 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-508A/DOP/XII/2025 & 1369a/BAK/WSDTR5/XII/2025",
    "no_invoice": null,
    "status_bayar": null,
    "keterangan": "belum ditagihkan",
    "harga_per_bulan": 18600000,
    "total_kontrak": 223200000,
    "uang_muka": null
  },
  {
    "no": 163,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "48 Core",
    "tanggal_mulai": "1-Jan-24",
    "tanggal_berakhir_1": "1-Jan-26",
    "tanggal_berakhir_2": "31-Dec-25",
    "jumlah_core": 48,
    "slot": null,
    "no_bak": "KIMA.PERU-013/DOP/III/2024 dan K.TEL.683/HK.810/DR7-10000000/2024",
    "no_invoice": "INV-012/KIMA/FO/III/2024, INV-017/KIMA/FO/VI/2024, INV-072/KIMA/FO/IX/2024, INV-100/KIMA/FO/XII/2024, INV-034/KIMA/FO/III/2025",
    "status_bayar": "-",
    "keterangan": "bayar/3 bulan, blm ada BAK fisik",
    "harga_per_bulan": 69600000,
    "total_kontrak": 835200000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "48 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-795A/DOP/XII/2024 dan Nomor. K-Tel122474/HK.000/T5R-0C010000/2024",
    "no_invoice": "INV-034/KIMA/FO/III/2025, 071/FO/7/25, 074/8/FO/25, 075/FO8/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 72000000,
    "total_kontrak": 864000000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Telekomunikasi Indonesia",
    "customer": "48 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-509A/DOP/XII/2025 & TEL.122989/HK.000/TR5-0C000000/2025",
    "no_invoice": "014/FO/2/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 74400000,
    "total_kontrak": 892800000,
    "uang_muka": null
  },
  {
    "no": 164,
    "provider": "PT Mora Telematika Indonesia",
    "customer": "2 Core",
    "tanggal_mulai": "8-Apr-23",
    "tanggal_berakhir_1": "8-Apr-24",
    "tanggal_berakhir_2": "7-Apr-25",
    "jumlah_core": 2,
    "slot": null,
    "no_bak": "KIMA.BAK-14/DBO/FO/IV/2023",
    "no_invoice": "098/INV.FO/III/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 11000000,
    "total_kontrak": 132000000,
    "uang_muka": null
  },
  {
    "no": 165,
    "provider": "PT Mora Telematika Indonesia",
    "customer": "2 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-17 DBO/FO/V/2024",
    "no_invoice": "INV-084/KIMA/FO/X/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Mora Telematika Indonesia",
    "customer": "2 Core",
    "tanggal_mulai": "15-Aug-23",
    "tanggal_berakhir_1": "15-Aug-23",
    "tanggal_berakhir_2": "14-Aug-24",
    "jumlah_core": 2,
    "slot": null,
    "no_bak": "KIMA.BAK-34/DBO/FO/VIII/2023",
    "no_invoice": "INV.036/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 11000000,
    "total_kontrak": 132000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Jenius Lintas Nusantara",
    "customer": "1 Core",
    "tanggal_mulai": "7-Jul-25",
    "tanggal_berakhir_1": "7-Jul-25",
    "tanggal_berakhir_2": "6-Oct-25",
    "jumlah_core": 1,
    "slot": null,
    "no_bak": "KIMA.BAK-30/DBO/FO/VII/2025 dan Nomor: 041/JELINTAS/VII/2025",
    "no_invoice": "076/FO/8/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 5500000,
    "total_kontrak": 16500000,
    "uang_muka": 1500000
  },
  {
    "no": null,
    "provider": "PT Jenius Lintas Nusantara",
    "customer": "1 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": "7-Oct-25",
    "tanggal_berakhir_2": "6-Jan-26",
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-45/DBO/FO/X/2025",
    "no_invoice": "080/FO/10/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 5500000,
    "total_kontrak": 16500000,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Jenius Lintas Nusantara",
    "customer": "1 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": "7-Jan-26",
    "tanggal_berakhir_2": "6-Apr-26",
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA-BAK-02/DBO/FO/I/2026",
    "no_invoice": "013/FO/2/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 5500000,
    "total_kontrak": 16500000,
    "uang_muka": null
  },
  {
    "no": 166,
    "provider": "PT Inet Global",
    "customer": "PT Nippon Indosari Corpindo Tbk",
    "tanggal_mulai": "23-Jun-23",
    "tanggal_berakhir_1": "23-Jun-24",
    "tanggal_berakhir_2": "22-Jun-25",
    "jumlah_core": null,
    "slot": "1/8",
    "no_bak": "KIMA.BAK-28/DBO/FO/VI/2023",
    "no_invoice": "128/INV.FO/VI/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 167,
    "provider": "PT Inet Global",
    "customer": "PT Nippon Indosari Corpindo Tbk",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "jumlah_core": null,
    "slot": null,
    "no_bak": "KIMA.BAK-27/DBO/FO/VI/2024",
    "no_invoice": "INV-033/KIMA/FO/VI/2024",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": 168,
    "provider": "PT Inet Global",
    "customer": "Maintenance",
    "tanggal_mulai": "Oct-23",
    "tanggal_berakhir_1": "Oct-23",
    "tanggal_berakhir_2": "Jun-25",
    "jumlah_core": null,
    "slot": null,
    "no_bak": null,
    "no_invoice": "-",
    "status_bayar": null,
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null,
    "uang_muka": null
  },
  {
    "no": null,
    "provider": "PT Multitech Infomedia",
    "customer": "4 Core",
    "tanggal_mulai": "28-Jul-25",
    "tanggal_berakhir_1": "28-Jul-25",
    "tanggal_berakhir_2": "27-Jul-26",
    "jumlah_core": 4,
    "slot": null,
    "no_bak": "KIMA.BAK-273A/DOP/FO/VII/2025",
    "no_invoice": "077/FO/8/25",
    "status_bayar": "Lunas",
    "keterangan": "ditagihkan per3 bulan",
    "harga_per_bulan": 20000000,
    "total_kontrak": 240000000,
    "uang_muka": 2500000
  },
  {
    "no": 168,
    "provider": "PT Panca Karsa Sejahtera",
    "customer": "4 Core",
    "tanggal_mulai": "14-Jan-26",
    "tanggal_berakhir_1": "14-Mar-26",
    "tanggal_berakhir_2": "13-May-26",
    "jumlah_core": 4,
    "slot": null,
    "no_bak": "KIMA.BAK-01/DBO/FO/I/2026",
    "no_invoice": "011/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 18000000,
    "total_kontrak": 36000000,
    "uang_muka": null
  }
]
$json$::jsonb
  ) WITH ORDINALITY AS t(item, ordinality)
)
SELECT
  ordinality::int AS source_row_id,
  NULLIF(trim(item ->> 'provider'), '') AS provider_name,
  NULLIF(trim(item ->> 'customer'), '') AS customer_name,
  NULLIF(trim(item ->> 'tanggal_mulai'), '') AS tanggal_mulai,
  NULLIF(trim(item ->> 'tanggal_berakhir_1'), '') AS tanggal_berakhir_1,
  NULLIF(trim(item ->> 'tanggal_berakhir_2'), '') AS tanggal_berakhir_2,
  NULLIF(trim(item ->> 'slot'), '') AS slot_raw,
  NULLIF(item ->> 'jumlah_core', '')::int AS jumlah_core,
  NULLIF(trim(item ->> 'no_bak'), '') AS no_bak,
  NULLIF(trim(item ->> 'no_invoice'), '') AS no_invoice,
  NULLIF(trim(item ->> 'status_bayar'), '') AS status_bayar,
  NULLIF(trim(item ->> 'keterangan'), '') AS keterangan,
  NULLIF(item ->> 'harga_per_bulan', '')::numeric(18,2) AS harga_per_bulan,
  NULLIF(item ->> 'total_kontrak', '')::numeric(18,2) AS total_kontrak,
  NULLIF(item ->> 'uang_muka', '')::numeric(18,2) AS uang_muka
FROM source_json;

DROP TABLE IF EXISTS tmp_import_contracts;
CREATE TEMP TABLE tmp_import_contracts AS
WITH prepared AS (
  SELECT
    r.source_row_id,
    r.provider_name,
    r.customer_name,
    r.no_bak,
    r.no_invoice,
    r.status_bayar,
    r.keterangan,
    r.slot_raw,
    r.jumlah_core,
    COALESCE(r.harga_per_bulan, CASE WHEN r.total_kontrak IS NOT NULL THEN round(r.total_kontrak / 12.0, 2) END, 0)::numeric(18,2) AS monthly_amount,
    COALESCE(r.total_kontrak, COALESCE(r.harga_per_bulan, 0) * 12)::numeric(18,2) AS total_contract_amount,
    COALESCE(r.uang_muka, 0)::numeric(18,2) AS uang_muka,
    COALESCE(
      CASE
        WHEN r.tanggal_mulai ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN to_date(r.tanggal_mulai, 'FMDD-Mon-YY')
        WHEN r.tanggal_mulai ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN to_date('01-' || r.tanggal_mulai, 'DD-Mon-YY')
        ELSE NULL
      END,
      CASE
        WHEN r.tanggal_berakhir_1 ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN to_date(r.tanggal_berakhir_1, 'FMDD-Mon-YY')
        WHEN r.tanggal_berakhir_1 ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN to_date('01-' || r.tanggal_berakhir_1, 'DD-Mon-YY')
        ELSE NULL
      END,
      CASE
        WHEN r.tanggal_berakhir_2 ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN (to_date(r.tanggal_berakhir_2, 'FMDD-Mon-YY') - interval '1 year' + interval '1 day')::date
        WHEN r.tanggal_berakhir_2 ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN (to_date('01-' || r.tanggal_berakhir_2, 'DD-Mon-YY') - interval '1 year' + interval '1 day')::date
        ELSE NULL
      END,
      CURRENT_DATE
    ) AS base_start_date,
    COALESCE(
      CASE
        WHEN r.tanggal_berakhir_2 ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN to_date(r.tanggal_berakhir_2, 'FMDD-Mon-YY')
        WHEN r.tanggal_berakhir_2 ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN (date_trunc('month', to_date('01-' || r.tanggal_berakhir_2, 'DD-Mon-YY')) + interval '1 month - 1 day')::date
        ELSE NULL
      END,
      CASE
        WHEN r.tanggal_berakhir_1 ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN to_date(r.tanggal_berakhir_1, 'FMDD-Mon-YY')
        WHEN r.tanggal_berakhir_1 ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN (date_trunc('month', to_date('01-' || r.tanggal_berakhir_1, 'DD-Mon-YY')) + interval '1 month - 1 day')::date
        ELSE NULL
      END,
      (COALESCE(
        CASE
          WHEN r.tanggal_mulai ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' THEN to_date(r.tanggal_mulai, 'FMDD-Mon-YY')
          WHEN r.tanggal_mulai ~ '^[A-Za-z]{3}-[0-9]{2}$' THEN to_date('01-' || r.tanggal_mulai, 'DD-Mon-YY')
          ELSE NULL
        END,
        CURRENT_DATE
      ) + interval '1 year' - interval '1 day')::date
    ) AS base_end_date,
    COUNT(*) OVER (PARTITION BY r.no_bak) AS source_contract_number_count,
    ROW_NUMBER() OVER (PARTITION BY r.no_bak ORDER BY r.source_row_id) AS source_contract_number_rank,
    EXISTS (
      SELECT 1
      FROM contracts c
      WHERE c.contract_number = r.no_bak
    ) AS contract_exists_in_db
  FROM tmp_import_raw r
)
SELECT
  source_row_id,
  provider_name,
  customer_name,
  COALESCE(
    CASE
      WHEN no_bak IS NULL THEN NULL
      WHEN source_contract_number_count > 1 THEN no_bak || '__SRCD' || source_contract_number_rank
      WHEN contract_exists_in_db THEN no_bak || '__BATCHD' || lpad(source_row_id::text, 4, '0')
      ELSE no_bak
    END,
    format('IMP-ROWD-%s-%s', to_char(base_start_date, 'YYYYMMDD'), lpad(source_row_id::text, 4, '0'))
  ) AS resolved_contract_number,
  CASE
    WHEN no_invoice IS NULL THEN NULL
    ELSE left(no_invoice, 100)
  END AS no_invoice,
  status_bayar,
  keterangan,
  base_start_date AS contract_start_date,
  base_end_date AS contract_end_date,
  CASE
    WHEN COALESCE(jumlah_core, 0) > 0 THEN 'core'::core_allocation_type
    WHEN slot_raw ~ '^[0-9]+$' THEN 'core'::core_allocation_type
    ELSE 'sharing_core'::core_allocation_type
  END AS core_type,
  CASE
    WHEN COALESCE(jumlah_core, 0) > 0 THEN jumlah_core
    WHEN slot_raw ~ '^[0-9]+$' THEN slot_raw::int
    ELSE 0
  END AS core_total,
  CASE
    WHEN slot_raw LIKE '%/%' THEN slot_raw
    ELSE NULL
  END AS sharing_ratio,
  monthly_amount,
  total_contract_amount,
  uang_muka,
  make_date(EXTRACT(YEAR FROM base_start_date)::int, EXTRACT(MONTH FROM base_start_date)::int, 1) AS invoice_period_date
FROM prepared;

DROP TABLE IF EXISTS tmp_customer_seed;
CREATE TEMP TABLE tmp_customer_seed AS
WITH ranked_customers AS (
  SELECT
    customer_name,
    MIN(provider_name) AS provider_name,
    MAX(uang_muka) AS activation_fee_amount,
    MIN(CASE WHEN uang_muka > 0 THEN contract_start_date END) AS activation_fee_paid_at,
    ROW_NUMBER() OVER (ORDER BY customer_name) AS customer_seq
  FROM tmp_import_contracts
  GROUP BY customer_name
)
SELECT
  customer_name,
  provider_name,
  format('CUST-IMP-D-%s', lpad(customer_seq::text, 4, '0')) AS customer_code,
  activation_fee_amount,
  activation_fee_paid_at
FROM ranked_customers;

INSERT INTO isps (
  name,
  status,
  paket,
  jumlah,
  activation_fee_amount,
  created_at,
  updated_at
)
SELECT
  provider_name,
  'aktif'::isp_status,
  CASE WHEN COUNT(*) FILTER (WHERE core_total > 0) > 0 THEN 'core'::isp_package_type ELSE 'shared'::isp_package_type END,
  GREATEST(1, COALESCE(MAX(NULLIF(core_total, 0)), 1)),
  0,
  NOW(),
  NOW()
FROM tmp_import_contracts
GROUP BY provider_name
ON CONFLICT (name) DO UPDATE
SET
  status = EXCLUDED.status,
  paket = EXCLUDED.paket,
  jumlah = EXCLUDED.jumlah,
  updated_at = NOW();

UPDATE customers AS c
SET
  isp_name = s.provider_name,
  status = 'aktif'::customer_status,
  activation_fee_amount = CASE WHEN COALESCE(c.activation_fee_amount, 0) = 0 AND COALESCE(s.activation_fee_amount, 0) > 0 THEN s.activation_fee_amount ELSE c.activation_fee_amount END,
  activation_fee_paid_at = COALESCE(c.activation_fee_paid_at, s.activation_fee_paid_at),
  updated_at = NOW()
FROM tmp_customer_seed AS s
WHERE c.name = s.customer_name;

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
  s.provider_name,
  s.customer_name,
  'aktif'::customer_status,
  COALESCE(s.activation_fee_amount, 0),
  s.activation_fee_paid_at,
  NOW(),
  NOW()
FROM tmp_customer_seed s
WHERE NOT EXISTS (
  SELECT 1 FROM customers c WHERE c.name = s.customer_name
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
FROM tmp_customer_seed s
JOIN customers c ON c.name = s.customer_name
JOIN isps i ON i.name = s.provider_name
WHERE NOT EXISTS (
  SELECT 1 FROM customer_isp_memberships m WHERE m.customer_id = c.id AND m.isp_id = i.id
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
    WHEN ic.keterangan ILIKE '%berhenti%' THEN 'terminated'::contract_status
    WHEN ic.contract_end_date < CURRENT_DATE THEN 'expired'::contract_status
    ELSE 'aktif'::contract_status
  END,
  1,
  'bulan'::billing_unit,
  NOW(),
  NOW()
FROM tmp_import_contracts ic
JOIN customers c ON c.name = ic.customer_name
ON CONFLICT (contract_number) DO UPDATE
SET
  customer_id = EXCLUDED.customer_id,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  core_type = EXCLUDED.core_type,
  core_total = EXCLUDED.core_total,
  sharing_ratio = EXCLUDED.sharing_ratio,
  status = EXCLUDED.status,
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
FROM tmp_import_contracts ic
JOIN customers c ON c.name = ic.customer_name
JOIN contracts ct ON ct.contract_number = ic.resolved_contract_number
ON CONFLICT (contract_id, version_number) DO UPDATE
SET
  customer_id = EXCLUDED.customer_id,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  core_type = EXCLUDED.core_type,
  core_total = EXCLUDED.core_total,
  shared_core_ratio = EXCLUDED.shared_core_ratio,
  updated_at = NOW();

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
  CASE WHEN ic.no_invoice = '-' THEN NULL ELSE ic.no_invoice END,
  ct.id,
  cv.id,
  ct.contract_number,
  EXTRACT(MONTH FROM ic.invoice_period_date)::int,
  EXTRACT(YEAR FROM ic.invoice_period_date)::int,
  ic.invoice_period_date,
  (date_trunc('month', ic.invoice_period_date) + interval '1 month - 1 day')::date,
  (date_trunc('month', ic.invoice_period_date) + interval '1 month - 1 day')::date,
  ic.monthly_amount,
  CASE
    WHEN ic.status_bayar = 'Lunas' THEN 'lunas'::invoice_status
    WHEN ic.status_bayar IN ('Cek inv', 'BT') THEN 'belum_bayar'::invoice_status
    ELSE 'belum_ditagih'::invoice_status
  END,
  CASE
    WHEN ic.status_bayar = 'Lunas' THEN (date_trunc('month', ic.invoice_period_date) + interval '1 month - 1 day')::timestamp
    ELSE NULL
  END,
  NOW(),
  NOW()
FROM tmp_import_contracts ic
JOIN customers c ON c.name = ic.customer_name
JOIN contracts ct ON ct.contract_number = ic.resolved_contract_number
JOIN contract_versions cv ON cv.contract_id = ct.id AND cv.version_number = 1
WHERE (ic.no_invoice IS NOT NULL OR ic.monthly_amount > 0)
  AND NOT EXISTS (
    SELECT 1
    FROM invoices i
    WHERE i.customer_id = c.id
      AND COALESCE(i.contract_id, 0) = ct.id
      AND COALESCE(i.invoice_number, '') = COALESCE(CASE WHEN ic.no_invoice = '-' THEN NULL ELSE ic.no_invoice END, '')
      AND i.period_month = EXTRACT(MONTH FROM ic.invoice_period_date)::int
      AND i.period_year = EXTRACT(YEAR FROM ic.invoice_period_date)::int
      AND i.amount = ic.monthly_amount
  );

COMMIT;
