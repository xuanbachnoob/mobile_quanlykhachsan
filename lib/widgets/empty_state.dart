import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';

/// Widget hiển thị khi không có dữ liệu
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon hoặc custom widget
            if (customIcon != null)
              customIcon!
            else
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),

            const SizedBox(height: AppDimensions.lg),

            // Title
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.sm),

            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.lg),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xl,
                    vertical: AppDimensions.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: Text(actionText!, style: AppTextStyles.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state cho không có phòng
class NoRoomsEmptyState extends StatelessWidget {
  final VoidCallback? onSearchAgain;

  const NoRoomsEmptyState({super.key, this.onSearchAgain});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.hotel_outlined,
      title: 'Không tìm thấy phòng',
      subtitle: 'Thử thay đổi bộ lọc hoặc tìm kiếm lại với ngày khác',
      actionText: 'Tìm kiếm lại',
      onAction: onSearchAgain,
    );
  }
}

/// Empty state cho chưa có booking
class NoBookingsEmptyState extends StatelessWidget {
  final VoidCallback? onBookNow;

  const NoBookingsEmptyState({super.key, this.onBookNow});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy_outlined,
      title: 'Chưa có đặt phòng',
      subtitle: 'Bạn chưa có lịch sử đặt phòng nào.\nHãy bắt đầu đặt phòng ngay!',
      actionText: 'Đặt phòng ngay',
      onAction: onBookNow,
    );
  }
}