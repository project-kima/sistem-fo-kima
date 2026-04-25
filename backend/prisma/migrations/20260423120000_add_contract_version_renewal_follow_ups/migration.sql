CREATE TABLE "contract_version_renewal_follow_ups" (
    "id" SERIAL NOT NULL,
    "version_id" INTEGER NOT NULL,
    "split_order" INTEGER NOT NULL,
    "source" "isp_renewal_follow_up_source" NOT NULL,
    "trigger_code" VARCHAR(120),
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "status" "isp_renewal_follow_up_status" NOT NULL,
    "renewal_file_url" TEXT,
    "renewal_file_name" VARCHAR(255),
    "response_file_url" TEXT,
    "response_file_name" VARCHAR(255),
    "response_decision" "isp_renewal_response_decision",
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contract_version_renewal_follow_ups_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "uq_contract_version_renewal_follow_ups_version_split_order"
    ON "contract_version_renewal_follow_ups"("version_id", "split_order");

CREATE INDEX "idx_contract_version_renewal_follow_ups_status"
    ON "contract_version_renewal_follow_ups"("status");

ALTER TABLE "contract_version_renewal_follow_ups"
    ADD CONSTRAINT "contract_version_renewal_follow_ups_version_id_fkey"
    FOREIGN KEY ("version_id") REFERENCES "contract_versions"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
