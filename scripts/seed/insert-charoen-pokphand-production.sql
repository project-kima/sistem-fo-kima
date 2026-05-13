-- ============================================================================
-- UPSERT DATA PT CHAROEN POKPHAND INDONESIA - PRODUCTION (SUPABASE)
-- ============================================================================
-- Tanggal: 2026-05-13
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
-- ============================================================================

-- IMPORTANT: Pastikan ISP "PT Cendikia Global Solusi" sudah ada di database.
-- SELECT id, name FROM isps WHERE name = 'PT Cendikia Global Solusi';

BEGIN;

DO $$
DECLARE
  v_customer_id BIGINT;
  v_isp_id BIGINT;
  v_contract_id BIGINT;
  v_version_id BIGINT;
  v_doc_id BIGINT;
  v_month INT;
  v_invoice_number TEXT;
  contract_row RECORD;
BEGIN
  SELECT id INTO v_isp_id
  FROM isps
  WHERE name = 'PT Cendikia Global Solusi'
  ORDER BY id
  LIMIT 1;

  IF v_isp_id IS NULL THEN
    RAISE EXCEPTION 'ISP PT Cendikia Global Solusi not found.';
  END IF;

  SELECT id INTO v_customer_id
  FROM customers
  WHERE customer_code = 'CUST-CPI-001'
     OR name = 'PT Charoen Pokphand Indonesia'
  ORDER BY id
  LIMIT 1;

  IF v_customer_id IS NULL THEN
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
      DATE '2024-01-01',
      NOW(),
      NOW()
    )
    RETURNING id INTO v_customer_id;
  ELSE
    UPDATE customers
    SET
      customer_code = COALESCE(customer_code, 'CUST-CPI-001'),
      isp_name = 'PT Cendikia Global Solusi',
      name = 'PT Charoen Pokphand Indonesia',
      status = 'aktif',
      activation_fee_amount = COALESCE(activation_fee_amount, 2500000),
      contract_start_date = COALESCE(contract_start_date, DATE '2024-01-01'),
      updated_at = NOW()
    WHERE id = v_customer_id;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM customer_isp_memberships
    WHERE customer_id = v_customer_id
      AND isp_id = v_isp_id
  ) THEN
    INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)
    VALUES (v_customer_id, v_isp_id, NOW(), NOW());
  END IF;

  FOR contract_row IN
    SELECT *
    FROM (VALUES
      ('KIMA.BAK-54/DBO/FO/XII/2023'::text, DATE '2024-01-01', DATE '2024-12-31', '1/32'::text, 'expired'::text, 250000::numeric, 3000000::numeric, 'Kontrak 2024 sesuai data Excel'::text, 'INV-024/KIMA/FO'::text),
      ('KIMA.BAK-70/DBO/FO/XII/2024'::text, DATE '2025-01-01', DATE '2025-12-31', '1/32'::text, 'expired'::text, 250000::numeric, 3000000::numeric, 'Kontrak 2025 sesuai data Excel; paket meneruskan 1/32'::text, 'INV-027/KIMA/FO'::text),
      ('KIMA.BAK-60/DBO/FO/XII/2025'::text, DATE '2026-01-01', DATE '2026-12-31', '1/8'::text, 'aktif'::text, 1000000::numeric, 12000000::numeric, 'Kontrak 2026 sesuai data Excel; upgrade sharing core ke 1/8'::text, '009/FO'::text)
    ) AS value(contract_number, start_date, end_date, sharing_ratio, status, monthly_amount, yearly_amount, remarks, invoice_prefix)
  LOOP
    SELECT id INTO v_contract_id
    FROM contracts
    WHERE customer_id = v_customer_id
      AND contract_number = contract_row.contract_number
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NULL THEN
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
        contract_row.contract_number,
        contract_row.start_date,
        contract_row.end_date,
        'sharing_core',
        0,
        contract_row.sharing_ratio,
        contract_row.status,
        1,
        'bulan',
        NOW(),
        NOW()
      )
      RETURNING id INTO v_contract_id;
    ELSE
      UPDATE contracts
      SET
        start_date = contract_row.start_date,
        end_date = contract_row.end_date,
        core_type = 'sharing_core',
        core_total = 0,
        sharing_ratio = contract_row.sharing_ratio,
        status = contract_row.status,
        billing_every = COALESCE(billing_every, 1),
        billing_unit = COALESCE(billing_unit, 'bulan'),
        updated_at = NOW()
      WHERE id = v_contract_id;
    END IF;

    SELECT id INTO v_version_id
    FROM contract_versions
    WHERE contract_id = v_contract_id
      AND version_number = 1
    ORDER BY id
    LIMIT 1;

    IF v_version_id IS NULL THEN
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
        contract_row.start_date,
        contract_row.end_date,
        'sharing_core',
        0,
        contract_row.sharing_ratio,
        contract_row.monthly_amount,
        contract_row.yearly_amount,
        contract_row.remarks,
        NULL,
        NOW(),
        NOW()
      )
      RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions
      SET
        start_date = contract_row.start_date,
        end_date = contract_row.end_date,
        core_type = 'sharing_core',
        core_total = 0,
        shared_core_ratio = contract_row.sharing_ratio,
        monthly_amount = contract_row.monthly_amount,
        yearly_amount = contract_row.yearly_amount,
        remarks = contract_row.remarks,
        updated_at = NOW()
      WHERE id = v_version_id;
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM documents
      WHERE customer_id = v_customer_id
        AND contract_id = v_contract_id
        AND jenis_dokumen IN ('kontrak', 'BAK')
    ) THEN
      INSERT INTO documents (
        customer_id,
        contract_id,
        contract_version_id,
        contract_number,
        jenis_dokumen,
        nomor_dokumen,
        tanggal_dokumen,
        file_url,
        created_at
      ) VALUES (
        v_customer_id,
        v_contract_id,
        v_version_id,
        contract_row.contract_number,
        'BAK',
        contract_row.contract_number,
        contract_row.start_date,
        'https://files.kima.local/bak/' || contract_row.contract_number || '.pdf',
        NOW()
      );
    END IF;

    FOR v_month IN 1..12 LOOP
      IF EXTRACT(YEAR FROM contract_row.start_date)::int = 2026 THEN
        v_invoice_number := contract_row.invoice_prefix || '/' || v_month || '/26';
      ELSE
        v_invoice_number := contract_row.invoice_prefix || '/' ||
          CASE v_month
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
          END || '/' || EXTRACT(YEAR FROM contract_row.start_date)::int;
      END IF;

      SELECT id INTO v_doc_id
      FROM documents
      WHERE customer_id = v_customer_id
        AND jenis_dokumen = 'invoice'
        AND nomor_dokumen = v_invoice_number
      ORDER BY id
      LIMIT 1;

      IF v_doc_id IS NULL THEN
        INSERT INTO documents (
          customer_id,
          contract_id,
          contract_version_id,
          contract_number,
          jenis_dokumen,
          nomor_dokumen,
          tanggal_dokumen,
          file_url,
          created_at
        ) VALUES (
          v_customer_id,
          v_contract_id,
          v_version_id,
          contract_row.contract_number,
          'invoice',
          v_invoice_number,
          make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1),
          'https://files.kima.local/invoices/' || v_invoice_number || '.pdf',
          NOW()
        )
        RETURNING id INTO v_doc_id;
      ELSE
        UPDATE documents
        SET
          contract_id = v_contract_id,
          contract_version_id = v_version_id,
          contract_number = contract_row.contract_number,
          tanggal_dokumen = make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1)
        WHERE id = v_doc_id;
      END IF;

      IF EXISTS (
        SELECT 1
        FROM invoices
        WHERE customer_id = v_customer_id
          AND invoice_number = v_invoice_number
      ) THEN
        UPDATE invoices
        SET
          contract_id = v_contract_id,
          contract_version_id = v_version_id,
          contract_number = contract_row.contract_number,
          period_year = EXTRACT(YEAR FROM contract_row.start_date)::int,
          period_month = v_month,
          period_start_date = make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1),
          period_end_date = (make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1) + INTERVAL '1 month' - INTERVAL '1 day')::date,
          amount = contract_row.monthly_amount,
          status = 'lunas',
          schedule_version = 1,
          schedule_status = 'active',
          document_id = v_doc_id,
          updated_at = NOW()
        WHERE customer_id = v_customer_id
          AND invoice_number = v_invoice_number;
      ELSE
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
          document_id,
          paid_at,
          created_at,
          updated_at
        ) VALUES (
          v_customer_id,
          v_contract_id,
          v_version_id,
          contract_row.contract_number,
          v_invoice_number,
          EXTRACT(YEAR FROM contract_row.start_date)::int,
          v_month,
          make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1),
          (make_date(EXTRACT(YEAR FROM contract_row.start_date)::int, v_month, 1) + INTERVAL '1 month' - INTERVAL '1 day')::date,
          contract_row.monthly_amount,
          'lunas',
          1,
          'active',
          v_doc_id,
          NOW(),
          NOW(),
          NOW()
        );
      END IF;
    END LOOP;
  END LOOP;
END $$;

COMMIT;

-- Verification:
-- SELECT ct.contract_number, ct.start_date, ct.end_date, ct.core_type, ct.sharing_ratio, cv.monthly_amount, cv.yearly_amount
-- FROM customers c
-- JOIN contracts ct ON ct.customer_id = c.id
-- LEFT JOIN contract_versions cv ON cv.contract_id = ct.id
-- WHERE c.customer_code = 'CUST-CPI-001'
-- ORDER BY ct.end_date DESC;
--
-- SELECT period_year, contract_number, COUNT(*) AS total_invoices, SUM(amount) AS total_amount
-- FROM invoices
-- WHERE customer_id = (SELECT id FROM customers WHERE customer_code = 'CUST-CPI-001')
-- GROUP BY period_year, contract_number
-- ORDER BY period_year;
