import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/phong.dart';
import 'package:mobile_quanlykhachsan/models/voucher.dart';

class LoaiphongGrouped {
  final Loaiphong loaiphong;
  final Hinhanhphong hinhanhphong;
  final int soluongtrong;
  final List<Phong> danhsachphong;
  final Voucher? voucher;

  LoaiphongGrouped({
    required this.loaiphong,
    required this.hinhanhphong,
    required this.soluongtrong,
    required this.danhsachphong,
    this.voucher,
  });

  int get totalPrice => loaiphong.Giacoban * soluongtrong;
}