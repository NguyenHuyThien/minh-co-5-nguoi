
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách khiếu nại
  router.get("/", async (req, res) => {
    try {
      const { customer_id, order_id, status } = req.query;

      let sql = "SELECT * FROM complaints WHERE 1=1";
      const values = [];

      if (customer_id) {
        values.push(customer_id);
        sql += ` AND customer_id = $${values.length}`;
      }

      if (order_id) {
        values.push(order_id);
        sql += ` AND order_id = $${values.length}`;
      }

      if (status) {
        values.push(status);
        sql += ` AND status = $${values.length}`;
      }

      sql += " ORDER BY created_at DESC";

      const result = await pool.query(sql, values);
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách khiếu nại" });
    }
  });

  // Xem chi tiết khiếu nại và hình ảnh
  router.get("/:id", async (req, res) => {
    try {
      const complaint = await pool.query(
        "SELECT * FROM complaints WHERE id = $1",
        [req.params.id]
      );

      if (complaint.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy khiếu nại" });
      }

      const images = await pool.query(
        "SELECT * FROM complaint_images WHERE complaint_id = $1 ORDER BY created_at",
        [req.params.id]
      );

      res.json({
        ...complaint.rows[0],
        images: images.rows
      });
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy chi tiết khiếu nại" });
    }
  });

  // Tạo khiếu nại
  router.post("/", async (req, res) => {
    const client = await pool.connect();

    try {
      const {
        order_id,
        customer_id,
        title,
        content,
        image_urls = []
      } = req.body;

      if (
        !order_id ||
        !customer_id ||
        !title ||
        !content ||
        !Array.isArray(image_urls)
      ) {
        return res.status(400).json({
          message: "Vui lòng nhập đầy đủ thông tin khiếu nại"
        });
      }

      await client.query("BEGIN");

      const order = await client.query(
        "SELECT id FROM orders WHERE id = $1 AND customer_id = $2",
        [order_id, customer_id]
      );

      if (order.rows.length === 0) {
        throw new Error("Đơn hàng không tồn tại hoặc không thuộc khách hàng");
      }

      const result = await client.query(
        `INSERT INTO complaints
         (order_id, customer_id, title, content)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [order_id, customer_id, title, content]
      );

      const complaint = result.rows[0];

      for (const imageUrl of image_urls) {
        if (typeof imageUrl !== "string" || !imageUrl.trim()) {
          throw new Error("Đường dẫn hình ảnh không hợp lệ");
        }

        await client.query(
          `INSERT INTO complaint_images (complaint_id, image_url)
           VALUES ($1, $2)`,
          [complaint.id, imageUrl]
        );
      }

      await client.query("COMMIT");

      res.status(201).json({
        message: "Gửi khiếu nại thành công",
        complaint
      });
    } catch (error) {
      await client.query("ROLLBACK");
      res.status(400).json({ message: error.message });
    } finally {
      client.release();
    }
  });

  // Cập nhật trạng thái và phản hồi khiếu nại
  router.patch("/:id/status", async (req, res) => {
    try {
      const { status, admin_response } = req.body;

      const allowedStatus = [
        "pending",
        "processing",
        "resolved",
        "rejected"
      ];

      if (!allowedStatus.includes(status)) {
        return res.status(400).json({
          message: "Trạng thái khiếu nại không hợp lệ"
        });
      }

      const result = await pool.query(
        `UPDATE complaints
         SET status = $1,
             admin_response = $2,
             resolved_at = CASE
               WHEN $1 IN ('resolved', 'rejected') THEN NOW()
               ELSE NULL
             END
         WHERE id = $3
         RETURNING *`,
        [status, admin_response || null, req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          message: "Không tìm thấy khiếu nại"
        });
      }

      res.json({
        message: "Cập nhật khiếu nại thành công",
        complaint: result.rows[0]
      });
    } catch (error) {
      res.status(500).json({
        message: "Lỗi cập nhật khiếu nại"
      });
    }
  });

  return router;
};

