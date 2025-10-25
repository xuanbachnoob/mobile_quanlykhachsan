import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/khachhang.dart';

class KhachhangApiService {
  /// Cập nhật thông tin cá nhân - DÙNG KHACHHANG MODEL
  /// Cập nhật thông tin cá nhân - DÙNG KHACHHANG MODEL
  Future<Map<String, dynamic>> updateProfile({
    required int makh,
    required String hoten,
    required String email,
    required String sdt,
    required String cccd,
  }) async {
    final url = Uri.parse('${ApiConfig.khachhangEndpoint}/capnhatthongtin/$makh');

    // ✅ CHỈ GỬI 4 FIELDS
    final body = jsonEncode({
      'makh': makh,
      'hoten': hoten,
      'email': email,
      'sdt': sdt,
      'cccd': cccd,
      // ❌ KHÔNG GỬI: matkhau, diemthanhvien, token, v.v.
    });

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📝 UPDATE PROFILE REQUEST');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Body: $body');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http
          .put(url, headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.connectionTimeout);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 UPDATE PROFILE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          return {'message': 'Cập nhật thông tin thành công!'};
        }
      } else if (response.statusCode == 204) {
        return {'message': 'Cập nhật thông tin thành công!'};
      } else {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Cập nhật thất bại');
        } else {
          throw Exception('Cập nhật thất bại (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      print('❌ Update error: $e\n');
      rethrow;
    }
  }
}
