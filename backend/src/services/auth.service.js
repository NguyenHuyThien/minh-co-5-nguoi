// auth.service.js
// Service layer for authentication business logic

const authRepository = require('../repositories/auth.repository');
const { generateToken } = require('../utils/jwt');
const { hashPassword, comparePassword } = require('../utils/password'); // helper functions, will create if missing
const { USER_ROLES } = require('../constants/roles');

// Helper to map role strings to allowed registrations
const ALLOWED_REGISTRATION_ROLES = [USER_ROLES.CUSTOMER, USER_ROLES.MERCHANT, USER_ROLES.SHOPPER];

async function register(data) {
  const { email, password, role, full_name, phone } = data;

  // Validate role
  if (!ALLOWED_REGISTRATION_ROLES.includes(role)) {
    throw new Error('Invalid role for registration');
  }

  // full_name is required by the database schema
  if (!full_name || String(full_name).trim() === '') {
    const err = new Error('Full name is required');
    err.status = 400;
    throw err;
  }

  // Check email existence
  const existing = await authRepository.findByEmail(email);
  if (existing) {
    const err = new Error('Email already exists');
    err.code = 'EMAIL_EXISTS';
    throw err;
  }

  // Hash password
  const passwordHash = await hashPassword(password);

  // Users always start as 'active' (database only allows 'active' | 'locked').
  // Merchant approval is tracked via the stall_applications table, not users.status.
  const userPayload = {
    email,
    password_hash: passwordHash,
    role,
    status: 'active',
    full_name: full_name.trim(),
  };

  // Include phone only if provided
  if (phone && String(phone).trim() !== '') {
    userPayload.phone = String(phone).trim();
  }

  const user = await authRepository.create(userPayload);
  // Remove secret fields before returning
  const { password_hash, ...safeUser } = user;
  return safeUser;
}

async function login({ email, password }) {
  const user = await authRepository.findByEmail(email);
  if (!user) {
    const err = new Error('Invalid credentials');
    err.code = 'INVALID_CREDENTIALS';
    throw err;
  }

  const match = await comparePassword(password, user.password_hash);
  if (!match) {
    const err = new Error('Invalid credentials');
    err.code = 'INVALID_CREDENTIALS';
    throw err;
  }

  // Check account status (e.g., merchant pending)
  if (user.status && user.status !== 'active') {
    const err = new Error('Account not active');
    err.code = 'ACCOUNT_INACTIVE';
    throw err;
  }

  const token = generateToken({ id: user.id, role: user.role });
  const { password_hash, ...safeUser } = user;
  return { token, user: safeUser };
}

async function getUserById(id) {
  const user = await authRepository.findById(id);
  if (!user) {
    const err = new Error('User not found');
    err.code = 'USER_NOT_FOUND';
    throw err;
  }
  const { password_hash, ...safeUser } = user;
  return safeUser;
}

module.exports = { register, login, getUserById };
