import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/hinhanhphong.dart';
import '../models/loaiphong.dart';
import '../models/phongandloaiphong.dart';
import '../models/phong.dart';

/// Service xử lý đặt phòng
class DatPhongApiService {
  /// Lấy tất cả loại phòng
  Future<List<Loaiphong>> gettatcaloaiphong() async {
    final url = Uri.parse('${ApiConfig.loaiphongEndpoint}/getfullloaiphong');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Loaiphong.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi khi tải dữ liệu chi tiết phòng. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  /// Tìm và lấy thông tin phòng đầy đủ
  Future<List<Phongandloaiphong>> timVaLayThongTinPhongDayDu(
    DateTime checkin,
    DateTime checkout,
  ) async {
    // Bước 1: Lấy danh sách phòng trống
    final List<Phong> phongTrong = await _timPhongGoc(checkin, checkout);

    if (phongTrong.isEmpty) {
      return [];
    }

    // Bước 2: Lấy tất cả loại phòng và hình ảnh
    final List<Loaiphong> tatCaLoaiPhong = await getLoaiPhongs();
    final List<Hinhanhphong> hinhanhphong = await getHinhphong();

    // Bước 3: Tạo Map để tra cứu nhanh
    final Map<int, Loaiphong> loaiPhongMap = {
      for (var lp in tatCaLoaiPhong) lp.Maloaiphong: lp
    };
    final Map<int, Hinhanhphong> hinhanhphongMap = {
      for (var hp in hinhanhphong) hp.Mahinhphong: hp
    };

    // Bước 4: Kết hợp dữ liệu
    List<Phongandloaiphong> ketQua = [];
    for (var p in phongTrong) {
      final loaiPhongTuongUng = loaiPhongMap[p.Maloaiphong];
      final hinhanhphongTuongUng = hinhanhphongMap[p.Mahinhphong];
      
      if (loaiPhongTuongUng != null && hinhanhphongTuongUng != null) {
        ketQua.add(Phongandloaiphong(
          phong: p,
          loaiphong: loaiPhongTuongUng,
          hinhanhphong: hinhanhphongTuongUng,
        ));
      }
    }

    return ketQua;
  }

  /// Tìm phòng trống
  Future<List<Phong>> _timPhongGoc(DateTime checkin, DateTime checkout) async {
    final String checkinStr = DateFormat('yyyy-MM-dd').format(checkin);
    final String checkoutStr = DateFormat('yyyy-MM-dd').format(checkout);
    final url = Uri.parse('${ApiConfig.roomEndpoint}/timphong/$checkinStr/$checkoutStr');

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Phong.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi tải danh sách phòng từ API');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể tìm phòng: $e');
    }
  }

  /// Lấy tất cả loại phòng
  Future<List<Loaiphong>> getLoaiPhongs() async {
    final url = Uri.parse(ApiConfig.loaiphongEndpoint);

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Loaiphong.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi tải danh sách loại phòng');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể tải loại phòng: $e');
    }
  }

  /// Lấy hình ảnh phòng
  Future<List<Hinhanhphong>> getHinhphong() async {
    final url = Uri.parse(ApiConfig.hinhanhEndpoint);

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hinhanhphong.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi tải hình phòng');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối quá chậm. Vui lòng thử lại.');
      }
      throw Exception('Không thể tải hình ảnh: $e');
    }
  }
}