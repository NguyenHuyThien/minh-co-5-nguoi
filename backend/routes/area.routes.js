
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách khu vực của một chợ
  router.get("/markets/:marketId/areas", async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT * FROM market_areas
         WHERE market_id = $1
         ORDER BY name`,
        [req.params.marketId]
      );

      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách khu vực" });
    }
  });

  // Thêm khu vực
  router.post("/markets/:marketId/areas", async (req, res) => {
    try {
      const {
        name,
        description,
        map_image_url,
        map_width,
        map_height
      } = req.body;

      if (!name || !name.trim()) {
        return res.status(400).json({
          message: "Tên khu vực không được để trống"
        });
      }

      const result = await pool.query(
        `INSERT INTO market_areas
         (market_id, name, description, map_image_url, map_width, map_height)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [
          req.params.marketId,
          name.trim(),
          description || null,
          map_image_url || null,
          map_width ?? null,
          map_height ?? null
        ]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi thêm khu vực" });
    }
  });

  // Cập nhật khu vực
  router.put("/areas/:id", async (req, res) => {
    try {
      const {
        name,
        description,
        map_image_url,
        map_width,
        map_height
      } = req.body;

      if (!name || !name.trim()) {
        return res.status(400).json({
          message: "Tên khu vực không được để trống"
        });
      }

      const result = await pool.query(
        `UPDATE market_areas
         SET name = $1,
             description = $2,
             map_image_url = $3,
             map_width = $4,
             map_height = $5
         WHERE id = $6
         RETURNING *`,
        [
          name.trim(),
          description || null,
          map_image_url || null,
          map_width ?? null,
          map_height ?? null,
          req.params.id
        ]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          message: "Không tìm thấy khu vực"
        });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật khu vực" });
    }
  });

  // Xóa khu vực
  router.delete("/areas/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "DELETE FROM market_areas WHERE id = $1 RETURNING id",
        [req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          message: "Không tìm thấy khu vực"
        });
      }

      res.json({ message: "Đã xóa khu vực" });
    } catch (error) {
      if (error.code === "23503") {
        return res.status(409).json({
          message: "Không thể xóa khu vực đang có gian hàng"
        });
      }

      res.status(500).json({ message: "Lỗi xóa khu vực" });
    }
  });

  return router;
};
