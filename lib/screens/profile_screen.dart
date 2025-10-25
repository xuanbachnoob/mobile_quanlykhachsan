import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ HEADER WITH AVATAR
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppDimensions.xl),

                        // Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Text(
                              (user.hoten ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.md),

                        // Name
                        Text(
                          user.hoten ?? 'Người dùng',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),

                        const SizedBox(height: AppDimensions.xs),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                            vertical: AppDimensions.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Text(
                            user.role == 'customer'
                                ? 'Khách hàng'
                                : user.role ?? 'Khách hàng',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.xl),
                      ],
                    ),
                  ),

                  // ✅ INFORMATION CARDS
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.md),

                        // ✅ ĐIỂM THÀNH VIÊN (NẾU CÓ)
                        if (user.diemthanhvien != null)
                          _buildPointsCard(user.diemthanhvien!),
                        const SizedBox(height: AppDimensions.lg),
                        // ✅ HỌ TÊN
                        _buildInfoCard(
                          icon: Icons.person_outline,
                          label: 'Họ và tên',
                          value: user.hoten ?? 'Chưa cập nhật',
                          iconColor: AppColors.primary,
                        ),

                        // ✅ EMAIL
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email ?? 'Chưa cập nhật',
                          iconColor: Colors.orange,
                        ),

                        // ✅ SỐ ĐIỆN THOẠI
                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          label: 'Số điện thoại',
                          value: user.sdt ?? 'Chưa cập nhật',
                          iconColor: Colors.green,
                        ),

                        // ✅ CCCD
                        _buildInfoCard(
                          icon: Icons.credit_card_outlined,
                          label: 'CCCD/CMND',
                          value: user.cccd ?? 'Chưa cập nhật',
                          iconColor: Colors.purple,
                        ),

                        const SizedBox(height: AppDimensions.xl),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Chỉnh sửa thông tin'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.md,
                              ),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ✅ EDIT BUTTON (OPTIONAL)
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton.icon(
                        //     onPressed: () {
                        //       // TODO: Navigate to edit profile
                        //     },
                        //     icon: const Icon(Icons.edit),
                        //     label: const Text('Chỉnh sửa thông tin'),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.primary,
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: AppDimensions.md,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// ✅ CARD ĐIỂM THÀNH VIÊN
  Widget _buildPointsCard(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm thành viên',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$points điểm',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.7),
            size: 16,
          ),
        ],
      ),
    );
  }

  /// ✅ CARD THÔNG TIN
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      elevation: AppDimensions.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(width: AppDimensions.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
