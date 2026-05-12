-- ============================================================================
-- INSERT DATA PT CHAROEN POKPHAND INDONESIA - PRODUCTION (SUPABASE)
-- ============================================================================
-- Tanggal: 2026-05-12
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
-- ============================================================================

-- IMPORTANT: Pastikan ISP "PT Cendikia Global Solusi" sudah ada di database
-- Jika belum ada, jalankan query ini dulu untuk cek:
-- SELECT id, name FROM isps WHERE name = 'PT Cendikia Global Solusi';

BEGIN;

-- ============================================================================
-- STEP 1: INSERT CUSTOMER
-- ============================================================================
INSERT INTO customers (
  customer_code,
  isp_name,
  name,
  status,
  activation_fee_amount,
  activation_fee_paid_at,
  notes,
  contract_start_date,
  created_at,
  updated_at
) VALUES (
  'CUST-CPI-001',
  'PT Cendikia Global Solusi',
  'PT Charoen Pokphand Indonesia',
  'aktif',
  2500000,
  NOW(),
  NULL,
  '2024-01-01',
  NOW(),
  NOW()
);

-- Get customer_id yang baru dibuat (akan digunakan di step berikutnya)
-- Supabase akan auto-generate ID, kita ambil dari customer_code
-- Customer ID akan digunakan: SELECT id FROM customers WHERE customer_code = 'CUST-CPI-001'

-- ============================================================================
-- STEP 2: INSERT CUSTOMER-ISP MEMBERSHIP
-- ============================================================================
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
FROM customers c
CROSS JOIN isps i
WHERE c.customer_code = 'CUST-CPI-001'
  AND i.name = 'PT Cendikia Global Solusi';

-- ============================================================================
-- STEP 3: INSERT CONTRACT (PARENT)
-- ============================================================================
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
  id,
  'KIMA.BAK-54/DBO/FO/XII/2023',
  '2024-01-01',
  '2026-12-31',
  'sharing_core',
  0,
  '1/32',
  'aktif',
  1,
  'bulan',
  NOW(),
  NOW()
FROM customers
WHERE customer_code = 'CUST-CPI-001';

