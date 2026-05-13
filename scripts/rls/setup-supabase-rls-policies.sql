-- Setup Row Level Security (RLS) Policies for Supabase
-- Run this in Supabase SQL Editor after creating auth users

-- ============================================================================
-- HELPER FUNCTION: Get user role from JWT
-- ============================================================================
-- Note: Create in public schema instead of auth schema to avoid permission issues

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'role')::TEXT,
    'guest'
  );
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

-- ============================================================================
-- SIMPLIFIED RLS APPROACH
-- ============================================================================
-- Since we don't have direct mapping between auth.uid() (UUID) and users.id (INT),
-- we use role-based policies only:
-- - Admin: full access to everything
-- - Teknisi: read-only access to everything
-- - ISP: read-only access to everything (for now, until we implement proper ISP filtering)
-- ============================================================================

-- ============================================================================
-- CUSTOMERS TABLE
-- ============================================================================

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- Policy: Admin can do everything
CREATE POLICY "Admin full access on customers"
ON customers
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi can read all
CREATE POLICY "Teknisi read all customers"
ON customers
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP can read all (simplified - no filtering by ISP ownership yet)
CREATE POLICY "ISP read all customers"
ON customers
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- ISPs TABLE
-- ============================================================================

ALTER TABLE isps ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on isps"
ON isps
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all isps"
ON isps
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all isps"
ON isps
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- CUSTOMER_ISP_MEMBERSHIPS TABLE
-- ============================================================================

ALTER TABLE customer_isp_memberships ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on customer_isp_memberships"
ON customer_isp_memberships
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all memberships"
ON customer_isp_memberships
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all memberships"
ON customer_isp_memberships
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- CONTRACTS TABLE
-- ============================================================================

ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on contracts"
ON contracts
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all contracts"
ON contracts
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all contracts"
ON contracts
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- CONTRACT_VERSIONS TABLE
-- ============================================================================

ALTER TABLE contract_versions ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on contract_versions"
ON contract_versions
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all contract_versions"
ON contract_versions
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all contract_versions"
ON contract_versions
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- INVOICES TABLE
-- ============================================================================

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on invoices"
ON invoices
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all invoices"
ON invoices
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all invoices"
ON invoices
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- DOCUMENTS TABLE
-- ============================================================================

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on documents"
ON documents
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all documents"
ON documents
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all documents"
ON documents
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- CUSTOMER_ROUTE_VERSIONS TABLE
-- ============================================================================

ALTER TABLE customer_route_versions ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on customer_route_versions"
ON customer_route_versions
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all routes"
ON customer_route_versions
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all routes"
ON customer_route_versions
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- CUSTOMER_ROUTE_POINTS TABLE
-- ============================================================================

ALTER TABLE customer_route_points ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on customer_route_points"
ON customer_route_points
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all route points"
ON customer_route_points
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all route points"
ON customer_route_points
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- ISP_CONTRACT_ROWS TABLE
-- ============================================================================

ALTER TABLE isp_contract_rows ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on isp_contract_rows"
ON isp_contract_rows
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all isp contract rows"
ON isp_contract_rows
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all isp contract rows"
ON isp_contract_rows
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- ISP_RENEWAL_FOLLOW_UPS TABLE
-- ============================================================================

ALTER TABLE isp_renewal_follow_ups ENABLE ROW LEVEL SECURITY;

-- Policy: Admin full access
CREATE POLICY "Admin full access on isp_renewal_follow_ups"
ON isp_renewal_follow_ups
FOR ALL
USING (public.get_user_role() = 'admin')
WITH CHECK (public.get_user_role() = 'admin');

-- Policy: Teknisi read all
CREATE POLICY "Teknisi read all renewal follow ups"
ON isp_renewal_follow_ups
FOR SELECT
USING (public.get_user_role() = 'teknisi');

-- Policy: ISP read all
CREATE POLICY "ISP read all renewal follow ups"
ON isp_renewal_follow_ups
FOR SELECT
USING (public.get_user_role() = 'isp');

-- ============================================================================
-- VERIFY POLICIES
-- ============================================================================

-- List all RLS policies
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
