import 'package:mobile_quanlykhachsan/models/chitietdatphong.dart';
import 'package:mobile_quanlykhachsan/models/chitiethoadon.dart';
import 'package:mobile_quanlykhachsan/models/denbuthiethai.dart';
import 'package:mobile_quanlykhachsan/models/hoadon.dart';
import 'package:mobile_quanlykhachsan/models/sudungdv.dart';

class Datphong {
  final int? madatphong;
  final DateTime? ngaydat;
  final DateTime ngaynhanphong;
  final DateTime ngaytraphong;
  final String? trangthai;
  final int? dongia;
  final int? giamgia;
  final int? tongtien;
  final String? trangthaithanhtoan;
  final String? chinhsachhuy;
  final String? ghichu;
  final int? makh;
  final int? manv;
  final DateTime? ngayhuy;
  final List<Chitietdatphong>? chitietdatphongs;
  final List<Sudungdv>? sudungdichvus;
  final List<Denbuthiethai>? denbuthiethai;
  final List<Chitiethoadon>? chitiethoadons;
  final List<Hoadon>? hoadons;

  Datphong({
    this.madatphong,
    this.ngaydat,
    required this.ngaynhanphong,
    required this.ngaytraphong,
    this.trangthai,
    this.dongia,
    this.giamgia,
    this.tongtien,
    this.trangthaithanhtoan,
    this.chinhsachhuy,
    this.ghichu,
    this.makh,
    this.manv,
    this.ngayhuy,
    this.chitietdatphongs,
    this.sudungdichvus,
    this.denbuthiethai,
    this.chitiethoadons,
    this.hoadons,
  });

  /// toJson CHỈ GỬI: ngaynhanphong, ngaytraphong, makh, ghichu
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'ngaynhanphong': ngaynhanphong.toIso8601String().split('T')[0],
      'ngaytraphong': ngaytraphong.toIso8601String().split('T')[0],
      'makh': makh,
      'trangthai': trangthai,
      'trangthaithanhtoan': trangthaithanhtoan,
      'manv': null,
    };

    // Optional fields
    if (ghichu != null && ghichu!.isNotEmpty) {
      json['ghichu'] = ghichu;
    }

    print('📤 Datphong toJson (minimal):');
    print(json);

    return json;
  }

  factory Datphong.fromJson(Map<String, dynamic> json) {
    return Datphong(
      madatphong: json['madatphong'] as int?,
      ngaydat: json['ngaydat'] != null ? DateTime.parse(json['ngaydat']) : null,
      ngaynhanphong: DateTime.parse(json['ngaynhanphong']),
      ngaytraphong: DateTime.parse(json['ngaytraphong']),
      trangthai: json['trangthai'] as String?,
      dongia: json['dongia'] as int?,
      giamgia: json['giamgia'] as int?,
      tongtien: json['tongtien'] as int?,
      trangthaithanhtoan: json['trangthaithanhtoan'] as String?,
      chinhsachhuy: json['chinhsachhuy'] as String?,
      ghichu: json['ghichu'] as String?,
      makh: json['makh'] as int?,
      ngayhuy: json['ngayhuy'] != null ? DateTime.parse(json['ngayhuy']) : null,
      chitietdatphongs: json['chitietdatphongs'] != null
          ? (json['chitietdatphongs'] as List)
              .map((e) => Chitietdatphong.fromJson(e))
              .toList()
          : null,
      sudungdichvus: json['sudungdichvus'] != null
          ? (json['sudungdichvus'] as List)
              .map((e) => Sudungdv.fromJson(e))
              .toList()
          : null,
      denbuthiethai: json['denbuthiethais'] != null
          ? (json['denbuthiethais'] as List)
              .map((e) => Denbuthiethai.fromJson(e))
              .toList()
          : null,
      chitiethoadons: json['chitiethoadons'] != null
          ? (json['chitiethoadons'] as List)
              .map((e) => Chitiethoadon.fromJson(e))
              .toList()
          : null,
      hoadons: json['hoadons'] != null
          ? (json['hoadons'] as List)
              .map((e) => Hoadon.fromJson(e))
              .toList()
          : null,
    );
  }
}