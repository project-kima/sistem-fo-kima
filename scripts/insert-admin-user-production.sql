-- ============================================================================
-- INSERT DEFAULT ADMIN USER - PRODUCTION (SUPABASE)
-- ============================================================================
-- Tanggal: 2026-05-12
-- Database: Supabase PostgreSQL (Production)
-- Cara Pakai: Copy-paste script ini ke Supabase SQL Editor dan Run
-- ============================================================================

BEGIN;

-- Insert Admin User
INSERT INTO users (
  username,
  email,
  password_hash,
  role,
  display_name,
  is_active,
  created_at,
  updated_at
) VALUES (
  'admin',
  'admin@kima.local',
  -- Password: Admin@2026
  -- Hash menggunakan bcrypt (10 rounds)
  '$2b$10$tQfpWsjzRlzt.h6fN8QnA.v2Swv8Fg.WfSVlYLMBXfd6DZOV0wtgC',
  'admin',
  'Administrator',
  true,
  NOW(),
  NOW()
);

COMMIT;

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
-- Uncomment untuk verifikasi setelah insert

-- SELECT id, username, email, role, display_name, is_active
-- FROM users
-- WHERE username = 'admin';

-- ============================================================================
-- KREDENSIAL ADMIN
-- ============================================================================
-- Username: admin
-- Password: Admin@2026
-- Email: admin@kima.local
-- Role: admin
-- ============================================================================
