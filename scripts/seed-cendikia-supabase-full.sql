-- PT Cendikia Global Solusi - Full Supabase Seeding Script
-- Correct mapping: ISP/vendor = PT Cendikia Global Solusi; tenants = BTN and Wastec.

DO $$
DECLARE
  v_isp_id INT;
  v_btn_customer_id INT;
  v_wastec_customer_id INT;
  v_contract_id INT;
  v_version_id INT;
  v_doc_id INT;
BEGIN
  IF EXISTS (SELECT 1 FROM isps WHERE name = 'PT Cendikia Global Solusi') OR EXISTS (SELECT 1 FROM customers WHERE customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001')) THEN
    RAISE NOTICE 'Cendikia seed data already exists. Run rollback-cendikia-supabase.sql first if you want to reseed.';
    RETURN;
  END IF;

  INSERT INTO isps (name, status, contract_reference, contract_start_date, contract_period_start, contract_period_end, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)
  VALUES ('PT Cendikia Global Solusi', 'aktif', 'ISP-CENDIKIA-2022', '2022-07-25', '2022-07-25', '2026-08-17', 'shared', 2, 'monthly', 0, NOW(), NOW())
  RETURNING id INTO v_isp_id;

  INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
  VALUES ('CUST-BTN-001', 'PT Cendikia Global Solusi', 'PT Bank Tabungan Negara (Persero)', 'aktif', 2500000, '2022-07-25', NOW(), NOW())
  RETURNING id INTO v_btn_customer_id;

  INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)
  VALUES ('CUST-WASTEC-001', 'PT Cendikia Global Solusi', 'PT Karya Teknik Mulia (PT Wastec International)', 'aktif', 2500000, '2022-08-15', NOW(), NOW())
  RETURNING id INTO v_wastec_customer_id;

  INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)
  VALUES (v_btn_customer_id, v_isp_id, NOW(), NOW());

  INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)
  VALUES (v_wastec_customer_id, v_isp_id, NOW(), NOW());

  -- Contract 1: PT Bank Tabungan Negara (Persero)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_btn_customer_id, 'CTR-CGS-2022-001', '2022-07-25', '2023-07-24', 'sharing_core', 1, '1/32', 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_btn_customer_id, 1, '2022-07-25', '2023-07-24', 'sharing_core', 1, '1/32', NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'kontrak', 'CTR-CGS-2022-001', '2022-07-25', 'https://files.kima.local/contracts/CTR-CGS-2022-001.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202210', '2022-10-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202210.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202210', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 10, 2022, '2022-10-01', '2022-10-31', '2022-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-10-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202210.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202210-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202211', '2022-11-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202211.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202211', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 11, 2022, '2022-11-01', '2022-11-30', '2022-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-11-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202211.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202211-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202212', '2022-12-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202212.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202212', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 12, 2022, '2022-12-01', '2022-12-31', '2022-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-12-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202212.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202212-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202207', '2022-07-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202207.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202207', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 7, 2022, '2022-07-01', '2022-07-31', '2022-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-07-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202207.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202207-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202208', '2022-08-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202208.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202208', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 8, 2022, '2022-08-01', '2022-08-31', '2022-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-08-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202208.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202208-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202209', '2022-09-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202209.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202209', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 9, 2022, '2022-09-01', '2022-09-30', '2022-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-09-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202209.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202209-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202301', '2023-01-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202301.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202301', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 1, 2023, '2023-01-01', '2023-01-31', '2023-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-01-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202301.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202301-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202302', '2023-02-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202302.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202302', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 2, 2023, '2023-02-01', '2023-02-28', '2023-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-02-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202302.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202302-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202303', '2023-03-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202303.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202303', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 3, 2023, '2023-03-01', '2023-03-31', '2023-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-03-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202303.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202303-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202304', '2023-04-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202304.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202304', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 4, 2023, '2023-04-01', '2023-04-30', '2023-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-04-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202304.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202304-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202305', '2023-05-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202305.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202305', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 5, 2023, '2023-05-01', '2023-05-31', '2023-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-05-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202305.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202305-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-001', 'invoice', '065/INV.FO/XII/2022-202306', '2023-06-01', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202306.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '065/INV.FO/XII/2022-202306', v_contract_id, v_version_id, 'CTR-CGS-2022-001', 6, 2023, '2023-06-01', '2023-06-30', '2023-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-06-15 10:00:00+00', 'https://files.kima.local/invoices/065/INV.FO/XII/2022-202306.pdf', 'https://files.kima.local/payments/065/INV.FO/XII/2022-202306-proof.pdf', NOW(), NOW());

  -- Contract 2: PT Bank Tabungan Negara (Persero)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_btn_customer_id, 'KIMA.BAK-42/DBO/FO/IX/2023', '2023-07-08', '2024-07-07', 'core', 1, NULL, 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_btn_customer_id, 1, '2023-07-08', '2024-07-07', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'BAK', 'KIMA.BAK-42/DBO/FO/IX/2023', '2023-07-08', 'https://files.kima.local/bak/KIMA.BAK-42/DBO/FO/IX/2023.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202310', '2023-10-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202310.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202310', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 10, 2023, '2023-10-01', '2023-10-31', '2023-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-10-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202310.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202310-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202311', '2023-11-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202311.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202311', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 11, 2023, '2023-11-01', '2023-11-30', '2023-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-11-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202311.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202311-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202312', '2023-12-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202312.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202312', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 12, 2023, '2023-12-01', '2023-12-31', '2023-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-12-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202312.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202312-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202307', '2023-07-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202307.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202307', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 7, 2023, '2023-07-01', '2023-07-31', '2023-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-07-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202307.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202307-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202308', '2023-08-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202308.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202308', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 8, 2023, '2023-08-01', '2023-08-31', '2023-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-08-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202308.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202308-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202309', '2023-09-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202309.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202309', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 9, 2023, '2023-09-01', '2023-09-30', '2023-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-09-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202309.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202309-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202401', '2024-01-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202401.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202401', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 1, 2024, '2024-01-01', '2024-01-31', '2024-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-01-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202401.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202401-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202402', '2024-02-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202402.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202402', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 2, 2024, '2024-02-01', '2024-02-29', '2024-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-02-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202402.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202402-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202403', '2024-03-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202403.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202403', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 3, 2024, '2024-03-01', '2024-03-31', '2024-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-03-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202403.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202403-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202404', '2024-04-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202404.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202404', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 4, 2024, '2024-04-01', '2024-04-30', '2024-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-04-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202404.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202404-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202405', '2024-05-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202405.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202405', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 5, 2024, '2024-05-01', '2024-05-31', '2024-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-05-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202405.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202405-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 'invoice', '187/INV.FO/XI/2023-202406', '2024-06-01', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202406.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '187/INV.FO/XI/2023-202406', v_contract_id, v_version_id, 'KIMA.BAK-42/DBO/FO/IX/2023', 6, 2024, '2024-06-01', '2024-06-30', '2024-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-06-15 10:00:00+00', 'https://files.kima.local/invoices/187/INV.FO/XI/2023-202406.pdf', 'https://files.kima.local/payments/187/INV.FO/XI/2023-202406-proof.pdf', NOW(), NOW());

  -- Contract 3: PT Bank Tabungan Negara (Persero)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_btn_customer_id, 'KIMA.BAK-38/DBO/FO/VI/2024', '2024-07-08', '2025-07-07', 'core', 1, NULL, 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_btn_customer_id, 1, '2024-07-08', '2025-07-07', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'BAK', 'KIMA.BAK-38/DBO/FO/VI/2024', '2024-07-08', 'https://files.kima.local/bak/KIMA.BAK-38/DBO/FO/VI/2024.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202410', '2024-10-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202410.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202410', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 10, 2024, '2024-10-01', '2024-10-31', '2024-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-10-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202410.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202410-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202411', '2024-11-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202411.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202411', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 11, 2024, '2024-11-01', '2024-11-30', '2024-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-11-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202411.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202411-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202412', '2024-12-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202412.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202412', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 12, 2024, '2024-12-01', '2024-12-31', '2024-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-12-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202412.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202412-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202407', '2024-07-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202407.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202407', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 7, 2024, '2024-07-01', '2024-07-31', '2024-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-07-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202407.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202407-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202408', '2024-08-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202408.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202408', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 8, 2024, '2024-08-01', '2024-08-31', '2024-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-08-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202408.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202408-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202409', '2024-09-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202409.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202409', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 9, 2024, '2024-09-01', '2024-09-30', '2024-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-09-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202409.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202409-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202501', '2025-01-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202501.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202501', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 1, 2025, '2025-01-01', '2025-01-31', '2025-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-01-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202501.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202501-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202502', '2025-02-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202502.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202502', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 2, 2025, '2025-02-01', '2025-02-28', '2025-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-02-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202502.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202502-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202503', '2025-03-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202503.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202503', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 3, 2025, '2025-03-01', '2025-03-31', '2025-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-03-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202503.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202503-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202504', '2025-04-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202504.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202504', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 4, 2025, '2025-04-01', '2025-04-30', '2025-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-04-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202504.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202504-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202505', '2025-05-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202505.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202505', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 5, 2025, '2025-05-01', '2025-05-31', '2025-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-05-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202505.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202505-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 'invoice', 'INV-065/KIMA/FO/VII/2024-202506', '2025-06-01', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202506.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, 'INV-065/KIMA/FO/VII/2024-202506', v_contract_id, v_version_id, 'KIMA.BAK-38/DBO/FO/VI/2024', 6, 2025, '2025-06-01', '2025-06-30', '2025-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-06-15 10:00:00+00', 'https://files.kima.local/invoices/INV-065/KIMA/FO/VII/2024-202506.pdf', 'https://files.kima.local/payments/INV-065/KIMA/FO/VII/2024-202506-proof.pdf', NOW(), NOW());

  -- Contract 4: PT Bank Tabungan Negara (Persero)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_btn_customer_id, 'KIMA-BAK-32/DBO/FO/VII/2025', '2025-07-08', '2026-07-07', 'core', 1, NULL, 'aktif', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_btn_customer_id, 1, '2025-07-08', '2026-07-07', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'BAK', 'KIMA-BAK-32/DBO/FO/VII/2025', '2025-07-08', 'https://files.kima.local/bak/KIMA-BAK-32/DBO/FO/VII/2025.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202510', '2025-10-01', 'https://files.kima.local/invoices/087/FO/11/25-202510.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202510', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 10, 2025, '2025-10-01', '2025-10-31', '2025-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-10-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202510.pdf', 'https://files.kima.local/payments/087/FO/11/25-202510-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202511', '2025-11-01', 'https://files.kima.local/invoices/087/FO/11/25-202511.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202511', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 11, 2025, '2025-11-01', '2025-11-30', '2025-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-11-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202511.pdf', 'https://files.kima.local/payments/087/FO/11/25-202511-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202512', '2025-12-01', 'https://files.kima.local/invoices/087/FO/11/25-202512.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202512', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 12, 2025, '2025-12-01', '2025-12-31', '2025-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-12-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202512.pdf', 'https://files.kima.local/payments/087/FO/11/25-202512-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202507', '2025-07-01', 'https://files.kima.local/invoices/087/FO/11/25-202507.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202507', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 7, 2025, '2025-07-01', '2025-07-31', '2025-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-07-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202507.pdf', 'https://files.kima.local/payments/087/FO/11/25-202507-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202508', '2025-08-01', 'https://files.kima.local/invoices/087/FO/11/25-202508.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202508', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 8, 2025, '2025-08-01', '2025-08-31', '2025-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-08-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202508.pdf', 'https://files.kima.local/payments/087/FO/11/25-202508-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202509', '2025-09-01', 'https://files.kima.local/invoices/087/FO/11/25-202509.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202509', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 9, 2025, '2025-09-01', '2025-09-30', '2025-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-09-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202509.pdf', 'https://files.kima.local/payments/087/FO/11/25-202509-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202601', '2026-01-01', 'https://files.kima.local/invoices/087/FO/11/25-202601.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202601', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 1, 2026, '2026-01-01', '2026-01-31', '2026-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-01-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202601.pdf', 'https://files.kima.local/payments/087/FO/11/25-202601-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202602', '2026-02-01', 'https://files.kima.local/invoices/087/FO/11/25-202602.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202602', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 2, 2026, '2026-02-01', '2026-02-28', '2026-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-02-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202602.pdf', 'https://files.kima.local/payments/087/FO/11/25-202602-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202603', '2026-03-01', 'https://files.kima.local/invoices/087/FO/11/25-202603.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202603', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 3, 2026, '2026-03-01', '2026-03-31', '2026-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-03-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202603.pdf', 'https://files.kima.local/payments/087/FO/11/25-202603-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202604', '2026-04-01', 'https://files.kima.local/invoices/087/FO/11/25-202604.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202604', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 4, 2026, '2026-04-01', '2026-04-30', '2026-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-04-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202604.pdf', 'https://files.kima.local/payments/087/FO/11/25-202604-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202605', '2026-05-01', 'https://files.kima.local/invoices/087/FO/11/25-202605.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202605', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 5, 2026, '2026-05-01', '2026-05-31', '2026-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-05-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202605.pdf', 'https://files.kima.local/payments/087/FO/11/25-202605-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_btn_customer_id, v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 'invoice', '087/FO/11/25-202606', '2026-06-01', 'https://files.kima.local/invoices/087/FO/11/25-202606.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_btn_customer_id, '087/FO/11/25-202606', v_contract_id, v_version_id, 'KIMA-BAK-32/DBO/FO/VII/2025', 6, 2026, '2026-06-01', '2026-06-30', '2026-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-06-15 10:00:00+00', 'https://files.kima.local/invoices/087/FO/11/25-202606.pdf', 'https://files.kima.local/payments/087/FO/11/25-202606-proof.pdf', NOW(), NOW());

  -- Contract 5: PT Karya Teknik Mulia (PT Wastec International)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'CTR-CGS-2022-005', '2022-08-15', '2023-08-16', 'sharing_core', 1, '1/32', 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_wastec_customer_id, 1, '2022-08-15', '2023-08-16', 'sharing_core', 1, '1/32', NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'kontrak', 'CTR-CGS-2022-005', '2022-08-15', 'https://files.kima.local/contracts/CTR-CGS-2022-005.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202210', '2022-10-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202210.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202210', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 10, 2022, '2022-10-01', '2022-10-31', '2022-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-10-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202210.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202210-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202211', '2022-11-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202211.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202211', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 11, 2022, '2022-11-01', '2022-11-30', '2022-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-11-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202211.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202211-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202212', '2022-12-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202212.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202212', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 12, 2022, '2022-12-01', '2022-12-31', '2022-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-12-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202212.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202212-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202208', '2022-08-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202208.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202208', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 8, 2022, '2022-08-01', '2022-08-31', '2022-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-08-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202208.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202208-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202209', '2022-09-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202209.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202209', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 9, 2022, '2022-09-01', '2022-09-30', '2022-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2022-09-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202209.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202209-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202301', '2023-01-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202301.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202301', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 1, 2023, '2023-01-01', '2023-01-31', '2023-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-01-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202301.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202301-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202302', '2023-02-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202302.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202302', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 2, 2023, '2023-02-01', '2023-02-28', '2023-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-02-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202302.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202302-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202303', '2023-03-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202303.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202303', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 3, 2023, '2023-03-01', '2023-03-31', '2023-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-03-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202303.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202303-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202304', '2023-04-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202304.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202304', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 4, 2023, '2023-04-01', '2023-04-30', '2023-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-04-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202304.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202304-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202305', '2023-05-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202305.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202305', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 5, 2023, '2023-05-01', '2023-05-31', '2023-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-05-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202305.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202305-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202306', '2023-06-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202306.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202306', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 6, 2023, '2023-06-01', '2023-06-30', '2023-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-06-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202306.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202306-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'CTR-CGS-2022-005', 'invoice', '067/INV.FO/XII/2022-202307', '2023-07-01', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202307.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '067/INV.FO/XII/2022-202307', v_contract_id, v_version_id, 'CTR-CGS-2022-005', 7, 2023, '2023-07-01', '2023-07-31', '2023-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-07-15 10:00:00+00', 'https://files.kima.local/invoices/067/INV.FO/XII/2022-202307.pdf', 'https://files.kima.local/payments/067/INV.FO/XII/2022-202307-proof.pdf', NOW(), NOW());

  -- Contract 6: PT Karya Teknik Mulia (PT Wastec International)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'KIMA.BAK-43/DBO/FO/IX/2023', '2023-08-18', '2024-08-17', 'core', 1, NULL, 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_wastec_customer_id, 1, '2023-08-18', '2024-08-17', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'BAK', 'KIMA.BAK-43/DBO/FO/IX/2023', '2023-08-18', 'https://files.kima.local/bak/KIMA.BAK-43/DBO/FO/IX/2023.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202310', '2023-10-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202310.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202310', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 10, 2023, '2023-10-01', '2023-10-31', '2023-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-10-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202310.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202310-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202311', '2023-11-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202311.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202311', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 11, 2023, '2023-11-01', '2023-11-30', '2023-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-11-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202311.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202311-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202312', '2023-12-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202312.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202312', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 12, 2023, '2023-12-01', '2023-12-31', '2023-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-12-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202312.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202312-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202308', '2023-08-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202308.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202308', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 8, 2023, '2023-08-01', '2023-08-31', '2023-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-08-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202308.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202308-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202309', '2023-09-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202309.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202309', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 9, 2023, '2023-09-01', '2023-09-30', '2023-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2023-09-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202309.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202309-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202401', '2024-01-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202401.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202401', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 1, 2024, '2024-01-01', '2024-01-31', '2024-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-01-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202401.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202401-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202402', '2024-02-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202402.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202402', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 2, 2024, '2024-02-01', '2024-02-29', '2024-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-02-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202402.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202402-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202403', '2024-03-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202403.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202403', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 3, 2024, '2024-03-01', '2024-03-31', '2024-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-03-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202403.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202403-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202404', '2024-04-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202404.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202404', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 4, 2024, '2024-04-01', '2024-04-30', '2024-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-04-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202404.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202404-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202405', '2024-05-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202405.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202405', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 5, 2024, '2024-05-01', '2024-05-31', '2024-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-05-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202405.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202405-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202406', '2024-06-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202406.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202406', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 6, 2024, '2024-06-01', '2024-06-30', '2024-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-06-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202406.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202406-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 'invoice', '188/INV.FO/XI/2023-202407', '2024-07-01', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202407.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '188/INV.FO/XI/2023-202407', v_contract_id, v_version_id, 'KIMA.BAK-43/DBO/FO/IX/2023', 7, 2024, '2024-07-01', '2024-07-31', '2024-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-07-15 10:00:00+00', 'https://files.kima.local/invoices/188/INV.FO/XI/2023-202407.pdf', 'https://files.kima.local/payments/188/INV.FO/XI/2023-202407-proof.pdf', NOW(), NOW());

  -- Contract 7: PT Karya Teknik Mulia (PT Wastec International)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'KIMA.BAK-54/DBO/FO/IX/2024', '2024-08-18', '2025-08-17', 'core', 1, NULL, 'expired', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_wastec_customer_id, 1, '2024-08-18', '2025-08-17', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'BAK', 'KIMA.BAK-54/DBO/FO/IX/2024', '2024-08-18', 'https://files.kima.local/bak/KIMA.BAK-54/DBO/FO/IX/2024.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202410', '2024-10-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202410.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202410', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 10, 2024, '2024-10-01', '2024-10-31', '2024-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-10-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202410.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202410-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202411', '2024-11-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202411.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202411', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 11, 2024, '2024-11-01', '2024-11-30', '2024-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-11-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202411.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202411-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202412', '2024-12-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202412.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202412', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 12, 2024, '2024-12-01', '2024-12-31', '2024-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-12-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202412.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202412-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202408', '2024-08-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202408.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202408', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 8, 2024, '2024-08-01', '2024-08-31', '2024-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-08-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202408.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202408-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202409', '2024-09-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202409.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202409', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 9, 2024, '2024-09-01', '2024-09-30', '2024-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2024-09-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202409.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202409-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202501', '2025-01-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202501.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202501', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 1, 2025, '2025-01-01', '2025-01-31', '2025-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-01-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202501.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202501-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202502', '2025-02-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202502.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202502', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 2, 2025, '2025-02-01', '2025-02-28', '2025-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-02-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202502.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202502-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202503', '2025-03-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202503.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202503', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 3, 2025, '2025-03-01', '2025-03-31', '2025-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-03-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202503.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202503-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202504', '2025-04-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202504.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202504', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 4, 2025, '2025-04-01', '2025-04-30', '2025-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-04-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202504.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202504-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202505', '2025-05-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202505.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202505', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 5, 2025, '2025-05-01', '2025-05-31', '2025-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-05-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202505.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202505-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202506', '2025-06-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202506.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202506', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 6, 2025, '2025-06-01', '2025-06-30', '2025-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-06-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202506.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202506-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 'invoice', 'INV-016/KIMA/FO/I/2025-202507', '2025-07-01', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202507.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'INV-016/KIMA/FO/I/2025-202507', v_contract_id, v_version_id, 'KIMA.BAK-54/DBO/FO/IX/2024', 7, 2025, '2025-07-01', '2025-07-31', '2025-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-07-15 10:00:00+00', 'https://files.kima.local/invoices/INV-016/KIMA/FO/I/2025-202507.pdf', 'https://files.kima.local/payments/INV-016/KIMA/FO/I/2025-202507-proof.pdf', NOW(), NOW());

  -- Contract 8: PT Karya Teknik Mulia (PT Wastec International)
  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)
  VALUES (v_wastec_customer_id, 'KIMA.BAK-46/DBO/FO/X/2025', '2025-08-18', '2026-08-17', 'core', 1, NULL, 'aktif', 1, 'bulan', NOW(), NOW())
  RETURNING id INTO v_contract_id;

  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)
  VALUES (v_contract_id, v_wastec_customer_id, 1, '2025-08-18', '2026-08-17', 'core', 1, NULL, NOW(), NOW())
  RETURNING id INTO v_version_id;

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'BAK', 'KIMA.BAK-46/DBO/FO/X/2025', '2025-08-18', 'https://files.kima.local/bak/KIMA.BAK-46/DBO/FO/X/2025.pdf', NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202510', '2025-10-01', 'https://files.kima.local/invoices/090/FO/11/25-202510.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202510', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 10, 2025, '2025-10-01', '2025-10-31', '2025-10-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-10-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202510.pdf', 'https://files.kima.local/payments/090/FO/11/25-202510-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202511', '2025-11-01', 'https://files.kima.local/invoices/090/FO/11/25-202511.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202511', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 11, 2025, '2025-11-01', '2025-11-30', '2025-11-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-11-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202511.pdf', 'https://files.kima.local/payments/090/FO/11/25-202511-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202512', '2025-12-01', 'https://files.kima.local/invoices/090/FO/11/25-202512.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202512', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 12, 2025, '2025-12-01', '2025-12-31', '2025-12-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-12-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202512.pdf', 'https://files.kima.local/payments/090/FO/11/25-202512-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202508', '2025-08-01', 'https://files.kima.local/invoices/090/FO/11/25-202508.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202508', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 8, 2025, '2025-08-01', '2025-08-31', '2025-08-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-08-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202508.pdf', 'https://files.kima.local/payments/090/FO/11/25-202508-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202509', '2025-09-01', 'https://files.kima.local/invoices/090/FO/11/25-202509.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202509', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 9, 2025, '2025-09-01', '2025-09-30', '2025-09-10', 250000, 'lunas', 1, 'active', v_doc_id, '2025-09-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202509.pdf', 'https://files.kima.local/payments/090/FO/11/25-202509-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202601', '2026-01-01', 'https://files.kima.local/invoices/090/FO/11/25-202601.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202601', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 1, 2026, '2026-01-01', '2026-01-31', '2026-01-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-01-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202601.pdf', 'https://files.kima.local/payments/090/FO/11/25-202601-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202602', '2026-02-01', 'https://files.kima.local/invoices/090/FO/11/25-202602.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202602', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 2, 2026, '2026-02-01', '2026-02-28', '2026-02-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-02-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202602.pdf', 'https://files.kima.local/payments/090/FO/11/25-202602-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202603', '2026-03-01', 'https://files.kima.local/invoices/090/FO/11/25-202603.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202603', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 3, 2026, '2026-03-01', '2026-03-31', '2026-03-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-03-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202603.pdf', 'https://files.kima.local/payments/090/FO/11/25-202603-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202604', '2026-04-01', 'https://files.kima.local/invoices/090/FO/11/25-202604.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202604', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 4, 2026, '2026-04-01', '2026-04-30', '2026-04-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-04-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202604.pdf', 'https://files.kima.local/payments/090/FO/11/25-202604-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202605', '2026-05-01', 'https://files.kima.local/invoices/090/FO/11/25-202605.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202605', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 5, 2026, '2026-05-01', '2026-05-31', '2026-05-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-05-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202605.pdf', 'https://files.kima.local/payments/090/FO/11/25-202605-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202606', '2026-06-01', 'https://files.kima.local/invoices/090/FO/11/25-202606.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202606', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 6, 2026, '2026-06-01', '2026-06-30', '2026-06-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-06-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202606.pdf', 'https://files.kima.local/payments/090/FO/11/25-202606-proof.pdf', NOW(), NOW());

  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)
  VALUES (v_wastec_customer_id, v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 'invoice', '090/FO/11/25-202607', '2026-07-01', 'https://files.kima.local/invoices/090/FO/11/25-202607.pdf', NOW())
  RETURNING id INTO v_doc_id;

  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)
  VALUES (v_wastec_customer_id, '090/FO/11/25-202607', v_contract_id, v_version_id, 'KIMA.BAK-46/DBO/FO/X/2025', 7, 2026, '2026-07-01', '2026-07-31', '2026-07-10', 250000, 'lunas', 1, 'active', v_doc_id, '2026-07-15 10:00:00+00', 'https://files.kima.local/invoices/090/FO/11/25-202607.pdf', 'https://files.kima.local/payments/090/FO/11/25-202607-proof.pdf', NOW(), NOW());

  RAISE NOTICE 'Seeding completed: Cendikia ISP with BTN and Wastec tenants created.';
END $$;

SELECT 'ISP' AS type, id::TEXT AS code, name, status::TEXT AS status FROM isps WHERE name = 'PT Cendikia Global Solusi'
UNION ALL
SELECT 'Tenant' AS type, customer_code AS code, name, status::TEXT AS status FROM customers WHERE customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001')
UNION ALL
SELECT 'Summary' AS type, 'Contracts: ' || COUNT(DISTINCT c.id)::TEXT AS code, 'Invoices: ' || COUNT(DISTINCT i.id)::TEXT AS name, 'Total: Rp ' || COALESCE(SUM(i.amount), 0)::TEXT AS status FROM customers cu LEFT JOIN contracts c ON c.customer_id = cu.id LEFT JOIN invoices i ON i.customer_id = cu.id WHERE cu.customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001');
