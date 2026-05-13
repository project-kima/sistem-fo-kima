-- Fix customer contract document package data.
-- Run in Supabase SQL Editor. Review audit result before COMMIT.
-- Business rule: contracts represent real contract/BAK documents, and package fields on contracts are the source of truth.
-- Activation fee belongs to customers and is charged only once at the first cooperation date.

BEGIN;

-- Before audit: target customer contract rows.
SELECT
  c.name AS customer_name,
  ct.id AS contract_id,
  ct.contract_number,
  ct.start_date AS contract_start,
  ct.end_date AS contract_end,
  ct.core_type AS contract_core_type,
  ct.core_total AS contract_core_total,
  ct.sharing_ratio AS contract_sharing_ratio,
  cv.id AS version_id,
  cv.version_number,
  cv.core_type AS version_core_type,
  cv.core_total AS version_core_total,
  cv.shared_core_ratio AS version_shared_core_ratio
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN contract_versions cv ON cv.contract_id = ct.id
WHERE c.name IN (
  'PT Bank Tabungan Negara (Persero)',
  'PT Karya Teknik Mulia (PT Wastec International)',
  'PT Charoen Pokphand Indonesia'
)
ORDER BY c.name, ct.end_date DESC, ct.contract_number, cv.version_number DESC;

-- BTN and Wastec contract documents in this data set still use sharing core 1/32.
WITH target_contracts AS (
  SELECT ct.id
  FROM customers c
  JOIN contracts ct ON ct.customer_id = c.id
  WHERE c.name IN (
    'PT Bank Tabungan Negara (Persero)',
    'PT Karya Teknik Mulia (PT Wastec International)'
  )
)
UPDATE contracts ct
SET
  core_type = 'sharing_core',
  core_total = 0,
  sharing_ratio = '1/32',
  updated_at = NOW()
FROM target_contracts target
WHERE ct.id = target.id;

WITH target_contracts AS (
  SELECT ct.id
  FROM customers c
  JOIN contracts ct ON ct.customer_id = c.id
  WHERE c.name IN (
    'PT Bank Tabungan Negara (Persero)',
    'PT Karya Teknik Mulia (PT Wastec International)'
  )
)
UPDATE contract_versions cv
SET
  core_type = 'sharing_core',
  core_total = 0,
  shared_core_ratio = '1/32',
  updated_at = NOW()
FROM target_contracts target
WHERE cv.contract_id = target.id;

-- Charoen has three real annual BAK/contract documents in the spreadsheet.
-- Split the previously merged 2024-2026 parent contract into one contract row per document.
DO $$
DECLARE
  v_customer_id BIGINT;
  v_contract_2024_id BIGINT;
  v_contract_2025_id BIGINT;
  v_contract_2026_id BIGINT;
  v_version_2024_id BIGINT;
  v_version_2025_id BIGINT;
  v_version_2026_id BIGINT;
