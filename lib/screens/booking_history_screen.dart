import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/API/datphong_api_service.dart';
import 'package:mobile_quanlykhachsan/API/hoantien_api_service.dart';
import 'package:mobile_quanlykhachsan/API/review_api_service.dart';
import 'package:mobile_quanlykhachsan/models/chitiethoadon.dart';
import 'package:mobile_quanlykhachsan/models/datphong.dart';
import 'package:mobile_quanlykhachsan/models/chitietdatphong.dart';
import 'package:mobile_quanlykhachsan/models/denbuthiethai.dart';
import 'package:mobile_quanlykhachsan/models/hoadon.dart';
import 'package:mobile_quanlykhachsan/models/sudungdv.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
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
  int _reloadKey = 0;

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

  void _refresh() {
    setState(() {
      _reloadKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử đặt phòng'),
        elevation: 0,
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
          _buildBookingList('Đã đặt'),
          _buildBookingList('Đang ở'),
          _buildBookingList('Đã trả'),
          _buildBookingList('Đã hủy'),
        ],
      ),
    );
  }

  Widget _buildBookingList(String filter) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null || user.makh == null) {
      return const Center(child: NoBookingsEmptyState());
    }
    return FutureBuilder<List<Datphong>>(
      key: ValueKey('$filter-$_reloadKey'),
      future: DatPhongApiService().fetchDatphongs(user.makh!, filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: NoBookingsEmptyState());
        }

        final bookings = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return BookingCard(
              booking: bookings[index],
              onRefresh: _refresh,
            );
          },
        );
      },
    );
  }
}

/// Card hiển thị từng booking
class BookingCard extends StatefulWidget {
  final Datphong booking;
  final VoidCallback? onRefresh;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _hasReviewed = false;
  bool _isCheckingReview = false;

  @override
  void initState() {
    super.initState();
    // Chỉ check nếu trạng thái là "Đã trả"
    if (widget.booking.trangthai == 'Đã trả') {
      _checkReviewStatus();
    }
  }

  /// GỌI API CHECK REVIEW
  Future<void> _checkReviewStatus() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final madatphong = widget.booking.madatphong;

    if (user == null || user.makh == null || madatphong == null) return;

    setState(() => _isCheckingReview = true);

