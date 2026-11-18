// auth.repository.js
// Repository layer for user authentication interacting with PostgreSQL via pg pool

const { pool } = require('../config/database');

// Find a user by email
async function findByEmail(email) {
  const query = 'SELECT * FROM users WHERE email = $1';
  const { rows } = await pool.query(query, [email]);
  return rows[0];
}

// Find a user by id
async function findById(id) {
  const query = 'SELECT * FROM users WHERE id = $1';
  const { rows } = await pool.query(query, [id]);
  return rows[0];
}

// Create a new user
async function create(user) {
  const fields = Object.keys(user);
  const values = Object.values(user);
  const placeholders = fields.map((_, idx) => `$${idx + 1}`).join(', ');
  const query = `INSERT INTO users (${fields.join(', ')}) VALUES (${placeholders}) RETURNING *`;
  const { rows } = await pool.query(query, values);
  return rows[0];
}

module.exports = { findByEmail, findById, create };