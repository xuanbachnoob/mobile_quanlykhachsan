import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/API/auth_api_service.dart';
import 'package:mobile_quanlykhachsan/screens/chat_screen.dart';
import 'package:mobile_quanlykhachsan/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../models/loaiphong.dart';
import '../API/datphong_api_service.dart';
import '../providers/user_provider.dart';
import '../providers/booking_cart_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../utils/date_formatter.dart';
import 'search_result_screen.dart';
import '../widgets/room_detail_dialog.dart';
import 'profile_screen.dart';
import 'booking_history_screen.dart';
import 'change_password_screen.dart';

/// Màn hình Home hiện đại
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _guestCount = 2;

  List<Loaiphong> _roomTypes = [];
  bool _isLoading = true;
  bool _hasError = false;

  final _apiService = DatPhongApiService();

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final rooms = await _apiService.gettatcaloaiphong();
      setState(() {
        _roomTypes = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn ngày nhận - trả phòng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  void _search() {
    final cart = context.read<BookingCartProvider>();
    cart.updateSearchCriteria(_checkInDate, _checkOutDate);

    final searchFuture = _apiService.timVaNhomPhongTheoLoai(
      _checkInDate,
      _checkOutDate,
      _guestCount,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(
          searchFuture: searchFuture,
          checkInDate: _checkInDate,
          checkOutDate: _checkOutDate,
          guestCount: _guestCount,
        ),
      ),
    );
  }

  // ✅ THÊM METHODS XỬ LÝ MENU
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
        );
        break;
      case 'change_password':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
        );
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Logout
              await context.read<UserProvider>().logout();

              Navigator.of(context).pop();

              // Navigate to login - THAY ĐỔI Ở ĐÂY
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(user?.hoten ?? 'Khách'),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchCard(),
                const SizedBox(height: AppDimensions.lg),
                _buildRoomTypesSection(),
                
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      ),
      icon: const Icon(Icons.smart_toy, size: 24),
      label: const Text('Trợ lý AI', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF2196F3),
      elevation: 8,
    ),
    );
    
  }

  /// ✅ App Bar với PROFILE MENU
  Widget _buildAppBar(String userName) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // ✅ PROFILE MENU BUTTON
                      PopupMenuButton<String>(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào,',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: AppTextStyles.h4.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                        onSelected: _handleMenuSelection,
                        itemBuilder: (context) => [
                          // Thông tin cá nhân
                          const PopupMenuItem(
                            value: 'profile',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.person_outline),
                              title: Text('Thông tin cá nhân'),
                              dense: true,
                            ),
                          ),

                          // Lịch sử đặt phòng
                          const PopupMenuItem(
                            value: 'history',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.history),
                              title: Text('Lịch sử đặt phòng'),
                              dense: true,
                            ),
                          ),

                          // Đổi mật khẩu
                          const PopupMenuItem(
                            value: 'change_password',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.lock_outline),
                              title: Text('Đổi mật khẩu'),
                              dense: true,
                            ),
                          ),

                          const PopupMenuDivider(),

                          // Đăng xuất
                          const PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.red),
                              ),
                              dense: true,
                            ),
                          ),
                        ],
                      ),
 
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }

  /// Hero Search Card
  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary, size: 28),
              const SizedBox(width: AppDimensions.sm),
              Text('Tìm phòng của bạn', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Date selection
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày nhận - trả phòng',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormatter.formatDate(_checkInDate)} - ${DateFormatter.formatDate(_checkOutDate)}',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormatter.formatDuration(
                            _checkInDate,
                            _checkOutDate,
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Guest count
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số khách', style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        '$_guestCount người',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _guestCount > 1
                          ? AppColors.primary
                          : AppColors.textHint,
                      onPressed: _guestCount > 1
                          ? () => setState(() => _guestCount--)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      onPressed: () => setState(() => _guestCount++),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Search button
          PrimaryButton(
            text: 'Tìm kiếm phòng',
            onPressed: _search,
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  /// Room types section
  Widget _buildRoomTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loại phòng của chúng tôi', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {
                  // TODO: View all
                },
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        if (_isLoading)
          const SizedBox(height: 400, child: RoomListShimmer(itemCount: 2))
        else if (_hasError)
          SizedBox(
            height: 400,
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'Có lỗi xảy ra',
              subtitle: 'Không thể tải danh sách phòng',
              actionText: 'Thử lại',
              onAction: _loadRoomTypes,
            ),
          )
        else if (_roomTypes.isEmpty)
          const SizedBox(
            height: 400,
            child: EmptyState(
              icon: Icons.hotel_outlined,
              title: 'Chưa có phòng',
              subtitle: 'Hiện tại chưa có loại phòng nào',
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
            ),
            itemCount: _roomTypes.length,
            itemBuilder: (context, index) {
              return _buildRoomTypeCard(_roomTypes[index]);
            },
          ),
        const SizedBox(height: AppDimensions.xl),
      ],
    );
  }

  /// Room type card
  Widget _buildRoomTypeCard(Loaiphong room) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      elevation: AppDimensions.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showRoomDetailDialog(context, room),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.asset(
                'images/${room.HinhAnhUrl ?? 'placeholder.jpg'}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.Tenloaiphong,
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${room.Songuoitoida}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Icon(
                          Icons.king_bed_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text('${room.Sogiuong}', style: AppTextStyles.caption),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      formatter.format(room.Giacoban),
                      style: AppTextStyles.price.copyWith(fontSize: 16),
                    ),
                    Text('/ đêm', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
