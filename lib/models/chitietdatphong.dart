/// Model chi tiết đặt phòng
class Chitietdatphong {
  final int? madatphong;
  final int? maphong;
  final int? tongcong;
  final String? trangthai;
  final String? sophong; // Tên phòng (không lưu DB, chỉ để hiển thị)
  final String? tenloaiphong; // Tên loại phòng (không lưu DB, chỉ để hiển thị)

  Chitietdatphong({
    required this.madatphong,
    required this.maphong,
    this.tongcong,
    this.trangthai,
    this.sophong,
    this.tenloaiphong,
  });

  Map<String, dynamic> toJson() {
    return {
      'madatphong': madatphong,
      'maphong': maphong,
      'tongcong': tongcong,
      'trangthai': trangthai,
    };
  }

  factory Chitietdatphong.fromJson(Map<String, dynamic> json) {
    return Chitietdatphong(
      madatphong: json['madatphong'],
      maphong: json['maphong'],
      tongcong: json['tongcong'],
      trangthai: json['trangthai'],
      sophong: json['sophong'],
      tenloaiphong: json['tenloaiphong'],
    );
  }
}