import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String _baseUrl = 'https://localhost:7076/api/Taikhoans';

  /// Gửi yêu cầu đăng nhập đến API.
  /// Trả về một Map chứa thông tin người dùng nếu thành công.
  /// Ném ra một Exception nếu thất bại.
  Future<Map<String, dynamic>> login(String emailOrSdt, String password) async {
    final url = Uri.parse('$_baseUrl/DangNhap').replace(queryParameters: {
      'emailorsdt': emailOrSdt,
      'matkhau': password,
    });

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Chuyển đổi chuỗi JSON thành Map
        return jsonDecode(response.body);
      } else {
        // Nếu server trả về lỗi (401 Unauthorized, etc.)
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đã xảy ra lỗi không xác định.');
      }
    } catch (e) {
      throw Exception('Sai tài khoản hoặc mật khẩu.');
    }
  }

  /// Gửi yêu cầu đăng ký tài khoản mới.
  Future<Map<String, dynamic>> register({
    required String hoten,
    required String email,
    required String sdt,
    required String matkhau,
    String? diachi, // Các trường không bắt buộc
    String? cccd,
  }) async {
    final url = Uri.parse('$_baseUrl/DangKy');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    
    final body = jsonEncode({
      'hoten': hoten,
      'email': email,
      'sdt': sdt,
      'matkhau': matkhau,
      'diachi': diachi,
      'cccd': cccd,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối khi đăng ký.');
    }
  }

  /// Gửi yêu cầu quên mật khẩu.
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/QuenMatKhau').replace(queryParameters: {
      'email': email,
    });

    try {
      final response = await http.post(url);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData['message'];
      } else {
        throw Exception(responseData['message'] ?? 'Yêu cầu thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối khi gửi yêu cầu quên mật khẩu.');
    }
  }

  /// Gửi yêu cầu đổi mật khẩu.
  Future<String> changePassword({
    required String emailOrSdt,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/DoiMatKhau').replace(queryParameters: {
      'emailorsdt': emailOrSdt,
      'matkhaucu': oldPassword,
      'matkhaumoi': newPassword,
    });

    try {
      final response = await http.post(url);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData['message'];
      } else {
        throw Exception(responseData['message'] ?? 'Đổi mật khẩu thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối khi đổi mật khẩu.');
    }
  }
}