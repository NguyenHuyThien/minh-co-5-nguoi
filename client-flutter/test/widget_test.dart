import 'package:dichoho/main.dart';
import 'package:dichoho/screens/register_page.dart';
import 'package:dichoho/validators/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder field(String key) => find.byKey(ValueKey(key));

Future<void> fill(WidgetTester tester, String key, String value) async {
  await tester.ensureVisible(field(key));
  await tester.enterText(field(key), value);
  await tester.pump();
}

Future<void> submit(WidgetTester tester, String key) async {
  await tester.ensureVisible(field(key));
  await tester.tap(field(key));
  await tester.pumpAndSettle();
}

void main() {
  test('Validator kiểm tra email, số điện thoại và mật khẩu xác nhận', () {
    expect(AuthValidators.email(' toan@example.com '), isNull);
    expect(AuthValidators.email('toan@'), isNotNull);
    expect(AuthValidators.phone('0912345678'), isNull);
    expect(AuthValidators.phone('+84912345678'), isNull);
    expect(AuthValidators.phone('09123'), isNotNull);
    expect(AuthValidators.registerPassword('1234567'), isNotNull);
    expect(AuthValidators.registerPassword('        '), isNotNull);
    expect(AuthValidators.confirmPassword('khac', '12345678'), isNotNull);
  });

  testWidgets('Đăng nhập chặn form trống và email sai', (tester) async {
    await tester.pumpWidget(const MyApp());
    await submit(tester, 'login_submit');
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await fill(tester, 'login_email', 'sai-email');
    await submit(tester, 'login_submit');
    expect(find.text('Email không đúng định dạng'), findsOneWidget);
  });

  testWidgets('Đăng nhập hợp lệ chỉ hiện thông báo chờ Backend', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await fill(tester, 'login_email', 'toan@example.com');
    await fill(tester, 'login_password', 'matkhau');
    await submit(tester, 'login_submit');
    expect(
      find.text('Chức năng đăng nhập đang chờ kết nối Backend.'),
      findsOneWidget,
    );
    expect(field('login_email'), findsOneWidget);
  });

  testWidgets('Ẩn hiện mật khẩu giữ nguyên nội dung', (tester) async {
    await tester.pumpWidget(const MyApp());
    await fill(tester, 'login_password', '12345678');
    final input = find.descendant(
      of: field('login_password'),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(input).obscureText, isTrue);
    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(tester.widget<TextField>(input).obscureText, isFalse);
    expect(tester.widget<TextField>(input).controller!.text, '12345678');
    await tester.tap(find.byTooltip('Ẩn mật khẩu'));
    await tester.pump();
    expect(tester.widget<TextField>(input).obscureText, isTrue);
  });

  testWidgets('Navigator mở đăng ký và quay lại giữ email đăng nhập', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await fill(tester, 'login_email', 'toan@example.com');
    await submit(tester, 'open_register');
    expect(find.byType(RegisterPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsNothing);
    final input = find.descendant(
      of: field('login_email'),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(input).controller!.text,
      'toan@example.com',
    );
  });

  testWidgets('Đăng ký kiểm tra đủ trường và xác nhận lại khi đổi mật khẩu', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
    await submit(tester, 'register_submit');
    expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);

    await fill(tester, 'register_name', 'Trịnh Thanh Toàn');
    await fill(tester, 'register_email', 'toan@example.com');
    await fill(tester, 'register_phone', '123');
    await fill(tester, 'register_password', '12345678');
    await fill(tester, 'register_confirm', '87654321');
    await submit(tester, 'register_submit');
    expect(
      find.text('Nhập 10 chữ số bắt đầu bằng 0 hoặc dạng +84'),
      findsOneWidget,
    );
    expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await fill(tester, 'register_phone', '0912345678');
    await fill(tester, 'register_confirm', '12345678');
    await fill(tester, 'register_password', 'matkhaukhac');
    await submit(tester, 'register_submit');
    expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);

    await fill(tester, 'register_confirm', 'matkhaukhac');
    await submit(tester, 'register_submit');
    expect(
      find.text('Chức năng đăng ký đang chờ kết nối Backend.'),
      findsOneWidget,
    );
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('Hai form cuộn được trên màn hình nhỏ khi có bàn phím', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 600);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MyApp());
    await fill(tester, 'login_email', 'toan@example.com');
    await submit(tester, 'login_submit');
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await submit(tester, 'open_register');
    await fill(tester, 'register_confirm', '12345678');
    await submit(tester, 'register_submit');
    expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
