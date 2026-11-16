const { testConnection, closePool } = require('./database');

function sanitize(message) {
  return String(message).replace(/postgres(?:ql)?:\/\/\S+/gi, '[redacted connection string]');
}

async function main() {
  try {
    await testConnection();
    console.log('PostgreSQL connection successful (SELECT 1).');
    process.exitCode = 0;
  } catch (error) {
    console.error('PostgreSQL connection failed.');
    console.error(`Reason: ${sanitize(error.message)}`);

    if (error.code) {
      console.error(`Code: ${error.code}`);
    }

    process.exitCode = 1;
  } finally {
    await closePool();
  }
}

main().catch((error) => {
  console.error(`Unexpected error: ${sanitize(error.message)}`);
  process.exitCode = 1;
});
