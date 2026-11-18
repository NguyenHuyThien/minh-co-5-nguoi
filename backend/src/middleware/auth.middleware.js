// auth.middleware.js
// JWT authentication middleware

const { verifyToken } = require('../utils/jwt');

module.exports = async function (req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      const err = new Error('Authentication token missing');
      err.status = 401;
      throw err;
    }
    const token = authHeader.split(' ')[1];
    const payload = verifyToken(token);
    // Attach user info to request for downstream handlers
    req.user = { id: payload.id, role: payload.role };
    next();
  } catch (error) {
    const err = new Error('Invalid authentication token');
    err.status = 401;
    next(err);
  }
};