// error.middleware.js
// Centralized error handling middleware

module.exports = (err, req, res, next) => {
  // Default status and message
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';

  // In production, avoid leaking stack traces
  const response = {
    error: message,
  };

  if (process.env.NODE_ENV !== 'production' && err.stack) {
    response.stack = err.stack;
  }

  res.status(status).json(response);
};