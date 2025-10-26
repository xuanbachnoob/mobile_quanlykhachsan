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
  final DateTime? ngayhuy;

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
    this.ngayhuy,
  });

  /// ✅ toJson CHỈ GỬI: ngaynhanphong, ngaytraphong, makh, ghichu
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'ngaynhanphong': ngaynhanphong.toIso8601String().split('T')[0],
      'ngaytraphong': ngaytraphong.toIso8601String().split('T')[0],
      'makh': makh,
      'trangthai': trangthai,
      'trangthaithanhtoan': trangthaithanhtoan,
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
    );
  }
}