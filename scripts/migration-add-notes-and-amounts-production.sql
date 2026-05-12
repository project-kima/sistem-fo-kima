-- ============================================================================
-- MIGRATION: ADD NOTES AND CONTRACT AMOUNTS - PRODUCTION (SUPABASE)
-- ============================================================================
-- Tanggal: 2026-05-12
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
-- ============================================================================
-- IMPORTANT: Jalankan migration ini SEBELUM insert data PT Charoen Pokphand
-- ============================================================================

BEGIN;

-- ============================================================================
-- ADD NEW COLUMNS
-- ============================================================================

-- 1. Add 'notes' column to customers table
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS notes TEXT;

-- 2. Add 'monthly_amount', 'yearly_amount', and 'remarks' to contract_versions table
ALTER TABLE contract_versions
ADD COLUMN IF NOT EXISTS monthly_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS yearly_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS remarks TEXT;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Optional - untuk cek hasil)
-- ============================================================================
-- Uncomment untuk verifikasi setelah migration

-- -- Cek struktur tabel customers
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'customers'
--   AND column_name IN ('notes')
-- ORDER BY ordinal_position;

-- -- Cek struktur tabel contract_versions
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'contract_versions'
--   AND column_name IN ('monthly_amount', 'yearly_amount', 'remarks')
-- ORDER BY ordinal_position;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1. Migration ini menambahkan 4 field baru:
--    - customers.notes (TEXT, nullable)
--    - contract_versions.monthly_amount (DECIMAL, default 0)
--    - contract_versions.yearly_amount (DECIMAL, default 0)
--    - contract_versions.remarks (TEXT, nullable)
--
-- 2. Field ini diperlukan untuk merepresentasikan kolom spreadsheet:
--    - Keterangan (notes)
--    - Nilai Kontrak Bulanan (monthly_amount)
--    - Nilai Kontrak Tahunan (yearly_amount)
--    - Keterangan Kontrak (remarks)
--
-- 3. Setelah migration ini, jalankan script insert data:
--    insert-charoen-pokphand-production.sql
--
-- 4. Migration ini aman dijalankan multiple kali (IF NOT EXISTS)
-- ============================================================================
