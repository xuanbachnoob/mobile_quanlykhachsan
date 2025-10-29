import 'package:flutter/material.dart';
import '../models/phongandloaiphong.dart';

class BookingCartProvider with ChangeNotifier {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIVATE VARIABLES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  final Map<int, Phongandloaiphong> _selectedRooms = {};
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BASIC GETTERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  List<Phongandloaiphong> get selectedRooms => _selectedRooms.values.toList();
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;
  
  // ✅ SỐ PHÒNG
  int get roomCount => _selectedRooms.length;

  // ✅ SỐ ĐÊM
  int get numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) {
      return 1; // Mặc định 1 đêm
    }
    final int nights = _checkOutDate!.difference(_checkInDate!).inDays;
    return nights > 0 ? nights : 1; // Đảm bảo ít nhất 1 đêm
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ DISCOUNT LOGIC (GIẢM GIÁ THEO SỐ PHÒNG)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Tính % giảm giá dựa trên số phòng
  double get discountPercentage {
    if (roomCount >= 10) return 0.10; // 10% cho 10+ phòng
    if (roomCount >= 7)  return 0.05; // 5% cho 7-9 phòng
    if (roomCount >= 5)  return 0.03; // 3% cho 5-6 phòng
    return 0.0; // Không giảm giá nếu < 5 phòng
  }

  /// Message hiển thị giảm giá
  String get discountMessage {
    if (roomCount >= 10) {
      return 'Đặt từ 10 phòng - Giảm 10%! 🎉';
    } else if (roomCount >= 7) {
      return 'Đặt từ 7 phòng - Giảm 5%! 🎊';
    } else if (roomCount >= 5) {
      return 'Đặt từ 5 phòng - Giảm 3%! 🎁';
    } else if (roomCount >= 3) {
      final roomsNeeded = 5 - roomCount;
      return 'Đặt thêm $roomsNeeded phòng để được giảm 3%';
    }
    return '';
  }

  /// Icon cho từng mức giảm giá
  String get discountIcon {
    if (roomCount >= 10) return '🎉';
    if (roomCount >= 7)  return '🎊';
    if (roomCount >= 5)  return '🎁';
    return '💡';
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ PRICE CALCULATION (TÍNH TIỀN)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Tổng tiền GỐC (chưa giảm giá)
  int get subtotal {
    if (_selectedRooms.isEmpty) return 0;
    
    int total = 0;
    for (var room in _selectedRooms.values) {
      total += room.loaiphong.Giacoban;
    }
    
    // Nhân với số đêm
    return total * numberOfNights;
  }

  /// Số tiền GIẢM GIÁ
  int get discountAmount {
    return (subtotal * discountPercentage).toInt();
  }

  /// Tổng tiền SAU GIẢM GIÁ
  int get totalPrice {
    return subtotal - discountAmount;
  }

  /// Alias cho totalPrice (backward compatibility)
  int get totalAmount => totalPrice;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ DISCOUNT TIERS (THƯ VIỆN MỨC GIẢM GIÁ)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Danh sách các mức giảm giá
  List<DiscountTier> get discountTiers => [
    DiscountTier(
      minRooms: 5,
      percentage: 3,
      description: 'Giảm 3%',
      active: roomCount >= 5,
      icon: '🎁',
    ),
    DiscountTier(
      minRooms: 7,
      percentage: 5,
      description: 'Giảm 5%',
      active: roomCount >= 7,
      icon: '🎊',
    ),
    DiscountTier(
      minRooms: 10,
      percentage: 10,
      description: 'Giảm 10%',
      active: roomCount >= 10,
      icon: '🎉',
    ),
  ];

  /// Mức giảm giá TIẾP THEO (để hiển thị progress)
  DiscountTier? get nextDiscountTier {
    if (roomCount >= 10) return null; // Đã max
    if (roomCount >= 7)  return discountTiers[2]; // Next: 10%
    if (roomCount >= 5)  return discountTiers[1]; // Next: 5%
    return discountTiers[0]; // Next: 3%
  }

  /// Số phòng còn thiếu để đạt mức giảm giá tiếp theo
  int get roomsNeededForNextTier {
    if (nextDiscountTier == null) return 0;
    return nextDiscountTier!.minRooms - roomCount;
  }

  /// Progress tới mức giảm giá tiếp theo (0.0 - 1.0)
  double get progressToNextTier {
    if (nextDiscountTier == null) return 1.0;
    
    // Tính từ mức hiện tại đến mức tiếp theo
    final currentTierMin = roomCount >= 7 ? 7 : (roomCount >= 5 ? 5 : 0);
    final nextTierMin = nextDiscountTier!.minRooms;
    final range = nextTierMin - currentTierMin;
    final current = roomCount - currentTierMin;
    
    return range > 0 ? current / range : 0.0;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CART MANAGEMENT FUNCTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// Cập nhật tiêu chí tìm kiếm (check-in, check-out)
  void updateSearchCriteria(DateTime checkIn, DateTime checkOut) {
    _checkInDate = checkIn;
    _checkOutDate = checkOut;
    _selectedRooms.clear(); // Xóa phòng cũ khi tìm kiếm mới
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 UPDATED SEARCH CRITERIA');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Check-in:  ${checkIn.toString().split(' ')[0]}');
    print('Check-out: ${checkOut.toString().split(' ')[0]}');
    print('Nights: $numberOfNights');
    print('Cart cleared: ${_selectedRooms.isEmpty}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    notifyListeners();
  }

  /// Thêm phòng vào giỏ
  void addRoom(Phongandloaiphong item) {
    if (!_selectedRooms.containsKey(item.phong.Maphong)) {
      _selectedRooms[item.phong.Maphong] = item;
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ ROOM ADDED TO CART');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Room: ${item.phong.Sophong} - ${item.loaiphong.Tenloaiphong}');
      print('Price: ${item.loaiphong.Giacoban} VNĐ/night');
      print('Total rooms: $roomCount');
      print('Discount: ${(discountPercentage * 100).toInt()}%');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      notifyListeners();
    }
  }

  /// Xóa phòng khỏi giỏ
  void removeRoom(int maPhong) {
    if (_selectedRooms.containsKey(maPhong)) {
      final removedRoom = _selectedRooms.remove(maPhong);
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🗑️ ROOM REMOVED FROM CART');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Room: ${removedRoom?.phong.Sophong}');
      print('Remaining rooms: $roomCount');
      print('Discount: ${(discountPercentage * 100).toInt()}%');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      notifyListeners();
    }
  }

  /// Kiểm tra phòng đã được chọn chưa
  bool isRoomSelected(int maPhong) {
    return _selectedRooms.containsKey(maPhong);
  }

  /// Xóa toàn bộ giỏ hàng
  void clearCart() {
    _selectedRooms.clear();
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🧹 CART CLEARED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    notifyListeners();
  }

  /// Xóa tất cả (bao gồm cả ngày tháng)
  void clear() {
    _selectedRooms.clear();
    _checkInDate = null;
    _checkOutDate = null;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🧹 FULL RESET');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    notifyListeners();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DEBUG FUNCTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  /// In thông tin giỏ hàng ra console
  void debugPrintCart() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🛒 CART DEBUG INFO');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Check-in:  ${_checkInDate?.toString().split(' ')[0] ?? "Not set"}');
    print('Check-out: ${_checkOutDate?.toString().split(' ')[0] ?? "Not set"}');
    print('Nights: $numberOfNights');
    print('Rooms: $roomCount');
    print('Discount: ${(discountPercentage * 100).toInt()}%');
    print('Subtotal: $subtotal VNĐ');
    print('Discount Amount: $discountAmount VNĐ');
    print('Total: $totalPrice VNĐ');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (_selectedRooms.isNotEmpty) {
      print('Selected Rooms:');
      for (var room in _selectedRooms.values) {
        print('  - Room ${room.phong.Sophong}: ${room.loaiphong.Tenloaiphong}');
      }
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ DISCOUNT TIER MODEL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DiscountTier {
  final int minRooms;
  final int percentage;
  final String description;
  final bool active;
  final String icon;

  DiscountTier({
    required this.minRooms,
    required this.percentage,
    required this.description,
    required this.active,
    this.icon = '🎁',
  });

  String get roomsNeeded => '$minRooms+ phòng';
  
  String get percentageText => '$percentage%';
  
  String get fullDescription => '$icon $description - $roomsNeeded';
}