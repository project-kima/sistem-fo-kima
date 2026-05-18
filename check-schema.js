const { Client } = require('pg');

async function check() {
  const connectionString = process.env.DATABASE_URL_POOLER + "?options=reference%3Djkzjqzskrzcdmahrikwm";
  const client = new Client({
    connectionString: connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    const res = await client.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'isps'");
    console.log(res.rows);
  } catch (err) {
    console.error(err);
  } finally {
    await client.end();
  }
}
check();