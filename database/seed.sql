-- 0. NGUOI DUNG MAU
INSERT INTO users (
    id, full_name, email, password_hash, role
)
VALUES
(
    'aaaaaaaa-1111-1111-1111-111111111111',
    'Nguoi dang ky mau',
    'applicant@example.com',
    'SEED_ONLY_NOT_LOGIN',
    'merchant'
),
(
    'cccccccc-1111-1111-1111-111111111111',
    'Khach hang mau',
    'customer@example.com',
    'SEED_ONLY_NOT_LOGIN',
    'customer'
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role;
-- 1. CHỢ
INSERT INTO markets (id, name, address, description, latitude, longitude)
VALUES
('11111111-1111-1111-1111-111111111111',
 'Chợ Bến Thành', 'Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
 'Chợ truyền thống nổi tiếng tại trung tâm TP. Hồ Chí Minh',
 10.7725, 106.6980),

('22222222-2222-2222-2222-222222222222',
 'Chợ Tân Định', 'Đường Hai Bà Trưng, Quận 1, TP. Hồ Chí Minh',
 'Chợ truyền thống Tân Định',
 10.7900, 106.6900)
ON CONFLICT (id) DO UPDATE SET
 name = EXCLUDED.name,
 address = EXCLUDED.address,
 description = EXCLUDED.description,
 latitude = EXCLUDED.latitude,
 longitude = EXCLUDED.longitude;

-- 2. KHU VỰC
INSERT INTO market_areas (id, market_id, name, description, map_width, map_height)
VALUES
('33333333-3333-3333-3333-333333333333',
 '11111111-1111-1111-1111-111111111111',
 'Khu thực phẩm', 'Khu bán thực phẩm tươi sống', 1000, 800),

('44444444-4444-4444-4444-444444444444',
 '11111111-1111-1111-1111-111111111111',
 'Khu rau củ', 'Khu bán rau củ quả', 1000, 800),

('55555555-5555-5555-5555-555555555555',
 '22222222-2222-2222-2222-222222222222',
 'Khu hàng tiêu dùng', 'Khu bán hàng tiêu dùng', 800, 600)
ON CONFLICT (id) DO UPDATE SET
 name = EXCLUDED.name,
 description = EXCLUDED.description,
 map_width = EXCLUDED.map_width,
 map_height = EXCLUDED.map_height;

-- 3. SẠP
INSERT INTO stalls (
 id, market_id, area_id, stall_code, name,
 description, map_x, map_y, status
)
VALUES
('66666666-6666-6666-6666-666666666666',
 '11111111-1111-1111-1111-111111111111',
 '33333333-3333-3333-3333-333333333333',
 'A01', 'Sạp thịt tươi', 'Chuyên bán các loại thịt', 20, 30, 'approved'),

('77777777-7777-7777-7777-777777777777',
 '11111111-1111-1111-1111-111111111111',
 '44444444-4444-4444-4444-444444444444',
 'B01', 'Sạp rau sạch', 'Chuyên bán rau củ quả', 50, 40, 'approved'),

('88888888-8888-8888-8888-888888888888',
 '22222222-2222-2222-2222-222222222222',
 '55555555-5555-5555-5555-555555555555',
 'C01', 'Sạp đồ gia dụng', 'Đồ dùng gia đình', 30, 50, 'pending')
ON CONFLICT (id) DO UPDATE SET
 name = EXCLUDED.name,
 description = EXCLUDED.description,
 stall_code = EXCLUDED.stall_code,
 map_x = EXCLUDED.map_x,
 map_y = EXCLUDED.map_y,
 status = EXCLUDED.status;

-- 4. SẢN PHẨM
INSERT INTO products (
 id, stall_id, name, description, price,
 unit, stock_quantity, status
)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 '66666666-6666-6666-6666-666666666666',
 'Thịt heo ba rọi', 'Thịt heo tươi ngon', 150000, 'kg', 20, 'approved'),

('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
 '66666666-6666-6666-6666-666666666666',
 'Thịt heo nạc', 'Thịt heo nạc tươi', 130000, 'kg', 15, 'approved'),

('cccccccc-cccc-cccc-cccc-cccccccccccc',
 '77777777-7777-7777-7777-777777777777',
 'Rau muống', 'Rau muống tươi', 15000, 'bó', 50, 'approved'),

('dddddddd-dddd-dddd-dddd-dddddddddddd',
 '77777777-7777-7777-7777-777777777777',
 'Cà chua', 'Cà chua tươi', 25000, 'kg', 30, 'approved'),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
 '88888888-8888-8888-8888-888888888888',
 'Nồi inox', 'Nồi inox dùng trong gia đình', 180000, 'cái', 10, 'pending')
ON CONFLICT (id) DO UPDATE SET
 name = EXCLUDED.name,
 description = EXCLUDED.description,
 price = EXCLUDED.price,
 unit = EXCLUDED.unit,
 stock_quantity = EXCLUDED.stock_quantity,
 status = EXCLUDED.status;

