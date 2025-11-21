class Hoantien {
  final int? mahoantien;
  final int madatphong;
  final int sotienhoan;
  final String lydo;
  final String? trangthai;
  final DateTime? ngaytao;
  final String? ghichu;

  Hoantien({
    this.mahoantien,
    required this.madatphong,
    required this.sotienhoan,
    required this.lydo,
    this.trangthai,
    this.ngaytao,
    this.ghichu,
  });

  Map<String, dynamic> toJson() {
    return {
      'madatphong': madatphong,
      'sotienhoan': sotienhoan,
      'lydo': lydo,
      if (trangthai != null) 'trangthai': trangthai,
      if (ghichu != null) 'ghichu': ghichu,
    };
  }

  factory Hoantien.fromJson(Map<String, dynamic> json) {
    return Hoantien(
      mahoantien: json['mahoantien'],
      madatphong: json['madatphong'],
      sotienhoan: json['sotienhoan'],
      lydo: json['lydo'] ?? '',
      trangthai: json['trangthai'],
      ngaytao: json['ngaytao'] != null ? DateTime.parse(json['ngaytao']) : null,
      ghichu: json['ghichu'],
    );
  }
}