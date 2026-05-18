-- Performance indexes for Supabase/PostgREST read paths.
-- Run in Supabase SQL Editor. Safe to re-run because every index uses IF NOT EXISTS.
--
-- Goal:
-- - Speed up dashboard/workspace/detail/monitoring queries used by frontend/src/lib/api.js.
-- - Reduce long-running requests that can contribute to gateway pressure/rate-limit symptoms.
--
-- Note: indexes help query execution time. If rate limit is caused by too many separate
-- browser requests, the next fix is batching/debouncing on the frontend.

-- ============================================================================
-- MASTER LISTS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_customers_name
ON public.customers (name);

CREATE INDEX IF NOT EXISTS idx_customers_status_name
ON public.customers (status, name);

CREATE INDEX IF NOT EXISTS idx_customers_status_created_at
ON public.customers (status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_customers_customer_code
ON public.customers (customer_code);

CREATE INDEX IF NOT EXISTS idx_isps_name
ON public.isps (name);

CREATE INDEX IF NOT EXISTS idx_isps_status_name
ON public.isps (status, name);

CREATE INDEX IF NOT EXISTS idx_isps_created_at
ON public.isps (created_at DESC);

-- ============================================================================
-- CUSTOMER <-> ISP RELATION
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_customer_isp_memberships_customer_id
ON public.customer_isp_memberships (customer_id);

CREATE INDEX IF NOT EXISTS idx_customer_isp_memberships_isp_id
ON public.customer_isp_memberships (isp_id);

CREATE INDEX IF NOT EXISTS idx_customer_isp_memberships_isp_customer
ON public.customer_isp_memberships (isp_id, customer_id);

-- ============================================================================
-- CONTRACTS AND CONTRACT VERSIONS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_contracts_customer_created_at
ON public.contracts (customer_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_contracts_customer_start_end
ON public.contracts (customer_id, start_date DESC, end_date DESC);

CREATE INDEX IF NOT EXISTS idx_contracts_status_customer
ON public.contracts (status, customer_id);

CREATE INDEX IF NOT EXISTS idx_contracts_active_customer
ON public.contracts (customer_id)
WHERE status = 'aktif';

CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_version
ON public.contract_versions (contract_id, version_number DESC);

CREATE INDEX IF NOT EXISTS idx_contract_versions_customer_contract
ON public.contract_versions (customer_id, contract_id);

CREATE INDEX IF NOT EXISTS idx_contract_versions_contract_period
ON public.contract_versions (contract_id, start_date DESC, end_date DESC);

-- ============================================================================
-- INVOICES AND BILLING MONITORING
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_invoices_customer_period_desc
ON public.invoices (customer_id, period_year DESC, period_month DESC);

CREATE INDEX IF NOT EXISTS idx_invoices_year_schedule_status
ON public.invoices (period_year, schedule_status, status);

CREATE INDEX IF NOT EXISTS idx_invoices_active_year_customer
ON public.invoices (period_year, customer_id, period_month)
WHERE schedule_status = 'active';

CREATE INDEX IF NOT EXISTS idx_invoices_unpaid_active_year
ON public.invoices (period_year, due_date, customer_id)
WHERE schedule_status = 'active'
  AND status IN ('belum_bayar', 'terlambat');

CREATE INDEX IF NOT EXISTS idx_invoices_contract_id
ON public.invoices (contract_id);

CREATE INDEX IF NOT EXISTS idx_invoices_contract_version_id
ON public.invoices (contract_version_id);

-- ============================================================================
-- DOCUMENTS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_documents_customer_date_desc
ON public.documents (customer_id, tanggal_dokumen DESC);

CREATE INDEX IF NOT EXISTS idx_documents_contract_id
ON public.documents (contract_id);

CREATE INDEX IF NOT EXISTS idx_documents_contract_version_id
ON public.documents (contract_version_id);

CREATE INDEX IF NOT EXISTS idx_documents_type_date
ON public.documents (jenis_dokumen, tanggal_dokumen DESC);

-- ============================================================================
-- ROUTE PLANNER
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_customer_route_versions_customer_version
ON public.customer_route_versions (customer_id, version_number DESC);

CREATE INDEX IF NOT EXISTS idx_customer_route_versions_customer_updated
ON public.customer_route_versions (customer_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_customer_route_points_version_order
ON public.customer_route_points (route_version_id, order_number);

CREATE INDEX IF NOT EXISTS idx_customer_route_history_customer_created
ON public.customer_route_history (customer_id, created_at DESC);

-- ============================================================================
-- FOLLOW UPS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_invoice_follow_ups_invoice_split
ON public.invoice_follow_ups (invoice_id, split_order);

CREATE INDEX IF NOT EXISTS idx_contract_version_renewal_follow_ups_version_split
ON public.contract_version_renewal_follow_ups (version_id, split_order);

CREATE INDEX IF NOT EXISTS idx_isp_renewal_follow_ups_row_split
ON public.isp_renewal_follow_ups (row_id, split_order);

-- ============================================================================
-- ISP DETAIL
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_isp_contract_rows_isp_period
ON public.isp_contract_rows (isp_id, period_start DESC, period_end DESC);

CREATE INDEX IF NOT EXISTS idx_isp_contract_rows_renewal_status
ON public.isp_contract_rows (renewal_status);

-- ============================================================================
-- UPDATE PLANNER STATISTICS
-- ============================================================================

ANALYZE public.customers;
ANALYZE public.isps;
ANALYZE public.customer_isp_memberships;
ANALYZE public.contracts;
ANALYZE public.contract_versions;
ANALYZE public.invoices;
ANALYZE public.documents;
ANALYZE public.customer_route_versions;
ANALYZE public.customer_route_points;
ANALYZE public.customer_route_history;
ANALYZE public.invoice_follow_ups;
ANALYZE public.contract_version_renewal_follow_ups;
ANALYZE public.isp_renewal_follow_ups;
ANALYZE public.isp_contract_rows;
