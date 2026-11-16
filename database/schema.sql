CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. CHO
CREATE TABLE markets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    description TEXT,
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

-- 2. KHU VUC TRONG CHO
CREATE TABLE market_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    map_image_url TEXT,
    map_width INTEGER,
    map_height INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_area_market FOREIGN KEY (market_id) REFERENCES markets(id) ON DELETE CASCADE,
    CONSTRAINT uq_area_id_market UNIQUE (id, market_id),
    CHECK (map_width IS NULL OR map_width > 0),
    CHECK (map_height IS NULL OR map_height > 0)
);

-- 3. NGUOI DUNG
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    phone VARCHAR(20) UNIQUE,
    role VARCHAR(30) NOT NULL DEFAULT 'customer'
        CHECK (role IN ('customer', 'shopper', 'stall_owner', 'admin')),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'locked')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. SAP
CREATE TABLE stalls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_id UUID NOT NULL,
    area_id UUID NOT NULL,
    stall_code VARCHAR(30) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    owner_id UUID,
    contact_phone VARCHAR(20),
    rejection_reason TEXT,
    map_x NUMERIC(6,2),
    map_y NUMERIC(6,2),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'locked', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_stall_area FOREIGN KEY (area_id, market_id)
        REFERENCES market_areas(id, market_id),
    CONSTRAINT fk_stalls_owner FOREIGN KEY (owner_id) REFERENCES users(id),
    CONSTRAINT uq_stall_code_market UNIQUE (market_id, stall_code),
    CONSTRAINT uq_stall_id_market UNIQUE (id, market_id),
    CHECK (map_x IS NULL OR map_x BETWEEN 0 AND 100),
    CHECK (map_y IS NULL OR map_y BETWEEN 0 AND 100)
);

-- 5. SAN PHAM
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stall_id UUID NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    unit VARCHAR(30) NOT NULL DEFAULT 'san pham',
    image_url TEXT,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_in_stock BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'hidden', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_product_stall FOREIGN KEY (stall_id) REFERENCES stalls(id),
    CONSTRAINT uq_product_id_stall UNIQUE (id, stall_id)
);

-- 6. DON DANG KY SAP
CREATE TABLE stall_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_id UUID NOT NULL,
    area_id UUID NOT NULL,
    applicant_id UUID NOT NULL,
    requested_stall_name VARCHAR(150) NOT NULL,
    business_description TEXT,
    contact_phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_note TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_application_market FOREIGN KEY (market_id) REFERENCES markets(id),
    CONSTRAINT fk_application_area FOREIGN KEY (area_id, market_id)
        REFERENCES market_areas(id, market_id),
    CONSTRAINT fk_applications_applicant FOREIGN KEY (applicant_id) REFERENCES users(id)
);

-- 7. DON HANG
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    market_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    shopper_id UUID,
    assigned_by UUID,
    delivery_address TEXT NOT NULL,
    delivery_note TEXT,
    delivery_slot TIMESTAMPTZ,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    delivery_fee NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_order_market FOREIGN KEY (market_id) REFERENCES markets(id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_orders_shopper FOREIGN KEY (shopper_id) REFERENCES users(id),
    CONSTRAINT fk_orders_assigned_by FOREIGN KEY (assigned_by) REFERENCES users(id),
    CONSTRAINT uq_order_id_market UNIQUE (id, market_id)
);

-- 8. CHI TIET DON HANG
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    market_id UUID NOT NULL,
    product_id UUID NOT NULL,
    stall_id UUID NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    note TEXT,
    line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0),
    CONSTRAINT fk_item_order_market FOREIGN KEY (order_id, market_id)
        REFERENCES orders(id, market_id) ON DELETE CASCADE,
    CONSTRAINT fk_item_product_stall FOREIGN KEY (product_id, stall_id)
        REFERENCES products(id, stall_id)
);

-- 9. KHIẾU NẠI
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'resolved', 'rejected')),
    admin_response TEXT,
    handled_by UUID,
    resolution_method TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    CONSTRAINT fk_complaint_order FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_complaints_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_complaints_handler FOREIGN KEY (handled_by) REFERENCES users(id)
);

-- 10. HINH ANH KHIẾU NẠI
CREATE TABLE complaint_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_image_complaint FOREIGN KEY (complaint_id)
        REFERENCES complaints(id) ON DELETE CASCADE
);

-- 11. LICH SU TRANG THAI DON HANG
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by UUID,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_history_order FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_user FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- 12. LICH SU GIA
CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    old_price NUMERIC(12,2) NOT NULL CHECK (old_price >= 0),
    new_price NUMERIC(12,2) NOT NULL CHECK (new_price >= 0),
    changed_by UUID,
    effective_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_price_history_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_price_history_user FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- INDEXES
CREATE INDEX idx_areas_market ON market_areas(market_id);
CREATE INDEX idx_stalls_market ON stalls(market_id);
CREATE INDEX idx_stalls_area ON stalls(area_id);
CREATE INDEX idx_products_stall ON products(stall_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_shopper ON orders(shopper_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_complaints_order ON complaints(order_id);
CREATE INDEX idx_history_order ON order_status_history(order_id);
CREATE INDEX idx_price_history_product_time ON price_history(product_id, effective_at DESC);


-- Enforce that every ordered product's stall belongs to the order's market.
CREATE OR REPLACE FUNCTION check_order_item_market()
RETURNS TRIGGER AS $$
DECLARE
    order_market UUID;
    product_market UUID;
BEGIN
    SELECT market_id INTO order_market
    FROM orders WHERE id = NEW.order_id;

    SELECT s.market_id INTO product_market
    FROM products p
    JOIN stalls s ON s.id = p.stall_id
    WHERE p.id = NEW.product_id AND p.stall_id = NEW.stall_id;

    IF order_market IS NULL OR product_market IS NULL OR order_market <> product_market THEN
        RAISE EXCEPTION 'Sản phẩm và đơn hàng phải thuộc cùng một chợ';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_order_item_market
BEFORE INSERT OR UPDATE OF order_id, product_id, stall_id
ON order_items
FOR EACH ROW
EXECUTE FUNCTION check_order_item_market();
