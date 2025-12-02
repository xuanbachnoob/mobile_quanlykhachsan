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

    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {

        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Đã xảy ra lỗi không xác định.',
        );
      }
    } on SocketException catch (e) {

      throw Exception(
        'Không thể kết nối đến server. Vui lòng kiểm tra kết nối.',
      );
    } on TimeoutException catch (e) {

      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {

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


    try {
      final response = await http
          .post(url, headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.connectionTimeout);


      if (response.statusCode == 200 || response.statusCode == 201) {

        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại.');
      }
    } on SocketException catch (e) {

      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {

      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {

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


    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);



      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {

        return responseData['message'] ?? 'Đã gửi email khôi phục mật khẩu.';
      } else {
        throw Exception(responseData['message'] ?? 'Yêu cầu thất bại.');
      }
    } on SocketException catch (e) {

      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {

      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
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


    try {
      final response = await http
          .post(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);


      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {

        return responseData['message'] ?? 'Đổi mật khẩu thành công.';
      } else {
        throw Exception(responseData['message'] ?? 'Đổi mật khẩu thất bại.');
      }
    } on SocketException catch (e) {

      throw Exception('Không thể kết nối đến server.');
    } on TimeoutException catch (e) {

      throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Lỗi kết nối khi đổi mật khẩu.');
    }
  }
}
