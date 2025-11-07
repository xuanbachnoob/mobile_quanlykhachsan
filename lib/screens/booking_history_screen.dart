import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/API/datphong_api_service.dart';
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
        automaticallyImplyLeading: false,
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

/// Card hiển thị từng booking - REDESIGNED
class BookingCard extends StatelessWidget {
  final Datphong booking;
  final VoidCallback? onRefresh;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onRefresh,
  }) : super(key: key);

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
    final rooms = booking.chitietdatphongs ?? <Chitietdatphong>[];
    final sudungdv = booking.sudungdichvus ?? <Sudungdv>[];
    final denbuthiethai = booking.denbuthiethai ?? <Denbuthiethai>[];
    final chitiethoadon = booking.chitiethoadons ?? <Chitiethoadon>[];
    final hoadon = booking.hoadons ?? <Hoadon>[];
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
                '${booking.madatphong ?? 0}',
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
                  'Đặt phòng #${booking.madatphong ?? '-'}',
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
                // Date & Status
                Row(
                  children: [
                    Icon(Icons.event_note, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(booking.ngaydat),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(booking.trangthai).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.trangthai ?? '-',
                        style: TextStyle(
                          color: _statusColor(booking.trangthai),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Check-in / Check-out
                Row(
                  children: [
                    Icon(Icons.login, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(booking.ngaynhanphong),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.logout, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(booking.ngaytraphong),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Total
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
              ...sudungdv.map((s) => _buildServiceItem(
                icon: Icons.room_service,
                name: s.tendichvu ?? 'Dịch vụ',
                quantity: s.soluong ?? 1,
                price: s.dongia ?? 0,
                total: s.tongtien ?? 0,
              )),
              const Divider(height: 24),
            ],

            // Đền bù thiết bị
            if (denbuthiethai.isNotEmpty) ...[
              _buildSectionHeader('Đền bù thiết bị'),
              const SizedBox(height: 8),
              ...denbuthiethai.map((d) => _buildServiceItem(
                icon: Icons.build_circle,
                name: d.tenthietbi ?? 'Thiết bị',
                quantity: d.soluong ?? 1,
                price: d.dongia ?? 0,
                total: d.tongtien ?? 0,
              )),
              const Divider(height: 24),
            ],

            // Chi tiết hóa đơn
            if (chitiethoadon.isNotEmpty) ...[
              _buildSectionHeader('Chi tiết thanh toán'),
              const SizedBox(height: 8),
              ...chitiethoadon.map((c) => _buildFeeItem(
                c.loaiphi ?? 'Phí',
                c.dongia ?? 0,
              )),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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


            if (booking.trangthai == 'Đã đặt' || booking.trangthai == 'Đang ở')
              Row(
                children: [
                  if (booking.trangthai == 'Đã đặt')
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
                  if (booking.trangthai == 'Đang ở')
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
            child: Icon(Icons.meeting_room, size: 20, color: Colors.blue.shade700),
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
                child: Icon(Icons.receipt_long, size: 20, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeRoomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'UI đổi phòng (booking #${booking.madatphong})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _cancelBooking(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận hủy phòng'),
        content: const Text('Bạn có chắc chắn muốn hủy đặt phòng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy phòng'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await DatPhongApiService().huyphong(booking.madatphong!);
      Navigator.of(context).pop(); // close loading
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hủy đặt phòng thành công')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}