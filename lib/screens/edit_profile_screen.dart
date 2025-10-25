import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/API/khachhang_api_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../API/auth_api_service.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../models/khachhang.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authApi = AuthApiService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cccdController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final user = context.read<UserProvider>().currentUser;
    
    _nameController = TextEditingController(text: user?.hoten ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.sdt ?? '');
    _cccdController = TextEditingController(text: user?.cccd ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final userProvider = context.read<UserProvider>();
  final user = userProvider.currentUser;

  if (user == null || user.makh == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng đăng nhập trước'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // ✅ GỌI API VỚI CHỈ 4 FIELDS
    final result = await KhachhangApiService().updateProfile(
      makh: user.makh!,
      hoten: _nameController.text.trim(),
      email: _emailController.text.trim(),
      sdt: _phoneController.text.trim(),
      cccd: _cccdController.text.trim(),
    );

    if (!mounted) return;

    // ✅ UPDATE PROVIDER
    final updatedUser = user.copyWith(
      hoten: _nameController.text.trim(),
      email: _emailController.text.trim(),
      sdt: _phoneController.text.trim(),
      cccd: _cccdController.text.trim(),
    );

    userProvider.setUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Cập nhật thành công!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
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
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                Text(
                  'Cập nhật thông tin cá nhân',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.sm),
                
                Text(
                  'Chỉ có thể cập nhật: Họ tên, Email, SĐT, CCCD',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),

                // ✅ HỌ TÊN
                _buildTextField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ✅ EMAIL
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ✅ SỐ ĐIỆN THOẠI
                _buildTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Số điện thoại phải có 10 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ✅ CCCD
                _buildTextField(
                  controller: _cccdController,
                  label: 'CCCD/CMND',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập CCCD/CMND';
                    }
                    if (!RegExp(r'^\d{9}$|^\d{12}$').hasMatch(value)) {
                      return 'CCCD/CMND phải là 9 hoặc 12 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.xl),

                // ✅ INFO - ĐIỂM THÀNH VIÊN
                if (user?.diemthanhvien != null)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Điểm thành viên không thể chỉnh sửa',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Điểm hiện tại: ${user?.diemthanhvien} điểm',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppDimensions.xl),

                // ✅ SAVE BUTTON
                PrimaryButton(
                  text: 'Lưu thay đổi',
                  onPressed: _isLoading ? null : _updateProfile,
                  isLoading: _isLoading,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            prefixIcon: Icon(icon),
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
}