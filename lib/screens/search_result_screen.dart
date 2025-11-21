import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/API/voucher_api_service.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong_grouped.dart';
import 'package:mobile_quanlykhachsan/models/voucher.dart';
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
  final Future<List<LoaiphongGrouped>> searchFuture;
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
  String _sortBy = 'price_low'; // popular, price_low, price_high, rating
  final VoucherApiService _voucherService = VoucherApiService();
  Map<int, Voucher> _voucherMap = {};
  bool _loadingVouchers = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
  try {
    print('🔄 Loading vouchers for date: ${widget.checkInDate}');
    
    final vouchers = await _voucherService.getActiveVouchers(widget.checkInDate);
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📦 VOUCHERS LOADED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Total: ${vouchers.length} vouchers');
    
    for (var v in vouchers) {
      print('- ${v.tenvoucher}');
      print('  Mã loại phòng: ${v.maloaiphong}');
      print('  Giảm: ${v.giagiam} VNĐ');
      print('  Từ ${v.ngaybatdau} đến ${v.ngayketthuc}');
    }
    
    setState(() {
      _voucherMap = {
        for (var v in vouchers)
          if (v.maloaiphong != null) v.maloaiphong!: v
      };
      _loadingVouchers = false;
    });
    
    print('\n✅ Voucher Map created with keys: ${_voucherMap.keys.toList()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  } catch (e) {
    print('❌ Error loading vouchers: $e');
    setState(() => _loadingVouchers = false);
  }
}
  
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
            child: FutureBuilder<List<LoaiphongGrouped>>(
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

                var roomGroups = snapshot.data!;
                roomGroups = _sortRoomGroups(roomGroups);

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                    top: AppDimensions.sm,
                  ),
                  itemCount: roomGroups.length,
                  itemBuilder: (context, index) {
                    return _buildGroupedRoomCard(roomGroups[index]);
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

Widget _buildGroupedRoomCard(LoaiphongGrouped roomGroup) {
  return Consumer<BookingCartProvider>(
    builder: (context, cart, child) {
      final addedCount = cart.selectedRooms
          .where((r) => r.loaiphong.Maloaiphong == roomGroup.loaiphong.Maloaiphong)
          .length;
      final hasAvailableRoom = addedCount < roomGroup.danhsachphong.length;

      // ✅ LẤY VOUCHER
      final voucher = _voucherMap[roomGroup.loaiphong.Maloaiphong];
      final giagoc = roomGroup.loaiphong.Giacoban;
      final giagiam = voucher?.giagiam ?? 0;
      final giasaugiam = giagoc - giagiam;
      final hasDiscount = giagiam > 0;

      return Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        // ✅ THÊM STACK ĐỂ CHỨA RIBBON
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HÌNH ẢNH
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/${roomGroup.hinhanhphong.imageUrls.isNotEmpty ? roomGroup.hinhanhphong.imageUrls.first : "placeholder.jpg"}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.background,
                            child: const Center(
                              child: Icon(Icons.hotel, size: 64, color: AppColors.textHint),
                            ),
                          );
                        },
                      ),
                      
                      // BADGE PHÒNG TRỐNG
                      Positioned(
                        top: AppDimensions.md,
                        right: AppDimensions.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                            vertical: AppDimensions.sm,
                          ),
                          decoration: BoxDecoration(
                            color: hasAvailableRoom ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasAvailableRoom ? Icons.check_circle : Icons.info,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasAvailableRoom
                                    ? '${roomGroup.soluongtrong - addedCount} phòng trống'
                                    : 'Đã chọn hết',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TÊN LOẠI PHÒNG
                      Text(roomGroup.loaiphong.Tenloaiphong, style: AppTextStyles.h3),
                      const SizedBox(height: AppDimensions.sm),
                      
                      // THÔNG TIN
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${roomGroup.loaiphong.Songuoitoida} người', style: AppTextStyles.caption),
                          const SizedBox(width: AppDimensions.md),
                          Icon(Icons.king_bed_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${roomGroup.loaiphong.Sogiuong} giường', style: AppTextStyles.caption),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.sm),
                      
                      // MÔ TẢ
                      if (roomGroup.loaiphong.Mota != null)
                        Text(
                          roomGroup.loaiphong.Mota!,
                          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: AppDimensions.md),

                      // ✅ GIÁ VÀ BUTTON
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Giá từ', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                
                                // ✅ GIÁ GỐC (GẠCH NGANG NẾU CÓ VOUCHER)
                                if (hasDiscount) ...[
                                  Text(
                                    '${CurrencyFormatter.format(giagoc)} VNĐ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                
                                // ✅ GIÁ SAU GIẢM
                                Text(
                                  '${CurrencyFormatter.format(giasaugiam)} VNĐ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: hasDiscount ? Colors.red : AppColors.primary,
                                  ),
                                ),
                                
                                Text('/ đêm', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          
                          // NÚT THÊM
                          ElevatedButton.icon(
                            onPressed: hasAvailableRoom ? () => _autoAddRoom(roomGroup, cart) : null,
                            icon: Icon(hasAvailableRoom ? Icons.add_shopping_cart : Icons.check, size: 18),
                            label: Text(hasAvailableRoom ? 'Thêm vào giỏ' : 'Đã chọn hết'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasAvailableRoom ? AppColors.primary : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.lg,
                                vertical: AppDimensions.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ RIBBON VOUCHER GÓC TRÊN TRÁI
            if (hasDiscount)
              Positioned(
                top: 0,
                left: 0,
                child: CustomPaint(
                  painter: RibbonPainter(),
                  child: Container(
                    width: 140,
                    height: 36,
                    padding: const EdgeInsets.only(left: 8, top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            voucher!.tenvoucher,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

void _autoAddRoom(LoaiphongGrouped roomGroup, BookingCartProvider cart) {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🤖 AUTO ADD ROOM');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Loại phòng: ${roomGroup.loaiphong.Tenloaiphong}');
  print('Mã loại phòng: ${roomGroup.loaiphong.Maloaiphong}');
  
  // Kiểm tra voucher map
  print('🔍 Voucher Map contains ${_voucherMap.length} vouchers');
  print('🔍 Voucher Map Keys: ${_voucherMap.keys.toList()}');
  
  // Lấy voucher
  final voucher = _voucherMap[roomGroup.loaiphong.Maloaiphong];
  
  if (voucher != null) {
    print('✅ Found voucher:');
    print('   - Tên: ${voucher.tenvoucher}');
    print('   - Giảm: ${voucher.giagiam} VNĐ');
    print('   - Mã loại phòng: ${voucher.maloaiphong}');
  } else {
    print('❌ No voucher found for this room type');
  }
  
  final addedRoomIds = cart.selectedRooms
      .where((r) => r.loaiphong.Maloaiphong == roomGroup.loaiphong.Maloaiphong)
      .map((r) => r.phong.Maphong)
      .toSet();
  
  print('Phòng đã thêm: $addedRoomIds');
  
  final availableRoom = roomGroup.danhsachphong.firstWhere(
    (phong) => !addedRoomIds.contains(phong.Maphong),
    orElse: () => throw Exception('Không còn phòng trống'),
  );
  
  print('Tự động chọn phòng: ${availableRoom.Sophong} (ID: ${availableRoom.Maphong})');
  
  // Tạo object phòng với voucher
  final roomToAdd = Phongandloaiphong(
    phong: availableRoom,
    loaiphong: roomGroup.loaiphong,
    hinhanhphong: roomGroup.hinhanhphong,
    voucher: voucher, // ← QUAN TRỌNG
  );
  
  print('🔍 Voucher attached: ${roomToAdd.voucher != null}');
  print('🔍 Has discount: ${roomToAdd.hasVoucher}');
  print('🔍 Giá sau giảm: ${roomToAdd.giaSauGiam} VNĐ');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  cart.addRoom(roomToAdd);
}

// ✅ XEM PHÒNG ĐÃ THÊM CỦA LOẠI NÀY
void _showAddedRooms(LoaiphongGrouped roomGroup) {
  final cart = context.read<BookingCartProvider>();
  final addedRooms = cart.selectedRooms
      .where((r) => r.loaiphong.Maloaiphong == roomGroup.loaiphong.Maloaiphong)
      .toList();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phòng đã thêm - ${roomGroup.loaiphong.Tenloaiphong}',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.md),
          ...addedRooms.map((room) => ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                '${room.phong.Sophong}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text('Phòng ${room.phong.Sophong}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                cart.removeRoom(room.phong.Maphong);
                if (addedRooms.length == 1) {
                  Navigator.pop(context);
                }
              },
            ),
          )),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    ),
  );
}

  
  // ✅ SORT ROOM GROUPS
  List<LoaiphongGrouped> _sortRoomGroups(List<LoaiphongGrouped> groups) {
    switch (_sortBy) {
      case 'price_low':
        groups.sort((a, b) => a.loaiphong.Giacoban.compareTo(b.loaiphong.Giacoban));
        break;
      case 'price_high':
        groups.sort((a, b) => b.loaiphong.Giacoban.compareTo(a.loaiphong.Giacoban));
        break;
      case 'rating':
        // TODO: Sort by rating
        break;
      case 'popular':
      default:
        break;
    }
    return groups;
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
                _buildSortChip('Giá thấp', 'price_low'),
                _buildSortChip('Giá cao', 'price_high'),
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
                                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Giá gốc (nếu có voucher)
    if (room.hasVoucher) ...[
      Text(
        '${CurrencyFormatter.format(room.loaiphong.Giacoban)} VNĐ',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
        ),
      ),
      const SizedBox(height: 2),
    ],
    
    // Giá sau giảm
    Row(
      children: [
        Text(
          '${CurrencyFormatter.format(room.giaSauGiam)} VNĐ',
          style: AppTextStyles.body2.copyWith(
            color: room.hasVoucher ? Colors.red : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(' / đêm', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
    
    // Badge voucher
    if (room.hasVoucher)
      Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer, size: 10, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              room.voucher!.tenvoucher,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
  ],
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
}
class RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 8, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 8, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}