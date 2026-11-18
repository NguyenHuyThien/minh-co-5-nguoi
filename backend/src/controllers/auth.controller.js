// auth.controller.js
// Controller layer for authentication
// Receives request, calls service, returns response

const authService = require('../services/auth.service');

// Register new user
async function register(req, res, next) {
  try {
    const result = await authService.register(req.body);
    res.status(201).json({ user: result });
  } catch (err) {
    next(err);
  }
}

// Login user
async function login(req, res, next) {
  try {
    const { token, user } = await authService.login(req.body);
    res.json({ token, user });
  } catch (err) {
    next(err);
  }
}

// Get current user
async function me(req, res, next) {
  try {
    const user = await authService.getUserById(req.user.id);
    res.json({ user });
  } catch (err) {
    next(err);
  }
}

module.exports = { register, login, me };
