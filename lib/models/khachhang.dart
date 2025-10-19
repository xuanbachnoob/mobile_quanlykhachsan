class Khachhang {
  // Sửa tất cả các trường thành nullable (thêm dấu ?), trừ 'hoten'
  final int? makh;
  final String hoten; // API đăng nhập có trả về 'hoten', nên giữ required
  final String? email;
  final String? sdt;
  final String? diachi;
  final String? cccd;
  final DateTime? ngaysinh;
  final int? diemthanhvien;
  final String? trangthai;
  final DateTime? ngaytao;
  final String? matkhau; // (Cảnh báo: Không bao giờ nên gửi mật khẩu về client)

  Khachhang({
    this.makh,
    required this.hoten, // 'hoten' là bắt buộc
    this.email,
    this.sdt,
    this.diachi,
    this.cccd,
    this.ngaysinh,
    this.diemthanhvien,
    this.trangthai,
    this.ngaytao,
    this.matkhau,
  });

  /// Factory 1: Dùng cho API Đăng nhập (JSON phẳng, tối giản)
  /// Đây là hàm mà login_screen.dart của bạn đang dùng
  factory Khachhang.fromLoginResponse(Map<String, dynamic> json, String emailOrSdt) {
    String? emailValue;
    String? sdtValue;
    if (emailOrSdt.contains('@')) {
      emailValue = emailOrSdt;
    } else {
      sdtValue = emailOrSdt;
    }

    return Khachhang(
      hoten: json['hoten'], // Lấy 'hoten' từ API
      email: emailValue, // Lấy từ ô nhập liệu
      sdt: sdtValue,     // Lấy từ ô nhập liệu
      // Tất cả các trường khác sẽ là null
    );
  }

  /// Factory 2: Dùng cho API GetProfile (JSON đầy đủ)
  /// Bạn sẽ dùng hàm này SAU KHI đăng nhập
  factory Khachhang.fromJson(Map<String, dynamic> json) {
    return Khachhang(
      makh: json['Makh'],
      hoten: json['Hoten'],
      email: json['Email'],
      sdt: json['Sdt'],
      diachi: json['Diachi'],
      cccd: json['Cccd'],
      // Thêm kiểm tra null trước khi parse DateTime
      ngaysinh: json['Ngaysinh'] != null ? DateTime.parse(json['Ngaysinh']) : null,
      diemthanhvien: json['Diemthanhvien'],
      trangthai: json['Trangthai'],
      ngaytao: json['Ngaytao'] != null ? DateTime.parse(json['Ngaytao']) : null,
      matkhau: json['Matkhau'],
    );
  }

  /// Hàm tiện ích: Dùng để cập nhật UserProvider
  /// khi bạn lấy được thông tin đầy đủ từ API GetProfile
  Khachhang copyWith({
    int? makh,
    String? hoten,
    String? email,
    String? sdt,
    String? diachi,
    String? cccd,
    DateTime? ngaysinh,
    int? diemthanhvien,
    String? trangthai,
    DateTime? ngaytao,
    String? matkhau,
  }) {
    return Khachhang(
      makh: makh ?? this.makh,
      hoten: hoten ?? this.hoten,
      email: email ?? this.email,
      sdt: sdt ?? this.sdt,
      diachi: diachi ?? this.diachi,
      cccd: cccd ?? this.cccd,
      ngaysinh: ngaysinh ?? this.ngaysinh,
      diemthanhvien: diemthanhvien ?? this.diemthanhvien,
      trangthai: trangthai ?? this.trangthai,
      ngaytao: ngaytao ?? this.ngaytao,
      matkhau: matkhau ?? this.matkhau,
    );
  }
}