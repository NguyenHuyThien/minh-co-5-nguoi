// app.js
// Main Express application setup

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const { config } = require('./config/env');
const authRoutes = require('./routes/auth.routes');
const productImageRoutes = require('./routes/product-image.routes');
const errorMiddleware = require('./middleware/error.middleware');

const app = express();

// Global middlewares
app.use(express.json());
app.use(cors({ origin: config.CORS_ORIGIN }));
app.use(helmet());
app.use(morgan('dev'));

// Register routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productImageRoutes);

// Centralized error handling
app.use(errorMiddleware);

module.exports = app;