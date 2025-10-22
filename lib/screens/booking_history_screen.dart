import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../providers/user_provider.dart';
import '../widgets/empty_state.dart';

/// Màn hình lịch sử đặt phòng
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử đặt phòng'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('all'),
          _buildBookingList('upcoming'),
          _buildBookingList('completed'),
          _buildBookingList('cancelled'),
        ],
      ),
    );
  }

  /// Build booking list theo filter
  Widget _buildBookingList(String filter) {
    // TODO: Fetch bookings from API
    // For now, show empty state
    return const Center(
      child: NoBookingsEmptyState(),
    );
  }

  /// Booking card
  Widget _buildBookingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      elevation: AppDimensions.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to booking detail
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLg),
              ),
              child: Image.asset(
                'images/placeholder.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: AppColors.background,
                    child: const Icon(
                      Icons.hotel,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking code and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BK123456',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusBadge('confirmed'),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.sm),

                  // Room name
                  Text(
                    'Phòng Standard',
                    style: AppTextStyles.h4,
                  ),

                  const SizedBox(height: AppDimensions.sm),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        '19-20/10/2024',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.sm),

                  const Divider(),

                  const SizedBox(height: AppDimensions.sm),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng tiền',
                        style: AppTextStyles.body2,
                      ),
                      Text(
                        '500.000 VNĐ',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status badge
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'Chờ xác nhận';
        break;
      case 'confirmed':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Đã xác nhận';
        break;
      case 'completed':
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        label = 'Hoàn thành';
        break;
      case 'cancelled':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        label = 'Đã hủy';
        break;
      default:
        bgColor = AppColors.background;
        textColor = AppColors.textPrimary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}