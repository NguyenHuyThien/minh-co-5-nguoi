-- Migration: safely align the existing database with the agreed schema.
-- Review and test on a disposable PostgreSQL database before production.
-- The whole migration is atomic: any error rolls back every change.

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

-- Add constraints only when their names are not already present.
DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'orders'::regclass
          AND conname = 'orders_payment_status_check'
    ) THEN
        ALTER TABLE orders
            ADD CONSTRAINT orders_payment_status_check
            CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded'));
    END IF;
END
$do$;

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit VARCHAR(30);
UPDATE order_items oi
SET unit = p.unit
FROM products p
WHERE oi.product_id = p.id
  AND oi.unit IS NULL;

-- Fail safely instead of attempting SET NOT NULL with unresolved legacy rows.
DO $do$
DECLARE
    missing_unit_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO missing_unit_count
    FROM order_items
    WHERE unit IS NULL;

    IF missing_unit_count > 0 THEN
        RAISE EXCEPTION
            'Migration stopped: % order_items rows still have unit IS NULL. Resolve these rows before retrying.',
            missing_unit_count;
    END IF;
END
$do$;

ALTER TABLE order_items ALTER COLUMN unit SET NOT NULL;

ALTER TABLE complaints ADD COLUMN IF NOT EXISTS handled_by UUID REFERENCES users(id);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS resolution_method TEXT;
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

-- Keep the composite order/market relationship idempotent.
DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'orders'::regclass
          AND conname = 'uq_order_id_market'
    ) THEN
        ALTER TABLE orders
            ADD CONSTRAINT uq_order_id_market UNIQUE (id, market_id);
    END IF;
END
$do$;

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS market_id UUID;
UPDATE order_items oi
SET market_id = o.market_id
FROM orders o
WHERE oi.order_id = o.id
  AND oi.market_id IS NULL;

DO $do$
DECLARE
    missing_market_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO missing_market_count
    FROM order_items
    WHERE market_id IS NULL;

    IF missing_market_count > 0 THEN
        RAISE EXCEPTION
            'Migration stopped: % order_items rows still have market_id IS NULL. Resolve these rows before retrying.',
            missing_market_count;
    END IF;
END
$do$;

ALTER TABLE order_items ALTER COLUMN market_id SET NOT NULL;

DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'order_items'::regclass
          AND conname = 'fk_item_order_market'
    ) THEN
        ALTER TABLE order_items
            ADD CONSTRAINT fk_item_order_market
            FOREIGN KEY (order_id, market_id)
            REFERENCES orders(id, market_id) ON DELETE CASCADE;
    END IF;
END
$do$;

-- Role naming: the agreed application role is merchant.
-- Convert legacy stall_owner values without changing the users table structure.
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
UPDATE users SET role = 'merchant' WHERE role = 'stall_owner';

DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'users'::regclass
          AND conname = 'users_role_check'
    ) THEN
        ALTER TABLE users
            ADD CONSTRAINT users_role_check
            CHECK (role IN ('customer', 'shopper', 'merchant', 'admin'));
    END IF;
END
$do$;

-- Enforce that each ordered product's stall belongs to the order's market.
CREATE OR REPLACE FUNCTION check_order_item_market()
RETURNS TRIGGER AS $$
DECLARE
    order_market UUID;
    product_market UUID;
BEGIN
    SELECT market_id INTO order_market
    FROM orders
    WHERE id = NEW.order_id;

    SELECT s.market_id INTO product_market
    FROM products p
    JOIN stalls s ON s.id = p.stall_id
    WHERE p.id = NEW.product_id
      AND p.stall_id = NEW.stall_id;

    IF order_market IS NULL
       OR product_market IS NULL
       OR order_market <> product_market THEN
        RAISE EXCEPTION 'Sản phẩm và đơn hàng phải thuộc cùng một chợ';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_order_item_market ON order_items;
CREATE TRIGGER trg_check_order_item_market
BEFORE INSERT OR UPDATE OF order_id, product_id, stall_id
ON order_items
FOR EACH ROW
EXECUTE FUNCTION check_order_item_market();

-- Keep the availability flag consistent with stock quantity.
CREATE OR REPLACE FUNCTION sync_product_stock_flag()
RETURNS TRIGGER AS $$
BEGIN
    NEW.is_in_stock := (NEW.stock_quantity > 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_product_stock_flag ON products;
CREATE TRIGGER trg_sync_product_stock_flag
BEFORE INSERT OR UPDATE OF stock_quantity
ON products
FOR EACH ROW
EXECUTE FUNCTION sync_product_stock_flag();

-- Record every product price change automatically.
CREATE OR REPLACE FUNCTION record_product_price_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.price IS DISTINCT FROM OLD.price THEN
        INSERT INTO price_history (product_id, old_price, new_price, effective_at)
        VALUES (NEW.id, OLD.price, NEW.price, NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_record_product_price_change ON products;
CREATE TRIGGER trg_record_product_price_change
AFTER UPDATE OF price
ON products
FOR EACH ROW
EXECUTE FUNCTION record_product_price_change();

CREATE INDEX IF NOT EXISTS idx_price_history_product_time
    ON price_history(product_id, effective_at DESC);

COMMIT;
