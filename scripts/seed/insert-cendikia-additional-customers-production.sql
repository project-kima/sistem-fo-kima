-- ============================================================================
-- UPSERT DATA CUSTOMER TAMBAHAN PT CENDIKIA GLOBAL SOLUSI - PRODUCTION
-- ============================================================================
-- Tanggal: 2026-05-13
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
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
  v_contract_number TEXT;
  v_period_start DATE;
  v_period_end DATE;
  v_invoice_status invoices.status%TYPE;
  v_schedule_status invoices.schedule_status%TYPE := 'active';
  row_data RECORD;
BEGIN
  SELECT id INTO v_isp_id
  FROM isps
  WHERE name = 'PT Cendikia Global Solusi'
  ORDER BY id
  LIMIT 1;

  IF v_isp_id IS NULL THEN
    RAISE EXCEPTION 'ISP PT Cendikia Global Solusi not found.';
  END IF;

  FOR row_data IN
    SELECT *
    FROM (VALUES
      ('CUST-INDOFOOD-CBP-001', 'PT Indofood CBP Sukses Makmur', DATE '2023-03-26', DATE '2023-03-26', DATE '2024-03-25', 'sharing_core', 0, '1/32', 'KIMA.BAK-19/DBO/FO/V/2023', '121/INV.FO/VI/2023', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-INDOFOOD-CBP-001', 'PT Indofood CBP Sukses Makmur', DATE '2023-03-26', DATE '2024-03-26', DATE '2025-03-25', 'sharing_core', 0, '1/32', 'KIMA.BAK-22/DBO/FO/VI/2024', 'INV-028/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-INDOFOOD-CBP-001', 'PT Indofood CBP Sukses Makmur', DATE '2023-03-26', DATE '2025-03-26', DATE '2026-03-25', 'sharing_core', 0, '1/32', 'KIMA.BAK-02/DBO/FO/I/2025', 'INV-052/KIMA/FO/VI/2025', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-INDOMARCO-KIMA10-001', 'PT Indomarco Prismatama (Kima 10)', DATE '2022-10-22', DATE '2022-10-22', DATE '2023-10-21', 'sharing_core', 0, '1/32', '-', '079/INV.FO/XII/2022', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-INDOMARCO-KIMA10-001', 'PT Indomarco Prismatama (Kima 10)', DATE '2022-10-22', DATE '2023-10-22', DATE '2024-10-21', 'sharing_core', 0, '1/32', 'KIMA.BAK-49/DBO/FO/X/2023', 'INV-020/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-INDOMARCO-KIMA10-001', 'PT Indomarco Prismatama (Kima 10)', DATE '2022-10-22', DATE '2024-10-22', DATE '2025-10-21', 'sharing_core', 0, '1/32', 'KIMA.BAK-64/DBO/FO/X/2024', 'INV-021/KIMA/FO/I/2025', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-INDOMARCO-KIMA10-001', 'PT Indomarco Prismatama (Kima 10)', DATE '2022-10-22', DATE '2025-10-22', DATE '2026-10-21', 'sharing_core', 0, '1/32', 'KIMA.BAK-52/DBO/FO/XI/2025', '106/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-KEMASAN-CIPTATAMA-001', 'PT Kemasan Ciptatama Nusantara', DATE '2024-06-14', DATE '2024-06-14', DATE '2025-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-26/DBO/FO/VI/2024', 'INV-032/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-KEMASAN-CIPTATAMA-001', 'PT Kemasan Ciptatama Nusantara', DATE '2024-06-14', DATE '2025-06-14', DATE '2026-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-33/DBO/FO/VII/2025', '088/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-NIPPON-001', 'PT Nippon Indosari Corpindo Tbk', DATE '2022-09-28', DATE '2022-09-28', DATE '2023-09-27', 'sharing_core', 0, '1/32', '-', '081/INV.FO/XII/2022', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-NIPPON-001', 'PT Nippon Indosari Corpindo Tbk', DATE '2022-09-28', DATE '2023-09-28', DATE '2024-09-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-45/DBO/FO/IX/2023', '189/INV.FO/XI/2023', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-NIPPON-001', 'PT Nippon Indosari Corpindo Tbk', DATE '2022-09-28', DATE '2024-09-28', DATE '2025-09-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-55/DBO/FO/IX/2024', 'INV-017/KIMA/FO/I/2025', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-NIPPON-001', 'PT Nippon Indosari Corpindo Tbk', DATE '2022-09-28', DATE '2025-09-28', DATE '2026-09-27', 'sharing_core', 0, '1/32', 'KIMA.BAK-47/DBO/FO/X/2025', '092/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-NIPPON-JUN2025-001', 'PT Nippon Indosari Corpindo Tbk (Kontrak Jun 2025)', DATE '2025-06-27', DATE '2025-06-27', DATE '2026-06-26', 'sharing_core', 0, '1/32', 'KIMA.BAK-20/DBO/FO/VI/2025', 'INV-056/KIMA/FO/VI/2025', 'belum_ditagih', 250000::numeric, 3000000::numeric, 2500000::numeric),

      ('CUST-OCEAN-CHAMP-001', 'PT Ocean Champ Seafood', DATE '2022-01-25', DATE '2022-01-25', DATE '2023-01-24', 'sharing_core', 0, '1/32', 'KIMA.007A/FO-DIR/I/2022', '069/INV.FO/XII/2022', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-OCEAN-CHAMP-001', 'PT Ocean Champ Seafood', DATE '2022-01-25', DATE '2023-01-25', DATE '2024-01-24', 'sharing_core', 0, '1/32', '-', '082/INV.FO/XII/2022', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-OCEAN-CHAMP-001', 'PT Ocean Champ Seafood', DATE '2022-01-25', DATE '2024-01-25', DATE '2025-01-24', 'sharing_core', 0, '1/32', 'KIMA.BAK-19/DBO/FO/VI/2024', 'INV-025/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-OCEAN-CHAMP-001', 'PT Ocean Champ Seafood', DATE '2022-01-25', DATE '2025-01-25', DATE '2026-01-24', 'sharing_core', 0, '1/32', 'KIMA.BAK-71/DBO/FO/XII/2024', 'INV-026/KIMA/FO/I/2025', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-WASTEC-KIMA-RAYA1-001', 'PT Wastec International (Kima Raya 1)', DATE '2023-10-09', DATE '2023-10-09', DATE '2024-10-08', 'sharing_core', 0, '1/32', 'KIMA.BAK-46/DBO/FO/IX/2023', '190/INV.FO/XI/2023', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-WASTEC-KIMA-RAYA1-001', 'PT Wastec International (Kima Raya 1)', DATE '2023-10-09', DATE '2024-10-09', DATE '2025-10-08', 'sharing_core', 0, '1/32', 'KIMA.BAK-63/DBO/FO/X/2024', 'INV-020/KIMA/FO/I/2025', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),
      ('CUST-WASTEC-KIMA-RAYA1-001', 'PT Wastec International (Kima Raya 1)', DATE '2023-10-09', DATE '2025-10-09', DATE '2026-10-08', 'sharing_core', 0, '1/32', 'KIMA.BAK-50/DBO/FO/XI/2025', '104/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-MARUKI-001', 'PT Maruki International', DATE '2024-06-14', DATE '2024-06-14', DATE '2025-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-24/DBO/FO/VI/2024', 'INV-030/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-MARUKI-001', 'PT Maruki International', DATE '2024-06-14', DATE '2025-06-14', DATE '2026-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-34/DBO/FO/VII/2025', '091/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-TRAKTOR-NUSANTARA-001', 'PT Traktor Nusantara', DATE '2024-06-14', DATE '2024-06-14', DATE '2025-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-25/DBO/FO/VI/2024', 'INV-031/KIMA/FO/VI/2024', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-TRAKTOR-NUSANTARA-001', 'PT Traktor Nusantara', DATE '2024-06-14', DATE '2025-06-14', DATE '2026-06-13', 'sharing_core', 0, '1/32', 'KIMA.BAK-35/DBO/FO/VII/2025', '089/FO/11/25', 'lunas', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-KARYA-TEKNIK-MULIA2-001', 'PT Karya Teknik Mulia 2', DATE '2024-10-08', DATE '2024-10-08', DATE '2025-10-07', 'sharing_core', 0, '1/32', 'KIMA.BAK.58/DBO/FO/IX/2024', 'INV-019/KIMA/FO/I/2025', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-KARYA-TEKNIK-MULIA2-001', 'PT Karya Teknik Mulia 2', DATE '2024-10-08', DATE '2025-10-08', DATE '2026-10-07', 'sharing_core', 0, '1/32', 'KIMA.BAK.51/DBO/FO/XI/2025', '105/FO/11/25', 'belum_ditagih', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-DWIRA-MASAGENA-001', 'PT Dwira Masagena', DATE '2024-12-07', DATE '2024-12-07', DATE '2025-12-06', 'sharing_core', 0, '1/32', 'KIMA.BAK-67/DBO/FO/XI/2024', 'INV-024/KIMA/FO/I/2025', 'belum_ditagih', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-DWIRA-MASAGENA-001', 'PT Dwira Masagena', DATE '2024-12-07', DATE '2025-12-07', DATE '2026-12-06', 'sharing_core', 0, '1/32', 'KIMA.BAK-61/DBO/FO/XII/2025', '010/FO/1/26', 'belum_ditagih', 250000::numeric, 3000000::numeric, NULL::numeric),

      ('CUST-SAMATOR-INDO-GAS-001', 'PT Samator Indo Gas', DATE '2025-03-24', DATE '2025-03-24', DATE '2026-03-23', 'sharing_core', 0, '1/32', 'KIMA.BAK-08/DBO/FO/III/2025', 'INV-055/KIMA/FO/VI/2025', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-MSC-INDOSAT-KIMA13-001', 'MSC Indosat (kima 13)', DATE '2025-05-20', DATE '2025-05-20', DATE '2026-05-19', 'core', 1, NULL, 'KIMA.BAK-07/DBO/FO/V/2025', 'INV-048/KIMA/FO/VI/2025', 'lunas', 4000000::numeric, 48000000::numeric, 2500000::numeric),
      ('CUST-AGRENESIA-RAYA-001', 'PT Agrenesia Raya', DATE '2025-06-25', DATE '2025-06-25', DATE '2026-06-24', 'sharing_core', 0, '1/32', 'KIMA.BAK-21/DBO/FO/VI/2025', 'INV-054/KIMA/FO/VI/2025', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-MERAPI-UTAMA-PHARMA-001', 'PT Merapi Utama Pharma', DATE '2025-11-18', DATE '2025-11-18', DATE '2026-11-17', 'sharing_core', 0, '1/32', 'KIMA.BAK-54/DBO/FO/XI/2025', '111/FO/12/25', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-BUMI-MENARA-KIMA15-001', 'PT Bumi Menara Internusa (Kima 15)', DATE '2025-11-22', DATE '2025-11-22', DATE '2026-11-21', 'sharing_core', 0, '1/32', 'KIMA.BAK-55/DBO/FO/XI/2025', '112/FO/12/25', 'lunas', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-BUMI-MENARA-KIMA9-001', 'PT Bumi Menara Internusa (Kima 9)', DATE '2025-11-22', DATE '2025-11-22', DATE '2026-11-21', 'sharing_core', 0, '1/32', 'KIMA.BAK-56/DBO/FO/XI/2025', '113/FO/12/25', 'belum_ditagih', 250000::numeric, 3000000::numeric, 2500000::numeric),
      ('CUST-SUMBER-ALFARIA-001', 'PT Sumber Alfaria Trijaya', DATE '2025-11-25', DATE '2025-11-25', DATE '2026-11-24', 'sharing_core', 0, '1/4', 'KIMA.BAK-57/DBO/FO/XI/2025', '114/FO/12/25', 'lunas', 1800000::numeric, 21600000::numeric, 2500000::numeric)
    ) AS value(customer_code, customer_name, cooperation_start_date, contract_start_date, contract_end_date, core_type, core_total, sharing_ratio, contract_number, invoice_seed, invoice_status, monthly_amount, yearly_amount, activation_fee_amount)
  LOOP
    v_invoice_status := row_data.invoice_status;
    v_contract_number := CASE
      WHEN row_data.contract_number = '-' THEN 'NO-BAK-' || row_data.customer_code || '-' || to_char(row_data.contract_start_date, 'YYYYMMDD')
      ELSE row_data.contract_number
    END;

    SELECT id INTO v_customer_id
    FROM customers
    WHERE customer_code = row_data.customer_code
       OR name = row_data.customer_name
    ORDER BY id
    LIMIT 1;

    IF v_customer_id IS NULL THEN
      INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
      VALUES (row_data.customer_code, 'PT Cendikia Global Solusi', row_data.customer_name, 'aktif', COALESCE(row_data.activation_fee_amount, 0), row_data.cooperation_start_date, NOW(), NOW())
      RETURNING id INTO v_customer_id;
    ELSE
      UPDATE customers
      SET
        customer_code = COALESCE(customer_code, row_data.customer_code),
        isp_name = 'PT Cendikia Global Solusi',
        name = row_data.customer_name,
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
      AND start_date = row_data.contract_start_date
      AND end_date = row_data.contract_end_date
    ORDER BY id
    LIMIT 1;

    IF v_contract_id IS NULL THEN
      INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
      VALUES (v_customer_id, v_contract_number, row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, row_data.core_total, row_data.sharing_ratio, (CASE WHEN row_data.contract_end_date >= CURRENT_DATE THEN 'aktif' ELSE 'expired' END)::contract_status, 1, 'bulan', NOW(), NOW())
      RETURNING id INTO v_contract_id;
    ELSE
      UPDATE contracts
      SET
        contract_number = v_contract_number,
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
      AND version_number = 1
    ORDER BY id
    LIMIT 1;

    IF v_version_id IS NULL THEN
      INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, monthly_amount, yearly_amount, remarks, created_at, updated_at)
      VALUES (v_contract_id, v_customer_id, 1, row_data.contract_start_date, row_data.contract_end_date, row_data.core_type::core_allocation_type, row_data.core_total, row_data.sharing_ratio, row_data.monthly_amount, row_data.yearly_amount, 'Imported from Cendikia spreadsheet batch', NOW(), NOW())
      RETURNING id INTO v_version_id;
    ELSE
      UPDATE contract_versions
      SET
        start_date = row_data.contract_start_date,
        end_date = row_data.contract_end_date,
        core_type = row_data.core_type::core_allocation_type,
        core_total = row_data.core_total,
        shared_core_ratio = row_data.sharing_ratio,
        monthly_amount = row_data.monthly_amount,
        yearly_amount = row_data.yearly_amount,
        updated_at = NOW()
      WHERE id = v_version_id;
    END IF;

    IF row_data.contract_number <> '-' AND NOT EXISTS (SELECT 1 FROM documents WHERE customer_id = v_customer_id AND contract_id = v_contract_id AND jenis_dokumen IN ('kontrak'::document_type, 'BAK'::document_type)) THEN
      INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
      VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'BAK'::document_type, v_contract_number, row_data.contract_start_date, 'https://files.kima.local/bak/' || v_contract_number || '.pdf', NOW());
    END IF;

    FOR v_month_index IN 0..11 LOOP
      v_period_start := (row_data.contract_start_date + (v_month_index || ' month')::INTERVAL)::date;
      v_period_end := (v_period_start + INTERVAL '1 month' - INTERVAL '1 day')::date;
      v_invoice_number := row_data.invoice_seed || '-' || to_char(v_period_start, 'YYYYMM');

      SELECT id INTO v_doc_id
      FROM documents
      WHERE customer_id = v_customer_id
        AND jenis_dokumen = 'invoice'::document_type
        AND nomor_dokumen = v_invoice_number
      ORDER BY id
      LIMIT 1;

      IF v_doc_id IS NULL THEN
        INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
        VALUES (v_customer_id, v_contract_id, v_version_id, v_contract_number, 'invoice'::document_type, v_invoice_number, v_period_start, 'https://files.kima.local/invoices/' || v_invoice_number || '.pdf', NOW())
        RETURNING id INTO v_doc_id;
      ELSE
        UPDATE documents
        SET contract_id = v_contract_id, contract_version_id = v_version_id, contract_number = v_contract_number, tanggal_dokumen = v_period_start
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

SELECT
  c.name AS customer_name,
  ct.contract_number,
  ct.start_date,
  ct.end_date,
  ct.core_type,
  ct.core_total,
  ct.sharing_ratio,
  cv.monthly_amount,
  cv.yearly_amount,
  COUNT(i.id) AS invoice_count,
  SUM(i.amount) AS invoice_total
FROM customers c
JOIN contracts ct ON ct.customer_id = c.id
LEFT JOIN contract_versions cv ON cv.contract_id = ct.id
LEFT JOIN invoices i ON i.contract_id = ct.id
WHERE c.customer_code IN (
  'CUST-INDOFOOD-CBP-001',
  'CUST-INDOMARCO-KIMA10-001',
  'CUST-KEMASAN-CIPTATAMA-001',
  'CUST-NIPPON-001',
  'CUST-NIPPON-JUN2025-001',
  'CUST-OCEAN-CHAMP-001',
  'CUST-WASTEC-KIMA-RAYA1-001',
  'CUST-MARUKI-001',
  'CUST-TRAKTOR-NUSANTARA-001',
  'CUST-KARYA-TEKNIK-MULIA2-001',
  'CUST-DWIRA-MASAGENA-001',
  'CUST-SAMATOR-INDO-GAS-001',
  'CUST-MSC-INDOSAT-KIMA13-001',
  'CUST-AGRENESIA-RAYA-001',
  'CUST-MERAPI-UTAMA-PHARMA-001',
  'CUST-BUMI-MENARA-KIMA15-001',
  'CUST-BUMI-MENARA-KIMA9-001',
  'CUST-SUMBER-ALFARIA-001'
)
GROUP BY c.name, ct.contract_number, ct.start_date, ct.end_date, ct.core_type, ct.core_total, ct.sharing_ratio, cv.monthly_amount, cv.yearly_amount
ORDER BY c.name, ct.end_date DESC;

COMMIT;
