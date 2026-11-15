# Đi Chợ Hộ – Flutter Client

Ứng dụng khách hàng thuộc đồ án **Nền tảng số hóa chợ truyền thống – Đi chợ hộ**, môn **INT4211 – Lập trình trên các thiết bị di động**.

**Thành viên phụ trách:** Trịnh Thanh Toàn – MSSV **221A010953**.

Flutter Client phục vụ khách hàng chọn chợ, mua hàng và theo dõi đơn đi chợ hộ. Phiên bản hiện tại triển khai giao diện tài khoản và luồng chọn chợ → khu vực → gian hàng → sản phẩm → chi tiết bằng dữ liệu mẫu. Xem [README chung của nhóm](../README.md) để biết phân công toàn hệ thống.

## Công nghệ và môi trường

| Thành phần | Cấu hình hiện tại |
|---|---|
| Flutter project | `dichoho` |
| Flutter | Đã phát triển và chạy thử với **3.38.6**, Material 3 |
| Dart | **3.10.7**; ràng buộc SDK trong `pubspec.yaml` là `^3.10.7` |
| Nền tảng đã khởi tạo | Android |
| Ngôn ngữ giao diện và logic | Dart |
| Android host | Kotlin |
| Android applicationId | `com.minhco5nguoi.dichoho` |

Cấu hình dependency nằm trong [pubspec.yaml](pubspec.yaml); applicationId nằm trong [android/app/build.gradle.kts](android/app/build.gradle.kts).

Project hiện giữ các dependency của template Flutter: `cupertino_icons`, `flutter_test` và `flutter_lints`, ngoài Flutter SDK. Chưa thêm thư viện HTTP, lưu token, định vị hoặc chọn ảnh.

## Trạng thái chức năng

| Chức năng | Trạng thái thực tế | Giới hạn |
|---|---|---|
| Giao diện đăng nhập | Đã triển khai | Email, mật khẩu, ẩn/hiện mật khẩu và kiểm tra dữ liệu |
| Giao diện đăng ký khách hàng | Đã triển khai | Họ tên, email, SĐT, mật khẩu, xác nhận mật khẩu |
| Gửi form tài khoản hợp lệ | Đã có phản hồi giao diện | Chỉ thông báo đang chờ kết nối Backend |
| Điều hướng tài khoản | Đã triển khai | Mở đăng ký và quay lại đăng nhập bằng Navigator |
| Chọn chợ | Đã triển khai **demo với Mock Data** | Danh sách chợ mẫu, chọn và trả kết quả về màn hình trước |
| Loading, dữ liệu, rỗng, lỗi và thử lại | Đã triển khai cho chợ, khu vực, gian hàng và sản phẩm mẫu | Chuyển kịch bản bằng bộ chọn trên từng màn hình demo |
| Xác thực thật và lưu token | Chưa triển khai | Chưa gọi API, chưa có JWT hoặc SharedPreferences |
| Chọn chợ gần nhất theo vị trí | Dự kiến | Chưa lấy vị trí, tính khoảng cách hoặc sắp theo khoảng cách |
| Khu vực và gian hàng | Đã triển khai demo bằng Mock Data | Xem khu vực theo chợ, gian hàng theo khu vực; lọc đúng ID chợ và khu vực, chưa gọi API thật |
| Tìm kiếm và chi tiết sản phẩm | Đã triển khai demo bằng Mock Data | Danh sách theo gian hàng; tìm tên trong gian hàng hoặc toàn chợ; chi tiết, giá và tồn hàng đều là mẫu |
| Giỏ hàng nhiều gian hàng trong cùng chợ | Dự kiến | Bao gồm số lượng và ghi chú từng dòng hàng |
| Chọn khung giờ, xem phí và đặt đơn | Dự kiến | Cần thống nhất nghiệp vụ và API |
| Theo dõi đơn hàng | Dự kiến | Chưa kết nối dữ liệu đơn |
| Khiếu nại kèm ảnh | Dự kiến | Chưa có form, chọn ảnh hoặc API upload |

### Phạm vi demo

