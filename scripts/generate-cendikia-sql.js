const fs = require('fs');
const path = require('path');

const vendor = 'PT Cendikia Global Solusi';
const btn = 'PT Bank Tabungan Negara (Persero)';
const wastec = 'PT Karya Teknik Mulia (PT Wastec International)';

const contractsData = [
  { klien: btn, tanggal_kontrak: '2022-07-25', tanggal_mulai: '2022-07-25', tanggal_selesai: '2023-07-24', rasio: '1/32', no_spk: null, no_invoice: '065/INV.FO/XII/2022', pembayaran_bulanan: { '2022': { '07': 250000, '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2023': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000 } } },
  { klien: btn, tanggal_kontrak: null, tanggal_mulai: '2023-07-08', tanggal_selesai: '2024-07-07', rasio: null, no_spk: 'KIMA.BAK-42/DBO/FO/IX/2023', no_invoice: '187/INV.FO/XI/2023', pembayaran_bulanan: { '2023': { '07': 250000, '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2024': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000 } } },
  { klien: btn, tanggal_kontrak: null, tanggal_mulai: '2024-07-08', tanggal_selesai: '2025-07-07', rasio: null, no_spk: 'KIMA.BAK-38/DBO/FO/VI/2024', no_invoice: 'INV-065/KIMA/FO/VII/2024', pembayaran_bulanan: { '2024': { '07': 250000, '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2025': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000 } } },
  { klien: btn, tanggal_kontrak: null, tanggal_mulai: '2025-07-08', tanggal_selesai: '2026-07-07', rasio: null, no_spk: 'KIMA-BAK-32/DBO/FO/VII/2025', no_invoice: '087/FO/11/25', pembayaran_bulanan: { '2025': { '07': 250000, '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2026': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000 } } },
  { klien: wastec, tanggal_kontrak: '2022-08-15', tanggal_mulai: '2022-08-15', tanggal_selesai: '2023-08-16', rasio: '1/32', no_spk: null, no_invoice: '067/INV.FO/XII/2022', pembayaran_bulanan: { '2022': { '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2023': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000, '07': 250000 } } },
  { klien: wastec, tanggal_kontrak: null, tanggal_mulai: '2023-08-18', tanggal_selesai: '2024-08-17', rasio: null, no_spk: 'KIMA.BAK-43/DBO/FO/IX/2023', no_invoice: '188/INV.FO/XI/2023', pembayaran_bulanan: { '2023': { '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2024': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000, '07': 250000 } } },
  { klien: wastec, tanggal_kontrak: null, tanggal_mulai: '2024-08-18', tanggal_selesai: '2025-08-17', rasio: null, no_spk: 'KIMA.BAK-54/DBO/FO/IX/2024', no_invoice: 'INV-016/KIMA/FO/I/2025', pembayaran_bulanan: { '2024': { '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2025': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000, '07': 250000 } } },
  { klien: wastec, tanggal_kontrak: null, tanggal_mulai: '2025-08-18', tanggal_selesai: '2026-08-17', rasio: null, no_spk: 'KIMA.BAK-46/DBO/FO/X/2025', no_invoice: '090/FO/11/25', pembayaran_bulanan: { '2025': { '08': 250000, '09': 250000, '10': 250000, '11': 250000, '12': 250000 }, '2026': { '01': 250000, '02': 250000, '03': 250000, '04': 250000, '05': 250000, '06': 250000, '07': 250000 } } },
];

const q = (value) => value == null ? 'NULL' : `'${String(value).replace(/'/g, "''")}'`;
const periodEnd = (year, month) => `${year}-${String(month).padStart(2, '0')}-${String(new Date(Date.UTC(year, month, 0)).getUTCDate()).padStart(2, '0')}`;
const isExpired = (endDate) => new Date(`${endDate}T00:00:00Z`) < new Date();
const contractNumberFor = (contract, index) => contract.no_spk || `CTR-CGS-${contract.tanggal_mulai.slice(0, 4)}-${String(index + 1).padStart(3, '0')}`;
const customerRefFor = (contract) => contract.klien === btn ? 'v_btn_customer_id' : 'v_wastec_customer_id';

