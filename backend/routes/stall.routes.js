
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách gian hàng
  router.get("/", async (req, res) => {
    try {
      const { market_id, area_id } = req.query;

      const result = await pool.query(
        `SELECT * FROM stalls
         WHERE ($1::uuid IS NULL OR market_id = $1)
         AND ($2::uuid IS NULL OR area_id = $2)
         ORDER BY stall_code`,
        [market_id || null, area_id || null]
      );

      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách gian hàng" });
    }
  });

  // Lấy chi tiết gian hàng
  router.get("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "SELECT * FROM stalls WHERE id = $1",
        [req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy gian hàng" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy thông tin gian hàng" });
    }
  });

  // Thêm gian hàng
  router.post("/", async (req, res) => {
    try {
      const {
        market_id, area_id, stall_code,
        name, description, owner_id, map_x, map_y
      } = req.body;

      if (!market_id || !area_id || !stall_code || !name) {
        return res.status(400).json({
          message: "Vui lòng nhập đầy đủ thông tin bắt buộc"
        });
      }

      const area = await pool.query(
        `SELECT id FROM market_areas
         WHERE id = $1 AND market_id = $2`,
        [area_id, market_id]
      );

      if (area.rowCount === 0) {
        return res.status(400).json({
          message: "Khu vực không thuộc chợ đã chọn"
        });
      }

      const result = await pool.query(
        `INSERT INTO stalls
         (market_id, area_id, stall_code, name, description,
          owner_id, map_x, map_y)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
         RETURNING *`,
        [
          market_id, area_id, stall_code, name,
          description || null, owner_id || null,
          map_x ?? null, map_y ?? null
        ]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      if (error.code === "23505") {
        return res.status(409).json({
          message: "Mã gian hàng đã tồn tại trong chợ"
        });
      }
      res.status(500).json({ message: "Lỗi thêm gian hàng" });
    }
  });

  // Cập nhật gian hàng
  router.put("/:id", async (req, res) => {
    try {
      const {
        stall_code, name, description,
        area_id, map_x, map_y
      } = req.body;

      if (!stall_code || !name || !area_id) {
        return res.status(400).json({
          message: "Vui lòng nhập mã, tên và khu vực gian hàng"
        });
      }

      const result = await pool.query(
        `UPDATE stalls
         SET stall_code = $1, name = $2, description = $3,
             area_id = $4, map_x = $5, map_y = $6
         WHERE id = $7
         AND EXISTS (
           SELECT 1 FROM market_areas a
           WHERE a.id = $4 AND a.market_id = stalls.market_id
         )
         RETURNING *`,
        [
          stall_code, name, description || null,
          area_id, map_x ?? null, map_y ?? null,
          req.params.id
        ]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          message: "Không tìm thấy gian hàng hoặc khu vực không hợp lệ"
        });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật gian hàng" });
    }
  });

  // Cập nhật trạng thái gian hàng
  router.patch("/:id/status", async (req, res) => {
    try {
      const { status } = req.body;
      const allowed = ["pending", "approved", "locked", "rejected"];

      if (!allowed.includes(status)) {
        return res.status(400).json({
          message: "Trạng thái gian hàng không hợp lệ"
        });
      }

      const result = await pool.query(
        `UPDATE stalls SET status = $1
         WHERE id = $2 RETURNING *`,
        [status, req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy gian hàng" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật trạng thái" });
    }
  });

  // Xóa gian hàng
  router.delete("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "DELETE FROM stalls WHERE id = $1 RETURNING id",
        [req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy gian hàng" });
      }

      res.json({ message: "Đã xóa gian hàng" });
    } catch (error) {
      if (error.code === "23503") {
        return res.status(409).json({
          message: "Không thể xóa gian hàng đang có sản phẩm"
        });
      }
      res.status(500).json({ message: "Lỗi xóa gian hàng" });
    }
  });

  return router;
};