-- 5. ĐƠN ĐĂNG KÝ SẠP
INSERT INTO stall_applications (
 id, market_id, area_id, applicant_id,
 requested_stall_name, business_description,
 contact_phone, status
)
VALUES (
 '99999999-9999-9999-9999-999999999999',
 '11111111-1111-1111-1111-111111111111',
 '33333333-3333-3333-3333-333333333333',
 'aaaaaaaa-1111-1111-1111-111111111111',
 'Sạp trái cây tươi',
 'Đăng ký kinh doanh trái cây',
 '0900000001',
 'pending'
)
ON CONFLICT (id) DO UPDATE SET
 requested_stall_name = EXCLUDED.requested_stall_name,
 business_description = EXCLUDED.business_description,
 contact_phone = EXCLUDED.contact_phone,
 status = EXCLUDED.status;

-- 6. ĐƠN HÀNG
INSERT INTO orders (
 id, market_id, customer_id, delivery_address,
 delivery_note, subtotal, delivery_fee,
 total_amount, status
)
VALUES (
 'bbbbbbbb-1111-1111-1111-111111111111',
 '11111111-1111-1111-1111-111111111111',
 'cccccccc-1111-1111-1111-111111111111',
 '123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh',
 'Giao hàng trong giờ hành chính',
 180000, 15000, 195000, 'pending'
)
ON CONFLICT (id) DO UPDATE SET
 delivery_address = EXCLUDED.delivery_address,
 delivery_note = EXCLUDED.delivery_note,
 subtotal = EXCLUDED.subtotal,
 delivery_fee = EXCLUDED.delivery_fee,
 total_amount = EXCLUDED.total_amount,
 status = EXCLUDED.status;

-- 7. CHI TIẾT ĐƠN HÀNG
INSERT INTO order_items (
 id, order_id, market_id, product_id, stall_id,
 product_name, unit, unit_price, quantity, note, line_total
)
VALUES
('dddddddd-1111-1111-1111-111111111111',
 'bbbbbbbb-1111-1111-1111-111111111111',
 '11111111-1111-1111-1111-111111111111',
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 '66666666-6666-6666-6666-666666666666',
 'Thịt heo ba rọi', 'kg', 150000, 1, 'Cắt mỏng', 150000),

('eeeeeeee-1111-1111-1111-111111111111',
 'bbbbbbbb-1111-1111-1111-111111111111',
 '11111111-1111-1111-1111-111111111111',
 'cccccccc-cccc-cccc-cccc-cccccccccccc',
 '77777777-7777-7777-7777-777777777777',
 'Rau muống', 'bó', 15000, 2, 'Chọn rau tươi', 30000)
ON CONFLICT (id) DO UPDATE SET
 market_id = EXCLUDED.market_id,
 product_name = EXCLUDED.product_name,
 unit = EXCLUDED.unit,
 unit_price = EXCLUDED.unit_price,
 quantity = EXCLUDED.quantity,
 note = EXCLUDED.note,
 line_total = EXCLUDED.line_total;

-- 8. KHIẾU NẠI
INSERT INTO complaints (
 id, order_id, customer_id, title, content, status
)
VALUES (
 'ffffffff-1111-1111-1111-111111111111',
 'bbbbbbbb-1111-1111-1111-111111111111',
 'cccccccc-1111-1111-1111-111111111111',
 'Thiếu sản phẩm',
 'Đơn hàng bị thiếu một sản phẩm',
 'pending'
)
ON CONFLICT (id) DO UPDATE SET
 title = EXCLUDED.title,
 content = EXCLUDED.content,
 status = EXCLUDED.status;

-- 9. HÌNH ẢNH KHIẾU NẠI
INSERT INTO complaint_images (
 id, complaint_id, image_url
)
VALUES (
 '12121212-1212-1212-1212-121212121212',
 'ffffffff-1111-1111-1111-111111111111',
 'https://placehold.co/600x400?text=Sample+Complaint+Image'
)
ON CONFLICT (id) DO UPDATE SET
 image_url = EXCLUDED.image_url;

-- 10. LỊCH SỬ TRẠNG THÁI ĐƠN HÀNG
INSERT INTO order_status_history (
 id, order_id, old_status, new_status, note
)
VALUES (
 '13131313-1313-1313-1313-131313131313',
 'bbbbbbbb-1111-1111-1111-111111111111',
 NULL,
 'pending',
 'Đơn hàng được tạo'
)
ON CONFLICT (id) DO UPDATE SET
 old_status = EXCLUDED.old_status,
 new_status = EXCLUDED.new_status,
 note = EXCLUDED.note;


-- 11. LICH SU GIA MAU
INSERT INTO price_history (id, product_id, old_price, new_price, effective_at)
VALUES (
 '14141414-1414-1414-1414-141414141414',
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 140000, 150000, NOW()
)
ON CONFLICT (id) DO UPDATE SET
 old_price = EXCLUDED.old_price,
 new_price = EXCLUDED.new_price,
 effective_at = EXCLUDED.effective_at;
