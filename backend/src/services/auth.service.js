// auth.service.js
// Service layer for authentication business logic

const authRepository = require('../repositories/auth.repository');
const { generateToken } = require('../utils/jwt');
const { hashPassword, comparePassword } = require('../utils/password'); // helper functions, will create if missing
const { USER_ROLES } = require('../constants/roles');

// Helper to map role strings to allowed registrations
const ALLOWED_REGISTRATION_ROLES = [USER_ROLES.CUSTOMER, USER_ROLES.MERCHANT, USER_ROLES.SHOPPER];

async function register(data) {
  const { email, password, role, ...rest } = data;

  // Validate role
  if (!ALLOWED_REGISTRATION_ROLES.includes(role)) {
    throw new Error('Invalid role for registration');
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

  // Set initial status based on role
  let status = 'active';
  if (role === USER_ROLES.MERCHANT) {
    status = 'pending'; // requires admin approval
  }

  const user = await authRepository.create({ email, password_hash: passwordHash, role, status, ...rest });
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
