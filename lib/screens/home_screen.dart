import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/phongandloaiphong.dart';
import 'package:mobile_quanlykhachsan/providers/booking_cart_provider.dart';
import 'package:mobile_quanlykhachsan/screens/search_result_screen.dart';
import '../API/datphong_api_service.dart';
import 'package:provider/provider.dart';

// Represents the main screen of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _roomCount = 1;
  int _guestCount = 2;

  // Mock data for room types
  final List<Loaiphong> phongdaydu = [];
  void layphongdaydu() {
    DatPhongApiService().gettatcaloaiphong().then((value) {
      setState(() {
        phongdaydu.addAll(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    layphongdaydu();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to show the date range picker
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
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
              primary: Color(0xFF007BFF),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked.start != _checkInDate) {
      // Ensure checkout date is always after check-in date
      final newCheckOut =
          picked.end.isBefore(picked.start.add(const Duration(days: 1)))
          ? picked.start.add(const Duration(days: 1))
          : picked.end;

      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = newCheckOut;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'images/bg_mobile.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Scrollable Content
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchFilterCard(),
                        const SizedBox(height: 24),
                        _buildRoomTypesSection(),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Builds the top AppBar
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.blue,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khách sạn Thanh Trà',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              shadows: [
                Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(backgroundImage: AssetImage('images/logo.jpg')),
        ),
      ],
    );
  }

  // Builds the search and filter card with blur effect
  Widget _buildSearchFilterCard() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ngày nhận - trả phòng',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${formatter.format(_checkInDate)} - ${formatter.format(_checkOutDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Số phòng',
                      _roomCount,
                      Icons.king_bed_outlined,
                      (val) {
                        if (val != null) setState(() => _roomCount = val);
                      },
                      [1, 2, 3, 4],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      'Số người',
                      _guestCount,
                      Icons.person_outline,
                      (val) {
                        if (val != null) setState(() => _guestCount = val);
                      },
                      [1, 2, 3, 4, 5, 6],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 1. LẤY GIỎ HÀNG (DÙNG .read() VÌ Ở TRONG HÀM)
                    final cart = context.read<BookingCartProvider>();

                    // 2. GỌI HÀM MỚI: Cập nhật ngày và xóa giỏ hàng cũ
                    cart.updateSearchCriteria(_checkInDate, _checkOutDate);

                    // 3. Tạo "lời hứa" (Future)
                    final Future<List<Phongandloaiphong>> searchFuture =
                        DatPhongApiService().timVaLayThongTinPhongDayDu(
                          _checkInDate,
                          _checkOutDate,
                        );

                    // 4. Chuyển màn hình
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(
                          searchFuture: searchFuture,
                          // Vẫn truyền ngày sang để màn hình kết quả hiển thị
                          checkInDate: _checkInDate,
                          checkOutDate: _checkOutDate,
                          guestCount: _guestCount,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tìm kiếm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build dropdown menus for the new style
  Widget _buildDropdown(
    String title,
    int value,
    IconData icon,
    void Function(int?) onChanged,
    List<int> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          items: items.map((int val) {
            return DropdownMenuItem<int>(
              value: val,
              child: Text('$val', style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: Colors.grey[200],
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Builds the "Room Types" section with better contrast
  Widget _buildRoomTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại phòng của khách sạn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.7)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          itemCount: phongdaydu.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildRoomTypeCard(phongdaydu[index]);
          },
        ),
      ],
    );
  }

  // Builds a single card for a room type
  Widget _buildRoomTypeCard(Loaiphong room) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'images/' + room.HinhAnhUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.Tenloaiphong,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.person_outline,
                      '${room.Songuoitoida} người',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.king_bed_outlined,
                      '${room.Sogiuong} giường',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    currencyFormatter.format(room.Giacoban),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build small info chips
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF495057)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF495057))),
        ],
      ),
    );
  }

  // Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Tìm kiếm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Đặt chỗ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF007BFF),
      unselectedItemColor: Colors.grey[600],
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 5,
      backgroundColor: Colors.white,
    );
  }
}
