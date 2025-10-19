import 'dart:ui';
import 'package:flutter/material.dart';
import '../API/auth_api_service.dart'; // Import service để gọi API

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthApiService _apiService = AuthApiService();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Kiểm tra form và mật khẩu khớp nhau
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Mật khẩu xác nhận không khớp.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final result = await _apiService.register(
          hoten: _nameController.text,
          email: _emailController.text,
          sdt: _phoneController.text,
          matkhau: _passwordController.text,
        );
        
        // Đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Đăng ký thành công!')),
        );
        // Quay lại màn hình đăng nhập sau khi thành công
        Navigator.pop(context);

      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép body nằm sau AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Nền và overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/bg_hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          // Form đăng ký
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                                                    Image.asset(
                            'images/logo.jpg',
                            height:
                                80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Khách Sạn Thanh Trà', // Tiêu đề mới
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Màu chữ trắng
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black38,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'TẠO TÀI KHOẢN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black38, offset: Offset(1, 1))
                              ]
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Các trường nhập liệu
                          _buildTextFormField(
                            controller: _nameController,
                            labelText: 'Họ và tên',
                            icon: Icons.person,
                            validator: (val) => val!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _emailController,
                            labelText: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => !(val?.contains('@') ?? false) ? 'Email không hợp lệ' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _phoneController,
                            labelText: 'Số điện thoại',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (val) => val!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: _passwordController,
                            labelText: 'Mật khẩu',
                            icon: Icons.lock,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            validator: (val) => (val!.length < 6) ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                          ),
                          const SizedBox(height: 20),
                           _buildTextFormField(
                            controller: _confirmPasswordController,
                            labelText: 'Xác nhận mật khẩu',
                            icon: Icons.lock,
                            isPassword: true,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                            validator: (val) => val!.isEmpty ? 'Vui lòng xác nhận mật khẩu' : null,
                          ),
                          const SizedBox(height: 30),

                          // Hiển thị lỗi nếu có
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Nút Đăng ký
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.8),
                              foregroundColor: Colors.blueAccent,
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
                                    'Đăng ký',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
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

  // Widget con để tái sử dụng cho các TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}