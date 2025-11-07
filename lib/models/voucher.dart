class Voucher {
  final String mavoucher;
  final String tenvoucher;
  final String? mota;
  final int? giagiam;
  final DateTime? ngaybatdau;
  final DateTime? ngayketthuc;
  final int? maloaiphong;
  final String? tenLoaiPhong;

  Voucher({
    required this.mavoucher,
    required this.tenvoucher,
    this.mota,
    this.giagiam,
    this.ngaybatdau,
    this.ngayketthuc,
    this.maloaiphong,
    this.tenLoaiPhong,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      mavoucher: json['mavoucher'] as String,
      tenvoucher: json['tenvoucher'] as String,
      mota: json['mota'] as String?,
      giagiam: (json['giagiam'] as num?)?.toInt(),
      ngaybatdau: json['ngaybatdau'] != null 
          ? DateTime.parse(json['ngaybatdau']) 
          : null,
      ngayketthuc: json['ngayketthuc'] != null 
          ? DateTime.parse(json['ngayketthuc']) 
          : null,
      maloaiphong: (json['maloaiphong'] as num?)?.toInt(),
      tenLoaiPhong: json['tenLoaiPhong'] as String?,
    );
  }
}