-- ============================================================================
-- STEP 4: INSERT CONTRACT VERSION 1 (2024)
-- ============================================================================
INSERT INTO contract_versions (
  contract_id,
  customer_id,
  version_number,
  start_date,
  end_date,
  core_type,
  core_total,
  shared_core_ratio,
  monthly_amount,
  yearly_amount,
  remarks,
  bak_document_id,
  created_at,
  updated_at
)
SELECT
  ct.id,
  c.id,
  1,
  '2024-01-01',
  '2024-12-31',
  'sharing_core',
  0,
  '1/32',
  250000,
  3000000,
  'Kontrak awal 2024',
  NULL,
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- ============================================================================
-- STEP 5: INSERT INVOICES 2024 (12 bulan)
-- ============================================================================
INSERT INTO invoices (
  customer_id,
  contract_id,
  contract_version_id,
  contract_number,
  invoice_number,
  period_year,
  period_month,
  period_start_date,
  period_end_date,
  amount,
  status,
  schedule_version,
  schedule_status,
  paid_at,
  created_at,
  updated_at
)
SELECT
  c.id,
  ct.id,
  cv.id,
  'KIMA.BAK-54/DBO/FO/XII/2023',
  'INV-024/KIMA/FO/' ||
    CASE month_num
      WHEN 1 THEN 'I'
      WHEN 2 THEN 'II'
      WHEN 3 THEN 'III'
      WHEN 4 THEN 'IV'
      WHEN 5 THEN 'V'
      WHEN 6 THEN 'VI'
      WHEN 7 THEN 'VII'
      WHEN 8 THEN 'VIII'
      WHEN 9 THEN 'IX'
      WHEN 10 THEN 'X'
      WHEN 11 THEN 'XI'
      WHEN 12 THEN 'XII'
    END || '/2024',
  2024,
  month_num,
  DATE '2024-01-01' + (month_num - 1 || ' month')::INTERVAL,
  (DATE '2024-01-01' + (month_num || ' month')::INTERVAL) - INTERVAL '1 day',
  250000,
  'lunas',
  1,
  'active',
  NOW(),
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
JOIN contract_versions cv ON cv.contract_id = ct.id AND cv.version_number = 1
CROSS JOIN generate_series(1, 12) AS month_num
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- ============================================================================
-- STEP 6: INSERT CONTRACT VERSION 2 (2025)
-- ============================================================================
INSERT INTO contract_versions (
  contract_id,
  customer_id,
  version_number,
  start_date,
  end_date,
  core_type,
  core_total,
  shared_core_ratio,
  monthly_amount,
  yearly_amount,
  remarks,
  bak_document_id,
  created_at,
  updated_at
)
SELECT
  ct.id,
  c.id,
  2,
  '2025-01-01',
  '2025-12-31',
  'sharing_core',
  0,
  '1/32',
  250000,
  3000000,
  'Perpanjangan 2025',
  NULL,
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- ============================================================================
-- STEP 7: INSERT INVOICES 2025 (12 bulan)
-- ============================================================================
INSERT INTO invoices (
  customer_id,
  contract_id,
  contract_version_id,
  contract_number,
  invoice_number,
  period_year,
  period_month,
  period_start_date,
  period_end_date,
  amount,
  status,
  schedule_version,
  schedule_status,
  paid_at,
  created_at,
  updated_at
)
SELECT
  c.id,
  ct.id,
  cv.id,
  'KIMA.BAK-70/DBO/FO/XII/2024',
  'INV-027/KIMA/FO/' ||
    CASE month_num
      WHEN 1 THEN 'I'
      WHEN 2 THEN 'II'
      WHEN 3 THEN 'III'
      WHEN 4 THEN 'IV'
      WHEN 5 THEN 'V'
      WHEN 6 THEN 'VI'
      WHEN 7 THEN 'VII'
      WHEN 8 THEN 'VIII'
      WHEN 9 THEN 'IX'
      WHEN 10 THEN 'X'
      WHEN 11 THEN 'XI'
      WHEN 12 THEN 'XII'
    END || '/2025',
  2025,
  month_num,
  DATE '2025-01-01' + (month_num - 1 || ' month')::INTERVAL,
  (DATE '2025-01-01' + (month_num || ' month')::INTERVAL) - INTERVAL '1 day',
  250000,
  'lunas',
  1,
  'active',
  NOW(),
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
JOIN contract_versions cv ON cv.contract_id = ct.id AND cv.version_number = 2
CROSS JOIN generate_series(1, 12) AS month_num
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- ============================================================================
-- STEP 8: INSERT CONTRACT VERSION 3 (2026) - UPGRADE
-- ============================================================================
INSERT INTO contract_versions (
  contract_id,
  customer_id,
  version_number,
  start_date,
  end_date,
  core_type,
  core_total,
  shared_core_ratio,
  monthly_amount,
  yearly_amount,
  remarks,
  bak_document_id,
  created_at,
  updated_at
)
SELECT
  ct.id,
  c.id,
  3,
  '2026-01-01',
  '2026-12-31',
  'sharing_core',
  0,
  '1/8',
  1000000,
  12000000,
  'Perpanjangan 2026 dengan upgrade sharing core dari 1/32 ke 1/8',
  NULL,
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- ============================================================================
-- STEP 9: INSERT INVOICES 2026 (12 bulan)
-- ============================================================================
INSERT INTO invoices (
  customer_id,
  contract_id,
  contract_version_id,
  contract_number,
  invoice_number,
  period_year,
  period_month,
  period_start_date,
  period_end_date,
  amount,
  status,
  schedule_version,
  schedule_status,
  paid_at,
  created_at,
  updated_at
)
SELECT
  c.id,
  ct.id,
  cv.id,
  'KIMA.BAK-60/DBO/FO/XII/2025',
  '009/FO/' || month_num || '/26',
  2026,
  month_num,
  DATE '2026-01-01' + (month_num - 1 || ' month')::INTERVAL,
  (DATE '2026-01-01' + (month_num || ' month')::INTERVAL) - INTERVAL '1 day',
  1000000,
  'lunas',
  1,
  'active',
  NOW(),
  NOW(),
  NOW()
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
JOIN contract_versions cv ON cv.contract_id = ct.id AND cv.version_number = 3
CROSS JOIN generate_series(1, 12) AS month_num
WHERE c.customer_code = 'CUST-CPI-001'
  AND ct.contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Optional - untuk cek hasil)
-- ============================================================================
-- Uncomment untuk verifikasi setelah insert

-- -- Cek customer
-- SELECT id, customer_code, name, status, activation_fee_amount
-- FROM customers
-- WHERE customer_code = 'CUST-CPI-001';

-- -- Cek contract
-- SELECT id, customer_id, contract_number, start_date, end_date, status
-- FROM contracts
-- WHERE contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023';

-- -- Cek contract versions
-- SELECT id, version_number, start_date, end_date, shared_core_ratio, monthly_amount, yearly_amount
-- FROM contract_versions
-- WHERE customer_id = (SELECT id FROM customers WHERE customer_code = 'CUST-CPI-001')
-- ORDER BY version_number;

-- -- Cek total invoices
-- SELECT period_year, COUNT(*) as total_invoices, SUM(amount) as total_amount
-- FROM invoices
-- WHERE customer_id = (SELECT id FROM customers WHERE customer_code = 'CUST-CPI-001')
-- GROUP BY period_year
-- ORDER BY period_year;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. Script ini akan insert:
--    - 1 Customer (PT Charoen Pokphand Indonesia)
--    - 1 Contract dengan 3 versions (2024, 2025, 2026)
--    - 36 Invoices (12 per tahun, semua lunas)
--
-- 2. Upgrade di 2026:
--    - Sharing core: 1/32 → 1/8
--    - Monthly amount: Rp 250,000 → Rp 1,000,000
--    - Yearly amount: Rp 3,000,000 → Rp 12,000,000
--
-- 3. Jika ada error "duplicate key", berarti data sudah ada.
--    Hapus dulu dengan:
--    DELETE FROM customers WHERE customer_code = 'CUST-CPI-001';
--
-- 4. Pastikan field baru (monthly_amount, yearly_amount, notes, remarks)
--    sudah ada di production database. Jika belum, jalankan migration dulu.
-- ============================================================================
