-- Insert Data PT Charoen Pokphand Indonesia
-- Tanggal: 2026-05-12
-- 3 Versi Kontrak: 2024, 2025, 2026

BEGIN;

-- 1. Cek ISP PT Cendikia Global Solusi
DO $$
DECLARE
  v_isp_id INT;
  v_customer_id INT;
  v_contract_id INT;
  v_version_id INT;
BEGIN
  -- Get ISP ID
  SELECT id INTO v_isp_id FROM isps WHERE name = 'PT Cendikia Global Solusi';

  IF v_isp_id IS NULL THEN
    RAISE EXCEPTION 'ISP PT Cendikia Global Solusi tidak ditemukan';
  END IF;

  -- 2. Insert Customer
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
    NOW(), -- Sudah dibayar
    NULL,
    '2024-01-01',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_customer_id;

  RAISE NOTICE 'Customer created with ID: %', v_customer_id;

  -- 3. Insert Customer-ISP Membership
  INSERT INTO customer_isp_memberships (
    customer_id,
    isp_id,
    created_at,
    updated_at
  ) VALUES (
    v_customer_id,
    v_isp_id,
    NOW(),
    NOW()
  );

  -- 4. Insert Contract (Parent)
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
    'KIMA.BAK-54/DBO/FO/XII/2023', -- Kontrak pertama
    '2024-01-01',
    '2026-12-31', -- End date dari versi terakhir
    'sharing_core',
    0,
    '1/32', -- Ratio awal
    'aktif',
    1,
    'bulan',
    NOW(),
    NOW()
  )
  RETURNING id INTO v_contract_id;

  RAISE NOTICE 'Contract created with ID: %', v_contract_id;

  -- 5. Insert Contract Version 1 (2024)
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
  ) VALUES (
    v_contract_id,
    v_customer_id,
    1,
    '2024-01-01',
    '2024-12-31',
    'sharing_core',
    0,
    '1/32',
    250000,
    3000000,
    'Kontrak awal 2024',
    NULL, -- BAK akan diupload terpisah
    NOW(),
    NOW()
  )
  RETURNING id INTO v_version_id;

  RAISE NOTICE 'Contract Version 1 (2024) created with ID: %', v_version_id;

  -- Insert Invoices untuk 2024 (Jan-Dec)
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
  ) VALUES
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/I/2024', 2024, 1, '2024-01-01', '2024-01-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/II/2024', 2024, 2, '2024-02-01', '2024-02-29', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/III/2024', 2024, 3, '2024-03-01', '2024-03-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/IV/2024', 2024, 4, '2024-04-01', '2024-04-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/V/2024', 2024, 5, '2024-05-01', '2024-05-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/VI/2024', 2024, 6, '2024-06-01', '2024-06-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/VII/2024', 2024, 7, '2024-07-01', '2024-07-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/VIII/2024', 2024, 8, '2024-08-01', '2024-08-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/IX/2024', 2024, 9, '2024-09-01', '2024-09-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/X/2024', 2024, 10, '2024-10-01', '2024-10-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/XI/2024', 2024, 11, '2024-11-01', '2024-11-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/XII/2023', 'INV-024/KIMA/FO/XII/2024', 2024, 12, '2024-12-01', '2024-12-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW());

  RAISE NOTICE 'Invoices 2024 created (12 invoices)';

  -- 6. Insert Contract Version 2 (2025)
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
  ) VALUES (
    v_contract_id,
    v_customer_id,
    2,
    '2025-01-01',
    '2025-12-31',
    'sharing_core',
    0,
    '1/32', -- Sama dengan 2024
    250000,
    3000000,
    'Perpanjangan 2025',
    NULL,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_version_id;

  RAISE NOTICE 'Contract Version 2 (2025) created with ID: %', v_version_id;

  -- Insert Invoices untuk 2025 (Jan-Dec)
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
  ) VALUES
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/I/2025', 2025, 1, '2025-01-01', '2025-01-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/II/2025', 2025, 2, '2025-02-01', '2025-02-28', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/III/2025', 2025, 3, '2025-03-01', '2025-03-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/IV/2025', 2025, 4, '2025-04-01', '2025-04-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/V/2025', 2025, 5, '2025-05-01', '2025-05-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/VI/2025', 2025, 6, '2025-06-01', '2025-06-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/VII/2025', 2025, 7, '2025-07-01', '2025-07-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/VIII/2025', 2025, 8, '2025-08-01', '2025-08-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/IX/2025', 2025, 9, '2025-09-01', '2025-09-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/X/2025', 2025, 10, '2025-10-01', '2025-10-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/XI/2025', 2025, 11, '2025-11-01', '2025-11-30', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-70/DBO/FO/XII/2024', 'INV-027/KIMA/FO/XII/2025', 2025, 12, '2025-12-01', '2025-12-31', 250000, 'lunas', 1, 'active', NOW(), NOW(), NOW());

  RAISE NOTICE 'Invoices 2025 created (12 invoices)';

  -- 7. Insert Contract Version 3 (2026) - Upgrade ke 1/8
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
  ) VALUES (
    v_contract_id,
    v_customer_id,
    3,
    '2026-01-01',
    '2026-12-31',
    'sharing_core',
    0,
    '1/8', -- UPGRADE dari 1/32 ke 1/8
    1000000, -- Naik dari 250k ke 1jt
    12000000, -- Naik dari 3jt ke 12jt
    'Perpanjangan 2026 dengan upgrade sharing core dari 1/32 ke 1/8',
    NULL,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_version_id;

  RAISE NOTICE 'Contract Version 3 (2026) created with ID: %', v_version_id;

  -- Insert Invoices untuk 2026 (Jan-Dec)
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
  ) VALUES
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/1/26', 2026, 1, '2026-01-01', '2026-01-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/2/26', 2026, 2, '2026-02-01', '2026-02-28', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/3/26', 2026, 3, '2026-03-01', '2026-03-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/4/26', 2026, 4, '2026-04-01', '2026-04-30', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/5/26', 2026, 5, '2026-05-01', '2026-05-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/6/26', 2026, 6, '2026-06-01', '2026-06-30', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/7/26', 2026, 7, '2026-07-01', '2026-07-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/8/26', 2026, 8, '2026-08-01', '2026-08-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/9/26', 2026, 9, '2026-09-01', '2026-09-30', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/10/26', 2026, 10, '2026-10-01', '2026-10-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/11/26', 2026, 11, '2026-11-01', '2026-11-30', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW()),
    (v_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-60/DBO/FO/XII/2025', '009/FO/12/26', 2026, 12, '2026-12-01', '2026-12-31', 1000000, 'lunas', 1, 'active', NOW(), NOW(), NOW());

  RAISE NOTICE 'Invoices 2026 created (12 invoices)';

  RAISE NOTICE '=== DATA INSERTION COMPLETED ===';
  RAISE NOTICE 'Customer ID: %', v_customer_id;
  RAISE NOTICE 'Contract ID: %', v_contract_id;
  RAISE NOTICE 'Total Contract Versions: 3';
  RAISE NOTICE 'Total Invoices: 36 (12 per year)';

END $$;

COMMIT;
