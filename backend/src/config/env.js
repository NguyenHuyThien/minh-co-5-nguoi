const path = require('path');
const fs = require('fs');
const dotenv = require('dotenv');

const envFilePath = path.resolve(__dirname, '../../.env');

if (fs.existsSync(envFilePath)) {
  const result = dotenv.config({ path: envFilePath, quiet: true });

  if (result.error) {
    throw new Error(`Unable to load environment file: ${envFilePath}`);
  }
}

const REQUIRED_APP_VARS = [
  'DATABASE_URL',
  'SUPABASE_URL',
  'SUPABASE_SECRET_KEY',
  'JWT_SECRET',
  'JWT_EXPIRES_IN',
];

const DATABASE_REQUIRED_VARS = ['DATABASE_URL'];
const JWT_REQUIRED_VARS = ['JWT_SECRET', 'JWT_EXPIRES_IN'];
const STORAGE_REQUIRED_VARS = ['SUPABASE_URL', 'SUPABASE_SECRET_KEY'];

function parsePort(rawPort) {
  if (rawPort === undefined || String(rawPort).trim() === '') {
    return 3000;
  }

  const value = String(rawPort).trim();

  if (!/^\d+$/.test(value)) {
    throw new Error('PORT must be an integer between 1 and 65535');
  }

  const port = Number(value);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535');
  }

  return port;
}

function isPostgresUrl(value) {
  try {
    const parsed = new URL(value);
    return parsed.protocol === 'postgresql:' || parsed.protocol === 'postgres:';
  } catch (error) {
    return false;
  }
}

function isHttpUrl(value) {
  try {
    const parsed = new URL(value);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch (error) {
    return false;
  }
}

const config = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parsePort(process.env.PORT),
  DATABASE_URL: process.env.DATABASE_URL || '',
  SUPABASE_URL: process.env.SUPABASE_URL || '',
  SUPABASE_SECRET_KEY: process.env.SUPABASE_SECRET_KEY || '',
  JWT_SECRET: process.env.JWT_SECRET || '',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '',
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
};

function getMissingVariables(names) {
  return names.filter((name) => {
    const value = process.env[name];
    return value === undefined || String(value).trim() === '';
  });
}

function assertRequiredVariables(names = REQUIRED_APP_VARS) {
  const missing = getMissingVariables(names);

  if (missing.length > 0) {
    throw new Error(`Missing required environment variable(s): ${missing.join(', ')}`);
  }

  if (names.includes('DATABASE_URL') && !isPostgresUrl(config.DATABASE_URL)) {
    throw new Error(
      'DATABASE_URL must be a valid PostgreSQL connection string (postgresql://...). URL-encode special characters in the password.'
    );
  }

  if (names.includes('SUPABASE_URL') && !isHttpUrl(config.SUPABASE_URL)) {
    throw new Error('SUPABASE_URL must be a valid http(s) URL');
  }
}

assertRequiredVariables(DATABASE_REQUIRED_VARS);

module.exports = {
  config,
  envFilePath,
  REQUIRED_APP_VARS,
  DATABASE_REQUIRED_VARS,
  JWT_REQUIRED_VARS,
  STORAGE_REQUIRED_VARS,
  getMissingVariables,
  assertRequiredVariables,
};
