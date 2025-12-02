import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/providers/user_provider.dart';
import 'package:mobile_quanlykhachsan/screens/login_screen.dart';
import 'package:mobile_quanlykhachsan/API/auth_api_service.dart';  // ✅ THÊM
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authApi = AuthApiService();  //  THÊM API SERVICE

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    //  GET USER FROM PROVIDER
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final emailOrSdt = user.email ?? user.sdt ?? '';

    if (emailOrSdt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy email hoặc số điện thoại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {



      final message = await _authApi.changePassword(
        emailOrSdt: emailOrSdt,
        oldPassword: currentPassword,
        newPassword: newPassword,
      );

      print('✅ Password changed successfully!');
      print('Message: $message\n');

      if (!mounted) return;

      //  LOGOUT SAU KHI ĐỔI MẬT KHẨU
      await userProvider.logout();

      //  SHOW SUCCESS DIALOG
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Thành công'),
            ],
          ),
          content: Text(
            '$message\n\nVui lòng đăng nhập lại.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog

                //  Navigate to login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Đăng nhập lại'),
            ),
          ],
        ),
      );
    } catch (e) {
      print(' Change password failed: $e\n');

      if (!mounted) return;

      //  SHOW ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Title
                Text(
                  'Đổi mật khẩu',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Nhập mật khẩu hiện tại và mật khẩu mới của bạn',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),

                // Current password
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Mật khẩu hiện tại',
                  hintText: 'Nhập mật khẩu hiện tại',
                  obscureText: _obscureCurrentPassword,
                  onToggleVisibility: () {
                    setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu hiện tại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.lg),

                // New password
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'Mật khẩu mới',
                  hintText: 'Nhập mật khẩu mới',
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppDimensions.lg),

                // Confirm password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu mới',
                  hintText: 'Nhập lại mật khẩu mới',
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.sm),

                // Password requirements
                _buildPasswordRequirements(),

                const SizedBox(height: AppDimensions.xl),

                // Submit button
                PrimaryButton(
                  text: 'Đổi mật khẩu',
                  onPressed: _isLoading ? null : _changePassword,
                  isLoading: _isLoading,
                  icon: Icons.lock_reset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppDimensions.sm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Yêu cầu mật khẩu:',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          _buildRequirementItem('Ít nhất 6 ký tự'),
          _buildRequirementItem('Chữ cái đầu viết hoa'),
          _buildRequirementItem('Có ít nhất 1 chữ số'),
          _buildRequirementItem('Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*)'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  //  VALIDATE MẬT KHẨU MẠNH
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    // Kiểm tra chữ cái đầu viết hoa
    if (!RegExp(r'^[A-Z]').hasMatch(value)) {
      return 'Chữ cái đầu phải viết hoa';
    }

    // Kiểm tra có chữ số
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }

    // Kiểm tra có ký tự đặc biệt
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    }

    //  KIỂM TRA KHÁC MẬT KHẨU CŨ
    if (value == _currentPasswordController.text) {
      return 'Mật khẩu mới phải khác mật khẩu hiện tại';
    }

    return null;
  }
}