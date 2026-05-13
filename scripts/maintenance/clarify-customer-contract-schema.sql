-- Clarify customer contract document package fields.
-- Run after package data is cleaned. Constraints are NOT VALID first for safer production rollout.
-- Business rule: contracts represent real contract/BAK documents and are the source of truth for package, period, and contract number.
-- contract_versions are optional snapshots/amendments, not the primary source for normal contract rows.

BEGIN;

COMMENT ON TABLE contracts IS 'Customer contract/BAK document. For customer package display, this table is the source of truth per contract document.';
COMMENT ON COLUMN contracts.core_type IS 'Customer package for this contract document: core or sharing_core.';
COMMENT ON COLUMN contracts.core_total IS 'Dedicated core quantity. Use only when core_type = core.';
COMMENT ON COLUMN contracts.sharing_ratio IS 'Sharing core ratio such as 1/32. Use only when core_type = sharing_core.';

COMMENT ON TABLE contract_versions IS 'Optional snapshot/amendment detail for a customer contract document. Normal contract rows should read package fields from contracts first.';
COMMENT ON COLUMN contract_versions.core_type IS 'Package snapshot for this contract version: core or sharing_core.';
COMMENT ON COLUMN contract_versions.core_total IS 'Dedicated core quantity snapshot. Use only when core_type = core.';
COMMENT ON COLUMN contract_versions.shared_core_ratio IS 'Sharing core ratio snapshot such as 1/32. Use only when core_type = sharing_core.';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'contracts_core_type_allowed'
      AND conrelid = 'contracts'::regclass
  ) THEN
    ALTER TABLE contracts
      ADD CONSTRAINT contracts_core_type_allowed
      CHECK (core_type IS NULL OR core_type IN ('core', 'sharing_core')) NOT VALID;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'contract_versions_core_type_allowed'
      AND conrelid = 'contract_versions'::regclass
  ) THEN
    ALTER TABLE contract_versions
      ADD CONSTRAINT contract_versions_core_type_allowed
      CHECK (core_type IS NULL OR core_type IN ('core', 'sharing_core')) NOT VALID;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'contracts_package_shape_valid'
      AND conrelid = 'contracts'::regclass
  ) THEN
    ALTER TABLE contracts
      ADD CONSTRAINT contracts_package_shape_valid
      CHECK (
        core_type IS NULL
        OR (
          core_type = 'sharing_core'
          AND sharing_ratio IS NOT NULL
          AND sharing_ratio <> ''
          AND (core_total IS NULL OR core_total = 0)
        )
        OR (
          core_type = 'core'
          AND core_total IS NOT NULL
          AND core_total > 0
          AND sharing_ratio IS NULL
        )
      ) NOT VALID;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'contract_versions_package_shape_valid'
      AND conrelid = 'contract_versions'::regclass
  ) THEN
    ALTER TABLE contract_versions
      ADD CONSTRAINT contract_versions_package_shape_valid
      CHECK (
        core_type IS NULL
        OR (
          core_type = 'sharing_core'
          AND shared_core_ratio IS NOT NULL
          AND shared_core_ratio <> ''
          AND (core_total IS NULL OR core_total = 0)
        )
        OR (
          core_type = 'core'
          AND core_total IS NOT NULL
          AND core_total > 0
          AND shared_core_ratio IS NULL
        )
      ) NOT VALID;
  END IF;
END $$;

-- Audit rows that violate the intended package shape.
SELECT
  'contracts_invalid_package_shape' AS audit_type,
  ct.id,
  c.name AS customer_name,
  ct.contract_number,
  ct.core_type,
  ct.core_total,
  ct.sharing_ratio
FROM contracts ct
JOIN customers c ON c.id = ct.customer_id
WHERE NOT (
  ct.core_type IS NULL
  OR (
    ct.core_type = 'sharing_core'
    AND ct.sharing_ratio IS NOT NULL
    AND ct.sharing_ratio <> ''
    AND (ct.core_total IS NULL OR ct.core_total = 0)
  )
  OR (
    ct.core_type = 'core'
    AND ct.core_total IS NOT NULL
    AND ct.core_total > 0
    AND ct.sharing_ratio IS NULL
  )
)
ORDER BY c.name, ct.end_date DESC;

SELECT
  'contract_versions_invalid_package_shape' AS audit_type,
  cv.id,
  c.name AS customer_name,
  ct.contract_number,
  cv.version_number,
  cv.core_type,
  cv.core_total,
  cv.shared_core_ratio
FROM contract_versions cv
JOIN contracts ct ON ct.id = cv.contract_id
JOIN customers c ON c.id = cv.customer_id
WHERE NOT (
  cv.core_type IS NULL
  OR (
    cv.core_type = 'sharing_core'
    AND cv.shared_core_ratio IS NOT NULL
    AND cv.shared_core_ratio <> ''
    AND (cv.core_total IS NULL OR cv.core_total = 0)
  )
  OR (
    cv.core_type = 'core'
    AND cv.core_total IS NOT NULL
    AND cv.core_total > 0
    AND cv.shared_core_ratio IS NULL
  )
)
ORDER BY c.name, ct.end_date DESC, cv.version_number DESC;

WITH latest_versions AS (
  SELECT DISTINCT ON (cv.contract_id)
    cv.*
  FROM contract_versions cv
  ORDER BY cv.contract_id, cv.version_number DESC, cv.end_date DESC, cv.start_date DESC
)
SELECT
  'contract_latest_version_parent_mismatch' AS audit_type,
  lv.id AS version_id,
  c.name AS customer_name,
  ct.contract_number,
  lv.version_number,
  ct.core_type AS contract_core_type,
  lv.core_type AS version_core_type,
  ct.core_total AS contract_core_total,
  lv.core_total AS version_core_total,
  ct.sharing_ratio AS contract_sharing_ratio,
  lv.shared_core_ratio AS version_shared_core_ratio
FROM latest_versions lv
JOIN contracts ct ON ct.id = lv.contract_id
JOIN customers c ON c.id = lv.customer_id
WHERE COALESCE(ct.core_type::text, '') <> COALESCE(lv.core_type::text, '')
   OR COALESCE(ct.core_total, -1) <> COALESCE(lv.core_total, -1)
   OR COALESCE(ct.sharing_ratio, '') <> COALESCE(lv.shared_core_ratio, '')
ORDER BY c.name, ct.end_date DESC, lv.version_number DESC;

-- After all audit queries return expected results, run these manually:
-- ALTER TABLE contracts VALIDATE CONSTRAINT contracts_core_type_allowed;
-- ALTER TABLE contracts VALIDATE CONSTRAINT contracts_package_shape_valid;
-- ALTER TABLE contract_versions VALIDATE CONSTRAINT contract_versions_core_type_allowed;
-- ALTER TABLE contract_versions VALIDATE CONSTRAINT contract_versions_package_shape_valid;

COMMIT;
