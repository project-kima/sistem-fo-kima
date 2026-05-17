-- ============================================================================
-- UPSERT DATA CUSTOMER BERHENTI PT CENDIKIA GLOBAL SOLUSI - PRODUCTION
-- ============================================================================
-- Tanggal: 2026-05-17
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Review, lalu copy-paste script ini ke Supabase SQL Editor dan Run
-- Catatan:
-- - Semua customer pada batch ini ditandai status 'berhenti'.
-- - Customer status 'berhenti' wajib membuat customer_route_versions.flow_status = 'nonaktif'.
-- - Status '-' pada invoice dimasukkan sebagai 'belum_ditagih'.
-- - Baris tanpa nomor BAK memakai nomor teknis NO-BAK-*; nomor invoice asli tetap menjadi invoice seed.
-- - Semua paket 1/32 dimasukkan sebagai sharing_core; data MSC Indosat core memakai core_total sesuai angka spreadsheet.
-- ============================================================================

BEGIN;

DO $$
DECLARE
  v_isp_id BIGINT;
  v_customer_id BIGINT;
  v_contract_id BIGINT;
  v_version_id BIGINT;
  v_doc_id BIGINT;
  v_route_version_id BIGINT;
  v_period_start DATE;
  v_period_end DATE;
  v_invoice_number TEXT;
  v_invoice_file_name TEXT;
  v_contract_number TEXT;
  v_contract_status contract_status;
  v_invoice_status invoices.status%TYPE;
  v_invoice_amount numeric;
  v_monthly_amount numeric;
  v_yearly_amount numeric;
  v_invoice_month_count int;
  v_schedule_status invoices.schedule_status%TYPE := 'active';
  row_data RECORD;
