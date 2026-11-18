const { randomUUID } = require('crypto');
const { pool } = require('../config/database');
const { config } = require('../config/env');

const MIME_TO_EXTENSION = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

function hasValidImageSignature(buffer, mimeType) {
  if (mimeType === 'image/jpeg') {
    return buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
  }
  if (mimeType === 'image/png') {
    return buffer.length >= 8 && buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]));
  }
  if (mimeType === 'image/webp') {
    return buffer.length >= 12 && buffer.toString('ascii', 0, 4) === 'RIFF' && buffer.toString('ascii', 8, 12) === 'WEBP';
  }
  return false;
}

function getObjectUrl(objectPath) {
  const encodedPath = objectPath.split('/').map(encodeURIComponent).join('/');
  return `${config.SUPABASE_URL.replace(/\/$/, '')}/storage/v1/object/public/${config.STORAGE_BUCKET}/${encodedPath}`;
}

async function uploadToStorage(objectPath, fileBuffer, mimeType) {
  const encodedPath = objectPath.split('/').map(encodeURIComponent).join('/');
  const url = `${config.SUPABASE_URL.replace(/\/$/, '')}/storage/v1/object/${config.STORAGE_BUCKET}/${encodedPath}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      apikey: config.SUPABASE_SECRET_KEY,
      Authorization: `Bearer ${config.SUPABASE_SECRET_KEY}`,
      'Content-Type': mimeType,
      'x-upsert': 'false',
      'cache-control': '3600',
    },
    body: fileBuffer,
  });

  if (!response.ok) {
    const detail = await response.text();
    const error = new Error(`Không thể tải ảnh lên Storage: ${detail}`);
    error.status = response.status >= 500 ? 502 : 400;
    throw error;
  }
}

async function removeFromStorage(objectPath) {
  const encodedPath = objectPath.split('/').map(encodeURIComponent).join('/');
  const url = `${config.SUPABASE_URL.replace(/\/$/, '')}/storage/v1/object/${config.STORAGE_BUCKET}/${encodedPath}`;
  await fetch(url, {
    method: 'DELETE',
    headers: {
      apikey: config.SUPABASE_SECRET_KEY,
      Authorization: `Bearer ${config.SUPABASE_SECRET_KEY}`,
    },
  });
}

async function uploadProductImage(req, res, next) {
  let uploadedPath;

  try {
    if (!config.SUPABASE_URL || !config.SUPABASE_SECRET_KEY) {
      const error = new Error('Backend chưa cấu hình SUPABASE_URL hoặc SUPABASE_SECRET_KEY');
      error.status = 500;
      throw error;
    }

    const { id: productId } = req.params;
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(productId)) {
      return res.status(400).json({ error: 'Mã sản phẩm không hợp lệ' });
    }

    const mimeType = req.headers['content-type'];
    if (!MIME_TO_EXTENSION[mimeType]) {
      return res.status(415).json({ error: 'Chỉ chấp nhận ảnh JPG, PNG hoặc WEBP' });
    }

    if (!Buffer.isBuffer(req.body) || req.body.length === 0) {
      return res.status(400).json({ error: 'Vui lòng gửi dữ liệu ảnh dạng binary' });
    }

    if (!hasValidImageSignature(req.body, mimeType)) {
      return res.status(400).json({ error: 'Nội dung tệp không khớp định dạng ảnh' });
    }

    const productResult = await pool.query(
      `SELECT p.id, s.owner_id
       FROM products p
       JOIN stalls s ON s.id = p.stall_id
       WHERE p.id = $1`,
      [productId]
    );

    if (productResult.rowCount === 0) {
      return res.status(404).json({ error: 'Không tìm thấy sản phẩm' });
    }

    const product = productResult.rows[0];
    const isAdmin = req.user.role === 'admin';
    const isOwner = product.owner_id && product.owner_id === req.user.id;

    if (!isAdmin && !isOwner) {
      return res.status(403).json({ error: 'Bạn không có quyền cập nhật ảnh sản phẩm này' });
    }

    const extension = MIME_TO_EXTENSION[mimeType];
    uploadedPath = `products/${productId}/${randomUUID()}.${extension}`;

    await uploadToStorage(uploadedPath, req.body, mimeType);
    const imageUrl = getObjectUrl(uploadedPath);

    try {
      await pool.query(
        'UPDATE products SET image_url = $1, updated_at = NOW() WHERE id = $2',
        [imageUrl, productId]
      );
    } catch (databaseError) {
      await removeFromStorage(uploadedPath).catch(() => {});
      throw databaseError;
    }

    return res.status(200).json({
      message: 'Tải ảnh sản phẩm thành công',
      product_id: productId,
      image_url: imageUrl,
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = { uploadProductImage };
