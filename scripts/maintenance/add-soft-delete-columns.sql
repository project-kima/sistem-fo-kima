-- ============================================================================
-- SOFT DELETE IMPLEMENTATION
-- Add deleted_at and deleted_by columns to all main tables
-- ============================================================================
-- Date: 2026-05-18
-- Purpose: Enable soft delete functionality for trash/restore feature
-- ============================================================================

-- ISPs
ALTER TABLE isps 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN isps.deleted_at IS 'Timestamp when ISP was soft deleted';
COMMENT ON COLUMN isps.deleted_by IS 'User who deleted the ISP';

-- Customers
ALTER TABLE customers 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN customers.deleted_at IS 'Timestamp when customer was soft deleted';
COMMENT ON COLUMN customers.deleted_by IS 'User who deleted the customer';

-- Contracts
ALTER TABLE contracts 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN contracts.deleted_at IS 'Timestamp when contract was soft deleted';
COMMENT ON COLUMN contracts.deleted_by IS 'User who deleted the contract';

-- Contract Versions
ALTER TABLE contract_versions 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN contract_versions.deleted_at IS 'Timestamp when contract version was soft deleted';
COMMENT ON COLUMN contract_versions.deleted_by IS 'User who deleted the contract version';

-- Invoices
ALTER TABLE invoices 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN invoices.deleted_at IS 'Timestamp when invoice was soft deleted';
COMMENT ON COLUMN invoices.deleted_by IS 'User who deleted the invoice';

-- Documents
ALTER TABLE documents 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN documents.deleted_at IS 'Timestamp when document was soft deleted';
COMMENT ON COLUMN documents.deleted_by IS 'User who deleted the document';

-- Customer Route Versions
ALTER TABLE customer_route_versions 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN customer_route_versions.deleted_at IS 'Timestamp when route version was soft deleted';
COMMENT ON COLUMN customer_route_versions.deleted_by IS 'User who deleted the route version';

-- Customer Route Points
ALTER TABLE customer_route_points 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN customer_route_points.deleted_at IS 'Timestamp when route point was soft deleted';
COMMENT ON COLUMN customer_route_points.deleted_by IS 'User who deleted the route point';

-- ISP Contract Rows
ALTER TABLE isp_contract_rows 
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

COMMENT ON COLUMN isp_contract_rows.deleted_at IS 'Timestamp when ISP contract row was soft deleted';
COMMENT ON COLUMN isp_contract_rows.deleted_by IS 'User who deleted the ISP contract row';

-- ============================================================================
-- CREATE INDEXES FOR SOFT DELETE QUERIES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_isps_deleted_at ON isps(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_customers_deleted_at ON customers(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contracts_deleted_at ON contracts(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contract_versions_deleted_at ON contract_versions(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_invoices_deleted_at ON invoices(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_documents_deleted_at ON documents(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_customer_route_versions_deleted_at ON customer_route_versions(deleted_at) WHERE deleted_at IS NOT NULL;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if columns were added successfully
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name IN ('deleted_at', 'deleted_by')
  AND table_name IN (
    'isps', 'customers', 'contracts', 'contract_versions', 
    'invoices', 'documents', 'customer_route_versions', 
    'customer_route_points', 'isp_contract_rows'
  )
ORDER BY table_name, column_name;

-- Check indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%_deleted_at'
ORDER BY tablename;