let sql = `-- PT Cendikia Global Solusi - Full Supabase Seeding Script\n`;
sql += `-- Correct mapping: ISP/vendor = PT Cendikia Global Solusi; tenants = BTN and Wastec.\n\n`;
sql += `DO $$\nDECLARE\n  v_isp_id INT;\n  v_btn_customer_id INT;\n  v_wastec_customer_id INT;\n  v_contract_id INT;\n  v_version_id INT;\n  v_doc_id INT;\nBEGIN\n`;
sql += `  IF EXISTS (SELECT 1 FROM isps WHERE name = ${q(vendor)}) OR EXISTS (SELECT 1 FROM customers WHERE customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001')) THEN\n    RAISE NOTICE 'Cendikia seed data already exists. Run rollback-cendikia-supabase.sql first if you want to reseed.';\n    RETURN;\n  END IF;\n\n`;
sql += `  INSERT INTO isps (name, status, contract_reference, contract_start_date, contract_period_start, contract_period_end, paket, jumlah, billing_period_mode, activation_fee_amount, created_at, updated_at)\n  VALUES (${q(vendor)}, 'aktif', 'ISP-CENDIKIA-2022', '2022-07-25', '2022-07-25', '2026-08-17', 'shared', 2, 'monthly', 0, NOW(), NOW())\n  RETURNING id INTO v_isp_id;\n\n`;
sql += `  INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)\n  VALUES ('CUST-BTN-001', ${q(vendor)}, ${q(btn)}, 'aktif', 2500000, '2022-07-25', NOW(), NOW())\n  RETURNING id INTO v_btn_customer_id;\n\n`;
sql += `  INSERT INTO customers (customer_code, isp_name, name, status, activation_fee_amount, contract_start_date, created_at, updated_at)\n  VALUES ('CUST-WASTEC-001', ${q(vendor)}, ${q(wastec)}, 'aktif', 2500000, '2022-08-15', NOW(), NOW())\n  RETURNING id INTO v_wastec_customer_id;\n\n`;
sql += `  INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)\n  VALUES (v_btn_customer_id, v_isp_id, NOW(), NOW());\n\n`;
sql += `  INSERT INTO customer_isp_memberships (customer_id, isp_id, created_at, updated_at)\n  VALUES (v_wastec_customer_id, v_isp_id, NOW(), NOW());\n\n`;

