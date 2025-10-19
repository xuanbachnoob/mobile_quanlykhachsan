import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/phongandloaiphong.dart';
import '../models/phong.dart';
class DatPhongApiService {
  static const String _baseUrl = 'https://localhost:7076/api';

  Future<List<Loaiphong>> gettatcaloaiphong() async {
    final url = Uri.parse('$_baseUrl/Loaiphongs/getfullloaiphong'); 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Dùng `map` để duyệt qua từng item trong list và chuyển nó thành một đối tượng Phongandloaiphong
        return data.map((item) => Loaiphong.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi khi tải dữ liệu chi tiết phòng. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }
  /// Tìm các phòng trống trong khoảng thời gian từ [checkin] đến [checkout].
  Future<List<Phongandloaiphong>> timVaLayThongTinPhongDayDu(DateTime checkin, DateTime checkout) async {
    // Bước 1: Gọi API để lấy danh sách các phòng trống (1 cuộc gọi)
    final List<Phong> phongTrong = await _timPhongGoc(checkin, checkout);

    if (phongTrong.isEmpty) {
      return []; // Trả về danh sách rỗng nếu không có phòng.
    }

    // Bước 2: Gọi API để lấy tất cả các loại phòng (1 cuộc gọi)
    final List<Loaiphong> tatCaLoaiPhong = await getLoaiPhongs();
    final List<Hinhanhphong> hinhanhphong = await getHinhphong();
    // Bước 3: Chuyển danh sách loại phòng thành một Map để tra cứu nhanh hơn
    final Map<int, Loaiphong> loaiPhongMap = {
      for (var lp in tatCaLoaiPhong) lp.Maloaiphong: lp
    };
    final Map<int, Hinhanhphong> hinhanhphongMap = {
      for (var hp in hinhanhphong) hp.Mahinhphong: hp
    };

    // Bước 4: Kết hợp dữ liệu (thực hiện trên điện thoại, không cần gọi mạng)
    List<Phongandloaiphong> ketQua = [];
    for (var p in phongTrong) {
      final loaiPhongTuongUng = loaiPhongMap[p.Maloaiphong];
      final hinhanhphongTuongUng = hinhanhphongMap[p.Mahinhphong];
      if (loaiPhongTuongUng != null) {
        ketQua.add(Phongandloaiphong(
          phong: p,
          loaiphong: loaiPhongTuongUng,
          hinhanhphong: hinhanhphongTuongUng!,
        ));
      }
    }
    
    return ketQua;
  }


  // Hàm riêng tư để lấy phòng trống
  Future<List<Phong>> _timPhongGoc(DateTime checkin, DateTime checkout) async {
    final String checkinStr = DateFormat('yyyy-MM-dd').format(checkin);
    final String checkoutStr = DateFormat('yyyy-MM-dd').format(checkout);
    final url = Uri.parse('$_baseUrl/Phongs/timphong/$checkinStr/$checkoutStr');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Phong.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách phòng từ API');
    }
  }

  // Hàm để lấy tất cả loại phòng
  Future<List<Loaiphong>> getLoaiPhongs() async {
    final url = Uri.parse('$_baseUrl/Loaiphongs');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Loaiphong.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách loại phòng');
    }
  }

  Future<List<Hinhanhphong>> getHinhphong() async {
    final url = Uri.parse('$_baseUrl/Hinhanhphongs');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Hinhanhphong.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi tải Hình phòng');
    }
  }
}