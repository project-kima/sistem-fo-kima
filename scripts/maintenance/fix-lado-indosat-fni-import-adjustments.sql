-- ============================================================================
-- FIX IMPORT ADJUSTMENTS FOR LADO / INDOSAT / FNI DATA
-- ============================================================================
-- Tanggal: 2026-05-15
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste ke Supabase SQL Editor setelah seed berhasil masuk.
-- Tujuan:
-- 1. Samakan nilai contract_versions Bumi Sarana Beton 2025/2026 dengan rincian invoice aktual.
-- 2. Simpan nomor dokumen BAK asli di documents.nomor_dokumen walau contracts.contract_number memakai suffix unik.
-- ============================================================================

BEGIN;

DO $$
DECLARE
  v_customer_id BIGINT;
  v_contract_id BIGINT;
  v_contract_version_id BIGINT;
  v_original_contract_number TEXT := 'KIMA.BAK-06/DBO/FO/IX/2025';
  v_unique_contract_number TEXT := 'KIMA.BAK-06/DBO/FO/IX/2025-CUST-FNI-GRAND-KAKAO';
BEGIN
  SELECT id INTO v_customer_id
  FROM customers
  WHERE customer_code = 'CUST-FNI-BUMI-SARANA-BETON'
  ORDER BY id
  LIMIT 1;

  IF v_customer_id IS NOT NULL THEN
    SELECT id INTO v_contract_id
    FROM contracts
    WHERE customer_id = v_customer_id
      AND contract_number = 'KIMA.BAK-53/DBO/FO/XI/2025'
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NOT NULL THEN
      UPDATE contract_versions
      SET
        monthly_amount = 13925000::numeric / 9,
        yearly_amount = 13925000::numeric,
        remarks = 'Okt 25 - Nov 25 (1 Core) Des 25- Jun 26 (1/32); total mengikuti rincian invoice bulanan',
        updated_at = NOW()
      WHERE contract_id = v_contract_id
        AND start_date = DATE '2025-10-01'
        AND end_date = DATE '2026-06-30';

      UPDATE invoices
      SET amount = CASE
          WHEN period_start_date IN (DATE '2025-10-01', DATE '2025-11-01') THEN 6000000::numeric
          ELSE 275000::numeric
        END,
        updated_at = NOW()
      WHERE contract_id = v_contract_id
        AND period_start_date BETWEEN DATE '2025-10-01' AND DATE '2026-06-01';
    END IF;
  END IF;

  SELECT id INTO v_customer_id
  FROM customers
  WHERE customer_code = 'CUST-FNI-GRAND-KAKAO'
  ORDER BY id
  LIMIT 1;

  IF v_customer_id IS NOT NULL THEN
    SELECT id INTO v_contract_id
    FROM contracts
    WHERE customer_id = v_customer_id
      AND contract_number = v_unique_contract_number
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NOT NULL THEN
      SELECT id INTO v_contract_version_id
      FROM contract_versions
      WHERE contract_id = v_contract_id
      ORDER BY version_number DESC, id DESC
      LIMIT 1;

      UPDATE documents
      SET
        contract_number = v_unique_contract_number,
        nomor_dokumen = v_original_contract_number,
        contract_version_id = COALESCE(contract_version_id, v_contract_version_id)
      WHERE customer_id = v_customer_id
        AND contract_id = v_contract_id
        AND jenis_dokumen IN ('BAK'::document_type, 'kontrak'::document_type);
    END IF;
  END IF;
END $$;

WITH invoice_summary AS (
  SELECT
    contract_id,
    COUNT(*) AS invoice_count,
    SUM(amount) AS invoice_total
  FROM invoices
  GROUP BY contract_id
), document_summary AS (
  SELECT
    contract_id,
    MAX(nomor_dokumen) FILTER (WHERE jenis_dokumen IN ('BAK'::document_type, 'kontrak'::document_type)) AS original_document_number
  FROM documents
  GROUP BY contract_id
), latest_contract_version AS (
  SELECT DISTINCT ON (contract_id)
    contract_id,
    monthly_amount,
    yearly_amount,
    remarks
  FROM contract_versions
  ORDER BY contract_id, version_number DESC, id DESC
)
SELECT
  c.customer_code,
  c.name AS customer_name,
  ct.contract_number,
  cv.monthly_amount,
  cv.yearly_amount,
  cv.remarks,
  COALESCE(inv.invoice_count, 0) AS invoice_count,
  COALESCE(inv.invoice_total, 0) AS invoice_total,
  doc.original_document_number
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN latest_contract_version cv ON cv.contract_id = ct.id
LEFT JOIN invoice_summary inv ON inv.contract_id = ct.id
LEFT JOIN document_summary doc ON doc.contract_id = ct.id
WHERE c.customer_code IN ('CUST-FNI-BUMI-SARANA-BETON', 'CUST-FNI-GRAND-KAKAO')
ORDER BY c.customer_code, ct.start_date;

COMMIT;
