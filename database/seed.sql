-- 1. CHO
INSERT INTO markets (id, name, address, description, latitude, longitude)
VALUES
('11111111-1111-1111-1111-111111111111',
 'Cho Ben Thanh', 'Le Loi, Quan 1, TP.HCM',
 'Cho truyen thong tai trung tam TP.HCM',
 10.7725, 106.6980),

('22222222-2222-2222-2222-222222222222',
 'Cho Tan Dinh', 'Hai Ba Trung, Quan 1, TP.HCM',
 'Cho truyen thong Tan Dinh',
 10.7900, 106.6900)
ON CONFLICT DO NOTHING;

-- 2. KHU VUC
INSERT INTO market_areas (id, market_id, name, description, map_width, map_height)
VALUES
('33333333-3333-3333-3333-333333333333',
 '11111111-1111-1111-1111-111111111111',
 'Khu thuc pham', 'Khu ban thuc pham tuoi song', 1000, 800),

('44444444-4444-4444-4444-444444444444',
 '11111111-1111-1111-1111-111111111111',
 'Khu rau cu', 'Khu ban rau cu qua', 1000, 800),

('55555555-5555-5555-5555-555555555555',
 '22222222-2222-2222-2222-222222222222',
 'Khu hang tieu dung', 'Khu ban hang tieu dung', 800, 600)
ON CONFLICT DO NOTHING;

-- 3. SAP
INSERT INTO stalls (
    id, market_id, area_id, stall_code, name,
    description, map_x, map_y, status
)
VALUES
('66666666-6666-6666-6666-666666666666',
 '11111111-1111-1111-1111-111111111111',
 '33333333-3333-3333-3333-333333333333',
 'A01', 'Sap thit tuoi', 'Chuyen ban cac loai thit', 20, 30, 'approved'),

('77777777-7777-7777-7777-777777777777',
 '11111111-1111-1111-1111-111111111111',
 '44444444-4444-4444-4444-444444444444',
 'B01', 'Sap rau sach', 'Chuyen ban rau cu qua', 50, 40, 'approved'),

('88888888-8888-8888-8888-888888888888',
 '22222222-2222-2222-2222-222222222222',
 '55555555-5555-5555-5555-555555555555',
 'C01', 'Sap do gia dung', 'Do dung gia dinh', 30, 50, 'pending')
ON CONFLICT DO NOTHING;

-- 4. SAN PHAM
INSERT INTO products (
    id, stall_id, name, description, price,
    unit, stock_quantity, status
)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 '66666666-6666-6666-6666-666666666666',
 'Thit heo ba roi', 'Thit heo tuoi', 150000, 'kg', 20, 'approved'),

('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
 '66666666-6666-6666-6666-666666666666',
 'Thit heo nac', 'Thit heo nac tuoi', 130000, 'kg', 15, 'approved'),

('cccccccc-cccc-cccc-cccc-cccccccccccc',
 '77777777-7777-7777-7777-777777777777',
 'Rau muong', 'Rau muong tuoi', 15000, 'bo', 50, 'approved'),

('dddddddd-dddd-dddd-dddd-dddddddddddd',
 '77777777-7777-7777-7777-777777777777',
 'Ca chua', 'Ca chua tuoi', 25000, 'kg', 30, 'approved'),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
 '88888888-8888-8888-8888-888888888888',
 'Noi inox', 'Noi inox gia dung', 180000, 'cai', 10, 'pending')
ON CONFLICT DO NOTHING;

-- 5. DON DANG KY SAP
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
    'Sap trai cay tuoi',
    'Dang ky kinh doanh trai cay',
    '0900000001',
    'pending'
)
ON CONFLICT DO NOTHING;

-- 6. DON HANG
INSERT INTO orders (
    id, market_id, customer_id, delivery_address,
    delivery_note, subtotal, delivery_fee,
    total_amount, status
)
VALUES (
    'bbbbbbbb-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'cccccccc-1111-1111-1111-111111111111',
    '123 Nguyen Trai, Quan 1, TP.HCM',
    'Giao hang trong gio hanh chinh',
    180000, 15000, 195000, 'pending'
)
ON CONFLICT DO NOTHING;

-- 7. CHI TIET DON HANG
INSERT INTO order_items (
    id, order_id, product_id, stall_id,
    product_name, unit_price, quantity, note, line_total
)
VALUES
('dddddddd-1111-1111-1111-111111111111',
 'bbbbbbbb-1111-1111-1111-111111111111',
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 '66666666-6666-6666-6666-666666666666',
 'Thit heo ba roi', 150000, 1, 'Cat mong', 150000),

('eeeeeeee-1111-1111-1111-111111111111',
 'bbbbbbbb-1111-1111-1111-111111111111',
 'cccccccc-cccc-cccc-cccc-cccccccccccc',
 '77777777-7777-7777-7777-777777777777',
 'Rau muong', 15000, 2, 'Rau tuoi', 30000)
ON CONFLICT DO NOTHING;

-- 8. KHIẾU NẠI
INSERT INTO complaints (
    id, order_id, customer_id, title, content, status
)
VALUES (
    'ffffffff-1111-1111-1111-111111111111',
    'bbbbbbbb-1111-1111-1111-111111111111',
    'cccccccc-1111-1111-1111-111111111111',
    'Thieu san pham',
    'Don hang bi thieu mot san pham',
    'pending'
)
ON CONFLICT DO NOTHING;

-- 9. HINH ANH KHIẾU NẠI
INSERT INTO complaint_images (
    id, complaint_id, image_url
)
VALUES (
    '12121212-1212-1212-1212-121212121212',
    'ffffffff-1111-1111-1111-111111111111',
    'https://example.com/complaint-image.jpg'
)
ON CONFLICT DO NOTHING;

-- 10. LICH SU TRANG THAI DON HANG
INSERT INTO order_status_history (
    id, order_id, old_status, new_status, note
)
VALUES (
    '13131313-1313-1313-1313-131313131313',
    'bbbbbbbb-1111-1111-1111-111111111111',
    NULL,
    'pending',
    'Don hang duoc tao'
)
ON CONFLICT DO NOTHING;