contractsData.forEach((contract, index) => {
  const customerRef = customerRefFor(contract);
  const contractNumber = contractNumberFor(contract, index);
  const coreType = contract.rasio ? 'sharing_core' : 'core';
  const status = isExpired(contract.tanggal_selesai) ? 'expired' : 'aktif';
  sql += `  -- Contract ${index + 1}: ${contract.klien}\n`;
  sql += `  INSERT INTO contracts (customer_id, contract_number, start_date, end_date, core_type, core_total, sharing_ratio, status, billing_every, billing_unit, created_at, updated_at)\n  VALUES (${customerRef}, ${q(contractNumber)}, ${q(contract.tanggal_mulai)}, ${q(contract.tanggal_selesai)}, ${q(coreType)}, 1, ${q(contract.rasio)}, ${q(status)}, 1, 'bulan', NOW(), NOW())\n  RETURNING id INTO v_contract_id;\n\n`;
  sql += `  INSERT INTO contract_versions (contract_id, customer_id, version_number, start_date, end_date, core_type, core_total, shared_core_ratio, created_at, updated_at)\n  VALUES (v_contract_id, ${customerRef}, 1, ${q(contract.tanggal_mulai)}, ${q(contract.tanggal_selesai)}, ${q(coreType)}, 1, ${q(contract.rasio)}, NOW(), NOW())\n  RETURNING id INTO v_version_id;\n\n`;
  if (contract.tanggal_kontrak) {
    sql += `  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)\n  VALUES (${customerRef}, v_contract_id, v_version_id, ${q(contractNumber)}, 'kontrak', ${q(contractNumber)}, ${q(contract.tanggal_kontrak)}, ${q(`https://files.kima.local/contracts/${contractNumber}.pdf`)}, NOW());\n\n`;
  }
  if (contract.no_spk) {
    sql += `  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)\n  VALUES (${customerRef}, v_contract_id, v_version_id, ${q(contractNumber)}, 'BAK', ${q(contract.no_spk)}, ${q(contract.tanggal_mulai)}, ${q(`https://files.kima.local/bak/${contract.no_spk}.pdf`)}, NOW());\n\n`;
  }
  Object.entries(contract.pembayaran_bulanan).forEach(([year, months]) => {
    Object.entries(months).forEach(([month, amount]) => {
      const y = Number(year);
      const m = Number(month);
      const mm = String(m).padStart(2, '0');
      const invoiceNumber = `${contract.no_invoice}-${y}${mm}`;
      const periodStart = `${y}-${mm}-01`;
      const dueDate = `${y}-${mm}-10`;
      const paidAt = `${y}-${mm}-15 10:00:00+00`;
      sql += `  INSERT INTO documents (customer_id, contract_id, contract_version_id, contract_number, jenis_dokumen, nomor_dokumen, tanggal_dokumen, file_url, created_at)\n  VALUES (${customerRef}, v_contract_id, v_version_id, ${q(contractNumber)}, 'invoice', ${q(invoiceNumber)}, ${q(periodStart)}, ${q(`https://files.kima.local/invoices/${invoiceNumber}.pdf`)}, NOW())\n  RETURNING id INTO v_doc_id;\n\n`;
      sql += `  INSERT INTO invoices (customer_id, invoice_number, contract_id, contract_version_id, contract_number, period_month, period_year, period_start_date, period_end_date, due_date, amount, status, schedule_version, schedule_status, document_id, paid_at, invoice_file_url, payment_proof_file_url, created_at, updated_at)\n  VALUES (${customerRef}, ${q(invoiceNumber)}, v_contract_id, v_version_id, ${q(contractNumber)}, ${m}, ${y}, ${q(periodStart)}, ${q(periodEnd(y, m))}, ${q(dueDate)}, ${amount}, 'lunas', 1, 'active', v_doc_id, ${q(paidAt)}, ${q(`https://files.kima.local/invoices/${invoiceNumber}.pdf`)}, ${q(`https://files.kima.local/payments/${invoiceNumber}-proof.pdf`)}, NOW(), NOW());\n\n`;
    });
  });
});

sql += `  RAISE NOTICE 'Seeding completed: Cendikia ISP with BTN and Wastec tenants created.';\nEND $$;\n\n`;
sql += `SELECT 'ISP' AS type, id::TEXT AS code, name, status::TEXT AS status FROM isps WHERE name = ${q(vendor)}\nUNION ALL\nSELECT 'Tenant' AS type, customer_code AS code, name, status::TEXT AS status FROM customers WHERE customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001')\nUNION ALL\nSELECT 'Summary' AS type, 'Contracts: ' || COUNT(DISTINCT c.id)::TEXT AS code, 'Invoices: ' || COUNT(DISTINCT i.id)::TEXT AS name, 'Total: Rp ' || COALESCE(SUM(i.amount), 0)::TEXT AS status FROM customers cu LEFT JOIN contracts c ON c.customer_id = cu.id LEFT JOIN invoices i ON i.customer_id = cu.id WHERE cu.customer_code IN ('CUST-BTN-001', 'CUST-WASTEC-001');\n`;

const outputPath = path.join(__dirname, 'seed-cendikia-supabase-full.sql');
fs.writeFileSync(outputPath, sql);
const invoiceCount = contractsData.reduce((total, contract) => total + Object.values(contract.pembayaran_bulanan).reduce((subtotal, months) => subtotal + Object.keys(months).length, 0), 0);
console.log(`Generated ${outputPath}`);
console.log(`ISP: ${vendor}`);
console.log(`Tenants: 2`);
console.log(`Contracts: ${contractsData.length}`);
console.log(`Invoices: ${invoiceCount}`);
console.log(`Total: Rp ${invoiceCount * 250000}`);
