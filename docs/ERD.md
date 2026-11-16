# ERD – Nền tảng số hóa chợ truyền thống – Đi chợ hộ

## 1. Tổng quan

Cơ sở dữ liệu PostgreSQL trên Supabase. ERD dưới đây dùng đúng tên bảng, cột và giá trị trạng thái đang được định nghĩa trong `database/schema.sql`.

### Vai trò người dùng

- `customer`: Khách hàng.
- `stall_owner`: Tiểu thương.
- `shopper`: Người đi chợ hộ.
- `admin`: Ban quản lý chợ.

Mỗi tài khoản có một vai trò trong cột `users.role`. Không tự chuyển vai trò trong quy trình đăng ký.

## 2. Sơ đồ ERD

```mermaid
erDiagram
    users {
        UUID id PK
        VARCHAR full_name
        VARCHAR email UK
        TEXT password_hash
        VARCHAR phone UK
        VARCHAR role
        VARCHAR status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }
    markets {
        UUID id PK
        VARCHAR name
        TEXT address
        TEXT description
        NUMERIC latitude
        NUMERIC longitude
        VARCHAR status
        TIMESTAMPTZ created_at
    }
    market_areas {
        UUID id PK
        UUID market_id FK
        VARCHAR name
        TEXT description
        TEXT map_image_url
        INTEGER map_width
        INTEGER map_height
        TIMESTAMPTZ created_at
    }
    stalls {
        UUID id PK
        UUID market_id FK
        UUID area_id FK
        UUID owner_id FK
        VARCHAR stall_code
        VARCHAR name
        TEXT description
        VARCHAR contact_phone
        TEXT rejection_reason
        NUMERIC map_x
        NUMERIC map_y
        VARCHAR status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }
    products {
        UUID id PK
        UUID stall_id FK
        VARCHAR name
        TEXT description
        NUMERIC price
        VARCHAR unit
        TEXT image_url
        INTEGER stock_quantity
        BOOLEAN is_in_stock
        VARCHAR status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }
    stall_applications {
        UUID id PK
        UUID market_id FK
        UUID area_id FK
        UUID applicant_id FK
        VARCHAR requested_stall_name
        TEXT business_description
        VARCHAR contact_phone
        VARCHAR status
        TEXT admin_note
        TIMESTAMPTZ reviewed_at
        TIMESTAMPTZ created_at
    }
    orders {
        UUID id PK
        UUID market_id FK
        UUID customer_id FK
        UUID shopper_id FK
        UUID assigned_by FK
        TEXT delivery_address
        TEXT delivery_note
        TIMESTAMPTZ delivery_slot
        NUMERIC subtotal
        NUMERIC delivery_fee
        NUMERIC total_amount
        VARCHAR payment_status
        VARCHAR status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }
    order_items {
        UUID id PK
        UUID order_id FK
        UUID market_id FK
        UUID product_id FK
        UUID stall_id FK
        VARCHAR product_name
        VARCHAR unit
        NUMERIC unit_price
        INTEGER quantity
        TEXT note
        NUMERIC line_total
    }
    complaints {
        UUID id PK
        UUID order_id FK
        UUID customer_id FK
        UUID handled_by FK
        VARCHAR title
        TEXT content
        VARCHAR status
        TEXT admin_response
        TEXT resolution_method
        TIMESTAMPTZ created_at
        TIMESTAMPTZ processed_at
        TIMESTAMPTZ resolved_at
    }
    complaint_images {
        UUID id PK
        UUID complaint_id FK
        TEXT image_url
        TIMESTAMPTZ created_at
    }
    order_status_history {
        UUID id PK
        UUID order_id FK
        UUID changed_by FK
        VARCHAR old_status
        VARCHAR new_status
        TEXT note
        TIMESTAMPTZ created_at
    }
    price_history {
        UUID id PK
        UUID product_id FK
        UUID changed_by FK
        NUMERIC old_price
        NUMERIC new_price
        TIMESTAMPTZ effective_at
    }

    markets ||--o{ market_areas : contains
    markets ||--o{ stalls : contains
    market_areas ||--o{ stalls : classifies
    users o|--o{ stalls : owns
    stalls ||--o{ products : sells
    markets ||--o{ stall_applications : receives
    market_areas ||--o{ stall_applications : receives
    users ||--o{ stall_applications : submits
    markets ||--o{ orders : receives
    users ||--o{ orders : places
    users o|--o{ orders : shopper
    users o|--o{ orders : assigns
    orders ||--|{ order_items : contains
    products ||--o{ order_items : ordered
    stalls ||--o{ order_items : sourced_from
    orders ||--o{ complaints : has
    users ||--o{ complaints : submits
    users o|--o{ complaints : handles
    complaints ||--o{ complaint_images : includes
    orders ||--o{ order_status_history : records
    users o|--o{ order_status_history : changes
    products ||--o{ price_history : tracks
    users o|--o{ price_history : changes
```

