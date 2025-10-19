import 'dart:ui'; // Cần import để dùng ImageFilter
import 'package:flutter/material.dart';
// Import các file mới và đã sửa
import 'package:mobile_quanlykhachsan/models/khachhang.dart'; 
import 'package:mobile_quanlykhachsan/providers/user_provider.dart';
import 'package:mobile_quanlykhachsan/screens/home_screen.dart';
import '../API/auth_api_service.dart'; // Import service
import 'register_screen.dart'; // Import màn hình đăng ký
import 'forgot_password_screen.dart'; // Import màn hình quên mật khẩu

// Imports cho các tính năng mới
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrSdtController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthApiService _apiService = AuthApiService(); // Khởi tạo service
  final storage = const FlutterSecureStorage(); // Khởi tạo bộ nhớ an toàn

  bool _isLoading = false;
  String _errorMessage = '';
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials(); // Tải thông tin "Ghi nhớ tôi" khi màn hình khởi động
  }

  /// Tải thông tin đăng nhập đã lưu từ SharedPreferences
  Future<void> _loadUserCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? emailOrSdt = prefs.getString('emailOrSdt');
    final String? password = prefs.getString('password');

    if (emailOrSdt != null && password != null) {
      setState(() {
        _emailOrSdtController.text = emailOrSdt;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailOrSdtController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Xử lý logic đăng nhập (ĐÃ ĐƯỢC CẬP NHẬT)
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // 1. GỌI API ĐỂ LẤY KẾT QUẢ (JSON phẳng)
        // API trả về: { "message": "...", "hoten": "...", "role": "...", "token": "..." }
        final result = await _apiService.login(
          _emailOrSdtController.text,
          _passwordController.text,
        );

        // 2. KIỂM TRA ROLE (CỰC KỲ QUAN TRỌNG)
        // Vì API của bạn đăng nhập cả nhân viên, chúng ta phải chặn họ ở đây
        if (result['role'] != 'customer') {
          throw Exception(
              'Tài khoản nhân viên không được phép đăng nhập trên ứng dụng này.');
        }

        // 3. LƯU TOKEN VÀO BỘ NHỚ AN TOÀN
        final String token = result['token'];
        await storage.write(key: 'auth_token', value: token);

        // 4. TẠO MODEL VÀ LƯU VÀO "SESSION" (PROVIDER)
        // Dùng factory mới, truyền `result` (JSON phẳng) và `email/sdt` đã nhập
        final Khachhang user = Khachhang.fromLoginResponse(
          result,
          _emailOrSdtController.text,
        );
        
        if (!mounted) return;
        context.read<UserProvider>().setUser(user);

        // 5. XỬ LÝ "GHI NHỚ TÔI"
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('emailOrSdt', _emailOrSdtController.text);
          await prefs.setString('password', _passwordController.text);
        } else {
          await prefs.remove('emailOrSdt');
          await prefs.remove('password');
        }

        // 6. CHUYỂN TRANG
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chào mừng ${user.hoten}!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    // --- PHẦN UI GIỮ NGUYÊN NHƯ CŨ, KHÔNG CẦN THAY ĐỔI ---
    //
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_hero.jpg'), // Đã sửa đường dẫn
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset('assets/images/logo.jpg', height: 80), // Đã sửa đường dẫn
                          const SizedBox(height: 16),
                          const Text(
                            'Khách Sạn Thanh Trà',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      blurRadius: 5,
                                      color: Colors.black38,
                                      offset: Offset(1, 1))
                                ]),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'ĐĂNG NHẬP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      blurRadius: 5,
                                      color: Colors.black38,
                                      offset: Offset(1, 1))
                                ]),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailOrSdtController,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tên đăng nhập (Email hoặc SĐT)',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(
                                0.1,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email hoặc số điện thoại';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.white; // Màu tick
                                      }
                                      return Colors.white
                                          .withOpacity(0.3); // Nền checkbox
                                    }),
                                    checkColor: Colors.blueAccent,
                                  ),
                                  const Text(
                                    'Ghi nhớ tôi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Quên mật khẩu?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.8),
                              foregroundColor: Colors.blueAccent,
                              shadowColor: Colors.black.withOpacity(0.4),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Chưa có tài khoản?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 3,
                                            color: Colors.black38,
                                            offset: Offset(0.5, 0.5))
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}