
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách sản phẩm
  router.get("/", async (req, res) => {
    try {
      const { stall_id, status } = req.query;

      let sql = `
        SELECT p.*, s.name AS stall_name
        FROM products p
        JOIN stalls s ON p.stall_id = s.id
        WHERE 1=1
      `;
      const values = [];

      if (stall_id) {
        values.push(stall_id);
        sql += ` AND p.stall_id = $${values.length}`;
      }

      if (status) {
        values.push(status);
        sql += ` AND p.status = $${values.length}`;
      } else {
        sql += ` AND p.status = 'approved' AND s.status = 'approved'`;
      }

      sql += " ORDER BY p.created_at DESC";

      const result = await pool.query(sql, values);
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách sản phẩm" });
    }
  });

  // Lấy chi tiết sản phẩm
  router.get("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT p.*, s.name AS stall_name
         FROM products p
         JOIN stalls s ON p.stall_id = s.id
         WHERE p.id = $1`,
        [req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy thông tin sản phẩm" });
    }
  });

  // Thêm sản phẩm
  router.post("/", async (req, res) => {
    try {
      const {
        stall_id,
        name,
        description,
        price,
        unit,
        image_url,
        stock_quantity
      } = req.body;

      if (!stall_id || !name || price == null || Number(price) < 0) {
        return res.status(400).json({ message: "Thông tin sản phẩm không hợp lệ" });
      }

      const stall = await pool.query(
        "SELECT id FROM stalls WHERE id = $1 AND status = 'approved'",
        [stall_id]
      );

      if (stall.rows.length === 0) {
        return res.status(400).json({ message: "Quầy chưa được duyệt hoặc không tồn tại" });
      }

      const result = await pool.query(
        `INSERT INTO products
         (stall_id, name, description, price, unit, image_url, stock_quantity, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending')
         RETURNING *`,
        [
          stall_id,
          name,
          description || null,
          price,
          unit || null,
          image_url || null,
          stock_quantity ?? 0
        ]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi thêm sản phẩm" });
    }
  });

  // Cập nhật sản phẩm
  router.put("/:id", async (req, res) => {
    try {
      const {
        name,
        description,
        price,
        unit,
        image_url,
        stock_quantity
      } = req.body;

      if (!name || price == null || Number(price) < 0) {
        return res.status(400).json({ message: "Thông tin sản phẩm không hợp lệ" });
      }

      const result = await pool.query(
        `UPDATE products
         SET name = $1,
             description = $2,
             price = $3,
             unit = $4,
             image_url = $5,
             stock_quantity = $6
         WHERE id = $7
         RETURNING *`,
        [
          name,
          description || null,
          price,
          unit || null,
          image_url || null,
          stock_quantity ?? 0,
          req.params.id
        ]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật sản phẩm" });
    }
  });

  // Duyệt, ẩn hoặc từ chối sản phẩm
  router.patch("/:id/status", async (req, res) => {
    try {
      const { status } = req.body;
      const allowedStatus = ["pending", "approved", "hidden", "rejected"];

      if (!allowedStatus.includes(status)) {
        return res.status(400).json({ message: "Trạng thái không hợp lệ" });
      }

      const result = await pool.query(
        `UPDATE products
         SET status = $1
         WHERE id = $2
         RETURNING *`,
        [status, req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật trạng thái sản phẩm" });
    }
  });

  // Xóa sản phẩm
  router.delete("/:id", async (req, res) => {
    try {
      const result = await pool.query(
        "DELETE FROM products WHERE id = $1 RETURNING id",
        [req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy sản phẩm" });
      }

      res.json({ message: "Xóa sản phẩm thành công" });
    } catch (error) {
      res.status(500).json({ message: "Lỗi xóa sản phẩm" });
    }
  });

  return router;
};
