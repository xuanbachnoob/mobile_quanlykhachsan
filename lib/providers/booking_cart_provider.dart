import 'package:flutter/material.dart';
import '../models/phongandloaiphong.dart'; // Đảm bảo đường dẫn này đúng

class BookingCartProvider with ChangeNotifier {
  
  final Map<int, Phongandloaiphong> _selectedRooms = {};
  
  // 1. THÊM BIẾN LƯU NGÀY
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  // --- Getters ---
  List<Phongandloaiphong> get selectedRooms => _selectedRooms.values.toList();
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;

  // 2. THÊM HÀM TÍNH SỐ ĐÊM
  int get numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) {
      return 1; // Mặc định là 1 đêm nếu có lỗi
    }
    // Tính số ngày chênh lệch
    final int nights = _checkOutDate!.difference(_checkInDate!).inDays;
    // Đảm bảo luôn trả về ít nhất 1 đêm
    return nights > 0 ? nights : 1;
  }

  // 3. THÊM HÀM CẬP NHẬT NGÀY (VÀ XÓA GIỎ HÀNG CŨ)
  void updateSearchCriteria(DateTime checkIn, DateTime checkOut) {
    _checkInDate = checkIn;
    _checkOutDate = checkOut;
    _selectedRooms.clear(); // Xóa các phòng đã chọn của lần tìm kiếm trước
    notifyListeners(); // Thông báo (để giỏ hàng cũ biến mất)
  }

  // --- Các hàm quản lý giỏ hàng (giữ nguyên) ---
  void addRoom(Phongandloaiphong item) {
    if (!_selectedRooms.containsKey(item.phong.Maphong)) {
      _selectedRooms[item.phong.Maphong] = item;
      notifyListeners();
    }
  }

  void removeRoom(int maPhong) {
    if (_selectedRooms.containsKey(maPhong)) {
      _selectedRooms.remove(maPhong);
      notifyListeners();
    }
  }

  bool isRoomSelected(int maPhong) {
    return _selectedRooms.containsKey(maPhong);
  }

  void clearCart() {
    _selectedRooms.clear();
    notifyListeners();
  }

  // 4. SỬA LẠI HÀM TÍNH TỔNG TIỀN
  int get totalPrice {
    int total = 0;
    for (var item in _selectedRooms.values) {
      total += item.loaiphong.Giacoban;
    }
    // NHÂN VỚI SỐ ĐÊM
    return total * numberOfNights; 
  }

  void clear() {}
}