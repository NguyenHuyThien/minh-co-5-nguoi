
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách chợ
  router.get("/", async (req, res) => {
    try {
      const result = await pool.query(
        "SELECT * FROM markets ORDER BY created_at DESC"
      );
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách chợ" });
    }
  });

  // Lấy thông tin một chợ
  router.get("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "SELECT * FROM markets WHERE id = $1",
        [req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy chợ" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy thông tin chợ" });
    }
  });

  // Thêm chợ
  router.post("/", async (req, res) => {
    try {
      const { name, address, description, latitude, longitude } = req.body;

      if (!name || !address) {
        return res.status(400).json({
          message: "Tên chợ và địa chỉ không được để trống"
        });
      }

      const result = await pool.query(
        `INSERT INTO markets
        (name, address, description, latitude, longitude)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *`,
        [name, address, description || null,
         latitude ?? null, longitude ?? null]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi thêm chợ" });
    }
  });

  // Cập nhật chợ
  router.put("/:id", async (req, res) => {
    try {
      const { name, address, description, latitude, longitude, status } = req.body;

      if (!name || !address) {
        return res.status(400).json({
          message: "Tên chợ và địa chỉ không được để trống"
        });
      }

      if (status && !["active", "inactive"].includes(status)) {
        return res.status(400).json({ message: "Trạng thái không hợp lệ" });
      }

      const result = await pool.query(
        `UPDATE markets
        SET name = $1, address = $2, description = $3,
            latitude = $4, longitude = $5, status = COALESCE($6, status)
        WHERE id = $7
        RETURNING *`,
        [name, address, description || null,
         latitude ?? null, longitude ?? null,
         status || null, req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy chợ" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật chợ" });
    }
  });

  // Xóa chợ
  router.delete("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "DELETE FROM markets WHERE id = $1 RETURNING id",
        [req.params.id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({ message: "Không tìm thấy chợ" });
      }

      res.json({ message: "Đã xóa chợ" });
    } catch (error) {
      if (error.code === "23503") {
        return res.status(409).json({
          message: "Không thể xóa chợ vì đang có dữ liệu liên quan"
        });
      }

      res.status(500).json({ message: "Lỗi xóa chợ" });
    }
  });

  return router;
};

