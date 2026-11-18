// utils/jwt.js
// JWT utility functions
const jwt = require('jsonwebtoken');
const { config, assertRequiredVariables, JWT_REQUIRED_VARS } = require('../config/env');

// Ensure JWT env vars are present before using them
assertRequiredVariables(JWT_REQUIRED_VARS);

function generateToken(payload) {
  return jwt.sign(payload, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });
}

function verifyToken(token) {
  return jwt.verify(token, config.JWT_SECRET);
}

module.exports = { generateToken, verifyToken };
