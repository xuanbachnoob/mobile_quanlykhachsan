class Khachhang {
  final int? makh;
  final String hoten;
  final String? email;
  final String? sdt;
  final String? diachi;
  final String? cccd;
  final DateTime? ngaysinh;
  final int? diemthanhvien;
  final String? trangthai;
  final DateTime? ngaytao;
  final String? matkhau;
  
  // ✅ THÊM: Role và Token cho login
  final String? role;
  final String? token;

  Khachhang({
    this.makh,
    required this.hoten,
    this.email,
    this.sdt,
    this.diachi,
    this.cccd,
    this.ngaysinh,
    this.diemthanhvien,
    this.trangthai,
    this.ngaytao,
    this.matkhau,
    this.role,
    this.token,
  });

  /// ✅ Factory CŨ (giữ nguyên để không break code)
  factory Khachhang.fromLoginResponse(Map<String, dynamic> json, String emailOrSdt) {
    String? emailValue;
    String? sdtValue;
    if (emailOrSdt.contains('@')) {
      emailValue = emailOrSdt;
    } else {
      sdtValue = emailOrSdt;
    }

    return Khachhang(
      hoten: json['hoten'] as String? ?? '',
      email: emailValue,
      sdt: sdtValue,
    );
  }

  /// ✅ Factory MỚI - Parse từ login response CÓ makh
  factory Khachhang.fromLoginJson(Map<String, dynamic> json) {
    print('🔍 Parsing Khachhang from login JSON: $json');
    
    return Khachhang(
      makh: json['makh'] as int?,           // ← Parse makh
      hoten: json['hoten'] as String? ?? '',
      email: json['email'] as String?,
      sdt: json['sdt'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Factory cho API GetProfile (JSON đầy đủ)
  factory Khachhang.fromJson(Map<String, dynamic> json) {
    return Khachhang(
      makh: json['makh'] as int? ?? json['Makh'] as int?,  // Support both formats
      hoten: json['hoten'] as String? ?? json['Hoten'] as String? ?? '',
      email: json['email'] as String? ?? json['Email'] as String?,
      sdt: json['sdt'] as String? ?? json['Sdt'] as String?,
      diachi: json['diachi'] as String? ?? json['Diachi'] as String?,
      cccd: json['cccd'] as String? ?? json['Cccd'] as String?,
      ngaysinh: json['ngaysinh'] != null 
          ? DateTime.parse(json['ngaysinh']) 
          : (json['Ngaysinh'] != null ? DateTime.parse(json['Ngaysinh']) : null),
      diemthanhvien: json['diemthanhvien'] as int? ?? json['Diemthanhvien'] as int?,
      trangthai: json['trangthai'] as String? ?? json['Trangthai'] as String?,
      ngaytao: json['ngaytao'] != null 
          ? DateTime.parse(json['ngaytao']) 
          : (json['Ngaytao'] != null ? DateTime.parse(json['Ngaytao']) : null),
      matkhau: json['matkhau'] as String? ?? json['Matkhau'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Hàm copy with
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
    String? role,
    String? token,
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
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makh': makh,
      'hoten': hoten,
      'email': email,
      'sdt': sdt,
      'diachi': diachi,
      'cccd': cccd,
      'ngaysinh': ngaysinh?.toIso8601String(),
      'diemthanhvien': diemthanhvien,
      'trangthai': trangthai,
      'ngaytao': ngaytao?.toIso8601String(),
      'matkhau': matkhau,
      'role': role,
      'token': token,
    };
  }
}