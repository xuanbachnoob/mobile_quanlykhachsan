import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/providers/booking_provider.dart';
import 'package:mobile_quanlykhachsan/screens/booking_confirmation_screen.dart';
import 'package:mobile_quanlykhachsan/screens/room_card.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../models/phongandloaiphong.dart';
import '../providers/booking_cart_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/primary_button.dart';
/// Màn hình kết quả tìm kiếm hiện đại
class SearchResultScreen extends StatefulWidget {
  final Future<List<Phongandloaiphong>> searchFuture;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;

  const SearchResultScreen({
    super.key,
    required this.searchFuture,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
  });

  @override
  State<SearchResultScreen> createState() =>
      _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String _sortBy = 'popular'; // popular, price_low, price_high, rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSummary(),
          _buildSortBar(),
          Expanded(
            child: FutureBuilder<List<Phongandloaiphong>>(
              future: widget.searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const RoomListShimmer(itemCount: 3);
                }

                if (snapshot.hasError) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Có lỗi xảy ra',
                    subtitle: 'Không thể tải danh sách phòng.\n${snapshot.error}',
                    actionText: 'Thử lại',
                    onAction: () {
                      setState(() {});
                    },
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return NoRoomsEmptyState(
                    onSearchAgain: () => Navigator.pop(context),
                  );
                }

                var rooms = snapshot.data!;
                rooms = _sortRooms(rooms);

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                    top: AppDimensions.sm,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return RoomCard(item: rooms[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildCartBottomSheet(),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Chọn phòng'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Show filter bottom sheet
          },
        ),
      ],
    );
  }

  /// Search summary
  Widget _buildSearchSummary() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      DateFormatter.formatDateRange(
                        widget.checkInDate,
                        widget.checkOutDate,
                      ),
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    Text(
                      '${widget.guestCount} người',
                      style: AppTextStyles.caption,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.xs,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormatter.formatDuration(
                        widget.checkInDate,
                        widget.checkOutDate,
                      ),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thay đổi'),
          ),
        ],
      ),
    );
  }

  /// Sort bar
  Widget _buildSortBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Sắp xếp:',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSortChip('Phổ biến', 'popular'),
                _buildSortChip('Giá thấp', 'price_low'),
                _buildSortChip('Giá cao', 'price_high'),
                _buildSortChip('Đánh giá', 'rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _sortBy = value;
            });
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
        ),
      ),
    );
  }

  /// Cart bottom sheet
  Widget _buildCartBottomSheet() {
  return Consumer<BookingCartProvider>(
    builder: (context, cart, child) {
      if (cart.selectedRooms.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showCartDetails(), // ✅ Show modal
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${cart.selectedRooms.length} phòng đã chọn',
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.xs),
                              const Icon(
                                Icons.keyboard_arrow_up,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tổng: ${CurrencyFormatter.format(cart.totalPrice)} VNĐ',
                            style: AppTextStyles.price.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.lg,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF66BB6A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'XEM CHI TIẾT',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  /// Show cart details bottom sheet
 void _showCartDetails() {
  final cart = context.read<BookingCartProvider>();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiết đặt phòng',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cart.selectedRooms.length} phòng',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Room list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  itemCount: cart.selectedRooms.length,
                  itemBuilder: (context, index) {
                    final room = cart.selectedRooms[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppDimensions.md),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Room image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              child: Image.asset(
                                'assets/images/${room.hinhanhphong.imageUrls.isNotEmpty ? room.hinhanhphong.imageUrls.first : "placeholder.jpg"}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.hotel,
                                      size: 32,
                                      color: AppColors.textHint,
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(width: AppDimensions.md),
                            
                            // Room info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room.loaiphong.Tenloaiphong,
                                    style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phòng ${room.phong.Sophong}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.sm),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${room.loaiphong.Songuoitoida} người',
                                        style: AppTextStyles.caption,
                                      ),
                                      const SizedBox(width: AppDimensions.md),
                                      Icon(
                                        Icons.king_bed_outlined,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${room.loaiphong.Sogiuong} giường',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.sm),
                                  Text(
                                    '${CurrencyFormatter.format(room.loaiphong.Giacoban)} VNĐ / đêm',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Delete button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () {
                                cart.removeRoom(room.phong.Maphong);
                                if (cart.selectedRooms.isEmpty) {
                                  Navigator.pop(context);
                                } else {
                                  setState(() {}); // Refresh modal
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Total and button
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Total price
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng cộng',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${CurrencyFormatter.format(cart.totalPrice)} VNĐ',
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: AppDimensions.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: Text(
                                'Chưa bao gồm dịch vụ',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.md),
                      
                      // Book button
                      PrimaryButton(
                        text: 'ĐẶT PHÒNG',
                        onPressed: () {
                          Navigator.pop(context); // Close modal
                          
                          // Navigate to booking confirmation
                          final booking = context.read<BookingProvider>();
                          booking.setSearchCriteria(
                            widget.checkInDate,
                            widget.checkOutDate,
                            widget.guestCount,
                          );
                          booking.setSelectedRooms(cart.selectedRooms);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookingConfirmationScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  /// Sort rooms
  List<Phongandloaiphong> _sortRooms(List<Phongandloaiphong> rooms) {
    switch (_sortBy) {
      case 'price_low':
        rooms.sort((a, b) => a.loaiphong.Giacoban.compareTo(b.loaiphong.Giacoban));
        break;
      case 'price_high':
        rooms.sort((a, b) => b.loaiphong.Giacoban.compareTo(a.loaiphong.Giacoban));
        break;
      case 'rating':
        // TODO: Sort by rating when available
        break;
      case 'popular':
      default:
        // Keep original order
        break;
    }
    return rooms;
  }
}