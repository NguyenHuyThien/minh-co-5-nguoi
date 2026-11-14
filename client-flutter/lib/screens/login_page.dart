import 'package:flutter/material.dart';

import '../models/market.dart';
import '../validators/auth_validators.dart';
import 'market_area_page.dart';
import 'market_selection_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  Market? _demoMarket;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openMarketDemo() async {
    FocusScope.of(context).unfocus();
    final market = await Navigator.push<Market>(
      context,
      MaterialPageRoute<Market>(
        builder: (context) => const MarketSelectionPage(),
      ),
    );
    if (!mounted || market == null) return;
    setState(() => _demoMarket = market);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Đã chọn chợ mẫu: ${market.name}')),
      );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Chức năng đăng nhập đang chờ kết nối Backend.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Đi Chợ Hộ')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text('Đăng nhập', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    const Text('Đi chợ thuận tiện, nhận hàng tận nơi.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const ValueKey('login_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('login_password'),
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Hiện mật khẩu'
                              : 'Ẩn mật khẩu',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: AuthValidators.loginPassword,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('login_submit'),
                      onPressed: _submit,
                      child: const Text('Đăng nhập'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey('open_register'),
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      child: const Text('Chưa có tài khoản? Đăng ký'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('open_market_demo'),
                      onPressed: _openMarketDemo,
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Demo chọn chợ · Dữ liệu mẫu'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chỉ xem giao diện chọn chợ; không đăng nhập và không đặt hàng.',
                      textAlign: TextAlign.center,
                    ),
                    if (_demoMarket != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Chợ mẫu đã chọn: ${_demoMarket!.name}',
                        key: const ValueKey('selected_demo_market'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const ValueKey('open_market_directory_demo'),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  MarketAreaPage(market: _demoMarket!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.category_outlined),
                        label: const Text('Demo xem khu vực và gian hàng'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Đăng nhập tài khoản khách hàng. Chức năng đang chờ kết nối Backend.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
