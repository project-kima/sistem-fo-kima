const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const customerCount = await prisma.customer.count();
  const ispCount = await prisma.isp.count();
  const invoiceCount = await prisma.invoice.count();
  const invoices2026 = await prisma.invoice.count({ where: { periodYear: 2026 } });
  
  console.log('--- DATABASE STATS ---');
  console.log('Customers:', customerCount);
  console.log('ISPs:', ispCount);
  console.log('Total Invoices:', invoiceCount);
  console.log('Invoices (2026):', invoices2026);
  
  if (invoiceCount > 0) {
    const years = await prisma.invoice.findMany({
      select: { periodYear: true },
      distinct: ['periodYear']
    });
    console.log('Years available in database:', years.map(y => y.periodYear));
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
