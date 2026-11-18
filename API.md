# API DOCUMENTATION
## Dự án: Đi chợ số hóa

Base URL: /api

## 1. MARKETS – Quản lý chợ
- GET /markets
- GET /markets/:id
- POST /markets
- PUT /markets/:id
- DELETE /markets/:id

## 2. AREAS – Quản lý khu vực
- GET /markets/:marketId/areas
- POST /markets/:marketId/areas
- PUT /areas/:id
- DELETE /areas/:id

## 3. STALLS – Quản lý gian hàng
- GET /stalls
- GET /stalls/:id
- POST /stalls
- PUT /stalls/:id
- PATCH /stalls/:id/status
- DELETE /stalls/:id

## 4. PRODUCTS – Quản lý sản phẩm
- GET /products
- GET /products/:id
- POST /products
- PUT /products/:id
- PATCH /products/:id/status
- DELETE /products/:id

### Upload ảnh sản phẩm
- PUT /products/:id/image
- Header: Authorization: Bearer <JWT>
- Content-Type: image/jpeg | image/png | image/webp
- Body: dữ liệu ảnh dạng binary (tối đa 5 MB)
- Quyền: admin hoặc chủ sạp sở hữu sản phẩm
- Response: product_id, image_url
- Ảnh được lưu trong Supabase Storage bucket `product-images`; URL được cập nhật vào `products.image_url`.

## 5. ORDERS – Quản lý đơn hàng
- GET /orders
- GET /orders/:id
- POST /orders
- PATCH /orders/:id/status
- PATCH /orders/:id/assign

## 6. COMPLAINTS – Khiếu nại
- GET /complaints
- GET /complaints/:id
- POST /complaints
- PATCH /complaints/:id/status

## 7. REPORTS – Thống kê
- GET /reports/orders
- GET /reports/products
- GET /reports/markets

## Quy tắc chung
- Dữ liệu trao đổi sử dụng JSON.
- API cần xác thực bằng JWT.
- Kiểm tra dữ liệu đầu vào trước khi xử lý.
- Trả mã HTTP phù hợp khi thành công hoặc thất bại.
