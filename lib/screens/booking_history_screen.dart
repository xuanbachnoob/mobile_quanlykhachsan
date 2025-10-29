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
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đang ở'),
            Tab(text: 'Hoàn tất'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('upcoming'),
          _buildBookingList('in_progress'),
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
}