BEGIN
  FOR row_data IN
    SELECT *
    FROM (VALUES
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BSC-XL-KIMA-9', 'BSC XL (Kima 9)', DATE '2023-09-04', DATE '2023-09-04', DATE '2024-09-03', 'sharing_core', 0, '1/32', 'KIMA.BAK-39/DBO/FO/VIII/2023', '184/INV.FO/XI/2023', 'lunas', 'Berhenti', 500000::numeric, 6000000::numeric, 2500000::numeric, DATE '2023-09-01', DATE '2024-08-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BSC-XL-KIMA-9', 'BSC XL (Kima 9)', DATE '2023-09-04', DATE '2024-09-04', DATE '2025-09-03', 'sharing_core', 0, '1/32', 'KIMA.BAK-56/DBO/FO/IX/2024', 'INV-018/KIMA/FO/I/2025', 'lunas', 'Berhenti', 500000::numeric, 6000000::numeric, NULL::numeric, DATE '2024-09-01', DATE '2025-08-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-1', 'PT Bumi Menara Internusa Plant 1', DATE '2022-11-28', DATE '2022-11-28', DATE '2023-02-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-21/DBO/FO/V/2023', 'INV-018/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2022-11-01', DATE '2023-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-1', 'PT Bumi Menara Internusa Plant 1', DATE '2022-11-28', DATE '2023-11-28', DATE '2024-02-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-52/DBO/FO/X/2023', 'INV-019/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-11-01', DATE '2024-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-1', 'PT Bumi Menara Internusa Plant 1', DATE '2022-11-28', DATE '2024-11-28', DATE '2025-02-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-69/DBO/FO/XII/2024', 'INV-051/KIMA/FO/VI/2025', 'belum_ditagih', 'Berhenti', 250000::numeric, 750000::numeric, NULL::numeric, DATE '2024-11-01', DATE '2025-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-2', 'PT Bumi Menara Internusa Plant 2', DATE '2022-11-07', DATE '2022-11-07', DATE '2023-02-06', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-BUMI-MENARA-PLANT-2-2022', '078/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 1000000::numeric, DATE '2022-11-01', DATE '2023-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-2', 'PT Bumi Menara Internusa Plant 2', DATE '2022-11-07', DATE '2023-11-07', DATE '2024-02-06', 'sharing_core', 0, '1/32', 'KIMA.BAK-51/DBO/FO/X/2023', 'INV-022/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-11-01', DATE '2024-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-MENARA-PLANT-2', 'PT Bumi Menara Internusa Plant 2', DATE '2022-11-07', DATE '2024-11-07', DATE '2025-02-06', 'sharing_core', 0, '1/32', 'KIMA.BAK-66/DBO/FO/X/2024', 'INV-050/KIMA/FO/VI/2025', 'lunas', 'Berhenti', 250000::numeric, 750000::numeric, NULL::numeric, DATE '2024-11-01', DATE '2025-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-BUMI-SARANA-BETON', 'PT Bumi Sarana Beton', DATE '2023-11-23', DATE '2023-11-23', DATE '2024-11-22', 'sharing_core', 0, '1/32', 'KIMA.BAK-53/DBO/FO/XI/2023', 'INV-023/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2023-11-01', DATE '2024-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-GLOBAL-RETAILINDO-PRATAMA', 'PT Global Retailindo Pratama', DATE '2022-02-05', DATE '2022-02-05', DATE '2023-08-04', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-GLOBAL-RETAILINDO-2022', '068/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2022-02-01', DATE '2023-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-GLOBAL-RETAILINDO-PRATAMA', 'PT Global Retailindo Pratama', DATE '2022-02-05', DATE '2023-02-05', DATE '2024-08-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-17/DBO/FO/V/2023', '119/INV.FO/VI/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-02-01', DATE '2024-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-GLOBAL-RETAILINDO-PRATAMA', 'PT Global Retailindo Pratama', DATE '2022-02-05', DATE '2024-02-05', DATE '2025-08-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-20/DBO/FO/VI/2024', 'INV-026/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2024-02-01', DATE '2025-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-INDOMARCO-KIMA-6', 'PT Indomarco Prismatama (Kima 6)', DATE '2021-09-24', DATE '2021-09-24', DATE '2022-09-24', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-INDOMARCO-KIMA-6-2021', '125/INV.FO/VI/2023', 'lunas', 'Berhenti', 250000::numeric, 2250000::numeric, 1000000::numeric, DATE '2021-09-01', DATE '2022-05-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-INDOMARCO-KIMA-6', 'PT Indomarco Prismatama (Kima 6)', DATE '2021-09-24', DATE '2022-09-24', DATE '2023-09-24', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-INDOMARCO-KIMA-6-2022', '126/INV.FO/VI/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2022-09-01', DATE '2023-08-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MSC-INDOSAT-KIMA-13', 'MSC PT Indosat Tbk (Kima 13)', DATE '2022-02-03', DATE '2022-02-03', DATE '2023-06-02', 'core', 4, NULL, 'NO-BAK-CENDIKIA-MSC-INDOSAT-KIMA-13-2022', '124/INV.FO/VI/2023', 'lunas', 'Berhenti', 12000000::numeric, 48000000::numeric, NULL::numeric, DATE '2022-02-01', DATE '2022-05-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MSC-INDOSAT-KIMA-13', 'MSC PT Indosat Tbk (Kima 13)', DATE '2022-02-03', DATE '2023-02-03', DATE '2023-06-02', 'core', 4, NULL, 'KIMA.BAK-22/DBO/FO/V/2023', '166/INV.FO/VIII/2023', 'lunas', 'Berhenti', 12000000::numeric, 48000000::numeric, NULL::numeric, DATE '2023-02-01', DATE '2023-05-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MSC-INDOSAT-KIMA-9', 'MSC PT Indosat Tbk (Kima 9)', DATE '2023-07-12', DATE '2023-07-12', DATE '2024-07-11', 'core', 6, NULL, 'KIMA.BAK-26/DBO/FO/VI/2023', '129/INV.FO/VII/2023', 'lunas', 'Berhenti', 21780000::numeric, 261360000::numeric, 2500000::numeric, DATE '2023-07-01', DATE '2024-06-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MSC-INDOSAT-KIMA-9', 'MSC PT Indosat Tbk (Kima 9)', DATE '2023-07-12', DATE '2024-07-14', DATE '2024-08-13', 'core', 6, NULL, 'KIMA.BAK-46/DBO/FO/VII/2024', 'INV-067/KIMA/FO/VII/2024', 'lunas', 'Berhenti', 27000000::numeric, 27000000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-07-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-KEMASAN-CIPTA-NUSANTARA', 'PT Kemasan Cipta Nusantara', DATE '2022-09-28', DATE '2022-09-28', DATE '2023-09-27', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-KEMASAN-CIPTA-2022', '080/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2022-09-01', DATE '2023-08-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MALINDO-FEEDMIL', 'PT Malindo Feedmil', DATE '2022-07-21', DATE '2022-07-21', DATE '2023-07-20', 'sharing_core', 0, '1/32', 'KIMA.108A/FO-DIR/VII/2022', '064/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2022-07-01', DATE '2023-06-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MALINDO-FEEDMIL', 'PT Malindo Feedmil', DATE '2022-07-21', DATE '2023-07-21', DATE '2024-07-20', 'sharing_core', 0, '1/32', 'KIMA.BAK-41/DBO/FO/IX/2023', '186/INV.FO/XI/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-07-01', DATE '2024-06-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MULTISARI-MAKASSAR', 'PT Multisari Makassar', DATE '2023-07-24', DATE '2023-07-24', DATE '2024-07-23', 'sharing_core', 0, '1/32', 'KIMA.BAK-31/DBO/FO/VII/2023', '158/INV.FO/VII/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2023-07-01', DATE '2024-06-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-SINAR-SEJAHTERA-SENTOSA', 'PT Sinar Sejahtera Sentosa', DATE '2022-05-05', DATE '2022-05-05', DATE '2023-05-04', 'sharing_core', 0, '1/32', 'KIMA.077A/FO-DIR/V/2022', '066/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2022-05-01', DATE '2023-04-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-SINAR-SEJAHTERA-SENTOSA', 'PT Sinar Sejahtera Sentosa', DATE '2022-05-05', DATE '2023-05-05', DATE '2024-05-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-20/DBO/FO/V/2023', '122/INV.FO/VI/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-05-01', DATE '2024-04-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-SINAR-SEJAHTERA-SENTOSA', 'PT Sinar Sejahtera Sentosa', DATE '2022-05-05', DATE '2024-05-05', DATE '2025-05-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-23/DBO/FO/VI/2024', 'INV-029/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2024-05-01', DATE '2025-04-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-TOARCO-JAYA', 'PT Toarco Jaya', DATE '2022-11-24', DATE '2022-11-24', DATE '2023-11-23', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-TOARCO-JAYA-2022', '083/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 1000000::numeric, DATE '2022-11-01', DATE '2023-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-CARGILL', 'PT Cargill', DATE '2023-10-09', DATE '2023-10-09', DATE '2024-10-08', 'sharing_core', 0, '1/32', 'KIMA.BAK.47/DBO/FO/IX/2023', '191/INV.FO/XI/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2023-10-01', DATE '2024-09-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MAKASSAR-KULINA-UTAMA', 'PT Makassar Kulina Utama', DATE '2022-11-05', DATE '2022-11-05', DATE '2023-02-04', 'sharing_core', 0, '1/32', 'NO-BAK-CENDIKIA-MAKASSAR-KULINA-2022', '086/INV.FO/XII/2022', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2022-11-01', DATE '2023-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MAKASSAR-KULINA-UTAMA', 'PT Makassar Kulina Utama', DATE '2022-11-05', DATE '2023-11-05', DATE '2024-02-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-50/DBO/FO/X/2023', 'INV-021/KIMA/FO/VI/2024', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2023-11-01', DATE '2024-10-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-MAKASSAR-KULINA-UTAMA', 'PT Makassar Kulina Utama', DATE '2022-11-05', DATE '2024-11-05', DATE '2025-02-04', 'sharing_core', 0, '1/32', 'KIMA.BAK-65/DBO/FO/X/2024', 'INV-049/KIMA/FO/VI/2025', 'lunas', 'Berhenti', 250000::numeric, 750000::numeric, NULL::numeric, DATE '2024-11-01', DATE '2025-01-01'),
      ('PT Cendikia Global Solusi', 'CUST-CENDIKIA-RUDI-CAHYADI', 'Rudi Cahyadi', DATE '2023-03-13', DATE '2023-03-13', DATE '2024-03-12', 'sharing_core', 0, '1/32', 'KIMA.BAK-03/DBO/FO/III/2023', '096/INV.FO/III/2023', 'lunas', 'Berhenti', 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2023-03-01', DATE '2024-02-01')
    ) AS value(isp_name, customer_code, customer_name, cooperation_start_date, contract_start_date, contract_end_date, core_type, core_total, sharing_ratio, contract_number, invoice_seed, invoice_status, remarks, monthly_amount, yearly_amount, activation_fee_amount, invoice_start_month, invoice_end_month)
  LOOP
    SELECT id INTO v_isp_id FROM isps WHERE lower(trim(name)) = lower(trim(row_data.isp_name)) ORDER BY id LIMIT 1;
    IF v_isp_id IS NULL THEN
      INSERT INTO isps (name, status, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)
      VALUES (row_data.isp_name, 'aktif', (CASE WHEN row_data.core_type = 'core' THEN 'core' ELSE 'shared' END)::isp_package_type, COALESCE(row_data.core_total, 0), 'monthly', 0, NOW(), NOW()) RETURNING id INTO v_isp_id;
    ELSE
      UPDATE isps SET status = COALESCE(status, 'aktif'), paket = COALESCE(paket, (CASE WHEN row_data.core_type = 'core' THEN 'core' ELSE 'shared' END)::isp_package_type), jumlah = GREATEST(COALESCE(jumlah, 0), COALESCE(row_data.core_total, 0)), billing_period_mode = COALESCE(billing_period_mode, 'monthly'), updated_at = NOW() WHERE id = v_isp_id;
    END IF;

    SELECT id INTO v_customer_id FROM customers WHERE customer_code = row_data.customer_code ORDER BY id LIMIT 1;
    IF v_customer_id IS NULL THEN
      INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
      VALUES (row_data.customer_code, row_data.isp_name, row_data.customer_name, 'berhenti', COALESCE(row_data.activation_fee_amount, 0), row_data.cooperation_start_date, NOW(), NOW()) RETURNING id INTO v_customer_id;
    ELSE
      UPDATE customers SET isp_name = row_data.isp_name, name = row_data.customer_name, status = 'berhenti', activation_fee_amount = CASE WHEN COALESCE(activation_fee_amount, 0) = 0 THEN COALESCE(row_data.activation_fee_amount, activation_fee_amount, 0) ELSE activation_fee_amount END, contract_start_date = COALESCE(contract_start_date, row_data.cooperation_start_date), updated_at = NOW() WHERE id = v_customer_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM customer_isp_memberships WHERE customer_id = v_customer_id AND isp_id = v_isp_id) THEN
      INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at) VALUES (v_customer_id, v_isp_id, NOW(), NOW());
    END IF;

    SELECT id INTO v_route_version_id FROM customer_route_versions WHERE customer_id = v_customer_id AND flow_status = 'nonaktif' AND change_note = 'Customer berhenti; jalur otomatis nonaktif.' ORDER BY version_number DESC, created_at DESC, id DESC LIMIT 1;
    IF v_route_version_id IS NULL THEN
      INSERT INTO customer_route_versions (customer_id, version_number, flow_status, change_note, created_at, updated_at)
      VALUES (v_customer_id, (SELECT COALESCE(MAX(version_number), 0) + 1 FROM customer_route_versions WHERE customer_id = v_customer_id), 'nonaktif', 'Customer berhenti; jalur otomatis nonaktif.', NOW(), NOW()) RETURNING id INTO v_route_version_id;
    ELSE
      UPDATE customer_route_versions SET flow_status = 'nonaktif', change_note = 'Customer berhenti; jalur otomatis nonaktif.', updated_at = NOW() WHERE id = v_route_version_id;
    END IF;

    v_contract_number := row_data.contract_number;
    IF EXISTS (SELECT 1 FROM contracts c JOIN customers cu ON cu.id = c.customer_id WHERE c.contract_number = v_contract_number AND cu.customer_code <> row_data.customer_code) THEN
      v_contract_number := v_contract_number || '-' || row_data.customer_code;
    END IF;

    v_contract_status := CASE WHEN row_data.contract_end_date >= CURRENT_DATE THEN 'aktif' ELSE 'expired' END::contract_status;
    v_invoice_month_count := ((EXTRACT(YEAR FROM age(row_data.invoice_end_month, row_data.invoice_start_month))::int * 12) + EXTRACT(MONTH FROM age(row_data.invoice_end_month, row_data.invoice_start_month))::int + 1);
    v_monthly_amount := COALESCE(row_data.monthly_amount, CASE WHEN v_invoice_month_count > 0 THEN row_data.yearly_amount / v_invoice_month_count ELSE 0 END, 0);
    v_yearly_amount := COALESCE(row_data.yearly_amount, v_monthly_amount * v_invoice_month_count, 0);

    SELECT id INTO v_contract_id FROM contracts WHERE customer_id = v_customer_id AND contract_number = v_contract_number ORDER BY id LIMIT 1;
    IF v_contract_id IS NULL THEN
      INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
      VALUES (v_customer_id, v_contract_number, row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, COALESCE(row_data.core_total, 0), row_data.sharing_ratio, v_contract_status, 1, 'bulan', NOW(), NOW()) RETURNING id INTO v_contract_id;
    ELSE
      UPDATE contracts SET start_date = row_data.contract_start_date, end_date = row_data.contract_end_date, core_type = row_data.core_type::core_allocation_type, core_total = COALESCE(row_data.core_total, 0), sharing_ratio = row_data.sharing_ratio, status = v_contract_status, billing_every = COALESCE(billing_every, 1), billing_unit = COALESCE(billing_unit, 'bulan'), updated_at = NOW() WHERE id = v_contract_id;
    END IF;

    SELECT id INTO v_version_id FROM contract_versions WHERE contract_id = v_contract_id AND start_date = row_data.contract_start_date AND end_date = row_data.contract_end_date ORDER BY id LIMIT 1;
    IF v_version_id IS NULL THEN
      INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, monthly_amount, yearly_amount, remarks, created_at, updated_at)
      VALUES (v_contract_id, v_customer_id, (SELECT COALESCE(MAX(version_number), 0) + 1 FROM contract_versions WHERE contract_id = v_contract_id), row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, COALESCE(row_data.core_total, 0), row_data.sharing_ratio, v_monthly_amount, v_yearly_amount, COALESCE(row_data.remarks, 'Imported from stopped Cendikia batch'), NOW(), NOW()) RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions SET core_type = row_data.core_type::core_allocation_type, core_total = COALESCE(row_data.core_total, 0), shared_core_ratio = row_data.sharing_ratio, monthly_amount = v_monthly_amount, yearly_amount = v_yearly_amount, remarks = COALESCE(row_data.remarks, remarks), updated_at = NOW() WHERE id = v_version_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM documents WHERE customer_id = v_customer_id AND contract_id = v_contract_id AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type)) THEN
      INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
      VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'BAK'::document_type, row_data.contract_number, row_data.contract_start_date, 'https://files.kima.local/bak/' || replace(replace(row_data.contract_number, '/', '-'), ' ', '-') || '.pdf', NOW());
    ELSE
      UPDATE documents SET contract_version_id = v_version_id, contract_number = v_contract_number, nomor_dokumen = row_data.contract_number, tanggal_dokumen = row_data.contract_start_date WHERE customer_id = v_customer_id AND contract_id = v_contract_id AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type);
    END IF;

    v_period_start := row_data.invoice_start_month;
    WHILE v_period_start <= row_data.invoice_end_month LOOP
      v_period_end := (v_period_start + INTERVAL '1 month' - INTERVAL '1 day')::date;
      v_invoice_number := COALESCE(row_data.invoice_seed, row_data.customer_code) || '-' || to_char(v_period_start, 'YYYYMM');
      IF length(v_invoice_number) > 100 THEN v_invoice_number := row_data.customer_code || '-' || to_char(v_period_start, 'YYYYMM'); END IF;
      v_invoice_file_name := replace(replace(v_invoice_number, '/', '-'), ' ', '-');
      IF length('https://files.kima.local/invoices/' || v_invoice_file_name || '.pdf') > 100 THEN v_invoice_file_name := row_data.customer_code || '-' || to_char(v_period_start, 'YYYYMM'); END IF;
      v_invoice_status := row_data.invoice_status;
      v_invoice_amount := v_monthly_amount;

      SELECT id INTO v_doc_id FROM documents WHERE customer_id = v_customer_id AND jenis_dokumen = 'invoice'::document_type AND nomor_dokumen = v_invoice_number ORDER BY id LIMIT 1;
      IF v_doc_id IS NULL THEN
        INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'invoice'::document_type, v_invoice_number, v_period_start, 'https://files.kima.local/invoices/' || v_invoice_file_name || '.pdf', NOW()) RETURNING id INTO v_doc_id;
      ELSE
        UPDATE documents SET contract_id = v_contract_id, contract_version_id = v_version_id, contract_number = v_contract_number, tanggal_dokumen = v_period_start WHERE id = v_doc_id;
      END IF;

      IF EXISTS (SELECT 1 FROM invoices WHERE customer_id = v_customer_id AND invoice_number = v_invoice_number) THEN
        UPDATE invoices SET contract_id = v_contract_id, contract_version_id = v_version_id, contract_number = v_contract_number, period_year = EXTRACT(YEAR FROM v_period_start)::int, period_month = EXTRACT(MONTH FROM v_period_start)::int, period_start_date = v_period_start, period_end_date = v_period_end, amount = v_invoice_amount, status = v_invoice_status, schedule_version = 1, schedule_status = v_schedule_status, document_id = v_doc_id, paid_at = CASE WHEN v_invoice_status = 'lunas' THEN COALESCE(paid_at, NOW()) ELSE NULL END, updated_at = NOW() WHERE customer_id = v_customer_id AND invoice_number = v_invoice_number;
      ELSE
        INSERT INTO invoices (customer_id, contract_id, contract_version_id, contract_number, invoice_number, period_year, period_month, period_start_date, period_end_date, amount, status, schedule_version, schedule_status, document_id, paid_at, created_at, updated_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, v_invoice_number, EXTRACT(YEAR FROM v_period_start)::int, EXTRACT(MONTH FROM v_period_start)::int, v_period_start, v_period_end, v_invoice_amount, v_invoice_status, 1, v_schedule_status, v_doc_id, CASE WHEN v_invoice_status = 'lunas' THEN NOW() ELSE NULL END, NOW(), NOW());
      END IF;

      v_period_start := (v_period_start + INTERVAL '1 month')::date;
    END LOOP;
  END LOOP;
