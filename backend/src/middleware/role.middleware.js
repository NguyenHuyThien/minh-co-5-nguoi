// role.middleware.js
// Middleware to enforce user role(s) for protected routes

module.exports = function (allowedRoles) {
  return function (req, res, next) {
    try {
      if (!req.user || !req.user.role) {
        const err = new Error('User role not found');
        err.status = 403;
        throw err;
      }
      if (!allowedRoles.includes(req.user.role)) {
        const err = new Error('Forbidden: insufficient role');
        err.status = 403;
        throw err;
      }
      next();
    } catch (error) {
      next(error);
    }
  };
};