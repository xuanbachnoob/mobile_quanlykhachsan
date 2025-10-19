import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phongandloaiphong.dart';
import '../providers/booking_cart_provider.dart';
import 'room_card.dart';
import '../utils/currency_formatter.dart';

class SearchResultScreen extends StatelessWidget {
  final Future<List<Phongandloaiphong>> searchFuture;
  // Nhận cả ngày để hiển thị
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phòng'), elevation: 1),
      body: Column(
        children: [
          // 1. Thanh tóm tắt tìm kiếm (thay cho thanh tím)
          _buildStickySearchSummary(context),

          // 2. Danh sách phòng
          Expanded(
            child: FutureBuilder<List<Phongandloaiphong>>(
              future: searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không tìm thấy phòng nào.'));
                }

                final results = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // Chừa chỗ cho thanh bottom
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    // 3. Gọi Card Phòng (Widget riêng)
                    return RoomCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 4. Thanh tóm tắt "Giỏ hàng" (thay cho sidebar)
      bottomSheet: _buildBookingSummary(context),
    );
  }

  /// Thanh tóm tắt tìm kiếm (nằm cố định)
  Widget _buildStickySearchSummary(BuildContext context) {
    // 1. TÍNH TOÁN SỐ ĐÊM VÀ SỐ NGÀY
    // Lấy số đêm (ví dụ: 20/10 - 19/10 = 1)
    final int numberOfNights = checkOutDate.difference(checkInDate).inDays;
    // Số ngày luôn là số đêm + 1
    final int numberOfDays = numberOfNights + 1;
    // Tạo chuỗi hiển thị
    final String durationText = "$numberOfDays ngày $numberOfNights đêm";

    // 2. ĐỊNH DẠNG NGÀY (dùng intl)
    // Bạn có thể dùng DateFormat('dd/MM') nếu muốn
    String checkIn = "${checkInDate.day}/${checkInDate.month}";
    String checkOut = "${checkOutDate.day}/${checkOutDate.month}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngày: $checkIn - $checkOut',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2), // Khoảng cách nhỏ
              // 3. HIỂN THỊ SỐ NGƯỜI VÀ SỐ ĐÊM TRÊN CÙNG 1 HÀNG
              Row(
                children: [
                  Text(
                    '$guestCount người',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  // Dấu chấm phân cách
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      Icons.circle,
                      size: 4,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    durationText, // <-- Hiển thị chuỗi mới
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // Quay lại màn hình tìm kiếm để sửa
              Navigator.pop(context);
            },
            child: const Text('Thay đổi'),
          ),
        ],
      ),
    );
  }

  /// Thanh tóm tắt "Giỏ hàng" (chỉ hiện khi có phòng)
  Widget _buildBookingSummary(BuildContext context) {
    // Dùng Consumer để tự động cập nhật khi giỏ hàng thay đổi
    return Consumer<BookingCartProvider>(
      builder: (context, cart, child) {
        if (cart.selectedRooms.isEmpty) {
          return const SizedBox.shrink(); // Ẩn đi
        }

        // 1. BỌC BẰNG INKWELL VÀ GỌI HÀM _showCartDetails
        return InkWell(
          onTap: () => _showCartDetails(context), // <--- GỌI DIALOG CHI TIẾT
          child: Container(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [/* ... box shadow ... */],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- PHẦN BÊN TRÁI (TÓM TẮT) ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thêm icon mũi tên lên cho trực quan
                    Row(
                      children: [
                        Text(
                          '${cart.selectedRooms.length} phòng đã chọn',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.keyboard_arrow_up,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    Text(
                      'Tổng cộng: ${CurrencyFormatter.format(cart.totalPrice)} VNĐ',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // --- PHẦN BÊN PHẢI (NÚT ĐẶT NGAY) ---
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 6, 177, 28),
                  ),
                  child: const Text(
                    'ĐẶT NGAY',
                    style: TextStyle(color: Color.fromARGB(255, 251, 251, 251)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. HÀM MỚI ĐỂ HIỂN THỊ BOTTOM SHEET CHI TIẾT
  void _showCartDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép sheet cao hơn nửa màn hình
      shape: const RoundedRectangleBorder(
        // Bo tròn góc trên
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext innerContext) {
        // Dùng Consumer ở đây để dialog tự cập nhật khi xóa
        return Consumer<BookingCartProvider>(
          builder: (context, cart, child) {
            // Nếu giỏ hàng rỗng (vừa xóa hết), tự đóng dialog
            if (cart.selectedRooms.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(innerContext);
              });
              return const SizedBox.shrink(); // Trả về widget trống trong khi chờ đóng
            }

            return DraggableScrollableSheet(
              expand: false, // Không cho kéo full màn hình
              initialChildSize: 0.5, // Chiều cao ban đầu (50% màn hình)
              minChildSize: 0.3, // Chiều cao nhỏ nhất khi kéo xuống
              maxChildSize: 0.8, // Chiều cao lớn nhất khi kéo lên
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Thanh kéo nhỏ ở trên cùng (cho đẹp)
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Tiêu đề
                      Text(
                        'Phòng đã chọn (${cart.selectedRooms.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(height: 20),
                      // Danh sách phòng
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController, // Gắn scroll controller
                          itemCount: cart.selectedRooms.length,
                          itemBuilder: (context, index) {
                            final item = cart.selectedRooms[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.king_bed,
                              ), // Thay bằng ảnh nhỏ nếu muốn
                              title: Text(item.loaiphong.Tenloaiphong),
                              subtitle: Text('Phòng: ${item.phong.Sophong}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${item.loaiphong.Giacoban} VNĐ'),
                                  // Nút xóa
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Gọi hàm xóa (dùng context.read vì đang trong onPressed)
                                      context
                                          .read<BookingCartProvider>()
                                          .removeRoom(item.phong.Maphong);
                                      // Không cần pop dialog, Consumer sẽ tự cập nhật
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
