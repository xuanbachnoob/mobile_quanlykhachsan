import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/khachhang.dart';
import '../API/khachhang_api_service.dart';

class UserProvider extends ChangeNotifier {
  Khachhang? _currentUser;
  bool _isLoading = false;

  Khachhang? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  final KhachhangApiService _khachhangApi = KhachhangApiService();

  /// Load user từ SharedPreferences
  Future<void> loadUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = Khachhang.fromJson(userData);
        print('✅ User loaded from SharedPreferences');
        print('   - Makh: ${_currentUser?.makh}');
        print('   - Hoten: ${_currentUser?.hoten}');
        print('   - Points: ${_currentUser?.diemthanhvien}');
      } else {
        print('ℹ️ No user data found in SharedPreferences');
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set user và lưu vào SharedPreferences
  Future<void> setUser(Khachhang user) async {
    try {
      _currentUser = user;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(user.toJson()));
      
      print('✅ User saved to SharedPreferences');
      print('   - Makh: ${user.makh}');
      print('   - Hoten: ${user.hoten}');
      print('   - Points: ${user.diemthanhvien}');
      
      notifyListeners();
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  /// ✅ REFRESH USER DATA TỪ SERVER
  Future<void> refreshUserData() async {
    if (_currentUser?.makh == null) {
      print('⚠️ Cannot refresh user data: makh is null');
      return;
    }

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 REFRESHING USER DATA FROM SERVER');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Makh: ${_currentUser!.makh}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      final updatedUser = await _khachhangApi.fetchCustomer(_currentUser!.makh!);
      
      print('✅ User data fetched from server');
      print('   - Old points: ${_currentUser?.diemthanhvien}');
      print('   - New points: ${updatedUser.diemthanhvien}');
      
      await setUser(updatedUser);
      
      print('✅ User data refreshed successfully!\n');
    } catch (e) {
      print('❌ Error refreshing user data: $e\n');
      // Không throw error để không làm crash app
      // App vẫn hoạt động với dữ liệu cũ
    }
  }

  /// ✅ CẬP NHẬT ĐIỂM LOCAL (Không gọi API, chỉ update UI)
  void updateLocalPoints(int newPoints) {
    if (_currentUser != null) {
      print('📝 Updating local points: ${_currentUser!.diemthanhvien} → $newPoints');
      
      _currentUser = Khachhang(
        makh: _currentUser!.makh,
        hoten: _currentUser!.hoten,
        email: _currentUser!.email,
        sdt: _currentUser!.sdt,
        diachi: _currentUser!.diachi,
        cccd: _currentUser!.cccd,
        ngaysinh: _currentUser!.ngaysinh,
        diemthanhvien: newPoints,
        trangthai: _currentUser!.trangthai,
        ngaytao: _currentUser!.ngaytao,
        matkhau: _currentUser!.matkhau,
        role: _currentUser!.role,
        token: _currentUser!.token,
      );
      
      notifyListeners();
      
      // Lưu vào SharedPreferences
      _saveUserToPrefs();
    }
  }

  /// Lưu user vào SharedPreferences (private method)
  Future<void> _saveUserToPrefs() async {
    if (_currentUser != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(_currentUser!.toJson()));
        print('💾 User saved to SharedPreferences');
      } catch (e) {
        print('❌ Error saving to SharedPreferences: $e');
      }
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      print('🚪 Logging out user: ${_currentUser?.hoten}');
      
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      
      print('✅ User logged out successfully');
      notifyListeners();
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  /// ✅ CLEAR ALL DATA (dùng khi logout hoàn toàn)
  Future<void> clearAllData() async {
    try {
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('✅ All user data cleared');
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}