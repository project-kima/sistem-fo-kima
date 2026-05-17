-- ============================================================================
-- UPSERT DATA CUSTOMER PT CITRA PRIMA MEDIA - PRODUCTION
-- ============================================================================
-- Tanggal: 2026-05-17
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
-- ============================================================================
-- Catatan import:
-- - Customer bernama Core dengan alokasi 2 core.
-- - Nomor invoice asli yang berisi beberapa nomor disimpan pada remarks.
-- - Nomor invoice teknis dibuat pendek agar aman untuk kolom varchar(100).
-- - Status invoice '-' dengan keterangan lunas dimasukkan sebagai 'lunas'.
-- ============================================================================

BEGIN;

DO $$
DECLARE
  v_isp_id BIGINT;
  v_customer_id BIGINT;
  v_contract_id BIGINT;
  v_version_id BIGINT;
  v_doc_id BIGINT;
  v_month_index INT;
  v_invoice_number TEXT;
  v_invoice_file_name TEXT;
  v_contract_number TEXT;
  v_period_start DATE;
  v_period_end DATE;
  v_invoice_status invoices.status%TYPE := 'lunas';
  v_schedule_status invoices.schedule_status%TYPE := 'active';
  row_data RECORD;
BEGIN
  SELECT id INTO v_isp_id
  FROM isps
  WHERE lower(trim(name)) = lower(trim('PT Citra Prima Media'))
     OR lower(name) LIKE '%citra prima media%'
  ORDER BY CASE
    WHEN lower(trim(name)) = lower(trim('PT Citra Prima Media')) THEN 1
    WHEN lower(name) LIKE '%citra prima media%' THEN 2
    ELSE 3
  END, id
  LIMIT 1;

  IF v_isp_id IS NULL THEN
    INSERT INTO isps (name, status, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)
    VALUES ('PT Citra Prima Media', 'aktif', 'core', 2, 'monthly', 2500000, NOW(), NOW())
    RETURNING id INTO v_isp_id;
  END IF;

  FOR row_data IN
    SELECT *
    FROM (VALUES
      (
        'CUST-CITRA-PRIMA-MEDIA-CORE-2',
        'Core',
        DATE '2024-09-13',
        DATE '2024-09-13',
        DATE '2025-09-12',
        'core',
        2,
        NULL,
        'KIMA.BAK-60/DOP/FO/IX/2024',
        'CPM-CORE2-2024',
        'lunas',
        11500000::numeric,
        138000000::numeric,
        2500000::numeric,
        12,
        'Tahap 1 & 2 lunas. Invoice sumber: INV-083/KIMA/FO/X/2024, INV-099/KIMA/FO/XII/2024, INV-036/KIMA/FO/IV/2025'
      )
    ) AS value(customer_code, customer_name, cooperation_start_date, contract_start_date, contract_end_date, core_type, core_total, sharing_ratio, contract_number, invoice_seed, invoice_status, monthly_amount, yearly_amount, activation_fee_amount, invoice_count, remarks)
  LOOP
    v_invoice_status := row_data.invoice_status;
    v_contract_number := row_data.contract_number;

    IF EXISTS (
      SELECT 1 FROM contracts c
      JOIN customers cu ON c.customer_id = cu.id
      WHERE c.contract_number = v_contract_number
        AND cu.customer_code != row_data.customer_code
    ) THEN
      v_contract_number := v_contract_number || '-' || row_data.customer_code;
    END IF;

    SELECT id INTO v_customer_id
    FROM customers
    WHERE customer_code = row_data.customer_code
    ORDER BY id
    LIMIT 1;

    IF v_customer_id IS NULL THEN
      INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
      VALUES (row_data.customer_code, 'PT Citra Prima Media', row_data.customer_name, 'aktif', COALESCE(row_data.activation_fee_amount, 0), row_data.cooperation_start_date, NOW(), NOW())
      RETURNING id INTO v_customer_id;
    ELSE
      UPDATE customers
      SET
        isp_name = 'PT Citra Prima Media',
        name = row_data.customer_name,
        status = 'aktif',
        activation_fee_amount = CASE WHEN COALESCE(activation_fee_amount, 0) = 0 THEN COALESCE(row_data.activation_fee_amount, activation_fee_amount, 0) ELSE activation_fee_amount END,
        contract_start_date = COALESCE(contract_start_date, row_data.cooperation_start_date),
        updated_at = NOW()
      WHERE id = v_customer_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM customer_isp_memberships WHERE customer_id = v_customer_id AND isp_id = v_isp_id) THEN
      INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)
      VALUES (v_customer_id, v_isp_id, NOW(), NOW());
    END IF;

    SELECT id INTO v_contract_id
    FROM contracts
    WHERE customer_id = v_customer_id
      AND contract_number = v_contract_number
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NULL THEN
      INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
      VALUES (v_customer_id, v_contract_number, row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, row_data.core_total, row_data.sharing_ratio, (CASE WHEN row_data.contract_end_date >= CURRENT_DATE THEN 'aktif' ELSE 'expired' END)::contract_status, 1, 'bulan', NOW(), NOW())
      RETURNING id INTO v_contract_id;
    ELSE
      UPDATE contracts
      SET
        start_date = row_data.contract_start_date,
        end_date = row_data.contract_end_date,
        core_type = row_data.core_type::core_allocation_type,
        core_total = row_data.core_total,
        sharing_ratio = row_data.sharing_ratio,
        status = (CASE WHEN row_data.contract_end_date >= CURRENT_DATE THEN 'aktif' ELSE 'expired' END)::contract_status,
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
        row_data.core_total,
        row_data.sharing_ratio,
        row_data.monthly_amount,
        row_data.yearly_amount,
        row_data.remarks,
        NOW(),
        NOW()
      )
      RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions
      SET
        core_type = row_data.core_type::core_allocation_type,
        core_total = row_data.core_total,
        shared_core_ratio = row_data.sharing_ratio,
        monthly_amount = row_data.monthly_amount,
        yearly_amount = row_data.yearly_amount,
        remarks = row_data.remarks,
        updated_at = NOW()
      WHERE id = v_version_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM documents WHERE customer_id = v_customer_id AND contract_id = v_contract_id AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type)) THEN
      INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
      VALUES (
        v_customer_id,
        v_contract_id,
        v_version_id,
        v_contract_number,
        'BAK'::document_type,
        row_data.contract_number,
        row_data.contract_start_date,
        'https://files.kima.local/bak/' || replace(replace(v_contract_number, '/', '-'), ' ', '-') || '.pdf',
        NOW()
      );
    END IF;

    FOR v_month_index IN 0..(row_data.invoice_count - 1) LOOP
      v_period_start := (row_data.contract_start_date + (v_month_index || ' month')::INTERVAL)::date;
      v_period_end := (v_period_start + INTERVAL '1 month' - INTERVAL '1 day')::date;
      v_invoice_number := row_data.invoice_seed || '-' || to_char(v_period_start, 'YYYYMM');

      IF length(v_invoice_number) > 100 THEN
        v_invoice_number := row_data.customer_code || '-' || to_char(v_period_start, 'YYYYMM');
      END IF;

      v_invoice_file_name := replace(replace(v_invoice_number, '/', '-'), ' ', '-');

      IF length('https://files.kima.local/invoices/' || v_invoice_file_name || '.pdf') > 100 THEN
        v_invoice_file_name := row_data.customer_code || '-' || to_char(v_period_start, 'YYYYMM');
      END IF;

      SELECT id INTO v_doc_id
      FROM documents
      WHERE customer_id = v_customer_id
        AND jenis_dokumen = 'invoice'::document_type
        AND nomor_dokumen = v_invoice_number
      ORDER BY id
      LIMIT 1;

      IF v_doc_id IS NULL THEN
        INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'invoice'::document_type, v_invoice_number, v_period_start, 'https://files.kima.local/invoices/' || v_invoice_file_name || '.pdf', NOW())
        RETURNING id INTO v_doc_id;
      ELSE
        UPDATE documents
        SET contract_id = v_contract_id,
            contract_version_id = v_version_id,
            contract_number = v_contract_number,
            tanggal_dokumen = v_period_start
        WHERE id = v_doc_id;
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
          amount = row_data.monthly_amount,
          status = v_invoice_status,
          schedule_version = 1,
          schedule_status = v_schedule_status,
          document_id = v_doc_id,
          paid_at = CASE WHEN row_data.invoice_status = 'lunas' THEN COALESCE(paid_at, NOW()) ELSE NULL END,
          updated_at = NOW()
        WHERE customer_id = v_customer_id
          AND invoice_number = v_invoice_number;
      ELSE
        INSERT INTO invoices (customer_id, contract_id, contract_version_id, contract_number, invoice_number, period_year, period_month, period_start_date, period_end_date, amount, status, schedule_version, schedule_status, document_id, paid_at, created_at, updated_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, v_invoice_number, EXTRACT(YEAR FROM v_period_start)::int, EXTRACT(MONTH FROM v_period_start)::int, v_period_start, v_period_end, row_data.monthly_amount, v_invoice_status, 1, v_schedule_status, v_doc_id, CASE WHEN row_data.invoice_status = 'lunas' THEN NOW() ELSE NULL END, NOW(), NOW());
      END IF;
    END LOOP;
  END LOOP;
