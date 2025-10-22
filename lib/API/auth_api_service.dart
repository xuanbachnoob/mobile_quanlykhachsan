import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service xử lý authentication
class AuthApiService {
  /// Đăng nhập
  Future<Map<String, dynamic>> login(String emailOrSdt, String password) async {
    final url = Uri.parse('${ApiConfig.authEndpoint}/DangNhap').replace(
      queryParameters: {
        'emailorsdt': emailOrSdt,
        'matkhau': password,
      },
    );

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đã xảy ra lỗi không xác định.');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Sai tài khoản hoặc mật khẩu.');
    }
  }

  /// Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register({
    required String hoten,
    required String email,
    required String sdt,
    required String matkhau,
    String? diachi,
    String? cccd,
  }) async {
    final url = Uri.parse('${ApiConfig.authEndpoint}/DangKy');

    final body = jsonEncode({
      'hoten': hoten,
      'email': email,
      'sdt': sdt,
      'matkhau': matkhau,
      'diachi': diachi,
      'cccd': cccd,
    });

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: body,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại.');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Lỗi kết nối khi đăng ký.');
    }
  }

  /// Quên mật khẩu
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('${ApiConfig.authEndpoint}/QuenMatKhau').replace(
      queryParameters: {'email': email},
    );

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData['message'];
      } else {
        throw Exception(responseData['message'] ?? 'Yêu cầu thất bại.');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Lỗi kết nối khi gửi yêu cầu quên mật khẩu.');
    }
  }

  /// Đổi mật khẩu
  Future<String> changePassword({
    required String emailOrSdt,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${ApiConfig.authEndpoint}/DoiMatKhau').replace(
      queryParameters: {
        'emailorsdt': emailOrSdt,
        'matkhaucu': oldPassword,
        'matkhaumoi': newPassword,
      },
    );

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData['message'];
      } else {
        throw Exception(responseData['message'] ?? 'Đổi mật khẩu thất bại.');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Lỗi kết nối khi đổi mật khẩu.');
    }
  }
}