// auth.routes.js
// Express router for authentication endpoints

const express = require('express');
const { register, login, me } = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../validators/auth.validator');
const authMiddleware = require('../middleware/auth.middleware');

const router = express.Router();

// Register new user
router.post('/register', validateRegister, register);

// Login user
router.post('/login', validateLogin, login);

// Get current authenticated user
router.get('/me', authMiddleware, me);

module.exports = router;