END $$;

WITH invoice_summary AS (
  SELECT
    contract_id,
    COUNT(*) AS invoice_count,
    SUM(amount) AS invoice_total,
    MIN(period_start_date) AS first_invoice_period,
    MAX(period_start_date) AS last_invoice_period
  FROM invoices
  GROUP BY contract_id
), latest_contract_version AS (
  SELECT DISTINCT ON (contract_id)
    contract_id,
    monthly_amount,
    yearly_amount,
    remarks
  FROM contract_versions
  ORDER BY contract_id, version_number DESC, id DESC
), document_summary AS (
  SELECT
    contract_id,
    MAX(nomor_dokumen) FILTER (WHERE jenis_dokumen IN ('BAK'::document_type, 'kontrak'::document_type)) AS original_document_number
  FROM documents
  GROUP BY contract_id
)
SELECT
  c.isp_name,
  c.customer_code,
  c.name AS customer_name,
  c.status AS customer_status,
  ct.contract_number,
  ct.start_date,
  ct.end_date,
  ct.core_type,
  ct.core_total,
  ct.sharing_ratio,
  ct.status AS contract_status,
  cv.monthly_amount,
  cv.yearly_amount,
  cv.remarks,
  COALESCE(inv.invoice_count, 0) AS invoice_count,
  COALESCE(inv.invoice_total, 0) AS invoice_total,
  inv.first_invoice_period,
  inv.last_invoice_period,
  doc.original_document_number
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN latest_contract_version cv ON cv.contract_id = ct.id
LEFT JOIN invoice_summary inv ON inv.contract_id = ct.id
LEFT JOIN document_summary doc ON doc.contract_id = ct.id
WHERE c.customer_code = 'CUST-CITRA-PRIMA-MEDIA-CORE-2'
ORDER BY c.customer_code, ct.start_date, ct.contract_number;

COMMIT;