- **Chưa kết nối Backend và chưa xác thực người dùng thật.** Gửi form hợp lệ không tạo tài khoản hoặc phiên đăng nhập.
- Không tạo JWT giả, không lưu mật khẩu và chưa lưu token.
- Nút **“Demo chọn chợ · Dữ liệu mẫu”** là lối trải nghiệm giao diện được ghi rõ trên màn hình đăng nhập; không cấp quyền đặt hàng.
- Tên và địa chỉ chợ trong [MockMarketService](lib/services/mock_market_service.dart) đều là dữ liệu minh họa trong bộ nhớ, không phải danh sách chợ lấy từ API.
- Không hiển thị khoảng cách, tọa độ hoặc vị trí giả như dữ liệu thật.
- Chợ đã chọn chỉ được giữ tạm trong trạng thái màn hình đăng nhập; chưa lưu bền vững hoặc tạo đơn.
- Sau khi chọn chợ, nút **“Demo xem khu vực và gian hàng”** mở luồng **chợ đã chọn → danh sách khu vực → danh sách gian hàng**. Chợ và khu vực được truyền qua Navigator.
- [MockMarketDirectoryService](lib/services/mock_market_directory_service.dart) cung cấp khu vực, gian hàng và vị trí sạp minh họa. Service và màn hình lọc theo ID để không hiển thị gian hàng sai chợ hoặc khu vực; đây chưa phải dữ liệu từ Backend API.

### Sản phẩm và giá mẫu

- [MockProductService](lib/services/mock_product_service.dart) cung cấp sản phẩm theo gian hàng; kiểm tra ID chợ và gian hàng. Màn hình tiếp tục lọc ID để không hiển thị sản phẩm của chợ khác.
- Mỗi gian hàng có 3 sản phẩm mẫu. Giá là số đồng nguyên, hiển thị dạng **“Giá mẫu: 18.000 ₫ / kg”**; tên, giá và tình trạng còn/hết hàng đều chỉ để thử giao diện, không phải dữ liệu thực tế từ chợ.
- Tìm theo tên bằng dữ liệu đã tải, không phân biệt chữ hoa/thường và bỏ khoảng trắng đầu/cuối; dấu tiếng Việt vẫn được giữ khi so khớp. Chưa tìm kiếm qua Backend API.
- Ảnh dùng biểu tượng placeholder; chưa tải ảnh URL. Chi tiết chỉ hiển thị thông tin, chưa có thêm giỏ hàng hoặc đặt đơn.

### Kiểm tra dữ liệu tài khoản

Form dùng `Form`, `TextFormField` và `validator`:

- Đăng nhập: email có định dạng cơ bản hợp lệ, mật khẩu không trống.
- Đăng ký: họ tên ít nhất 2 ký tự sau khi bỏ khoảng trắng đầu/cuối; email hợp lệ; SĐT gồm 10 chữ số bắt đầu bằng `0` hoặc `+84` kèm 9 chữ số.
- Mật khẩu đăng ký ít nhất 8 ký tự, không chỉ gồm khoảng trắng; xác nhận mật khẩu phải trùng.
- Các quy tắc trên là kiểm tra phía giao diện, cần thống nhất lại với Backend khi tích hợp.

## Cấu trúc thư mục hiện tại

Cây dưới đây liệt kê các file và thư mục chính đang tồn tại; lược bớt file Android do Flutter sinh và thư mục build/cache.

