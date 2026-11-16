
const express = require("express");

module.exports = (pool) => {
  const router = express.Router();

  // Báo cáo đơn hàng
  router.get("/orders", async (req, res) => {
    try {
      const { from, to } = req.query;
      const values = [];
      let where = "WHERE 1=1";

      if (from) {
        values.push(from);
        where += ` AND created_at >= $${values.length}::date`;
      }

      if (to) {
        values.push(to);
        where += ` AND created_at < ($${values.length}::date + INTERVAL '1 day')`;
      }

      const result = await pool.query(
        `SELECT
           COUNT(*) AS total_orders,
           COUNT(*) FILTER (WHERE status = 'pending') AS pending_orders,
           COUNT(*) FILTER (WHERE status = 'completed') AS completed_orders,
           COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders,
           COALESCE(SUM(total_amount) FILTER (
             WHERE status = 'completed'
           ), 0) AS completed_revenue
         FROM orders
         ${where}`,
        values
      );

      res.json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ message: "Lỗi báo cáo đơn hàng" });
    }
  });

  // Báo cáo sản phẩm bán chạy
  router.get("/products", async (req, res) => {
    try {
      const { from, to } = req.query;
      const values = [];
      let where = "WHERE o.status = 'completed'";

      if (from) {
        values.push(from);
        where += ` AND o.created_at >= $${values.length}::date`;
      }

      if (to) {
        values.push(to);
        where += ` AND o.created_at < ($${values.length}::date + INTERVAL '1 day')`;
      }

      const result = await pool.query(
        `SELECT
           oi.product_id,
           oi.product_name,
           SUM(oi.quantity) AS total_quantity,
           SUM(oi.line_total) AS total_revenue
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         ${where}
         GROUP BY oi.product_id, oi.product_name
         ORDER BY total_quantity DESC`,
        values
      );

      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi báo cáo sản phẩm" });
    }
  });

  // Báo cáo doanh thu theo chợ
  router.get("/markets", async (req, res) => {
    try {
      const { from, to } = req.query;
      const values = [];
      let where = "WHERE o.status = 'completed'";

      if (from) {
        values.push(from);
        where += ` AND o.created_at >= $${values.length}::date`;
      }

      if (to) {
        values.push(to);
        where += ` AND o.created_at < ($${values.length}::date + INTERVAL '1 day')`;
      }

      const result = await pool.query(
        `SELECT
           o.market_id,
           COUNT(*) AS total_orders,
           COALESCE(SUM(o.total_amount), 0) AS total_revenue
         FROM orders o
         ${where}
         GROUP BY o.market_id
         ORDER BY total_revenue DESC`
      , values);

      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ message: "Lỗi báo cáo theo chợ" });
    }
  });

  return router;
};
