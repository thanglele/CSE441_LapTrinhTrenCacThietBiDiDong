enum TrangThaiLopHoc {
  dangDienRa,
  sapDienRa,
  daKetThuc_DaDiemDanh,
  daKetThuc_ChuaDiemDanh,
}

class LopHoc {
  final String tenLop;
  final String phong;
  final String giangVien;
  final String thoiGian;
  final TrangThaiLopHoc trangThai;

  LopHoc({
    required this.tenLop,
    required this.phong,
    required this.giangVien,
    required this.thoiGian,
    required this.trangThai,
  });
}