    try {
      final hasReviewed = await ReviewApiService.checkReview(
        makh: user.makh!,
        madatphong: madatphong,
      );

      if (!mounted) return;
      setState(() {
        _hasReviewed = hasReviewed;
        _isCheckingReview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasReviewed = false;
        _isCheckingReview = false;
      });
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  String _formatCurrency(int? value) {
    if (value == null) return '-';
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Đã đặt':
        return Colors.orange;
      case 'Đang ở':
        return Colors.blue;
      case 'Đã trả':
      case 'Hoàn tất':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.booking.chitietdatphongs ?? <Chitietdatphong>[];
    final sudungdv = widget.booking.sudungdichvus ?? <Sudungdv>[];
    final denbuthiethai = widget.booking.denbuthiethai ?? <Denbuthiethai>[];
    final chitiethoadon = widget.booking.chitiethoadons ?? <Chitiethoadon>[];
    final hoadon = widget.booking.hoadons ?? <Hoadon>[];
    final tongTien = hoadon.isNotEmpty ? hoadon.first.tongtien : 0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${widget.booking.madatphong ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Đặt phòng #${widget.booking.madatphong ?? '-'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${rooms.length} phòng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_note, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(widget.booking.ngaydat),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(widget.booking.trangthai).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.booking.trangthai ?? '-',
                        style: TextStyle(
                          color: _statusColor(widget.booking.trangthai),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.login, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(widget.booking.ngaynhanphong),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.logout, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(widget.booking.ngaytraphong),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payments, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Tổng cộng: ',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    Text(
                      _formatCurrency(tongTien),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            const SizedBox(height: 8),

            // Chi tiết phòng
            if (rooms.isNotEmpty) ...[
              _buildSectionHeader('Chi tiết phòng'),
              const SizedBox(height: 8),
              ...rooms.map((r) => _buildRoomItem(r)),
              const Divider(height: 24),
            ],

            // Dịch vụ
            if (sudungdv.isNotEmpty) ...[
              _buildSectionHeader('Dịch vụ đã sử dụng'),
              const SizedBox(height: 8),
              ...sudungdv.map(
                (s) => _buildServiceItem(
                  icon: Icons.room_service,
                  name: s.tendichvu ?? 'Dịch vụ',
                  quantity: s.soluong ?? 1,
                  price: s.dongia ?? 0,
                  total: s.tongtien ?? 0,
                ),
              ),
              const Divider(height: 24),
            ],

            // Đền bù thiết bị
            if (denbuthiethai.isNotEmpty) ...[
              _buildSectionHeader('Đền bù thiết bị'),
              const SizedBox(height: 8),
              ...denbuthiethai.map(
                (d) => _buildServiceItem(
                  icon: Icons.build_circle,
                  name: d.tenthietbi ?? 'Thiết bị',
                  quantity: d.soluong ?? 1,
                  price: d.dongia ?? 0,
                  total: d.tongtien ?? 0,
                ),
              ),
              const Divider(height: 24),
            ],

            // Chi tiết hóa đơn
            if (chitiethoadon.isNotEmpty) ...[
              _buildSectionHeader('Chi tiết thanh toán'),
              const SizedBox(height: 8),
              ...chitiethoadon.map(
                (c) => _buildFeeItem(c.loaiphi ?? 'Phí', c.dongia ?? 0),
              ),
              const Divider(height: 24),
            ],

            // Tổng hóa đơn
            if (hoadon.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatCurrency(hoadon.first.tongtien),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            if (widget.booking.trangthai == 'Đã đặt' ||
                widget.booking.trangthai == 'Đang ở' ||
                widget.booking.trangthai == 'Đã trả')
              Row(
                children: [
                  if (widget.booking.trangthai == 'Đang ở' || 
                      widget.booking.trangthai == 'Đã đặt')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showChangeRoomDialog(context),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Đổi phòng'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (widget.booking.trangthai == 'Đã đặt')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _cancelBooking(context),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Hủy phòng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  
                  // NÚT ĐÁNH GIÁ - CÓ KIỂM TRA
                  if (widget.booking.trangthai == 'Đã trả')
                    Expanded(
                      child: _isCheckingReview
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : _hasReviewed
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.grey, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Đã đánh giá',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _showReviewDialog(context),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.star, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Đánh giá',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRoomItem(Chitietdatphong room) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.meeting_room,
              size: 20,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số phòng: ${room.sophong ?? 'Phòng ${room.maphong ?? ''}'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (room.tenloaiphong != null)
                  Text(
                    room.tenloaiphong!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Text(
            _formatCurrency(room.tongcong),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String name,
    required int quantity,
    required int price,
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.orange.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_formatCurrency(price)} × $quantity',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

void _showChangeRoomDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //  HEADER
            const Text(
              'Yêu Cầu Đổi Phòng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // Màu xanh navy
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            //  THÔNG BÁO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // Màu vàng nhạt
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFFC107),
                  width: 1,
                ),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF856404),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Yêu cầu đổi phòng cần ',
                    ),
                    TextSpan(
                      text: 'được xác nhận bởi nhân viên',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' và ',
                    ),
                    TextSpan(
                      text: 'KHÔNG THỂ HỦY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                      text: ' sau khi duyệt.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            //  ĐƯỜNG KẺ
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 20),

            //  THÔNG TIN LIÊN HỆ
            const Text(
              'Vui lòng liên hệ trực tiếp:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 3 CÁCH LIÊN HỆ
            Row(
              children: [
                // HOTLINE
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone,
                    iconColor: const Color(0xFF2196F3),
                    label: 'Hotline',
                    value: '1900 9999',
                    onTap: () {
                      // TODO: Gọi điện
                      print('Calling 1900 9999');
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // EMAIL
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email,
                    iconColor: const Color(0xFF2196F3),
                    label: 'Email',
                    value: 'thanhtrakhachsan@gmail.com',
                    fontSize: 10,
                    onTap: () {
                      // TODO: Gửi email
                      print('Send email');
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // LỄ TÂN
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.business,
                    iconColor: const Color(0xFF2196F3),
                    label: 'Lễ tân',
                    value: 'Tầng 1 - Khách sạn',
                    fontSize: 10,
                    onTap: () {
                      print('Go to reception');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            //  NÚT ĐÓNG
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Đã hiểu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // Màu xanh navy
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//  CARD LIÊN HỆ
Widget _buildContactCard({
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  double fontSize = 12,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),

          // LABEL
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // VALUE
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

    void _cancelBooking(BuildContext context) async {
    final booking = widget.booking;
    final ngaynhanphong = booking.ngaynhanphong;
    final hoadon = booking.hoadons?.isNotEmpty == true ? booking.hoadons!.first : null;
    final tongtien = hoadon?.tongtien ?? 0;

    //  TÍNH THỜI GIAN TRƯỚC CHECKIN
    final now = DateTime.now();
    final hoursUntilCheckin = ngaynhanphong.difference(now).inHours;

    //  TÍNH TIỀN HOÀN
    int refundAmount = 0;
    String refundPolicy = '';
    Color policyColor = Colors.green;

    if (hoursUntilCheckin >= 48) {
      refundAmount = tongtien; // Hoàn 100%
      refundPolicy = 'Hoàn 100%';
      policyColor = Colors.green;
    } else if (hoursUntilCheckin >= 24) {
      refundAmount = (tongtien * 0.5).round(); // Hoàn 50%
      refundPolicy = 'Hoàn 50%';
      policyColor = Colors.orange;
    } else {
      refundAmount = 0; // Không hoàn
      refundPolicy = 'Không hoàn tiền';
      policyColor = Colors.red;
    }

    //  SHOW DIALOG CHÍNH SÁCH HỦY
    final selectedReason = await showDialog<String>(
      context: context,
      builder: (ctx) => _CancelPolicyDialog(
        hoursUntilCheckin: hoursUntilCheckin,
        refundPolicy: refundPolicy,
        refundAmount: refundAmount,
        policyColor: policyColor,
      ),
    );

    if (selectedReason == null || !context.mounted) return;

    //  SHOW LOADING
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

        try {
      // 1️ HỦY PHÒNG -  TRUYỀN LÝ DO
      await DatPhongApiService().huyphong(
        booking.madatphong!,
        lydo: selectedReason, //  THÊM PARAMETER NÀY
      );
      print(' Hủy phòng thành công\n');
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Đóng loading

      // REFRESH
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    refundAmount > 0
                        ? 'Hủy phòng thành công! Số tiền hoàn: ${_formatCurrency(refundAmount)}'
                        : 'Hủy phòng thành công!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print(' LỖI HỦY PHÒNG');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Không thể hủy phòng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showReviewDialog(BuildContext context) {
    final madatphong = widget.booking.madatphong;

    if (madatphong == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin đặt phòng')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        booking: widget.booking,
        madatphong: madatphong,
        onSuccess: () {
          //  Sau khi đánh giá thành công, cập nhật UI
          setState(() => _hasReviewed = true);
          if (widget.onRefresh != null) widget.onRefresh!();
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  REVIEW DIALOG WIDGET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ReviewDialog extends StatefulWidget {
  final Datphong booking;
  final int madatphong;
  final VoidCallback? onSuccess;

  const ReviewDialog({
    Key? key,
    required this.booking,
    required this.madatphong,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late TextEditingController _commentController;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rất tệ ';
      case 2:
        return 'Tệ ';
      case 3:
        return 'Bình thường ';
      case 4:
        return 'Tốt ';
      case 5:
        return 'Xuất sắc ';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nhận xét'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final makh = userProvider.currentUser?.makh;

    if (makh == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    // LƯU NAVIGATOR TRƯỚC KHI POP
    final navigator = Navigator.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop(); // Đóng review dialog

    // Show loading với root navigator
    rootNavigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    try {
      await ReviewApiService.submitReview(
        makh: makh,
        madatphong: widget.madatphong,
        sosao: _rating,
        danhgia: _commentController.text.trim(),
      );

      //  Đóng loading
      rootNavigator.pop();

      // Show success
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cảm ơn bạn đã đánh giá!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      //  Đóng loading
      rootNavigator.pop();

      // Show error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đánh giá dịch vụ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Chia sẻ trải nghiệm của bạn',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Booking info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.hotel, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đặt phòng #${widget.booking.madatphong}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        if (widget.booking.chitietdatphongs != null &&
                            widget.booking.chitietdatphongs!.isNotEmpty &&
                            widget.booking.chitietdatphongs!.first.tenloaiphong != null)
                          Text(
                            widget.booking.chitietdatphongs!.first.tenloaiphong!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating stars
            const Text(
              'Đánh giá của bạn',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Comment
            const Text(
              'Nhận xét',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn về chất lượng phòng, dịch vụ...',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submitReview,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Gửi đánh giá'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder( 
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANCEL POLICY DIALOG
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CancelPolicyDialog extends StatefulWidget {
  final int hoursUntilCheckin;
  final String refundPolicy;
  final int refundAmount;
  final Color policyColor;

  const _CancelPolicyDialog({
    required this.hoursUntilCheckin,
    required this.refundPolicy,
    required this.refundAmount,
    required this.policyColor,
  });

  @override
  State<_CancelPolicyDialog> createState() => _CancelPolicyDialogState();
}

class _CancelPolicyDialogState extends State<_CancelPolicyDialog> {
  String? _selectedReason;

  final List<String> _reasons = [
    'Thay đổi kế hoạch',
    'Tìm được chỗ ở tốt hơn',
    'Lý do cá nhân',
    'Khác',
  ];

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.policy,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chính sách hủy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              //  CHÍNH SÁCH FULL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoàn 100% nếu hủy trước 48h; Hoàn 50% nếu hủy trước 24h; Không hoàn tiền nếu hủy trong 24h.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const Divider(height: 24),

                    //  HỦY TRƯỚC 48H
                    _buildPolicyRow(
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      label: 'Hủy trước 48h:',
                      value: 'Hoàn 100%',
                      valueColor: Colors.green,
                      isActive: widget.hoursUntilCheckin >= 48,
                    ),
                    const SizedBox(height: 12),

                    //  HỦY TRƯỚC 24H
                    _buildPolicyRow(
                      icon: Icons.schedule,
                      iconColor: Colors.orange,
                      label: 'Hủy trước 24h:',
                      value: 'Hoàn 50%',
                      valueColor: Colors.orange,
                      isActive: widget.hoursUntilCheckin >= 24 && widget.hoursUntilCheckin < 48,
                    ),
                    const SizedBox(height: 12),

                    //  HỦY TRONG 24H
                    _buildPolicyRow(
                      icon: Icons.cancel,
                      iconColor: Colors.red,
                      label: 'Hủy trong 24h:',
                      value: 'Không hoàn tiền',
                      valueColor: Colors.red,
                      isActive: widget.hoursUntilCheckin < 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              //  SỐ TIỀN ĐƯỢC HOÀN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.policyColor.withOpacity(0.1),
                      widget.policyColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.policyColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.refundAmount > 0 ? Icons.account_balance_wallet : Icons.money_off,
                      color: widget.policyColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số tiền được hoàn',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.refundAmount > 0
                                ? _formatCurrency(widget.refundAmount)
                                : '0 ₫ (0%)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.policyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ WARNING (NẾU KHÔNG HOÀN TIỀN)
              if (widget.refundAmount == 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Lưu ý: Bạn sẽ không được hoàn tiền do hủy trong vòng 24h trước khi nhận phòng.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              //  LÝ DO HỦY PHÒNG
              const Text(
                'Lý do hủy phòng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedReason,
                    hint: const Text(
                      '-- Chọn lý do hủy --',
                      style: TextStyle(color: Colors.grey),
                    ),
                    isExpanded: true,
                    items: _reasons.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedReason = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //  BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.arrow_back, size: 18),
                          SizedBox(width: 8),
                          Text('Quay Lại'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedReason == null
                          ? null
                          : () => Navigator.pop(context, _selectedReason),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, size: 18),
                          SizedBox(width: 8),
                          Text('Xác Nhận Hủy'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? iconColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? iconColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? iconColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.black87 : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? valueColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}