const express = require('express');
const authMiddleware = require('../middleware/auth.middleware');
const { uploadProductImage } = require('../controllers/product-image.controller');

const router = express.Router();
const imageBody = express.raw({
  type: ['image/jpeg', 'image/png', 'image/webp'],
  limit: '5mb',
});

router.put('/:id/image', authMiddleware, imageBody, uploadProductImage);

module.exports = router;
