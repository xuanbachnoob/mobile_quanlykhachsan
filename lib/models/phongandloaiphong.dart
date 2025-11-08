import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/phong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/voucher.dart';

class Phongandloaiphong {
  final Phong phong;
  final Loaiphong loaiphong;
  final Hinhanhphong hinhanhphong;
  final Voucher? voucher;

  Phongandloaiphong({
    required this.phong,
    required this.loaiphong,
    required this.hinhanhphong,
    this.voucher,
  });

  /// Getter: Giá sau khi trừ voucher
  int get giaSauGiam {
    final giagoc = loaiphong.Giacoban;
    final giagiam = voucher?.giagiam ?? 0;
    return giagoc - giagiam;
  }

  /// Getter: Kiểm tra có voucher không
  bool get hasVoucher => voucher != null && (voucher!.giagiam ?? 0) > 0;

  factory Phongandloaiphong.fromJson(Map<String, dynamic> json) {
    return Phongandloaiphong(
      phong: Phong.fromJson(json),
      loaiphong: Loaiphong.fromJson(json['maloaiphongNavigation']),
      hinhanhphong: Hinhanhphong.fromJson(json['mahinhphongNavigation']),
    );
  }

  /// Copy với voucher mới
  Phongandloaiphong copyWith({Voucher? voucher}) {
    return Phongandloaiphong(
      phong: phong,
      loaiphong: loaiphong,
      hinhanhphong: hinhanhphong,
      voucher: voucher ?? this.voucher,
    );
  }
}