import 'package:mobile_quanlykhachsan/models/hinhanhphong.dart';
import 'package:mobile_quanlykhachsan/models/phong.dart';
import 'package:mobile_quanlykhachsan/models/loaiphong.dart';
class Phongandloaiphong {
  final Phong phong;
  final Loaiphong loaiphong;
  final Hinhanhphong hinhanhphong;
  Phongandloaiphong({required this.phong, required this.loaiphong, required this.hinhanhphong});

    factory Phongandloaiphong.fromJson(Map<String, dynamic> json) {
    return Phongandloaiphong(
      // Toàn bộ json gốc được dùng để tạo đối tượng Phong
      phong: Phong.fromJson(json),
      
      // Lấy đối tượng JSON lồng nhau 'maloaiphongNavigation' để tạo Loaiphong
      loaiphong: Loaiphong.fromJson(json['maloaiphongNavigation']),
      
      // Lấy đối tượng JSON lồng nhau 'mahinhphongNavigation' để tạo Hinhanhphong
      hinhanhphong: Hinhanhphong.fromJson(json['mahinhphongNavigation']),
    );
  }
}