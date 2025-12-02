import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/khachhang.dart';

class KhachhangApiService {
  /// Cập nhật thông tin cá nhân - DÙNG KHACHHANG MODEL
  Future<Map<String, dynamic>> updateProfile({
    required int makh,
    required String hoten,
    required String email,
    required String sdt,
    required String cccd,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.khachhangEndpoint}/capnhatthongtinmb/$makh',
    );


    final body = jsonEncode({
      'makh': makh,
      'hoten': hoten,
      'email': email,
      'sdt': sdt,
      'cccd': cccd,

    });

    try {
      final response = await http
          .put(url, headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.connectionTimeout);

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

      rethrow;
    }
  }

  /// Lấy thông tin khách hàng theo mã (GET /Khachhangs/{makh})
  /// Trả về object Khachhang nếu thành công, hoặc throw Exception nếu lỗi
  Future<Khachhang> fetchCustomer(int makh) async {
    final url = Uri.parse('${ApiConfig.khachhangEndpoint}/$makh');


    try {
      final response = await http
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Khachhang.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy khách hàng (makh=$makh)');
      } else {
        if (response.body.isNotEmpty) {
          final err = jsonDecode(response.body);
          throw Exception(err['message'] ?? 'Lỗi khi lấy thông tin khách hàng');
        }
        throw Exception(
          'Lỗi khi lấy thông tin khách hàng (Status: ${response.statusCode})',
        );
      }
    } catch (e) {

      rethrow;
    }
  }

  /// Cập nhật điểm khách hàng
  /// - Endpoint giả định: PUT ${ApiConfig.khachhangEndpoint}/capnhatdiem/{makh}
  /// - Body: { "diem": newPoints }
  /// Trả về true nếu cập nhật thành công, false hoặc throw nếu lỗi.
  ///
  /// NOTE: Nếu backend của bạn có endpoint khác (ví dụ PUT /Khachhangs/{makh} với payload chứa diem),
  /// chỉnh URL / body cho phù hợp.
    Future<bool> updatePoints(int makh, int newPoints) async {
    final url = Uri.parse('${ApiConfig.khachhangEndpoint}/capnhatdiem/$makh');

    // GỬI ĐÚNG FORMAT BACKEND YÊU CẦU
    final body = jsonEncode({
      'diemthanhvien': newPoints, // Backend đọc field này
    });

    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...ApiConfig.headers,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Cập nhật điểm thất bại');
      }
    } on TimeoutException {

      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    } on SocketException {

      throw Exception('Không có kết nối internet');
    } catch (e) {

      rethrow;
    }
  }

  /// (Tùy chọn) Một helper để giảm điểm an toàn: kiểm tra đủ điểm rồi trừ
  /// - Trả về true nếu thành công
  Future<bool> deductPointsSafe(int makh, int pointsToDeduct) async {
    if (pointsToDeduct <= 0) return true;

    try {
      final current = await fetchCustomer(makh);
      final currentPoints = current.diemthanhvien ?? 0;
      if (currentPoints < pointsToDeduct) {
        throw Exception('Không đủ điểm để trừ');
      }
      final newPoints = currentPoints - pointsToDeduct;
      return await updatePoints(makh, newPoints);
    } catch (e) {

      rethrow;
    }
  }
}
