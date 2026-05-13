-- Create Supabase Auth Users
-- Run this in Supabase SQL Editor

-- Note: Supabase Auth users are created in auth.users table
-- Password will be hashed automatically by Supabase
-- User metadata stores the role information

-- 1. Admin User
-- Email: admin@kima.local
-- Password: Admin@2026
-- Role: admin

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@kima.local',
  crypt('Admin@2026', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"role":"admin","display_name":"Administrator"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- 2. Teknisi User
-- Email: teknisi@kima.local
-- Password: Teknisi@2026
-- Role: teknisi

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'teknisi@kima.local',
  crypt('Teknisi@2026', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"role":"teknisi","display_name":"Teknisi"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- 3. ISP User
-- Email: isp@kima.local
-- Password: Isp@2026
-- Role: isp

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'isp@kima.local',
  crypt('Isp@2026', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"role":"isp","display_name":"ISP User"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- Verify users created
SELECT
  id,
  email,
  raw_user_meta_data->>'role' as role,
  raw_user_meta_data->>'display_name' as display_name,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email IN ('admin@kima.local', 'teknisi@kima.local', 'isp@kima.local')
ORDER BY email;
