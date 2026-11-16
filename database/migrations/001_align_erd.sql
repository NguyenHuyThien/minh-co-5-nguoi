-- Migration: align current database with updated ERD
-- Run once on an existing database after taking a backup.
BEGIN;

CREATE TABLE IF NOT EXISTS price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    old_price NUMERIC(12,2) NOT NULL CHECK (old_price >= 0),
    new_price NUMERIC(12,2) NOT NULL CHECK (new_price >= 0),
    changed_by UUID REFERENCES users(id),
    effective_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE stalls ADD COLUMN IF NOT EXISTS contact_phone VARCHAR(20);
ALTER TABLE stalls ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE stalls ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE products ADD COLUMN IF NOT EXISTS is_in_stock BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
UPDATE products SET is_in_stock = (stock_quantity > 0);

ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) NOT NULL DEFAULT 'pending';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS assigned_by UUID REFERENCES users(id);
ALTER TABLE orders ADD CONSTRAINT orders_payment_status_check
    CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded'));

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit VARCHAR(30);
UPDATE order_items oi
SET unit = p.unit
FROM products p
WHERE oi.product_id = p.id AND oi.unit IS NULL;
ALTER TABLE order_items ALTER COLUMN unit SET NOT NULL;

ALTER TABLE complaints ADD COLUMN IF NOT EXISTS handled_by UUID REFERENCES users(id);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS resolution_method TEXT;
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

-- Composite key ensures each order item references the order's market.
ALTER TABLE orders ADD CONSTRAINT uq_order_id_market UNIQUE (id, market_id);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS market_id UUID;
UPDATE order_items oi
SET market_id = o.market_id
FROM orders o
WHERE oi.order_id = o.id AND oi.market_id IS NULL;
ALTER TABLE order_items ALTER COLUMN market_id SET NOT NULL;
ALTER TABLE order_items ADD CONSTRAINT fk_item_order_market
    FOREIGN KEY (order_id, market_id) REFERENCES orders(id, market_id) ON DELETE CASCADE;

-- Enforce that each product's stall belongs to the same market as its order.
CREATE OR REPLACE FUNCTION check_order_item_market()
RETURNS TRIGGER AS $
DECLARE
    order_market UUID;
    product_market UUID;
BEGIN
    SELECT market_id INTO order_market FROM orders WHERE id = NEW.order_id;
    SELECT s.market_id INTO product_market
    FROM products p JOIN stalls s ON s.id = p.stall_id
    WHERE p.id = NEW.product_id AND p.stall_id = NEW.stall_id;

    IF order_market IS NULL OR product_market IS NULL OR order_market <> product_market THEN
        RAISE EXCEPTION 'Sản phẩm và đơn hàng phải thuộc cùng một chợ';
    END IF;
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_order_item_market ON order_items;
CREATE TRIGGER trg_check_order_item_market
BEFORE INSERT OR UPDATE OF order_id, product_id, stall_id
ON order_items FOR EACH ROW EXECUTE FUNCTION check_order_item_market();

CREATE INDEX IF NOT EXISTS idx_price_history_product_time
    ON price_history(product_id, effective_at DESC);

COMMIT;
