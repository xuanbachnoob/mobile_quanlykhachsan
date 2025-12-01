import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_quanlykhachsan/models/chitiethoadon.dart';
import 'package:mobile_quanlykhachsan/models/datphong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong_grouped.dart';
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
      final response = await http
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Loaiphong.fromJson(item)).toList();
      } else {
        throw Exception(
          'Lỗi khi tải dữ liệu chi tiết phòng. Mã lỗi: ${response.statusCode}',
        );
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
      for (var lp in tatCaLoaiPhong) lp.Maloaiphong: lp,
    };
    final Map<int, Hinhanhphong> hinhanhphongMap = {
      for (var hp in hinhanhphong) hp.Mahinhphong: hp,
    };

    // Bước 4: Kết hợp dữ liệu
    List<Phongandloaiphong> ketQua = [];
    for (var p in phongTrong) {
      final loaiPhongTuongUng = loaiPhongMap[p.Maloaiphong];
      final hinhanhphongTuongUng = hinhanhphongMap[p.Mahinhphong];

      if (loaiPhongTuongUng != null && hinhanhphongTuongUng != null) {
        ketQua.add(
          Phongandloaiphong(
            phong: p,
            loaiphong: loaiPhongTuongUng,
            hinhanhphong: hinhanhphongTuongUng,
          ),
        );
      }
    }

    return ketQua;
  }

  /// Tìm phòng trống
  Future<List<Phong>> _timPhongGoc(DateTime checkin, DateTime checkout) async {
    final String checkinStr = DateFormat('yyyy-MM-dd').format(checkin);
    final String checkoutStr = DateFormat('yyyy-MM-dd').format(checkout);
    final url = Uri.parse(
      '${ApiConfig.roomEndpoint}/timphong/$checkinStr/$checkoutStr',
    );

    try {
      final response = await http
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

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
      final response = await http
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

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
      final response = await http
          .get(url, headers: ApiConfig.headers)
          .timeout(ApiConfig.connectionTimeout);

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

  /// Tìm và nhóm phòng theo loại phòng
  Future<List<LoaiphongGrouped>> timVaNhomPhongTheoLoai(
    DateTime checkin,
    DateTime checkout,
    int guestCount, // ← THÊM THAM SỐ NÀY
  ) async {
    // Bước 1: Lấy danh sách phòng trống
    final List<Phong> phongTrong = await _timPhongGoc(checkin, checkout);

    if (phongTrong.isEmpty) {
      return [];
    }

    // ✅ BƯỚC 1.5: LỌC PHÒNG THEO SỐ NGƯỜI (thêm vào đây)
    final List<Phong> phongPhuHop = phongTrong.where((phong) {
      // Giả sử model Phong có field songuoitoida hoặc suchua
      // Thay 'songuoitoida' bằng tên field thực tế trong model của bạn
      return (phong.Succhua ?? 0) >= guestCount;
    }).toList();

    if (phongPhuHop.isEmpty) {
      return [];
    }

    // Bước 2: Lấy tất cả loại phòng và hình ảnh
    final List<Loaiphong> tatCaLoaiPhong = await getLoaiPhongs();
    final List<Hinhanhphong> hinhanhphong = await getHinhphong();

    // Bước 3: Tạo Map để tra cứu nhanh
    final Map<int, Loaiphong> loaiPhongMap = {
      for (var lp in tatCaLoaiPhong) lp.Maloaiphong: lp,
    };
    final Map<int, Hinhanhphong> hinhanhphongMap = {
      for (var hp in hinhanhphong) hp.Mahinhphong: hp,
    };

    // Bước 4: NHÓM PHÒNG THEO LOẠI (dùng phongPhuHop thay vì phongTrong)
    final Map<int, List<Phong>> phongTheoLoai = {};

    for (var p in phongPhuHop) {
      // ← ĐỔI TỪ phongTrong SANG phongPhuHop
      if (!phongTheoLoai.containsKey(p.Maloaiphong)) {
        phongTheoLoai[p.Maloaiphong] = [];
      }
      phongTheoLoai[p.Maloaiphong]!.add(p);
    }

    // Bước 5: TẠO DANH SÁCH NHÓM
    List<LoaiphongGrouped> ketQua = [];

    phongTheoLoai.forEach((maloaiphong, danhsachphong) {
      final loaiPhong = loaiPhongMap[maloaiphong];

      final mahinhphong = danhsachphong.first.Mahinhphong;
      final hinhAnh = hinhanhphongMap[mahinhphong];

      if (loaiPhong != null && hinhAnh != null) {
        ketQua.add(
          LoaiphongGrouped(
            loaiphong: loaiPhong,
            hinhanhphong: hinhAnh,
            soluongtrong: danhsachphong.length,
            danhsachphong: danhsachphong,
          ),
        );
      }
    });

    ketQua.sort(
      (a, b) => a.loaiphong.Tenloaiphong.compareTo(b.loaiphong.Tenloaiphong),
    );

    return ketQua;
  }

  Future<List<Datphong>> fetchDatphongs(int makh, String trangthai) async {
    final url = Uri.parse('${ApiConfig.bookingEndpoint}/fillter').replace(
      queryParameters: {'makh': makh.toString(), 'trangthai': trangthai},
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Datphong.fromJson(e)).toList();
    } else {
      print('❌ Lỗi khi gọi API: ${response.statusCode}');
      throw Exception('Không thể tải dữ liệu');
    }
  }

    /// ✅ HỦY PHÒNG VỚI LÝ DO
  Future<Map<String, dynamic>> huyphong(int madatphong, {String? lydo}) async {
    final url = Uri.parse('${ApiConfig.bookingEndpoint}/huy/$madatphong');

    // ✅ GỬI LÝ DO TRONG BODY
    final body = jsonEncode({
      'LyDo': lydo ?? 'Không rõ lý do',
    });

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('❌ HỦY PHÒNG');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('URL: $url');
    print('Body: $body');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
      final response = await http.put(
        url,
        headers: ApiConfig.headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 RESPONSE HỦY PHÒNG');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Hủy phòng thất bại: ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi hủy phòng: $e\n');
      rethrow;
    }
  }
}
