-- PT Cendikia Global Solusi - Supabase Rollback Script
-- Removes both old incorrect seed shape and the corrected seed shape.

DO $$
DECLARE
  v_customer_ids INT[];
  v_isp_id INT;
BEGIN
  SELECT ARRAY_AGG(id) INTO v_customer_ids
  FROM customers
  WHERE customer_code IN ('CUST-CGS-001', 'CUST-BTN-001', 'CUST-WASTEC-001')
     OR name IN ('PT Cendikia Global Solusi', 'PT Bank Tabungan Negara (Persero)', 'PT Karya Teknik Mulia (PT Wastec International)');

  SELECT id INTO v_isp_id
  FROM isps
  WHERE name = 'PT Cendikia Global Solusi';

  IF v_customer_ids IS NOT NULL THEN
    DELETE FROM invoice_follow_ups WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id = ANY(v_customer_ids));
    DELETE FROM invoices WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM documents WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM contract_version_renewal_follow_ups WHERE version_id IN (SELECT id FROM contract_versions WHERE customer_id = ANY(v_customer_ids));
    DELETE FROM contract_versions WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM contracts WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM customer_route_history WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM customer_route_points WHERE route_version_id IN (SELECT id FROM customer_route_versions WHERE customer_id = ANY(v_customer_ids));
    DELETE FROM customer_route_versions WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM customer_isp_memberships WHERE customer_id = ANY(v_customer_ids);
    DELETE FROM customers WHERE id = ANY(v_customer_ids);
  END IF;

  IF v_isp_id IS NOT NULL THEN
    DELETE FROM customer_isp_memberships WHERE isp_id = v_isp_id;
    DELETE FROM isp_renewal_follow_ups WHERE row_id IN (SELECT id FROM isp_contract_rows WHERE isp_id = v_isp_id);
    DELETE FROM isp_contract_rows WHERE isp_id = v_isp_id;
    DELETE FROM isps WHERE id = v_isp_id;
  END IF;

  RAISE NOTICE 'Rollback completed for Cendikia seed data.';
END $$;

SELECT
  (SELECT COUNT(*) FROM isps WHERE name = 'PT Cendikia Global Solusi') AS remaining_cendikia_isps,
  (SELECT COUNT(*) FROM customers WHERE customer_code IN ('CUST-CGS-001', 'CUST-BTN-001', 'CUST-WASTEC-001')) AS remaining_cendikia_customers;