## 3. Giá trị vai trò và trạng thái

### 3.1. `users.role`
- `customer`
- `shopper`
- `stall_owner`
- `admin`

### 3.2. `users.status`
- `active`
- `locked`

### 3.3. `markets.status`
- `active`
- `inactive`

### 3.4. `stalls.status`
- `pending`
- `approved`
- `locked`
- `rejected`

### 3.5. `products.status` và `products.is_in_stock`
- `status`: `pending`, `approved`, `hidden`, `rejected`.
- `is_in_stock`: cờ còn hàng; `stock_quantity` lưu số lượng tồn kho.

### 3.6. `orders.status`
- `pending`
- `confirmed`
- `preparing`
- `ready`
- `delivering`
- `completed`
- `cancelled`

### 3.7. `orders.payment_status`
- `pending`
- `paid`
- `failed`
- `refunded`

### 3.8. `complaints.status`
- `pending`
- `processing`
- `resolved`
- `rejected`

## 4. Quy tắc nghiệp vụ và ràng buộc

1. Một người dùng có thể sở hữu nhiều gian hàng.
2. Một gian hàng thuộc một chợ và một khu vực của chính chợ đó.
3. Một gian hàng kinh doanh nhiều sản phẩm.
4. Một đơn hàng thuộc một khách hàng và một chợ.
5. Một đơn hàng có thể lấy hàng từ nhiều gian hàng, nhưng mọi dòng hàng phải mang cùng `market_id` với đơn hàng. Khóa ngoại ghép `order_items(order_id, market_id)` tham chiếu `orders(id, market_id)`; trigger PostgreSQL kiểm tra sạp của sản phẩm có cùng `market_id` với đơn hàng, vì vậy database cũng chặn dòng hàng khác chợ. Backend vẫn cần kiểm tra trạng thái sạp/sản phẩm và tồn kho.
6. Chi tiết đơn lưu tên sản phẩm, đơn vị tính, đơn giá tại thời điểm mua, số lượng và ghi chú.
7. Chỉ sản phẩm đã duyệt, còn hàng và thuộc sạp đã duyệt mới được đặt. Backend kiểm tra `status`, `is_in_stock`, `stock_quantity` và trạng thái sạp.
8. BQL là bên phân công người đi chợ hộ; `orders.assigned_by` lưu tài khoản thực hiện phân công.
9. Người đi chợ hộ chỉ xử lý đơn được phân công cho mình (kiểm tra tại Backend).
10. Khiếu nại có thể có nhiều ảnh; ảnh lưu trong `complaint_images`.
11. BQL xử lý khiếu nại; `handled_by`, `resolution_method` và `processed_at` lưu thông tin xử lý.
12. Thay đổi giá sản phẩm được ghi vào `price_history`, gồm giá cũ, giá mới, người thay đổi và thời điểm có hiệu lực.
13. Tổng tiền do Backend tính toán, không tin tổng tiền Client gửi lên.
14. Khi đổi trạng thái đơn, cập nhật đơn và ghi `order_status_history` trong cùng transaction.
15. Không xóa cứng dữ liệu đơn hàng, chi tiết đơn và lịch sử giao dịch.

## 5. Lưu ý triển khai

- ERD dùng đúng tên tiếng Anh và giá trị role/status trong SQL và backend, tránh song song hai bộ enum tiếng Việt/tiếng Anh.
- `stall_applications` và `complaint_images` là bảng thực tế trong SQL nên phải xuất hiện trong ERD.
- `order_items.market_id` được bổ sung và khóa ngoại ghép gắn dòng hàng với chợ của đơn; trigger `check_order_item_market()` kiểm tra sản phẩm/sạp cũng thuộc chợ đó. Backend cần truyền market_id của đơn khi insert từng dòng.
- Cột mới `is_in_stock` bổ sung cho cờ còn hàng; `stock_quantity` vẫn giữ để theo dõi tồn kho.
- Khi thêm các cột mới vào database đã tồn tại, dùng migration riêng thay vì chạy lại schema tạo bảng từ đầu.
