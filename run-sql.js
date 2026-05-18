const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function run() {
  let connectionString = process.env.DATABASE_URL_POOLER;
  connectionString = connectionString + "?options=reference%3Djkzjqzskrzcdmahrikwm";
  const client = new Client({
    connectionString: connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('Connected to database.');

    // 1. Run RPC script
    const rpcSql = fs.readFileSync(path.join(__dirname, 'scripts', 'auth', 'rpc-upsert-isp-account.sql'), 'utf8');
    await client.query(rpcSql);
    console.log('RPC created successfully.');

    // 2. Run Migration script
    const migrateSql = fs.readFileSync(path.join(__dirname, 'scripts', 'auth', 'migrate-existing-isps-to-auth.sql'), 'utf8');
    await client.query(migrateSql);
    console.log('Accounts migrated successfully.');

  } catch (err) {
    console.error('Database error:', err);
  } finally {
    await client.end();
  }
}

run();