END $$;

WITH invoice_summary AS (
  SELECT contract_id, COUNT(*) AS invoice_count, SUM(amount) AS invoice_total, MIN(period_start_date) AS first_invoice_period, MAX(period_start_date) AS last_invoice_period FROM invoices GROUP BY contract_id
), latest_route_version AS (
  SELECT DISTINCT ON (customer_id) customer_id, flow_status AS route_status, change_note AS route_change_note FROM customer_route_versions ORDER BY customer_id, version_number DESC, created_at DESC, id DESC
), latest_contract_version AS (
  SELECT DISTINCT ON (contract_id) contract_id, monthly_amount, yearly_amount, remarks FROM contract_versions ORDER BY contract_id, version_number DESC, id DESC
), document_summary AS (
  SELECT contract_id, MAX(nomor_dokumen) FILTER (WHERE jenis_dokumen IN ('BAK'::document_type, 'kontrak'::document_type)) AS original_document_number FROM documents GROUP BY contract_id
)
SELECT c.isp_name, c.customer_code, c.name AS customer_name, c.status AS customer_status, route.route_status, ct.contract_number, ct.start_date, ct.end_date, ct.core_type, ct.core_total, ct.sharing_ratio, ct.status AS contract_status, cv.monthly_amount, cv.yearly_amount, cv.remarks, COALESCE(inv.invoice_count, 0) AS invoice_count, COALESCE(inv.invoice_total, 0) AS invoice_total, inv.first_invoice_period, inv.last_invoice_period, doc.original_document_number
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN latest_route_version route ON route.customer_id = c.id
LEFT JOIN latest_contract_version cv ON cv.contract_id = ct.id
LEFT JOIN invoice_summary inv ON inv.contract_id = ct.id
LEFT JOIN document_summary doc ON doc.contract_id = ct.id
WHERE c.customer_code LIKE 'CUST-CENDIKIA-%'
  AND c.status = 'berhenti'
ORDER BY c.customer_code, ct.start_date, ct.contract_number;

COMMIT;
