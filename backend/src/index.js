// index.js
// Entry point to start the Backend server

const app = require('./app');
const { testConnection } = require('./config/database');
const { config } = require('./config/env');

async function startServer() {
  try {
    // Verify database connectivity before starting
    await testConnection();
    console.log('✅ PostgreSQL connection successful');
  } catch (err) {
    console.error('❌ Failed to connect to PostgreSQL:', err.message);
    process.exit(1);
  }

  const port = config.PORT || 3000;
  app.listen(port, () => {
    console.log(`🚀 Server running on http://localhost:${port}`);
  });
}

startServer();
