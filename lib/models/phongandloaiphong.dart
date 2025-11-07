import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/phong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/voucher.dart'; // ✅ THÊM IMPORT

class Phongandloaiphong {
  final Phong phong;
  final Loaiphong loaiphong;
  final Hinhanhphong hinhanhphong;
  final Voucher? voucher; // ✅ THÊM FIELD VOUCHER

  Phongandloaiphong({
    required this.phong,
    required this.loaiphong,
    required this.hinhanhphong,
    this.voucher, // ✅ THÊM PARAMETER
  });

  // ✅ THÊM GETTER TÍNH GIÁ SAU GIẢM
  int get giaSauGiam {
    final giagoc = loaiphong.Giacoban;
    final giagiam = voucher?.giagiam ?? 0;
    return giagoc - giagiam;
  }

  // ✅ THÊM GETTER KIỂM TRA CÓ VOUCHER KHÔNG
  bool get hasVoucher => voucher != null && (voucher!.giagiam ?? 0) > 0;

  factory Phongandloaiphong.fromJson(Map<String, dynamic> json) {
    return Phongandloaiphong(
      phong: Phong.fromJson(json),
      loaiphong: Loaiphong.fromJson(json['maloaiphongNavigation']),
      hinhanhphong: Hinhanhphong.fromJson(json['mahinhphongNavigation']),
      // voucher không có trong JSON từ API, sẽ được set thủ công khi add vào giỏ
    );
  }

  // ✅ THÊM METHOD COPY WITH VOUCHER
  Phongandloaiphong copyWith({Voucher? voucher}) {
    return Phongandloaiphong(
      phong: phong,
      loaiphong: loaiphong,
      hinhanhphong: hinhanhphong,
      voucher: voucher ?? this.voucher,
    );
  }
}