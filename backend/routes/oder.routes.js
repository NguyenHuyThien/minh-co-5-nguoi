
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Lấy danh sách đơn hàng
  router.get("/", async (req, res) => {
    try {
      const { customer_id, shopper_id, status, market_id } = req.query;

      let sql = `
        SELECT o.*,
               u.full_name AS customer_name
        FROM orders o
        LEFT JOIN users u ON u.id = o.customer_id
        WHERE 1=1
      `;
      const values = [];

      if (customer_id) {
        values.push(customer_id);
        sql += ` AND o.customer_id = $${values.length}`;
      }

      if (shopper_id) {
        values.push(shopper_id);
        sql += ` AND o.shopper_id = $${values.length}`;
      }

      if (status) {
        values.push(status);
        sql += ` AND o.status = $${values.length}`;
      }

      if (market_id) {
        values.push(market_id);
        sql += ` AND o.market_id = $${values.length}`;
      }

      sql += " ORDER BY o.created_at DESC";

      const result = await pool.query(sql, values);
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy danh sách đơn hàng" });
    }
  });

  // Xem chi tiết đơn hàng và các mặt hàng
  router.get("/:id", async (req, res) => {
    try {
      const order = await pool.query(
        "SELECT * FROM orders WHERE id = $1",
        [req.params.id]
      );

      if (order.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
      }

      const items = await pool.query(
        "SELECT * FROM order_items WHERE order_id = $1",
        [req.params.id]
      );

      res.json({
        ...order.rows[0],
        items: items.rows
      });
    } catch (error) {
      res.status(500).json({ message: "Lỗi lấy chi tiết đơn hàng" });
    }
  });

  // Tạo đơn hàng
  router.post("/", async (req, res) => {
    const client = await pool.connect();

    try {
      const {
        market_id,
        customer_id,
        delivery_address,
        delivery_note,
        delivery_slot,
        delivery_fee = 0,
        items
      } = req.body;

      if (
        !market_id ||
        !customer_id ||
        !delivery_address ||
        !Array.isArray(items) ||
        items.length === 0
      ) {
        return res.status(400).json({
          message: "Vui lòng nhập đầy đủ thông tin đơn hàng"
        });
      }

      if (!Number.isFinite(Number(delivery_fee)) || Number(delivery_fee) < 0) {
        return res.status(400).json({ message: "Phí giao hàng không hợp lệ" });
      }

      for (const item of items) {
        if (
          !item.product_id ||
          !Number.isInteger(Number(item.quantity)) ||
          Number(item.quantity) <= 0
        ) {
          return res.status(400).json({
            message: "Thông tin mặt hàng hoặc số lượng không hợp lệ"
          });
        }
      }

      await client.query("BEGIN");

      const productIds = items.map(item => item.product_id);

      const products = await client.query(
        `SELECT p.id, p.name, p.price, p.stall_id,
                s.market_id, s.status AS stall_status,
                p.status AS product_status
         FROM products p
         JOIN stalls s ON s.id = p.stall_id
         WHERE p.id = ANY($1::uuid[])
         FOR UPDATE OF p`,
        [productIds]
      );

      if (products.rows.length !== new Set(productIds).size) {
        throw new Error("Có sản phẩm không tồn tại");
      }

      const productMap = new Map(
        products.rows.map(product => [product.id, product])
      );

      let subtotal = 0;
      const orderItems = [];

      for (const item of items) {
        const product = productMap.get(item.product_id);

        if (
          product.market_id !== market_id ||
          product.stall_status !== "approved" ||
          product.product_status !== "approved"
        ) {
          throw new Error(
            `Sản phẩm ${product.name} không còn khả dụng`
          );
        }

        const unitPrice = Number(product.price);
        const quantity = Number(item.quantity);
        const lineTotal = unitPrice * quantity;

        subtotal += lineTotal;

        orderItems.push({
          product_id: product.id,
          stall_id: product.stall_id,
          product_name: product.name,
          unit_price: unitPrice,
          quantity,
          note: item.note || null,
          line_total: lineTotal
        });
      }

      const fee = Number(delivery_fee);
      const totalAmount = subtotal + fee;

      const order = await client.query(
        `INSERT INTO orders
         (market_id, customer_id, delivery_address, delivery_note,
          delivery_slot, subtotal, delivery_fee, total_amount, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending')
         RETURNING *`,
        [
          market_id,
          customer_id,
          delivery_address,
          delivery_note || null,
          delivery_slot || null,
          subtotal,
          fee,
          totalAmount
        ]
      );

      for (const item of orderItems) {
        await client.query(
          `INSERT INTO order_items
           (order_id, product_id, stall_id, product_name,
            unit_price, quantity, note, line_total)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            order.rows[0].id,
            item.product_id,
            item.stall_id,
            item.product_name,
            item.unit_price,
            item.quantity,
            item.note,
            item.line_total
          ]
        );
      }

      await client.query("COMMIT");

      res.status(201).json({
        message: "Tạo đơn hàng thành công",
        order: order.rows[0],
        items: orderItems
      });
    } catch (error) {
      await client.query("ROLLBACK");
      res.status(400).json({ message: error.message });
    } finally {
      client.release();
    }
  });

  // Cập nhật trạng thái đơn hàng
  router.patch("/:id/status", async (req, res) => {
    try {
      const { status } = req.body;

      const allowedStatus = [
        "pending",
        "confirmed",
        "preparing",
        "ready",
        "delivering",
        "completed",
        "cancelled"
      ];

      if (!allowedStatus.includes(status)) {
        return res.status(400).json({
          message: "Trạng thái đơn hàng không hợp lệ"
        });
      }

      const result = await pool.query(
        `UPDATE orders
         SET status = $1, updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [status, req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
      }

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi cập nhật trạng thái đơn hàng" });
    }
  });

  // Gán người đi chợ
  router.patch("/:id/assign", async (req, res) => {
    try {
      const { shopper_id } = req.body;

      if (!shopper_id) {
        return res.status(400).json({
          message: "Vui lòng chọn người đi chợ"
        });
      }

      const result = await pool.query(
        `UPDATE orders
         SET shopper_id = $1, updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [shopper_id, req.params.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy đơn hàng" });
      }

      res.json({
        message: "Gán người đi chợ thành công",
        order: result.rows[0]
      });
    } catch (error) {
      res.status(500).json({ message: "Lỗi gán người đi chợ" });
    }
  });

  return router;
};