```text
client-flutter/
├── android/
│   └── app/
│       ├── build.gradle.kts
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/minhco5nguoi/dichoho/MainActivity.kt
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── market.dart
│   │   ├── market_area.dart
│   │   ├── stall.dart
│   │   └── product.dart
│   ├── screens/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── market_selection_page.dart
│   │   ├── market_area_page.dart
│   │   ├── stall_list_page.dart
│   │   ├── product_list_page.dart
│   │   └── product_detail_page.dart
│   ├── services/
│   │   ├── mock_market_service.dart
│   │   ├── mock_market_directory_service.dart
│   │   └── mock_product_service.dart
│   ├── utils/
│   │   └── currency_formatter.dart
│   ├── validators/
│   │   └── auth_validators.dart
│   └── widgets/
│       └── demo_list_widgets.dart
├── test/
│   ├── widget_test.dart
│   ├── market_selection_test.dart
│   ├── market_directory_test.dart
│   └── product_test.dart
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

- [main.dart](lib/main.dart): điểm khởi chạy, theme xanh Material 3 và màn hình đăng nhập.
- [models/market.dart](lib/models/market.dart): model chợ bất biến gồm ID, tên và địa chỉ.
- [models/market_area.dart](lib/models/market_area.dart) và [models/stall.dart](lib/models/stall.dart): model khu vực và gian hàng, có ID liên kết chợ/khu vực.
- [models/product.dart](lib/models/product.dart): sản phẩm gắn ID chợ/gian hàng, tên, giá mẫu, đơn vị, mô tả và còn hàng.
- [screens/](lib/screens/): giao diện tài khoản, chọn chợ, khu vực/gian hàng, danh sách/tìm kiếm và chi tiết sản phẩm.
- [services/mock_market_service.dart](lib/services/mock_market_service.dart): cung cấp dữ liệu mẫu, độ trễ và lỗi mô phỏng, tách khỏi Widget.
- [services/mock_market_directory_service.dart](lib/services/mock_market_directory_service.dart): dữ liệu khu vực/gian hàng theo ID chợ và khu vực, có mô phỏng rỗng và lỗi.
- [services/mock_product_service.dart](lib/services/mock_product_service.dart): sản phẩm mẫu theo chợ/gian hàng và kịch bản loading/rỗng/lỗi.
- [utils/currency_formatter.dart](lib/utils/currency_formatter.dart): định dạng tiền Việt Nam, không cần package ngoài.
- [widgets/demo_list_widgets.dart](lib/widgets/demo_list_widgets.dart): bộ chọn kịch bản mẫu và thông báo rỗng/lỗi/thử lại dùng chung.
- [validators/auth_validators.dart](lib/validators/auth_validators.dart): quy tắc kiểm tra dùng chung.
- [test/](test/): kiểm thử validator, form, điều hướng và các trạng thái danh sách chợ, khu vực, gian hàng và sản phẩm.

## Chạy ứng dụng

Cần Flutter SDK tương thích với ràng buộc Dart trong project, Android SDK, JDK và Android Emulator hoặc điện thoại đã bật USB debugging. Kiểm tra môi trường bằng `flutter doctor -v`; hoàn tất Android licenses nếu công cụ yêu cầu.

Mở terminal tại thư mục `client-flutter/`. Nếu đang ở thư mục gốc repository, chuyển vào bằng:

```powershell
cd client-flutter
```

Tải các dependency đã khai báo, liệt kê thiết bị rồi chạy:

```powershell
flutter pub get
flutter devices
flutter run
```

Nếu thiết bị xuất hiện với ID `emulator-5554`, có thể chỉ định:

```powershell
flutter run -d emulator-5554
```

Dùng ID thực tế từ `flutter devices` nếu khác ví dụ. Project hiện chỉ khởi tạo Android; hướng dẫn này dành cho thiết bị Android.

### Trải nghiệm chọn chợ, khu vực, gian hàng và sản phẩm mẫu

1. Mở ứng dụng tại màn hình đăng nhập.
2. Bấm **“Demo chọn chợ · Dữ liệu mẫu”**; không cần gửi form đăng nhập.
3. Dùng **“Kịch bản dữ liệu mẫu”** để thử:
   - **Có dữ liệu:** hiển thị 3 chợ mẫu.
   - **Danh sách rỗng:** hiển thị thông báo chưa có chợ.
   - **Lỗi lần đầu, thử lại thành công:** hiển thị lỗi; bấm **“Thử lại”** để tải danh sách mẫu.
4. Chọn một chợ: Navigator trả về đối tượng `Market`; màn hình đăng nhập hiển thị tên chợ mẫu đã chọn và SnackBar.
5. Bấm **“Demo xem khu vực và gian hàng”** trên màn hình đăng nhập để mở danh sách khu vực của chợ đã chọn.
6. Chọn một khu vực để xem gian hàng tương ứng. Mỗi dòng hiển thị tên gian hàng, khu vực và vị trí sạp mẫu. Bấm gian hàng để mở danh sách sản phẩm của gian đó; bấm sản phẩm để xem chi tiết.
7. Ở màn hình khu vực và gian hàng, dùng **“Kịch bản dữ liệu mẫu”** để thử dữ liệu, danh sách rỗng hoặc lỗi lần đầu; bấm **“Thử lại”** để tải thành công. Dữ liệu mặc định có 3 khu vực mỗi chợ và 2 gian hàng mỗi khu vực.
8. Tìm theo tên trong ô tìm kiếm của danh sách sản phẩm. Từ danh sách của một gian hàng, bấm **“Tìm sản phẩm trong toàn chợ”** để mở phạm vi toàn chợ. Cũng có thể bấm biểu tượng tìm kiếm trên thanh tiêu đề màn hình khu vực.
9. Màn hình tìm toàn chợ luôn dùng chợ đã chọn, không chỉ khu vực đang xem; các dòng kết quả ghi tên gian hàng để phân biệt sản phẩm trùng tên.
10. Ở danh sách sản phẩm, có thể đổi kịch bản mẫu, thử lại hoặc xóa từ khóa để khôi phục danh sách. Giá và đơn vị tính được hiển thị cả ở danh sách và chi tiết.
11. Bấm Back lần lượt để về màn hình trước. Bấm Back ở màn hình chọn chợ khi chưa chọn không thay đổi lựa chọn trước đó. Luồng này vẫn là demo, không xác thực hoặc tạo đơn.

## Kiểm tra chất lượng

Chạy từ `client-flutter/`:

```powershell
flutter analyze
flutter test
```

**Kết quả kiểm thử mới nhất: 45 bài kiểm thử đều đạt**, gồm 30 bài đã có và 15 bài mới cho sản phẩm, tìm kiếm, chi tiết và định dạng giá.

Có thể chạy riêng kiểm thử chọn chợ, khu vực/gian hàng hoặc sản phẩm:

```powershell
flutter test test/market_selection_test.dart
flutter test test/market_directory_test.dart
flutter test test/product_test.dart
```

- [widget_test.dart](test/widget_test.dart): dữ liệu form, ẩn/hiện mật khẩu, Navigator, phản hồi chờ Backend và bố cục khi có bàn phím.
- [market_selection_test.dart](test/market_selection_test.dart): service mẫu, loading, danh sách, rỗng, lỗi/thử lại, trả kết quả chọn và kịch bản demo.

- [market_directory_test.dart](test/market_directory_test.dart): lọc đúng chợ/khu vực, loại bản ghi sai liên kết, loading/rỗng/lỗi/thử lại ở hai màn hình, điều hướng và thay đổi chợ trong demo.

- [product_test.dart](test/product_test.dart): lọc đúng chợ/gian hàng, tìm tên và xóa từ khóa, giá/đơn vị, loading/rỗng/lỗi/thử lại, điều hướng chi tiết và màn hình nhỏ có bàn phím.

Các test hiện tại kiểm tra logic và giao diện với dữ liệu trong bộ nhớ; chưa kiểm thử tích hợp API hoặc xác thực thật.

## Kiến thức Lab đã áp dụng

| Lab | Kiến thức được sử dụng trong source hiện tại |
|---|---|
| **F1** | Dart class, List, null safety, StatelessWidget/StatefulWidget và cập nhật giao diện bằng `setState` |
| **F2** | Column, Padding, SizedBox, theme; SafeArea, SingleChildScrollView, ConstrainedBox và giới hạn chiều rộng |
| **F3** | Form, GlobalKey, TextFormField, validator; TextField tìm kiếm, TextEditingController và `dispose` controller |
| **F4** | Navigator.push/pop, MaterialPageRoute, trả đối tượng Market, truyền chợ/khu vực giữa màn hình, xử lý kết quả null và kiểm tra mounted sau await |
| **F5** | Model tách khỏi Widget, ListView.builder, Card/ListTile và key theo ID chợ, khu vực, gian hàng và sản phẩm |
| **F6** | Scaffold, SnackBar và phản hồi thao tác |

Loading/error dùng `FutureBuilder` theo **Phụ lục 3 của tài liệu đồ án**, không quy thành nội dung chính của Lab F6. Hiện danh sách dùng biểu tượng chợ/gian hàng/sản phẩm; chưa triển khai tải ảnh URL, Drawer hoặc NavigationBar.

## Hướng phát triển tiếp theo

Tiếp tục triển khai giỏ hàng, khung giờ/phí, đặt đơn, theo dõi đơn và khiếu nại. Khi tích hợp Backend, cần thống nhất hợp đồng API, mã lỗi và nghiệp vụ với thành viên phụ trách; giá, phí và quyền thao tác phải được máy chủ kiểm tra.
