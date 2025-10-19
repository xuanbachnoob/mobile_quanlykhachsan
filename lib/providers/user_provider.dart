import 'package:flutter/material.dart';
import '../models/khachhang.dart'; // Import model của bạn

class UserProvider with ChangeNotifier {
  Khachhang? _currentUser;

  // Getter để các màn hình khác có thể truy cập thông tin người dùng
  Khachhang? get currentUser => _currentUser;

  // Kiểm tra xem người dùng đã đăng nhập hay chưa
  bool get isLoggedIn => _currentUser != null;

  // Hàm này được gọi khi đăng nhập thành công
  void setUser(Khachhang user) {
    _currentUser = user;
    notifyListeners(); // Thông báo cho toàn bộ ứng dụng biết "Người dùng đã đăng nhập"
  }

  // Hàm này được gọi khi đăng xuất
  void clearUser() {
    _currentUser = null;
    notifyListeners(); // Thông báo "Người dùng đã đăng xuất"
  }
}