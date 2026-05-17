-- ============================================================================
-- UPSERT DATA CUSTOMER PT LADO TEKNO PARKIR, INDOSAT, FNI - PRODUCTION
-- ============================================================================
-- Tanggal: 2026-05-15
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Review, lalu copy-paste script ini ke Supabase SQL Editor dan Run
-- Catatan:
-- - Status '-' dan 'BT' dari spreadsheet dimasukkan sebagai 'belum_ditagih'.
-- - Pelanggan Indosat bernama "Core" diperlakukan sebagai customer name literal.
-- - Baris "2027 ditagihkan" dibuat sebagai invoice pada kontrak yang sama, bukan kontrak baru.
-- - Paket Lado periode 2025/2026 diwariskan dari kontrak sebelumnya: sharing_core 1/8.
-- ============================================================================

BEGIN;

DO $$
DECLARE
  v_isp_id BIGINT;
  v_customer_id BIGINT;
  v_contract_id BIGINT;
  v_version_id BIGINT;
  v_doc_id BIGINT;
  v_period_start DATE;
  v_period_end DATE;
  v_invoice_number TEXT;
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
      -- PT Lado Tekno Parkir
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-001', 'POS 1', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-06/DBO/FO/IV/2024', 'INV-048/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-001', 'POS 1', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-72/DBO/FO/XII/2024', 'INV-007/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-001', 'POS 1', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-22/DBO/FO/VI/2025 dan 003/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 063/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-002', 'POS 2', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-07/DBO/FO/IV/2024', 'INV-049/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-002', 'POS 2', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-73/DBO/FO/XII/2024 dan 014/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-008/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-002', 'POS 2', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-23/DBO/FO/VI/2025 dan 004/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 064/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-003', 'POS 3', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-08/DBO/FO/IV/2024', 'INV-050/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-003', 'POS 3', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-74/DBO/FO/XII/2024 dan 015/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-009/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-003', 'POS 3', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-24/DBO/FO/VI/2025 dan 005/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 065/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-004', 'POS 4', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-09/DBO/FO/IV/2024', 'INV-051/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-004', 'POS 4', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-75/DBO/FO/XII/2024 dan 016/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-010/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-004', 'POS 4', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-25/DBO/FO/VI/2025 dan 006/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 066/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-005', 'POS 5', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-10/DBO/FO/IV/2024', 'INV-052/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-005', 'POS 5', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-76/DBO/FO/XII/2024 dan 017/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-011/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-005', 'POS 5', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-26/DBO/FO/VI/2025 dan 007/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 067/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-007', 'POS 7', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-11/DBO/FO/IV/2024', 'INV-053/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-007', 'POS 7', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-77/DBO/FO/XII/2024 dan 018/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-012/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-007', 'POS 7', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-27/DBO/FO/VI/2025 dan 008/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 068/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-008', 'POS 8', DATE '2023-12-29', DATE '2023-07-29', DATE '2024-12-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-12/DBO/FO/IV/2024', 'INV-054/KIMA/FO/VII/2024', 'lunas', NULL, 250000::numeric, 1750000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2024-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-008', 'POS 8', DATE '2023-12-29', DATE '2024-07-29', DATE '2025-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-78/DBO/FO/XII/2024 dan 019/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-013/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, NULL::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-008', 'POS 8', DATE '2023-12-29', DATE '2025-07-29', DATE '2026-12-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-28/DBO/FO/VI/2025 dan 009/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 069/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-07-01', DATE '2027-03-01'),

      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-010', 'POS 10', DATE '2024-05-20', DATE '2024-05-20', DATE '2025-12-19', 'sharing_core', 0, '1/8', 'KIMA.BAK-79/DBO/FO/XII/2024 dan 020/BAK.FO.LTPK-KIMA/LTPK/XII/2024', 'INV-015/KIMA/FO/I/2025', 'lunas', NULL, 250000::numeric, 3000000::numeric, 2500000::numeric, DATE '2025-01-01', DATE '2025-12-01'),
      ('PT Lado Tekno Parkir', 'CUST-LADO-POS-010', 'POS 10', DATE '2024-05-20', DATE '2025-05-20', DATE '2026-12-19', 'sharing_core', 0, '1/8', 'KIMA.BAK-29/DBO/FO/VI/2025 dan 010/BAK.FO.LTPK-KIMA/LTPK/VI/2025', 'INV. 070/FO/7/25', 'belum_ditagih', NULL, 250000::numeric, NULL::numeric, NULL::numeric, DATE '2026-05-01', DATE '2027-03-01'),

      -- PT Indonesian Satellite Corporation (PT Indosat Tbk)
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-35', 'Core', DATE '2024-06-01', DATE '2024-06-01', DATE '2025-05-31', 'core', 35, NULL, 'KIMA.PERU-069/DIU/X/2024 Nomor: 0366000000', 'INV-096/KIMA/FO/XII/2024', 'lunas', NULL, 73500000::numeric, 882000000::numeric, NULL::numeric, DATE '2024-06-01', DATE '2025-05-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-35', 'Core', DATE '2024-06-01', DATE '2025-06-01', DATE '2027-05-31', 'core', 35, NULL, 'KIMA.PERU-029/DIU/VI/2025 Nomor: 0366A01000', '073/FO/7/25', 'lunas', NULL, 73500000::numeric, 882000000::numeric, NULL::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-35', 'Core', DATE '2024-06-01', DATE '2025-06-01', DATE '2027-05-31', 'core', 35, NULL, 'KIMA.PERU-029/DIU/VI/2025 Nomor: 0366A01000', 'TAGIH-2027-0366A01000', 'belum_ditagih', '2027 ditagihkan', 77875000::numeric, 934500000::numeric, NULL::numeric, DATE '2026-06-01', DATE '2027-05-01'),

      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-15', 'Core', DATE '2023-04-25', DATE '2023-04-25', DATE '2024-04-24', 'core', 15, NULL, 'KIMA.PERU-084/DU/IV/2023', '112/INV.FO/V/2023', 'lunas', NULL, 42750000::numeric, 513000000::numeric, NULL::numeric, DATE '2023-05-01', DATE '2024-04-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-15', 'Core', DATE '2023-04-25', DATE '2024-04-25', DATE '2025-04-24', 'core', 15, NULL, 'KIMA.BAK- 169/DIU/VI/2024', 'INV-035/KIMA/FO/VI/2024', 'lunas', NULL, 31500000::numeric, 378000000::numeric, NULL::numeric, DATE '2024-06-01', DATE '2025-05-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-15', 'Core', DATE '2023-04-25', DATE '2025-04-25', DATE '2027-04-24', 'core', 15, NULL, 'KIMA-PERU-030/DIU/VI/2025 Nomor: 0087A03000', '072/FO/7/25', 'lunas', NULL, 31500000::numeric, 378000000::numeric, NULL::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-CORE-15', 'Core', DATE '2023-04-25', DATE '2025-04-25', DATE '2027-04-24', 'core', 15, NULL, 'KIMA-PERU-030/DIU/VI/2025 Nomor: 0087A03000', 'TAGIH-2027-0087A03000', 'belum_ditagih', '2027 ditagihkan', 33375000::numeric, 400500000::numeric, NULL::numeric, DATE '2026-06-01', DATE '2027-05-01'),

      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-PARAGON-001', 'PT Paragon Technology And Innovation', DATE '2023-08-01', DATE '2023-08-01', DATE '2024-07-31', 'core', 1, NULL, 'KIMA.BAK-32/DBO/FO/VII/2023', '161/INV.FO/VIII/2023', 'lunas', NULL, 2100000::numeric, 25200000::numeric, NULL::numeric, DATE '2023-08-01', DATE '2024-07-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-PARAGON-001', 'PT Paragon Technology And Innovation', DATE '2023-08-01', DATE '2024-08-01', DATE '2025-07-31', 'core', 1, NULL, 'KIMA.BAK-53/DBO/FO/VIII/2024', 'INV-094/KIMA/FO/XI/2024', 'lunas', NULL, 2100000::numeric, 25200000::numeric, NULL::numeric, DATE '2024-08-01', DATE '2025-07-01'),
      ('PT Indonesian Satellite Corporation (PT Indosat Tbk)', 'CUST-INDOSAT-PARAGON-001', 'PT Paragon Technology And Innovation', DATE '2023-08-01', DATE '2025-08-01', DATE '2026-07-31', 'core', 1, NULL, 'KIMA.BAK-19/DBO/FO/IV/2025', '110/FO/12/25', 'lunas', NULL, 2100000::numeric, 25200000::numeric, NULL::numeric, DATE '2025-08-01', DATE '2026-07-01'),

      -- PT Fiber Networks Indonesia
      ('PT Fiber Networks Indonesia', 'CUST-FNI-BUMI-SARANA-BETON', 'PT Bumi Sarana Beton', DATE '2024-10-01', DATE '2024-10-01', DATE '2025-06-30', 'core', 1, NULL, 'KIMA.BAK-61/DBO/FO/X/2024', 'INV-082/KIMA/FO/X/2024', 'lunas', 'Tahap 1 lunas; spreadsheet juga mencatat sharing core 1/32', 6000000::numeric, 72000000::numeric, 2500000::numeric, DATE '2024-10-01', DATE '2025-09-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-BUMI-SARANA-BETON', 'PT Bumi Sarana Beton', DATE '2024-10-01', DATE '2025-10-01', DATE '2026-06-30', 'sharing_core', 0, '1/32', 'KIMA.BAK-53/DBO/FO/XI/2025', '107/FO/11/25', 'lunas', 'Okt 25 - Nov 25 (1 Core) Des 25- Jun 26 (1/32); total mengikuti rincian invoice bulanan', NULL::numeric, 13925000::numeric, NULL::numeric, DATE '2025-10-01', DATE '2026-06-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-SINAR-SEJAHTERA', 'PT Sinar Sejahtera Sentosa', DATE '2025-05-14', DATE '2025-05-14', DATE '2026-05-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-09/DBO/FO/V/2025', 'INV-044/KIMA/FO/VI/2025', 'lunas', NULL, 275000::numeric, 3300000::numeric, 2500000::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-BUMI-MENARA-1', 'PT Bumi Menara Internusa 1', DATE '2025-05-14', DATE '2025-05-14', DATE '2026-05-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-10/DBO/FO/V/2025', 'INV-045/KIMA/FO/VI/2025', 'lunas', NULL, 275000::numeric, 3300000::numeric, 2500000::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-BUMI-MENARA-2', 'PT Bumi Menara Internusa 2', DATE '2025-05-14', DATE '2025-05-14', DATE '2026-05-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-12/DBO/FO/V/2025', 'INV-047/KIMA/FO/VI/2025', 'lunas', NULL, 275000::numeric, 3300000::numeric, 2500000::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-MAKASSAR-KULINA', 'PT Makassar Kulina Utama', DATE '2025-05-14', DATE '2025-05-14', DATE '2026-05-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-11/DBO/FO/V/2025', 'INV-046/KIMA/FO/VI/2025', 'lunas', NULL, 275000::numeric, 3300000::numeric, 2500000::numeric, DATE '2025-06-01', DATE '2026-05-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-GRAND-KAKAO', 'PT Grand Kakao Indonesia', DATE '2025-09-29', DATE '2025-09-29', DATE '2026-09-28', 'sharing_core', 0, '1/8', 'KIMA.BAK-06/DBO/FO/IX/2025', '078/FO/10/25', 'lunas', NULL, 1200000::numeric, 14400000::numeric, 2500000::numeric, DATE '2025-10-01', DATE '2026-09-01'),
      ('PT Fiber Networks Indonesia', 'CUST-FNI-WAHYU-PRADANA', 'PT Wahyu Pradana Binamulia', DATE '2026-03-01', DATE '2026-03-01', DATE '2027-02-28', 'sharing_core', 0, '1/32', 'KIMA.BAK-14/DBO/FO/III/2026', 'BT-CUST-FNI-WAHYU-PRADANA-202603', 'belum_ditagih', 'BT', 300000::numeric, 3600000::numeric, 2500000::numeric, DATE '2026-03-01', DATE '2027-02-01')
    ) AS value(isp_name, customer_code, customer_name, cooperation_start_date, contract_start_date, contract_end_date, core_type, core_total, sharing_ratio, contract_number, invoice_seed, invoice_status, remarks, monthly_amount, yearly_amount, activation_fee_amount, invoice_start_month, invoice_end_month)
  LOOP
    SELECT id INTO v_isp_id
    FROM isps
    WHERE lower(trim(name)) = lower(trim(row_data.isp_name))
    ORDER BY id
    LIMIT 1;

    IF v_isp_id IS NULL THEN
      INSERT INTO isps (name, status, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)
      VALUES (row_data.isp_name, 'aktif', (CASE WHEN row_data.core_type = 'core' THEN 'core' ELSE 'shared' END)::isp_package_type, COALESCE(row_data.core_total, 0), 'monthly', 0, NOW(), NOW())
      RETURNING id INTO v_isp_id;
    ELSE
      UPDATE isps
      SET status = COALESCE(status, 'aktif'), billing_period_mode = COALESCE(billing_period_mode, 'monthly'), updated_at = NOW()
      WHERE id = v_isp_id;
    END IF;

    SELECT id INTO v_customer_id
    FROM customers
    WHERE customer_code = row_data.customer_code
    ORDER BY id
    LIMIT 1;

    IF v_customer_id IS NULL THEN
      INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
      VALUES (row_data.customer_code, row_data.isp_name, row_data.customer_name, 'aktif', COALESCE(row_data.activation_fee_amount, 0), row_data.cooperation_start_date, NOW(), NOW())
      RETURNING id INTO v_customer_id;
    ELSE
      UPDATE customers
      SET
        isp_name = row_data.isp_name,
        name = row_data.customer_name,
        status = COALESCE(status, 'aktif'),
        activation_fee_amount = CASE WHEN COALESCE(activation_fee_amount, 0) = 0 THEN COALESCE(row_data.activation_fee_amount, activation_fee_amount, 0) ELSE activation_fee_amount END,
        contract_start_date = COALESCE(contract_start_date, row_data.cooperation_start_date),
        updated_at = NOW()
      WHERE id = v_customer_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM customer_isp_memberships WHERE customer_id = v_customer_id AND isp_id = v_isp_id) THEN
      INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)
      VALUES (v_customer_id, v_isp_id, NOW(), NOW());
    END IF;

    v_contract_number := row_data.contract_number;

    IF EXISTS (
      SELECT 1
      FROM contracts c
      JOIN customers cu ON cu.id = c.customer_id
      WHERE c.contract_number = v_contract_number
        AND cu.customer_code <> row_data.customer_code
    ) THEN
      v_contract_number := v_contract_number || '-' || row_data.customer_code;
    END IF;

    v_contract_status := CASE WHEN row_data.contract_end_date >= CURRENT_DATE THEN 'aktif' ELSE 'expired' END::contract_status;

    v_invoice_month_count := (
      (EXTRACT(YEAR FROM age(row_data.invoice_end_month, row_data.invoice_start_month))::int * 12)
      + EXTRACT(MONTH FROM age(row_data.invoice_end_month, row_data.invoice_start_month))::int
      + 1
    );
    v_monthly_amount := COALESCE(row_data.monthly_amount, CASE WHEN v_invoice_month_count > 0 THEN row_data.yearly_amount / v_invoice_month_count ELSE 0 END, 0);
    v_yearly_amount := COALESCE(row_data.yearly_amount, v_monthly_amount * v_invoice_month_count, 0);

    SELECT id INTO v_contract_id
    FROM contracts
    WHERE customer_id = v_customer_id
      AND contract_number = v_contract_number
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NULL THEN
      INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
      VALUES (v_customer_id, v_contract_number, row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, COALESCE(row_data.core_total, 0), row_data.sharing_ratio, v_contract_status, 1, 'bulan', NOW(), NOW())
      RETURNING id INTO v_contract_id;
    ELSE
      UPDATE contracts
      SET
        start_date = LEAST(start_date, row_data.contract_start_date),
        end_date = GREATEST(end_date, row_data.contract_end_date),
        core_type = row_data.core_type::core_allocation_type,
        core_total = COALESCE(row_data.core_total, 0),
        sharing_ratio = row_data.sharing_ratio,
        status = v_contract_status,
        billing_every = COALESCE(billing_every, 1),
        billing_unit = COALESCE(billing_unit, 'bulan'),
        updated_at = NOW()
      WHERE id = v_contract_id;
    END IF;

    SELECT id INTO v_version_id
    FROM contract_versions
    WHERE contract_id = v_contract_id
      AND start_date = row_data.contract_start_date
      AND end_date = row_data.contract_end_date
    ORDER BY id
    LIMIT 1;

    IF v_version_id IS NULL THEN
      INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, monthly_amount, yearly_amount, remarks, created_at, updated_at)
      VALUES (
        v_contract_id,
        v_customer_id,
        (SELECT COALESCE(MAX(version_number), 0) + 1 FROM contract_versions WHERE contract_id = v_contract_id),
        row_data.contract_start_date,
        row_data.contract_end_date,
        row_data.core_type::core_allocation_type,
        COALESCE(row_data.core_total, 0),
        row_data.sharing_ratio,
        v_monthly_amount,
        v_yearly_amount,
        COALESCE(row_data.remarks, 'Imported from Lado/Indosat/FNI spreadsheet batch'),
        NOW(),
        NOW()
      )
      RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions
      SET
        core_type = row_data.core_type::core_allocation_type,
        core_total = COALESCE(row_data.core_total, 0),
        shared_core_ratio = row_data.sharing_ratio,
        monthly_amount = v_monthly_amount,
        yearly_amount = v_yearly_amount,
        remarks = COALESCE(row_data.remarks, remarks),
        updated_at = NOW()
      WHERE id = v_version_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM documents WHERE customer_id = v_customer_id AND contract_id = v_contract_id AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type)) THEN
      INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
      VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'BAK'::document_type, row_data.contract_number, row_data.contract_start_date, 'https://files.kima.local/bak/' || replace(replace(row_data.contract_number, '/', '-'), ' ', '-') || '.pdf', NOW());
    ELSE
      UPDATE documents
      SET contract_version_id = v_version_id,
          contract_number = v_contract_number,
          nomor_dokumen = row_data.contract_number,
          tanggal_dokumen = row_data.contract_start_date
      WHERE customer_id = v_customer_id
        AND contract_id = v_contract_id
        AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type);
    END IF;

    v_period_start := row_data.invoice_start_month;
    WHILE v_period_start <= row_data.invoice_end_month LOOP
      v_period_end := (v_period_start + INTERVAL '1 month' - INTERVAL '1 day')::date;
      v_invoice_number := row_data.invoice_seed || '-' || to_char(v_period_start, 'YYYYMM');
      v_invoice_status := row_data.invoice_status;

      SELECT id INTO v_doc_id
      FROM documents
      WHERE customer_id = v_customer_id
        AND jenis_dokumen = 'invoice'::document_type
        AND nomor_dokumen = v_invoice_number
      ORDER BY id
      LIMIT 1;

      IF v_doc_id IS NULL THEN
        INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'invoice'::document_type, v_invoice_number, v_period_start, 'https://files.kima.local/invoices/' || replace(replace(v_invoice_number, '/', '-'), ' ', '-') || '.pdf', NOW())
        RETURNING id INTO v_doc_id;
      ELSE
        UPDATE documents
        SET contract_id = v_contract_id, contract_version_id = v_version_id, contract_number = v_contract_number, tanggal_dokumen = v_period_start
        WHERE id = v_doc_id;
      END IF;

      v_invoice_amount := row_data.monthly_amount;
      IF row_data.customer_code = 'CUST-FNI-BUMI-SARANA-BETON' AND row_data.contract_number = 'KIMA.BAK-53/DBO/FO/XI/2025' THEN
        IF v_period_start IN (DATE '2025-10-01', DATE '2025-11-01') THEN
          v_invoice_amount := 6000000::numeric;
        ELSE
          v_invoice_amount := 275000::numeric;
        END IF;
      END IF;

      IF EXISTS (SELECT 1 FROM invoices WHERE customer_id = v_customer_id AND invoice_number = v_invoice_number) THEN
        UPDATE invoices
        SET
          contract_id = v_contract_id,
          contract_version_id = v_version_id,
          contract_number = v_contract_number,
          period_year = EXTRACT(YEAR FROM v_period_start)::int,
          period_month = EXTRACT(MONTH FROM v_period_start)::int,
          period_start_date = v_period_start,
          period_end_date = v_period_end,
          amount = v_invoice_amount,
          status = v_invoice_status,
          schedule_version = 1,
          schedule_status = v_schedule_status,
          document_id = v_doc_id,
          paid_at = CASE WHEN v_invoice_status = 'lunas' THEN COALESCE(paid_at, NOW()) ELSE NULL END,
          updated_at = NOW()
        WHERE customer_id = v_customer_id
          AND invoice_number = v_invoice_number;
      ELSE
        INSERT INTO invoices (customer_id, contract_id, contract_version_id, contract_number, invoice_number, period_year, period_month, period_start_date, period_end_date, amount, status, schedule_version, schedule_status, document_id, paid_at, created_at, updated_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, v_invoice_number, EXTRACT(YEAR FROM v_period_start)::int, EXTRACT(MONTH FROM v_period_start)::int, v_period_start, v_period_end, v_invoice_amount, v_invoice_status, 1, v_schedule_status, v_doc_id, CASE WHEN v_invoice_status = 'lunas' THEN NOW() ELSE NULL END, NOW(), NOW());
      END IF;

      v_period_start := (v_period_start + INTERVAL '1 month')::date;
    END LOOP;
  END LOOP;
END $$;

-- Verification Query: Summary per ISP/customer/contract
SELECT
  c.isp_name,
  c.customer_code,
  c.name AS customer_name,
  c.contract_start_date AS cooperation_start_date,
  ct.contract_number,
  ct.start_date,
  ct.end_date,
  ct.core_type,
  ct.core_total,
  ct.sharing_ratio,
  ct.status AS contract_status,
  COUNT(i.id) AS invoice_count,
  COALESCE(SUM(i.amount), 0) AS invoice_total,
  MIN(i.period_start_date) AS first_invoice_period,
  MAX(i.period_start_date) AS last_invoice_period
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN invoices i ON i.contract_id = ct.id
WHERE c.customer_code LIKE 'CUST-LADO-%'
   OR c.customer_code LIKE 'CUST-INDOSAT-%'
   OR c.customer_code LIKE 'CUST-FNI-%'
GROUP BY c.isp_name, c.customer_code, c.name, c.contract_start_date, ct.id, ct.contract_number, ct.start_date, ct.end_date, ct.core_type, ct.core_total, ct.sharing_ratio, ct.status
ORDER BY c.isp_name, c.customer_code, ct.start_date;

COMMIT;
