import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/dichvu.dart';

/// Service xử lý API dịch vụ
class DichVuApiService {
  /// Lấy tất cả dịch vụ
  Future<List<DichVu>> getAllDichVu() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Dichvus');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => DichVu.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi khi tải danh sách dịch vụ. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  /// Lấy dịch vụ theo loại
  Future<List<DichVu>> getDichVuByLoai(int maloaidv) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Dichvus/byloai/$maloaidv');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => DichVu.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi khi tải dịch vụ theo loại');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể tải dịch vụ: $e');
    }
  }

  /// Lấy chi tiết 1 dịch vụ
  Future<DichVu> getDichVuById(int madv) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Dichvus/$madv');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return DichVu.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không tìm thấy dịch vụ');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể tải chi tiết dịch vụ: $e');
    }
  }
}