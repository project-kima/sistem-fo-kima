-- Create/sync Supabase Auth users from public.isps credentials
-- Run this in Supabase SQL Editor with sufficient privileges.
--
-- Source fields:
-- - public.isps.user_id        = login email
-- - public.isps.password_plain = initial/current password
--
-- This script is idempotent for the same ISP/email combination:
-- 1) creates missing auth.users rows for ISP credentials
-- 2) updates existing auth.users password/metadata for matching emails
-- 3) refreshes public.isp_user_accounts mapping (1 auth user = 1 ISP)

BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.isps i
    WHERE NULLIF(TRIM(i.user_id), '') IS NOT NULL
      AND NULLIF(TRIM(i.password_plain), '') IS NOT NULL
      AND COALESCE(i.deleted_at IS NULL, TRUE)
    GROUP BY LOWER(TRIM(i.user_id))
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'Ada email ISP duplikat di public.isps.user_id. Perbaiki data sebelum provisioning Auth.';
  END IF;
END $$;

WITH credential_isps AS (
  SELECT
    i.id AS isp_id,
    i.name AS isp_name,
    LOWER(TRIM(i.user_id)) AS email,
    i.password_plain AS password_plain
  FROM public.isps i
  WHERE NULLIF(TRIM(i.user_id), '') IS NOT NULL
    AND NULLIF(TRIM(i.password_plain), '') IS NOT NULL
    AND COALESCE(i.deleted_at IS NULL, TRUE)
),
updated_users AS (
  UPDATE auth.users au
  SET
    encrypted_password = crypt(ci.password_plain, gen_salt('bf')),
    email_confirmed_at = COALESCE(au.email_confirmed_at, NOW()),
    raw_app_meta_data = jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    raw_user_meta_data = jsonb_build_object(
      'role', 'isp',
      'display_name', ci.isp_name,
      'isp_id', ci.isp_id
    ),
    updated_at = NOW()
  FROM credential_isps ci
  WHERE LOWER(au.email) = ci.email
  RETURNING au.id, au.email
)
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
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  ci.email,
  crypt(ci.password_plain, gen_salt('bf')),
  NOW(),
  jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
  jsonb_build_object(
    'role', 'isp',
    'display_name', ci.isp_name,
    'isp_id', ci.isp_id
  ),
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
FROM credential_isps ci
WHERE NOT EXISTS (
  SELECT 1
  FROM auth.users au
  WHERE LOWER(au.email) = ci.email
);

WITH credential_isps AS (
  SELECT
    i.id AS isp_id,
    i.name AS isp_name,
    LOWER(TRIM(i.user_id)) AS email
  FROM public.isps i
  WHERE NULLIF(TRIM(i.user_id), '') IS NOT NULL
    AND NULLIF(TRIM(i.password_plain), '') IS NOT NULL
    AND COALESCE(i.deleted_at IS NULL, TRUE)
),
resolved AS (
  SELECT
    au.id AS auth_user_id,
    ci.isp_id,
    ci.email,
    ci.isp_name
  FROM credential_isps ci
  JOIN auth.users au
    ON LOWER(au.email) = ci.email
),
removed_stale_mapping AS (
  DELETE FROM public.isp_user_accounts iua
  USING resolved r
  WHERE iua.auth_user_id = r.auth_user_id
     OR iua.isp_id = r.isp_id
  RETURNING iua.id
)
INSERT INTO public.isp_user_accounts (
  auth_user_id,
  isp_id,
  email,
  display_name,
  created_at,
  updated_at
)
SELECT
  r.auth_user_id,
  r.isp_id,
  r.email,
  r.isp_name,
  NOW(),
  NOW()
FROM resolved r;

COMMIT;

-- Verification: ISP credentials and Auth mapping status
SELECT
  i.id AS isp_id,
  i.name AS isp_name,
  i.user_id AS login_email,
  au.id AS auth_user_id,
  au.raw_user_meta_data->>'role' AS auth_role,
  iua.id AS mapping_id,
  iua.updated_at AS mapped_at
FROM public.isps i
LEFT JOIN auth.users au
  ON LOWER(au.email) = LOWER(TRIM(i.user_id))
LEFT JOIN public.isp_user_accounts iua
  ON iua.isp_id = i.id
WHERE NULLIF(TRIM(i.user_id), '') IS NOT NULL
ORDER BY i.name;
