const fs = require('fs');

async function run() {
  const isps = [
    { id: 22, name: 'PT Fiber Networks Indonesia' },
    { id: 10, name: 'PT Indonesia Comnets Plus' },
    { id: 11, name: 'PT Aplikanusa Lintasarta' },
    { id: 12, name: 'PT Medialink Global Mandiri' },
    { id: 20, name: 'PT Lado Tekno Parkir' },
    { id: 21, name: 'PT Indonesian Satellite Corporation (PT Indosat Tbk)' },
    { id: 28, name: 'PT Iforte Solusi Infotek' },
    { id: 29, name: 'PT Telekomunikasi Indonesia' },
    { id: 30, name: 'PT Mora Telematika Indonesia' },
    { id: 31, name: 'PT Jenius Lintas Nusantara' },
    { id: 32, name: 'PT Multitech Infomedia' },
    { id: 33, name: 'PT Panca Karsa Sejahtera' },
    { id: 4, name: 'PT Cendikia Global Solusi' },
    { id: 34, name: 'PT Citra Prima Media' },
    { id: 23, name: 'PT XL Axiata Tbk' },
    { id: 36, name: 'PT Inet Global' }
  ];

  for (const isp of isps) {
    const payload = {
      p_isp_id: isp.id,
      p_email: `isp.${isp.id}@kima.local`,
      p_password: 'Isp@2026',
      p_name: isp.name
    };

    console.log(`Migrating ${isp.name}...`);
    const response = await fetch(`https://jkzjqzskrzcdmahrikwm.supabase.co/rest/v1/rpc/upsert_isp_account`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': process.env.SUPABASE_SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      const err = await response.text();
      console.error(`Failed for ${isp.name}:`, err);
    } else {
      console.log(`Success for ${isp.name}`);
    }
  }
}

run();