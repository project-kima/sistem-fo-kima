-- Map ISP auth users to public.isps (1 user = 1 ISP)
-- Jalankan setelah:
-- 1) Auth users sudah dibuat
-- 2) Script RLS sudah dijalankan (membuat table public.isp_user_accounts)
-- 3) Data ISP sudah tersedia di public.isps

-- Contoh mapping: email user ISP -> nama ISP
WITH mapping_input AS (
  SELECT 'isp@kima.local'::TEXT AS email, 'PT Cendikia Global Solusi'::TEXT AS isp_name
),
resolved AS (
  SELECT
    au.id AS auth_user_id,
    i.id AS isp_id
  FROM mapping_input m
  JOIN auth.users au
    ON LOWER(au.email) = LOWER(m.email)
  JOIN public.isps i
    ON i.name = m.isp_name
)
INSERT INTO public.isp_user_accounts (auth_user_id, isp_id, created_at, updated_at)
SELECT auth_user_id, isp_id, NOW(), NOW()
FROM resolved
ON CONFLICT (auth_user_id)
DO UPDATE SET
  isp_id = EXCLUDED.isp_id,
  updated_at = NOW();

-- Verifikasi mapping user -> ISP
SELECT
  iua.id,
  au.email,
  i.name AS isp_name,
  iua.created_at,
  iua.updated_at
FROM public.isp_user_accounts iua
JOIN auth.users au ON au.id = iua.auth_user_id
JOIN public.isps i ON i.id = iua.isp_id
ORDER BY au.email;
