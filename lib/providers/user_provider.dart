import 'package:flutter/foundation.dart';
import '../models/khachhang.dart';

class UserProvider extends ChangeNotifier {
  Khachhang? _user;

  Khachhang? get user => _user;
  
  // ✅ Alias để dễ dùng
  Khachhang? get currentUser => _user;

  void setUser(Khachhang user) {
    _user = user;
    print('✅ User set in provider:');
    print('   - Makh: ${user.makh}');
    print('   - Hoten: ${user.hoten}');
    print('   - Email: ${user.email}');
    print('   - Role: ${user.role}');
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    print('🗑️ User cleared from provider');
    notifyListeners();
  }

  bool get isLoggedIn => _user != null && _user!.makh != null;
}