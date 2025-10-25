import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service xử lý authentication
class AuthApiService {
  /// Đăng nhập
  Future<Map<String, dynamic>> login(String emailOrSdt, String password) async {
    final url = Uri.parse(
      '${ApiConfig.authEndpoint}/DangNhap',
    ).replace(queryParameters: {'emailorsdt': emailOrSdt, 'matkhau': password});

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔐 LOGIN REQUEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Email/SDT: $emailOrSdt');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 LOGIN RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        print('✅ Login successful!\n');
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Đã xảy ra lỗi không xác định.',
        );
      }
    } on SocketException catch (e) {
      print('❌ Socket error: $e\n');
      throw Exception(
        'Không thể kết nối đến server. Vui lòng kiểm tra kết nối.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e\n');
      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
      print('❌ Login error: $e\n');
      if (e.toString().contains('Exception:')) {
        rethrow;
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

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📝 REGISTER REQUEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Body: $body');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.connectionTimeout);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 REGISTER RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registration successful!\n');
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại.');
      }
    } on SocketException catch (e) {
      print('❌ Socket error: $e\n');
      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e\n');
      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
      print('❌ Register error: $e\n');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Lỗi kết nối khi đăng ký.');
    }
  }

  /// Quên mật khẩu
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse(
      '${ApiConfig.authEndpoint}/QuenMatKhau',
    ).replace(queryParameters: {'email': email});

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📧 FORGOT PASSWORD REQUEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Email: $email');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 FORGOT PASSWORD RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('✅ Forgot password request successful!\n');
        return responseData['message'] ?? 'Đã gửi email khôi phục mật khẩu.';
      } else {
        throw Exception(responseData['message'] ?? 'Yêu cầu thất bại.');
      }
    } on SocketException catch (e) {
      print('❌ Socket error: $e\n');
      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e\n');
      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
      print('❌ Forgot password error: $e\n');
      if (e.toString().contains('Exception:')) {
        rethrow;
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

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔐 CHANGE PASSWORD REQUEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Email/SDT: $emailOrSdt');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 CHANGE PASSWORD RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('✅ Password changed successfully!\n');
        return responseData['message'] ?? 'Đổi mật khẩu thành công.';
      } else {
        throw Exception(responseData['message'] ?? 'Đổi mật khẩu thất bại.');
      }
    } on SocketException catch (e) {
      print('❌ Socket error: $e\n');
      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e\n');
      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
      print('❌ Change password error: $e\n');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Lỗi kết nối khi đổi mật khẩu.');
    }
  }
}
