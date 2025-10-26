import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
import 'package:mobile_quanlykhachsan/models/phong.dart';

class LoaiphongGrouped {
  final Loaiphong loaiphong;
  final Hinhanhphong hinhanhphong;
  final int soluongtrong;
  final List<Phong> danhsachphong;

  LoaiphongGrouped({
    required this.loaiphong,
    required this.hinhanhphong,
    required this.soluongtrong,
    required this.danhsachphong,
  });

  int get totalPrice => loaiphong.Giacoban * soluongtrong;
}