BEGIN
  SELECT id INTO v_customer_id
  FROM customers
  WHERE name = 'PT Charoen Pokphand Indonesia'
  ORDER BY id
  LIMIT 1;

  IF v_customer_id IS NULL THEN
    RAISE NOTICE 'PT Charoen Pokphand Indonesia not found, skipping Charoen fix.';
    RETURN;
  END IF;

  UPDATE customers
  SET
    contract_start_date = COALESCE(contract_start_date, DATE '2024-01-01'),
    activation_fee_amount = COALESCE(activation_fee_amount, 2500000),
    updated_at = NOW()
  WHERE id = v_customer_id;

  SELECT id INTO v_contract_2024_id
  FROM contracts
  WHERE customer_id = v_customer_id
    AND contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023'
  ORDER BY id
  LIMIT 1;

  IF v_contract_2024_id IS NULL THEN
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
    ) VALUES (
      v_customer_id,
      'KIMA.BAK-54/DBO/FO/XII/2023',
      DATE '2024-01-01',
      DATE '2024-12-31',
      'sharing_core',
      0,
      '1/32',
      'expired',
      1,
      'bulan',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_contract_2024_id;
  ELSE
    UPDATE contracts
    SET
      start_date = DATE '2024-01-01',
      end_date = DATE '2024-12-31',
      core_type = 'sharing_core',
      core_total = 0,
      sharing_ratio = '1/32',
      status = 'expired',
      billing_every = COALESCE(billing_every, 1),
      billing_unit = COALESCE(billing_unit, 'bulan'),
      updated_at = NOW()
    WHERE id = v_contract_2024_id;
  END IF;

  SELECT id INTO v_contract_2025_id
  FROM contracts
  WHERE customer_id = v_customer_id
    AND contract_number = 'KIMA.BAK-70/DBO/FO/XII/2024'
  ORDER BY id
  LIMIT 1;

  IF v_contract_2025_id IS NULL THEN
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
    ) VALUES (
      v_customer_id,
      'KIMA.BAK-70/DBO/FO/XII/2024',
      DATE '2025-01-01',
      DATE '2025-12-31',
      'sharing_core',
      0,
      '1/32',
      'expired',
      1,
      'bulan',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_contract_2025_id;
  ELSE
    UPDATE contracts
    SET
      start_date = DATE '2025-01-01',
      end_date = DATE '2025-12-31',
      core_type = 'sharing_core',
      core_total = 0,
      sharing_ratio = '1/32',
      status = 'expired',
      billing_every = COALESCE(billing_every, 1),
      billing_unit = COALESCE(billing_unit, 'bulan'),
      updated_at = NOW()
    WHERE id = v_contract_2025_id;
  END IF;

  SELECT id INTO v_contract_2026_id
  FROM contracts
  WHERE customer_id = v_customer_id
    AND contract_number = 'KIMA.BAK-60/DBO/FO/XII/2025'
  ORDER BY id
  LIMIT 1;

  IF v_contract_2026_id IS NULL THEN
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
    ) VALUES (
      v_customer_id,
      'KIMA.BAK-60/DBO/FO/XII/2025',
      DATE '2026-01-01',
      DATE '2026-12-31',
      'sharing_core',
      0,
      '1/8',
      'aktif',
      1,
      'bulan',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_contract_2026_id;
  ELSE
    UPDATE contracts
    SET
      start_date = DATE '2026-01-01',
      end_date = DATE '2026-12-31',
      core_type = 'sharing_core',
      core_total = 0,
      sharing_ratio = '1/8',
      status = 'aktif',
      billing_every = COALESCE(billing_every, 1),
      billing_unit = COALESCE(billing_unit, 'bulan'),
      updated_at = NOW()
    WHERE id = v_contract_2026_id;
  END IF;

  SELECT id INTO v_version_2024_id
  FROM contract_versions
  WHERE customer_id = v_customer_id
    AND start_date = DATE '2024-01-01'
    AND end_date = DATE '2024-12-31'
  ORDER BY id
  LIMIT 1;

  IF v_version_2024_id IS NULL THEN
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
      created_at,
      updated_at
    ) VALUES (
      v_contract_2024_id,
      v_customer_id,
      1,
      DATE '2024-01-01',
      DATE '2024-12-31',
      'sharing_core',
      0,
      '1/32',
      250000,
      3000000,
      'Kontrak 2024 sesuai data Excel',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_version_2024_id;
  ELSE
    UPDATE contract_versions
    SET
      contract_id = v_contract_2024_id,
      version_number = 1,
      core_type = 'sharing_core',
      core_total = 0,
      shared_core_ratio = '1/32',
      monthly_amount = COALESCE(monthly_amount, 250000),
      yearly_amount = COALESCE(yearly_amount, 3000000),
      updated_at = NOW()
    WHERE id = v_version_2024_id;
  END IF;

  SELECT id INTO v_version_2025_id
  FROM contract_versions
  WHERE customer_id = v_customer_id
    AND start_date = DATE '2025-01-01'
    AND end_date = DATE '2025-12-31'
  ORDER BY id
  LIMIT 1;

  IF v_version_2025_id IS NULL THEN
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
      created_at,
      updated_at
    ) VALUES (
      v_contract_2025_id,
      v_customer_id,
      1,
      DATE '2025-01-01',
      DATE '2025-12-31',
      'sharing_core',
      0,
      '1/32',
      250000,
      3000000,
      'Kontrak 2025 sesuai data Excel; paket meneruskan 1/32',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_version_2025_id;
  ELSE
    UPDATE contract_versions
    SET
      contract_id = v_contract_2025_id,
      version_number = 1,
      core_type = 'sharing_core',
      core_total = 0,
      shared_core_ratio = '1/32',
      monthly_amount = COALESCE(monthly_amount, 250000),
      yearly_amount = COALESCE(yearly_amount, 3000000),
      updated_at = NOW()
    WHERE id = v_version_2025_id;
  END IF;

  SELECT id INTO v_version_2026_id
  FROM contract_versions
  WHERE customer_id = v_customer_id
    AND start_date = DATE '2026-01-01'
    AND end_date = DATE '2026-12-31'
  ORDER BY id
  LIMIT 1;

  IF v_version_2026_id IS NULL THEN
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
      created_at,
      updated_at
    ) VALUES (
      v_contract_2026_id,
      v_customer_id,
      1,
      DATE '2026-01-01',
      DATE '2026-12-31',
      'sharing_core',
      0,
      '1/8',
      1000000,
      12000000,
      'Kontrak 2026 sesuai data Excel; upgrade sharing core ke 1/8',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_version_2026_id;
  ELSE
    UPDATE contract_versions
    SET
      contract_id = v_contract_2026_id,
      version_number = 1,
      core_type = 'sharing_core',
      core_total = 0,
      shared_core_ratio = '1/8',
      monthly_amount = COALESCE(monthly_amount, 1000000),
      yearly_amount = COALESCE(yearly_amount, 12000000),
      updated_at = NOW()
    WHERE id = v_version_2026_id;
  END IF;

  UPDATE invoices
  SET
    contract_id = v_contract_2024_id,
    contract_version_id = v_version_2024_id,
    contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023',
    amount = COALESCE(amount, 250000),
    updated_at = NOW()
  WHERE customer_id = v_customer_id
    AND period_year = 2024;

  UPDATE invoices
  SET
    contract_id = v_contract_2025_id,
    contract_version_id = v_version_2025_id,
    contract_number = 'KIMA.BAK-70/DBO/FO/XII/2024',
    amount = COALESCE(amount, 250000),
    updated_at = NOW()
  WHERE customer_id = v_customer_id
    AND period_year = 2025;

  UPDATE invoices
  SET
    contract_id = v_contract_2026_id,
    contract_version_id = v_version_2026_id,
    contract_number = 'KIMA.BAK-60/DBO/FO/XII/2025',
    amount = COALESCE(amount, 1000000),
    updated_at = NOW()
  WHERE customer_id = v_customer_id
    AND period_year = 2026;

  UPDATE documents
  SET
    contract_id = v_contract_2024_id,
    contract_version_id = CASE WHEN contract_version_id IS NULL THEN NULL ELSE v_version_2024_id END,
    contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023'
  WHERE customer_id = v_customer_id
    AND (
      contract_number = 'KIMA.BAK-54/DBO/FO/XII/2023'
      OR tanggal_dokumen BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'
    );

  UPDATE documents
  SET
    contract_id = v_contract_2025_id,
    contract_version_id = CASE WHEN contract_version_id IS NULL THEN NULL ELSE v_version_2025_id END,
    contract_number = 'KIMA.BAK-70/DBO/FO/XII/2024'
  WHERE customer_id = v_customer_id
    AND (
      contract_number = 'KIMA.BAK-70/DBO/FO/XII/2024'
      OR tanggal_dokumen BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
    );

  UPDATE documents
  SET
    contract_id = v_contract_2026_id,
    contract_version_id = CASE WHEN contract_version_id IS NULL THEN NULL ELSE v_version_2026_id END,
    contract_number = 'KIMA.BAK-60/DBO/FO/XII/2025'
  WHERE customer_id = v_customer_id
    AND (
      contract_number = 'KIMA.BAK-60/DBO/FO/XII/2025'
      OR tanggal_dokumen BETWEEN DATE '2026-01-01' AND DATE '2026-12-31'
    );
END $$;

-- Normalize legacy sharing_core rows: ratio is the ordered amount, so core_total must not also contain 1.
UPDATE contracts
SET
  core_total = 0,
  updated_at = NOW()
WHERE core_type = 'sharing_core'
  AND sharing_ratio IS NOT NULL
  AND sharing_ratio <> ''
  AND COALESCE(core_total, 0) <> 0;

UPDATE contract_versions
SET
  core_total = 0,
  updated_at = NOW()
WHERE core_type = 'sharing_core'
  AND shared_core_ratio IS NOT NULL
  AND shared_core_ratio <> ''
  AND COALESCE(core_total, 0) <> 0;

-- After audit: Charoen should have three separate contract documents: 2024 1/32, 2025 1/32, 2026 1/8.
SELECT
  c.name AS customer_name,
  ct.id AS contract_id,
  ct.contract_number,
  ct.start_date AS contract_start,
  ct.end_date AS contract_end,
  ct.core_type AS contract_core_type,
  ct.core_total AS contract_core_total,
  ct.sharing_ratio AS contract_sharing_ratio,
  cv.id AS version_id,
  cv.version_number,
  cv.core_type AS version_core_type,
  cv.core_total AS version_core_total,
  cv.shared_core_ratio AS version_shared_core_ratio,
  cv.monthly_amount,
  cv.yearly_amount
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN contract_versions cv ON cv.contract_id = ct.id
WHERE c.name IN (
  'PT Bank Tabungan Negara (Persero)',
  'PT Karya Teknik Mulia (PT Wastec International)',
  'PT Charoen Pokphand Indonesia'
)
ORDER BY c.name, ct.end_date DESC, ct.contract_number, cv.version_number DESC;

COMMIT;
