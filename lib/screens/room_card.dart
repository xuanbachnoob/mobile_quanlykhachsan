import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phongandloaiphong.dart';
import '../providers/booking_cart_provider.dart';
import '../utils/currency_formatter.dart';
// 1. Chuyển thành StatefulWidget để quản lý PageView
class RoomCard extends StatefulWidget {
  final Phongandloaiphong item;
  const RoomCard({super.key, required this.item});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Để theo dõi ảnh hiện tại cho indicator

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<BookingCartProvider>();
    final bool isSelected = cart.isRoomSelected(widget.item.phong.Maphong);

    // 2. Lấy danh sách ảnh từ getter mới trong model
    final List<String> imageUrls = widget.item.hinhanhphong.imageUrls;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Để bo tròn ảnh
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. THAY THẾ IMAGE BẰNG STACK (CHỨA PAGEVIEW VÀ INDICATOR)
          Stack(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    
                    // ⚠️ LƯU Ý: Nếu API của bạn chỉ trả về tên file (vd: "phong1.jpg")
                    // bạn phải nối nó với địa chỉ gốc của server
                    // final String fullUrl = 'https://diachiAPIcuaban.com/images/' + imageUrls[index];
                    
                    // Nếu API đã trả về URL đầy đủ, dùng thẳng
                    final String fullUrl ='images/' + imageUrls[index];

                    return Image.asset(
                      fullUrl,
                    );
                  },
                ),
              ),
              // Indicator (các chấm tròn)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageUrls.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 12.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // 2. Tên phòng (Sử dụng widget.item)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              widget.item.loaiphong.Tenloaiphong,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 3. Tiện ích (giường, số người)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFeatureIcon(Icons.king_bed_outlined, '${widget.item.loaiphong.Sogiuong} giường'),
                const SizedBox(width: 16),
                _buildFeatureIcon(Icons.person_outline, '${widget.item.loaiphong.Songuoitoida} người'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Giá và Nút chọn
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Giá
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${CurrencyFormatter.format(widget.item.loaiphong.Giacoban)} VNĐ',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' / đêm', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                // Nút "Chọn" hoặc "Hủy"
                ElevatedButton(
                  onPressed: () {
                    final cartProvider = context.read<BookingCartProvider>();
                    if (isSelected) {
                      cartProvider.removeRoom(widget.item.phong.Maphong);
                    } else {
                      cartProvider.addRoom(widget.item);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.grey : const Color(0xFFFFC107),
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  child: Text(isSelected ? 'Đã chọn' : 'Chọn phòng'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget con cho tiện ích (giường, người)
  Widget _buildFeatureIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 18),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}