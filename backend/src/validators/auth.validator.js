// auth.validator.js
// Simple validation middleware for authentication endpoints

function validateEmail(email) {
  const re = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  return re.test(email);
}

function validateRegister(req, res, next) {
  const { email, password, role, full_name } = req.body;
  const errors = [];

  if (!full_name || String(full_name).trim() === '') errors.push('Full name is required');

  if (!email) errors.push('Email is required');
  else if (!validateEmail(email)) errors.push('Invalid email format');

  if (!password) errors.push('Password is required');
  else if (password.length < 8) errors.push('Password must be at least 8 characters');

  const allowedRoles = ['customer', 'merchant', 'shopper'];
  if (!role) errors.push('Role is required');
  else if (!allowedRoles.includes(role)) errors.push('Invalid role');

  if (errors.length > 0) {
    const err = new Error(errors.join('; '));
    err.status = 400;
    return next(err);
  }
  next();
}

function validateLogin(req, res, next) {
  const { email, password } = req.body;
  const errors = [];
  if (!email) errors.push('Email is required');
  else if (!validateEmail(email)) errors.push('Invalid email format');
  if (!password) errors.push('Password is required');

  if (errors.length > 0) {
    const err = new Error(errors.join('; '));
    err.status = 400;
    return next(err);
  }
  next();
}

module.exports = { validateRegister, validateLogin };
