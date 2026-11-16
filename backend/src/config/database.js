const { Pool } = require('pg');
const { config } = require('./env');

function hasSslMode(connectionString) {
  return /[?&]sslmode=/i.test(connectionString);
}

function buildPoolOptions() {
  const options = {
    connectionString: config.DATABASE_URL,
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
    application_name: 'cho-truyen-thong-backend',
  };

  // Supabase recommends SSL for shared pooler connections. `rejectUnauthorized: false`
  // is equivalent to `sslmode=require` (encrypted, no CA verification), which is the
  // recommended default unless the project supplies the Supabase root certificate:
  // https://supabase.com/docs/guides/database/connecting-to-postgres#ssl
  // If sslmode is present in DATABASE_URL, let pg-connection-string handle it.
  if (!hasSslMode(config.DATABASE_URL)) {
    options.ssl = { rejectUnauthorized: false };
  }

  return options;
}

const pool = new Pool(buildPoolOptions());

pool.on('error', (error) => {
  console.error(`[database] Unexpected idle client error: ${error.message}`);
});

async function testConnection() {
  try {
    await pool.query('SELECT 1');
  } catch (error) {
    const wrappedError = new Error(`PostgreSQL connection failed: ${error.message}`);
    wrappedError.code = error.code;
    throw wrappedError;
  }
}

let isPoolClosed = false;

async function closePool() {
  if (isPoolClosed) {
    return;
  }

  isPoolClosed = true;

  try {
    await pool.end();
  } catch (error) {
    console.error(`[database] Error while closing pool: ${error.message}`);
  }
}

function handleShutdown(signal) {
  console.log(`[database] Received ${signal}. Closing PostgreSQL pool...`);
  closePool().finally(() => process.exit(0));
}

process.once('SIGINT', handleShutdown);
process.once('SIGTERM', handleShutdown);

module.exports = {
  pool,
  testConnection,
  closePool,
};
