import 'package:flutter/foundation.dart';
import '../models/khachhang.dart';

class UserProvider extends ChangeNotifier {
  Khachhang? _user;

  Khachhang? get user => _user;
  
  // ✅ Alias để dễ dùng
  Khachhang? get currentUser => _user;

  /// ✅ SET USER (AFTER LOGIN)
  void setUser(Khachhang user) {
    _user = user;
    print('   - Makh: ${user.makh}');
    print('   - Hoten: ${user.hoten}');
    print('   - Hoten: ${user.sdt}');
    print('   - Hoten: ${user.cccd}');
    print('   - Hoten: ${user.diemthanhvien}');

    print('   - Email: ${user.email}');
    print('   - Role: ${user.role}');
    notifyListeners();
  }

  /// ✅ LOGOUT - CLEAR USER
  Future<void> logout() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🚪 LOGOUT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('User: ${_user?.hoten ?? "Unknown"}');
    print('Email: ${_user?.email ?? "Unknown"}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Clear user data
    _user = null;
    
    print('✅ User logged out successfully');
    print('✅ User data cleared\n');
    
    notifyListeners();
  }

  /// ✅ CLEAR USER (ALIAS FOR LOGOUT)
  void clearUser() {
    _user = null;
    print('🗑️ User cleared from provider');
    notifyListeners();
  }

  /// ✅ CHECK IF LOGGED IN
  bool get isLoggedIn => _user != null && _user!.makh != null;

  /// ✅ GET USER DISPLAY NAME
  String getDisplayName() {
    return _user?.hoten ?? 'Người dùng';
  }

  /// ✅ GET USER EMAIL
  String getEmail() {
    return _user?.email ?? '';
  }

  /// ✅ GET USER EMAIL OR SDT
  String getEmailOrSdt() {
    return _user?.email ?? _user?.sdt ?? '';
  }
}