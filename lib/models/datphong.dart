/// Model đặt phòng
class Datphong {
  final int? madatphong;
  final DateTime ngaydat;
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
  final DateTime? ngayhuy;

  Datphong({
    this.madatphong,
    required this.ngaydat,
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
    this.ngayhuy,
  });

  Map<String, dynamic> toJson() {
    return {
      'madatphong': madatphong,
      'ngaydat': ngaydat.toIso8601String().split('T')[0], // YYYY-MM-DD
      'ngaynhanphong': ngaynhanphong.toIso8601String().split('T')[0],
      'ngaytraphong': ngaytraphong.toIso8601String().split('T')[0],
      'trangthai': trangthai,
      'dongia': dongia,
      'giamgia': giamgia,
      'tongtien': tongtien,
      'trangthaithanhtoan': trangthaithanhtoan,
      'chinhsachhuy': chinhsachhuy,
      'ghichu': ghichu,
      'makh': makh,
      'ngayhuy': ngayhuy?.toIso8601String().split('T')[0],
    };
  }

  factory Datphong.fromJson(Map<String, dynamic> json) {
    return Datphong(
      madatphong: json['madatphong'],
      ngaydat: DateTime.parse(json['ngaydat']),
      ngaynhanphong: DateTime.parse(json['ngaynhanphong']),
      ngaytraphong: DateTime.parse(json['ngaytraphong']),
      trangthai: json['trangthai'],
      dongia: json['dongia'],
      giamgia: json['giamgia'],
      tongtien: json['tongtien'],
      trangthaithanhtoan: json['trangthaithanhtoan'],
      chinhsachhuy: json['chinhsachhuy'],
      ghichu: json['ghichu'],
      makh: json['makh'],
      ngayhuy: json['ngayhuy'] != null ? DateTime.parse(json['ngayhuy']) : null,
    );
  }
}