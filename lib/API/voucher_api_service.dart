import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/voucher.dart';
import '../config/api_config.dart';

class VoucherApiService {

  /// Lấy tất cả voucher đang hiệu lực theo ngày
  Future<List<Voucher>> getActiveVouchers(DateTime checkInDate) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(checkInDate);
    final url = Uri.parse('${ApiConfig.baseUrl}/Vouchers/active?checkInDate=$dateStr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Voucher.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi lấy voucher: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  /// Lấy voucher theo mã loại phòng
  Future<Voucher?> getVoucherByRoomType(int maloaiphong, DateTime checkInDate) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(checkInDate);
    final url = Uri.parse('${ApiConfig.baseUrl}/Vouchers/by-room-type/$maloaiphong?checkInDate=$dateStr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['hasVoucher'] == true) {
          return Voucher.fromJson(data['voucher']);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching voucher by room type: $e');
      return null;
    }
  }
}