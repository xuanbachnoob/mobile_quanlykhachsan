import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../API/auth_api_service.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cccdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthApiService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  //  VALIDATE HỌ TÊN (TỐI THIỂU 2 TỪ)
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ tên';
    }

    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final words = trimmed.split(' ');

    if (words.length < 2) {
      return 'Họ tên phải có ít nhất 2 từ (VD: Nguyễn Văn A)';
    }

    for (var word in words) {
      if (!RegExp(r'^[a-zA-ZÀ-ỹ]+$').hasMatch(word)) {
        return 'Họ tên chỉ được chứa chữ cái';
      }
    }

    return null;
  }

  //  VALIDATE EMAIL
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  //  VALIDATE SỐ ĐIỆN THOẠI
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Số điện thoại chỉ được chứa số';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Số điện thoại phải có đúng 10 chữ số';
    }

    if (!RegExp(r'^(03|05|07|08|09)\d{8}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ (phải bắt đầu bằng 03/05/07/08/09)';
    }

    return null;
  }

  //  VALIDATE CCCD
  String? _validateCccd(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập CCCD/CMND';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'CCCD/CMND chỉ được chứa số';
    }

    if (!RegExp(r'^\d{9}$|^\d{12}$').hasMatch(value)) {
      return 'CCCD/CMND phải là 9 hoặc 12 chữ số';
    }

    return null;
  }

  //  VALIDATE MẬT KHẨU
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Chữ cái đầu phải viết hoa';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    }

    return null;
  }

  //  VALIDATE XÁC NHẬN MẬT KHẨU
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Registering user...');

      await _authService.register(
        hoten: _nameController.text.trim(),
        email: _emailController.text.trim(),
        sdt: _phoneController.text.trim(),
        cccd: _cccdController.text.trim(),
        matkhau: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Đăng ký thành công',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Tài khoản của bạn đã được tạo thành công.\nVui lòng đăng nhập để tiếp tục.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng nhập ngay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(' Register error: $e');

      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
                const SizedBox(width: 12),
                const Text('Lỗi đăng ký'),
              ],
            ),
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang đăng ký...',
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: AppDimensions.xl),
                        _buildRegisterCard(),
                        const SizedBox(height: AppDimensions.lg),
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo và tiêu đề
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'images/logo.jpg',
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.hotel,
                size: 80,
                color: AppColors.primary,
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        const Text(
          'Khách sạn Thanh Trà',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          'Đăng ký tài khoản mới',
          style: AppTextStyles.body2.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// Card đăng ký
  Widget _buildRegisterCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Đăng ký',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.lg),

              //  HỌ TÊN
              CustomTextField(
                controller: _nameController,
                label: 'Họ và tên',
                hint: 'Nhập họ và tên (VD: Nguyễn Văn A)',
                prefixIcon: Icons.person_outline,
                validator: _validateName,
              ),
              const SizedBox(height: AppDimensions.md),

              //  EMAIL
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'example@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: AppDimensions.md),

              //  SỐ ĐIỆN THOẠI
              CustomTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                hint: '0987654321',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: _validatePhone,
              ),
              const SizedBox(height: AppDimensions.md),

              //  CCCD/CMND
              CustomTextField(
                controller: _cccdController,
                label: 'CCCD/CMND',
                hint: '9 hoặc 12 chữ số',
                prefixIcon: Icons.credit_card_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: _validateCccd,
              ),
              const SizedBox(height: AppDimensions.md),

              //  MẬT KHẨU
              CustomTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Ít nhất 6 ký tự',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                validator: _validatePassword,
              ),
              const SizedBox(height: AppDimensions.md),

              //  XÁC NHẬN MẬT KHẨU
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixTap: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                validator: _validateConfirmPassword,
              ),

              const SizedBox(height: AppDimensions.xl),

              //  NÚT ĐĂNG KÝ
              PrimaryButton(
                text: 'Đăng ký',
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Link đăng nhập
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Đăng nhập ngay',
            style: AppTextStyles.button.copyWith(
              color: Colors.white,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}