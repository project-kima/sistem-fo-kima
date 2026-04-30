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
    "no": 72,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Charoen Pokphand Indonesia",
    "tanggal_mulai": "20-Nov-22",
    "tanggal_berakhir_1": "20-Nov-24",
    "tanggal_berakhir_2": "19-Nov-25",
    "slot": "1/16",
    "no_bak": null,
    "no_invoice": "088/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 73,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Charoen Pokphand Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-01/DBO/FO/I/2024",
    "no_invoice": "INV-008/KIMA/FO/III/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 74,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Charoen Pokphand Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500022178",
    "no_invoice": "INV-004/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Charoen Pokphand Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": "25-Nov-25",
    "tanggal_berakhir_2": "24-Nov-26",
    "slot": null,
    "no_bak": "SP2K No. 4500026821",
    "no_invoice": "004/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": 78,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama",
    "tanggal_mulai": "28-Aug-23",
    "tanggal_berakhir_1": "28-Dec-25",
    "tanggal_berakhir_2": "27-Dec-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-36/DBO/FO/VIII/2023",
    "no_invoice": "177/INV.FO/IX/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 79,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-48/DBO/FO/VII/2024",
    "no_invoice": "INV-081/KIMA/FO/X/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No.4500026783",
    "no_invoice": "002/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 80,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama (IDM Kasir)",
    "tanggal_mulai": "17-May-24",
    "tanggal_berakhir_1": "17-May-25",
    "tanggal_berakhir_2": "16-May-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-14/DBO/FO/V/2024",
    "no_invoice": "INV-066/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama (IDM Kasir)",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K. No. 4500023043",
    "no_invoice": "INV.042/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 81,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Malindo Feedmil",
    "tanggal_mulai": "28-Apr-23",
    "tanggal_berakhir_1": "28-Dec-25",
    "tanggal_berakhir_2": "27-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-15/DBO/FO/IV/2023",
    "no_invoice": "108/INV.FO/V/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 82,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Malindo Feedmil",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-18/DBO/FO/VI/2024",
    "no_invoice": "INV-016/KIMA/FO/VI/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Malindo Feedmil",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500022654",
    "no_invoice": "INV-041/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 2200000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Malindo Feedmil",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500026819",
    "no_invoice": "006/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 83,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Mars Symbioscience Indonesia",
    "tanggal_mulai": "12-Sep-22",
    "tanggal_berakhir_1": "12-Dec-25",
    "tanggal_berakhir_2": "11-Dec-26",
    "slot": "1/16",
    "no_bak": null,
    "no_invoice": "044/INV.FO/X/2022",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 84,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Mars Symbioscience Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-37/DBO/FO/VIII/2023",
    "no_invoice": "176/INV.FO/IX/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 85,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Mars Symbioscience Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500021668",
    "no_invoice": "INV-006/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": "blm ada BAK",
    "harga_per_bulan": 550000,
    "total_kontrak": 8250000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Mars Symbioscience Indonesia",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 450026841",
    "no_invoice": "007/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": 86,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Sumber Alfaria Trijaya",
    "tanggal_mulai": "23-Jan-23",
    "tanggal_berakhir_1": "23-Jan-26",
    "tanggal_berakhir_2": "22-Jan-27",
    "slot": "1/16",
    "no_bak": null,
    "no_invoice": "099/INV.FO/III/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 87,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Sumber Alfaria Trijaya",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-04/DBO/FO/I/2024",
    "no_invoice": "INV-009/KIMA/FO/III/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Sumber Alfaria Trijaya",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500022163",
    "no_invoice": "INV.040/KIMA/FO/VI/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Sumber Alfaria Trijaya",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500022163",
    "no_invoice": "018/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 88,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Wijaya Karya Beton",
    "tanggal_mulai": "28-Nov-22",
    "tanggal_berakhir_1": "28-Nov-25",
    "tanggal_berakhir_2": "27-May-26",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "071/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": 89,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Wijaya Karya Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-02/DBO/FO/I/2024",
    "no_invoice": "INV-005/KIMA/FO/II/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 90,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Wijaya Karya Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500021625",
    "no_invoice": "INV-032/KIMA/FO/III/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Wijaya Karya Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500026818",
    "no_invoice": "005/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 1650000
  },
  {
    "no": 91,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indoroti Prima Cemerlang",
    "tanggal_mulai": "28-Aug-23",
    "tanggal_berakhir_1": "28-Aug-25",
    "tanggal_berakhir_2": "27-Dec-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-35/DBO/FO/VIII/2023",
    "no_invoice": "177/INV.FO/IX/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": 92,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indoroti Prima Cemerlang",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-47/DBO/FO/VII/2024",
    "no_invoice": "INV-081/KIMA/FO/X/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 275000,
    "total_kontrak": 4400000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indoroti Prima Cemerlang",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500026783",
    "no_invoice": "002/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 93,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Andiarta Muzizat",
    "tanggal_mulai": "25-Sep-23",
    "tanggal_berakhir_1": "25-Sep-25",
    "tanggal_berakhir_2": "24-Sep-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-40/DBO/FO/IX/2023",
    "no_invoice": "185/INV.FO/XI/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 94,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Andiarta Muzizat",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500023781",
    "no_invoice": "INV-104/KIMA/FO/XII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Andiarta Muzizat",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500023781",
    "no_invoice": "102/FO/11/25",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000
  },
  {
    "no": null,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Eastlync Technology Indonesia",
    "tanggal_mulai": "14-Jul-25",
    "tanggal_berakhir_1": "14-Jul-25",
    "tanggal_berakhir_2": "13-Jul-26",
    "slot": "1/16",
    "no_bak": "SP2K No. 4500025809",
    "no_invoice": "101/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 550000,
    "total_kontrak": 6600000,
    "uang_muka": 2500000
  },
  {
    "no": 95,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Anugerah Pharmindo Lestari",
    "tanggal_mulai": "20-Dec-21",
    "tanggal_berakhir_1": "20-Dec-22",
    "tanggal_berakhir_2": "19-Dec-23",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "014/INV.FO/IV/2022",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 2500000
  },
  {
    "no": 96,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Anugerah Pharmindo Lestari",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": null,
    "no_invoice": "097/INV.FO/III/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 97,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indomarco Prismatama",
    "tanggal_mulai": "9-Nov-22",
    "tanggal_berakhir_1": "9-Nov-22",
    "tanggal_berakhir_2": "8-Nov-23",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "087/INV.FO/I/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 98,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Olam Indonesia",
    "tanggal_mulai": "24-Sep-22",
    "tanggal_berakhir_1": "24-Sep-22",
    "tanggal_berakhir_2": "23-Sep-23",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "073/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 75,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indofood CBP Sukses Makmur",
    "tanggal_mulai": "30-Sep-22",
    "tanggal_berakhir_1": "30-Sep-24",
    "tanggal_berakhir_2": "29-Sep-25",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "074/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 76,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indofood CBP Sukses Makmur",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-38/DBO/FO/VIII/2024",
    "no_invoice": "183/INV.FO/XI/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 77,
    "provider": "PT Indonesia Comnets Plus",
    "customer": "PT Indofood CBP Sukses Makmur",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "SP2K No. 4500023787",
    "no_invoice": "INV-004/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 275000,
    "total_kontrak": 3300000
  },
  {
    "no": 99,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "ATM Center WIKA Beton",
    "tanggal_mulai": "15-Mar-23",
    "tanggal_berakhir_1": "15-Mar-26",
    "tanggal_berakhir_2": "14-Mar-27",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-10/DBO/FO/III/2023",
    "no_invoice": "105/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 100,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "ATM Center WIKA Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-28/DBO/FO/VI/2024",
    "no_invoice": "INV-055/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "ATM Center WIKA Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-36/DBO/FO/VIII/2025",
    "no_invoice": "098/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "ATM Center WIKA Beton",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.04/DBO/FO/II/2026",
    "no_invoice": "027/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 520000,
    "total_kontrak": 6240000
  },
  {
    "no": 105,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Hexindo Adiperkasa Tbk",
    "tanggal_mulai": "28-Oct-22",
    "tanggal_berakhir_1": "28-Oct-24",
    "tanggal_berakhir_2": "27-Oct-26",
    "slot": "1/32",
    "no_bak": null,
    "no_invoice": "-",
    "status_bayar": "Cek inv",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 106,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Hexindo Adiperkasa Tbk",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-32/DBO/FO/VI/2024",
    "no_invoice": "INV-059/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Hexindo Adiperkasa Tbk",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-39/DBO/FO/VIII/2025",
    "no_invoice": "096/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 107,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Kamadjaja Logistics/shopee",
    "tanggal_mulai": "13-Aug-22",
    "tanggal_berakhir_1": "13-Aug-24",
    "tanggal_berakhir_2": "12-Aug-26",
    "slot": "1/16",
    "no_bak": null,
    "no_invoice": "077/INV.FO/XII/2022",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 108,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Kamadjaja Logistics/shopee",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-34/DBO/FO/VI/2024",
    "no_invoice": "INV-061/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Kamadjaja Logistics/shopee",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-40/DBO/FO/VIII/2025",
    "no_invoice": "095/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 110,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Tunas Kreasi/Sharp",
    "tanggal_mulai": "21-Apr-23",
    "tanggal_berakhir_1": "21-Apr-26",
    "tanggal_berakhir_2": "20-Apr-27",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-36/DBO/FO/VI/2024",
    "no_invoice": "INV-063/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Tunas Kreasi/Sharp",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-43/DBO/FO/VIII/2025",
    "no_invoice": "100/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Tunas Kreasi/Sharp",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-05/DBO/FO/II/2026",
    "no_invoice": "028/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 520000,
    "total_kontrak": 6240000
  },
  {
    "no": 111,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars Symbioscience Indonesia 2",
    "tanggal_mulai": "13-Mar-23",
    "tanggal_berakhir_1": "13-Mar-26",
    "tanggal_berakhir_2": "12-Mar-27",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-09/DBO/FO/III/2023",
    "no_invoice": "104/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000
  },
  {
    "no": 112,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars Symbioscience Indonesia 2",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-31/DBO/FO/VI/2024",
    "no_invoice": "INV-058/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars Symbioscience Indonesia 2",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-41/DBO/FO/VIII/2025",
    "no_invoice": "094/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars Symbioscience Indonesia 2",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-07/DBO/FO/II/2026",
    "no_invoice": "030/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 520000,
    "total_kontrak": 6240000
  },
  {
    "no": 113,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Prima Indo Papua",
    "tanggal_mulai": "25-Mar-23",
    "tanggal_berakhir_1": "25-Mar-26",
    "tanggal_berakhir_2": "24-Mar-27",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-05/DBO/FO/III/2023",
    "no_invoice": "100/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 114,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Prima Indo Papua",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-29/DBO/FO/VI/2024",
    "no_invoice": "INV-056/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Prima Indo Papua",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-42/DBO/FO/VIII/2025",
    "no_invoice": "093/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Prima Indo Papua",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-06/DBO/FO/II/2026",
    "no_invoice": "029/Fo/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 260000,
    "total_kontrak": 3120000
  },
  {
    "no": 115,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "6 Core",
    "tanggal_mulai": "14-Oct-23",
    "tanggal_berakhir_1": "14-Jan-25",
    "tanggal_berakhir_2": "13-Jan-27",
    "slot": "6",
    "no_bak": "KIMA.BAK-48/DOP/FO/X/2023",
    "no_invoice": "180/INV.FO/X/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 25200000,
    "total_kontrak": 75600000
  },
  {
    "no": 116,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "6 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-37/DOP/FO/VI/2024",
    "no_invoice": "INV-070/KIMA/FO/VIII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 27000000,
    "total_kontrak": 324000000
  },
  {
    "no": 117,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "6 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-37/DOP/FO/VI/2024",
    "no_invoice": "INV-014/KIMA/FO/I/2025",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 29400000,
    "total_kontrak": 352800000
  },
  {
    "no": 118,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "6 Core",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-37/DOP/FO/VI/2024",
    "no_invoice": "008/FO/1/26",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 33000000,
    "total_kontrak": 396000000
  },
  {
    "no": 119,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Primacom Interbuana",
    "tanggal_mulai": "25-Mar-25",
    "tanggal_berakhir_1": "25-Mar-26",
    "tanggal_berakhir_2": "24-Mar-27",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-37/DBO/FO/VIII/2025",
    "no_invoice": "099/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Primacom Interbuana",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-08/DBO/FO/II/2026",
    "no_invoice": "031/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 520000,
    "total_kontrak": 6240000
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Toyota Kalla/Mega Akses Persada",
    "tanggal_mulai": "4-Feb-26",
    "tanggal_berakhir_1": "4-Feb-26",
    "tanggal_berakhir_2": "3-Feb-27",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-11/DBO/FO/II/2026",
    "no_invoice": "034/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 260000,
    "total_kontrak": 3120000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Mars/Telekomunikasi Indonesia International",
    "tanggal_mulai": "18-Nov-25",
    "tanggal_berakhir_1": "18-Nov-25",
    "tanggal_berakhir_2": "17-Nov-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-10/DBO/FO/II/2026",
    "no_invoice": "033/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT APL/Hipernet Indodata",
    "tanggal_mulai": "18-Nov-25",
    "tanggal_berakhir_1": "18-Nov-25",
    "tanggal_berakhir_2": "17-Nov-26",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-09/DBO/FO/II/2026",
    "no_invoice": "032/FO/4/26",
    "status_bayar": "-",
    "keterangan": null,
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 101,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Anugerah Pharmindo Lestari 1",
    "tanggal_mulai": "25-Mar-23",
    "tanggal_berakhir_1": "25-Mar-25",
    "tanggal_berakhir_2": "24-Mar-26",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-06/DBO/FO/III/2023",
    "no_invoice": "101/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 102,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Anugerah Pharmindo Lestari 1",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-30/DBO/FO/VI/2024",
    "no_invoice": "INV-057/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": null,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Anugerah Pharmindo Lestari 1",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-38/DBO/FO/VIII/2025",
    "no_invoice": "097/FO/11/25",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 109,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Kamadjaja Logistics 1",
    "tanggal_mulai": "15-Oct-23",
    "tanggal_berakhir_1": "15-Oct-23",
    "tanggal_berakhir_2": "14-Oct-24",
    "slot": "1/16",
    "no_bak": "KIMA.BAK-35/DBO/FO/VI/2024",
    "no_invoice": "INV-062/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 500000,
    "total_kontrak": 6000000,
    "uang_muka": 2500000
  },
  {
    "no": 103,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Enseval Putra Megatrading",
    "tanggal_mulai": "29-Apr-23",
    "tanggal_berakhir_1": "29-Apr-24",
    "tanggal_berakhir_2": "28-Apr-25",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-12/DBO/FO/III/2023",
    "no_invoice": "107/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": null,
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
  },
  {
    "no": 104,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Enseval Putra Megatrading Tbk",
    "tanggal_mulai": null,
    "tanggal_berakhir_1": null,
    "tanggal_berakhir_2": null,
    "slot": null,
    "no_bak": "KIMA.BAK-33/DBO/FO/VI/2024",
    "no_invoice": "INV-060/KIMA/FO/VII/2024",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": null,
    "total_kontrak": null
  },
  {
    "no": 120,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Indoarsip Kertas Karya",
    "tanggal_mulai": "16-Feb-23",
    "tanggal_berakhir_1": "16-Feb-23",
    "tanggal_berakhir_2": "15-Feb-24",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-02/DBO/FO/II/2023",
    "no_invoice": "093/INV.FO/II/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000,
    "uang_muka": 1500000
  },
  {
    "no": 121,
    "provider": "PT Aplikanusa Lintasarta",
    "customer": "PT Anugerah Pharmindo Lestari 2",
    "tanggal_mulai": "25-Mar-23",
    "tanggal_berakhir_1": "25-Mar-23",
    "tanggal_berakhir_2": "24-Mar-24",
    "slot": "1/32",
    "no_bak": "KIMA.BAK-07/DBO/FO/III/2023",
    "no_invoice": "102/INV.FO/IV/2023",
    "status_bayar": "Lunas",
    "keterangan": "Berhenti",
    "harga_per_bulan": 250000,
    "total_kontrak": 3000000
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
    COALESCE(r.harga_per_bulan, CASE WHEN r.total_kontrak IS NOT NULL THEN round(r.total_kontrak / 12.0, 2) END, 0)::numeric(18,2) AS monthly_amount,
    COALESCE(r.total_kontrak, COALESCE(r.harga_per_bulan, 0) * 12)::numeric(18,2) AS total_contract_amount,
    COALESCE(r.uang_muka, 0)::numeric(18,2) AS uang_muka,
    COALESCE(
      to_date(r.tanggal_mulai, 'FMDD-Mon-YY'),
      to_date(r.tanggal_berakhir_1, 'FMDD-Mon-YY'),
      (to_date(r.tanggal_berakhir_2, 'FMDD-Mon-YY') - interval '1 year' + interval '1 day')::date,
      CURRENT_DATE
    ) AS base_start_date,
    COALESCE(
      to_date(r.tanggal_berakhir_2, 'FMDD-Mon-YY'),
      to_date(r.tanggal_berakhir_1, 'FMDD-Mon-YY'),
      (COALESCE(to_date(r.tanggal_mulai, 'FMDD-Mon-YY'), CURRENT_DATE) + interval '1 year' - interval '1 day')::date
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
      WHEN source_contract_number_count > 1 THEN no_bak || '__SRC' || source_contract_number_rank
      WHEN contract_exists_in_db THEN no_bak || '__BATCHC' || lpad(source_row_id::text, 4, '0')
      ELSE no_bak
    END,
    format('IMP-ROWC-%s-%s', to_char(base_start_date, 'YYYYMMDD'), lpad(source_row_id::text, 4, '0'))
  ) AS resolved_contract_number,
  no_invoice,
  status_bayar,
  keterangan,
  base_start_date AS contract_start_date,
  base_end_date AS contract_end_date,
  CASE
    WHEN slot_raw ~ '^[0-9]+$' THEN 'core'::core_allocation_type
    ELSE 'sharing_core'::core_allocation_type
  END AS core_type,
  CASE
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
  format('CUST-IMP-C-%s', lpad(customer_seq::text, 4, '0')) AS customer_code,
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
    WHEN ic.status_bayar = 'Cek inv' THEN 'belum_bayar'::invoice_status
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
