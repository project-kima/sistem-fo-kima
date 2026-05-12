-- AlterTable
ALTER TABLE "contract_versions" ADD COLUMN     "monthly_amount" DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN     "remarks" TEXT,
ADD COLUMN     "yearly_amount" DECIMAL(18,2) NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "customers" ADD COLUMN     "notes" TEXT;
