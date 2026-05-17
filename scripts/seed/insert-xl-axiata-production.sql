-- ============================================================================
-- UPSERT DATA CUSTOMER PT XL AXIATA TBK - PRODUCTION
-- ============================================================================
-- Tanggal: 2026-05-17
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Review, lalu copy-paste script ini ke Supabase SQL Editor dan Run
-- Catatan:
-- - Pelanggan bernama "Core" diperlakukan sebagai customer name literal.
-- - Data Core dipisah menjadi customer_code berbeda berdasarkan kapasitas: 134 core dan 2 core.
-- - Status '-' dari spreadsheet dimasukkan sebagai 'belum_ditagih'.
-- - Tahap 1 dan Tahap 2 Core 134 dibuat sebagai dua row contracts karena nomor dokumennya berbeda.
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
      ('PT XL Axiata Tbk', 'CUST-XL-CORE-134', 'Core', DATE '2024-07-01', DATE '2024-07-01', DATE '2026-06-30', 'core', 134, NULL, 'KIMA.BAK-170A/DOP/VII/2024', 'INV-069/KIMA/FO/VIII/2024', 'lunas', 'Tahap 1', 167500000::numeric, 2010000000::numeric, NULL::numeric, DATE '2024-07-01', DATE '2025-06-01'),
      ('PT XL Axiata Tbk', 'CUST-XL-CORE-134', 'Core', DATE '2024-07-01', DATE '2024-07-01', DATE '2026-06-30', 'core', 134, NULL, 'KIMA. PERU.042/DIU/VII/2024 & 030/XL/VII/2024', 'INV.062/KIMA/FO/VII/2025', 'lunas', 'Tahap 2', 201000000::numeric, 2412000000::numeric, NULL::numeric, DATE '2025-07-01', DATE '2026-06-01'),
      ('PT XL Axiata Tbk', 'CUST-XL-CORE-2', 'Core', DATE '2024-12-05', DATE '2024-12-05', DATE '2025-12-04', 'core', 2, NULL, 'KIMA.BAK-68/DBO/FO/XI/2024', 'INV.101/KIMA/FO/XII/2024', 'lunas', NULL, 2500000::numeric, 30000000::numeric, 2500000::numeric, DATE '2024-12-01', DATE '2025-11-01'),
      ('PT XL Axiata Tbk', 'CUST-XL-CORE-2', 'Core', DATE '2024-12-05', DATE '2025-12-05', DATE '2026-12-04', 'core', 2, NULL, 'KIMA.BAK-03/DBO/FO/I/2026 & 32/FOIN-XLSMART/II/2026', '015/FO/3/26', 'belum_ditagih', NULL, 3000000::numeric, 36000000::numeric, NULL::numeric, DATE '2026-03-01', DATE '2027-02-01')
    ) AS value(isp_name, customer_code, customer_name, cooperation_start_date, contract_start_date, contract_end_date, core_type, core_total, sharing_ratio, contract_number, invoice_seed, invoice_status, remarks, monthly_amount, yearly_amount, activation_fee_amount, invoice_start_month, invoice_end_month)
  LOOP
    SELECT id INTO v_isp_id
    FROM isps
    WHERE lower(trim(name)) = lower(trim(row_data.isp_name))
    ORDER BY id
    LIMIT 1;

    IF v_isp_id IS NULL THEN
      INSERT INTO isps (name, status, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)
      VALUES (row_data.isp_name, 'aktif', 'core'::isp_package_type, COALESCE(row_data.core_total, 0), 'monthly', 0, NOW(), NOW())
      RETURNING id INTO v_isp_id;
    ELSE
      UPDATE isps
      SET status = COALESCE(status, 'aktif'),
          paket = COALESCE(paket, 'core'::isp_package_type),
          jumlah = GREATEST(COALESCE(jumlah, 0), COALESCE(row_data.core_total, 0)),
          billing_period_mode = COALESCE(billing_period_mode, 'monthly'),
          updated_at = NOW()
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
      SET isp_name = row_data.isp_name,
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
      SET start_date = LEAST(start_date, row_data.contract_start_date),
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
        COALESCE(row_data.remarks, 'Imported from XL Axiata spreadsheet batch'),
        NOW(),
        NOW()
      )
      RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions
      SET core_type = row_data.core_type::core_allocation_type,
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
      v_invoice_amount := v_monthly_amount;

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
        SET contract_id = v_contract_id,
            contract_version_id = v_version_id,
            contract_number = v_contract_number,
            tanggal_dokumen = v_period_start
        WHERE id = v_doc_id;
      END IF;

      IF EXISTS (SELECT 1 FROM invoices WHERE customer_id = v_customer_id AND invoice_number = v_invoice_number) THEN
        UPDATE invoices
        SET contract_id = v_contract_id,
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

WITH invoice_summary AS (
  SELECT contract_id, COUNT(*) AS invoice_count, SUM(amount) AS invoice_total, MIN(period_start_date) AS first_invoice_period, MAX(period_start_date) AS last_invoice_period
  FROM invoices
  GROUP BY contract_id
), document_summary AS (
  SELECT contract_id, MAX(nomor_dokumen) FILTER (WHERE jenis_dokumen IN ('BAK'::document_type, 'kontrak'::document_type)) AS original_document_number
  FROM documents
  GROUP BY contract_id
), latest_contract_version AS (
  SELECT DISTINCT ON (contract_id) contract_id, monthly_amount, yearly_amount, remarks
  FROM contract_versions
  ORDER BY contract_id, version_number DESC, id DESC
)
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
WHERE c.customer_code LIKE 'CUST-XL-%'
ORDER BY c.customer_code, ct.start_date, ct.contract_number;

COMMIT;
