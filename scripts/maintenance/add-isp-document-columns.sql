-- ============================================================================
-- ISP DOCUMENT COLUMNS
-- Add ISP BAK and contract file metadata columns
-- ============================================================================
-- Date: 2026-05-18
-- Purpose: Support ISP document upload fields used by the frontend
-- ============================================================================

ALTER TABLE isps
  ADD COLUMN IF NOT EXISTS bak_file_url TEXT,
  ADD COLUMN IF NOT EXISTS bak_file_name TEXT,
  ADD COLUMN IF NOT EXISTS contract_file_url TEXT,
  ADD COLUMN IF NOT EXISTS contract_file_name TEXT;

COMMENT ON COLUMN isps.bak_file_url IS 'Stored URL or data URL for ISP BAK document';
COMMENT ON COLUMN isps.bak_file_name IS 'Original file name for ISP BAK document';
COMMENT ON COLUMN isps.contract_file_url IS 'Stored URL or data URL for ISP contract document';
COMMENT ON COLUMN isps.contract_file_name IS 'Original file name for ISP contract document';

SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'isps'
  AND column_name IN (
    'bak_file_url',
    'bak_file_name',
    'contract_file_url',
    'contract_file_name'
  )
ORDER BY column_name;
