import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/lop_hoc.dart';

class LopHocCard extends StatelessWidget {
  final LopHoc lopHoc;

  const LopHocCard({super.key, required this.lopHoc});

  // Primary colors / palette from your list
  static const Color greenlight = Color(0xFFDCFCE7);
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color greenPrimary = Color(0xFF166534);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color bgBlueLight = Color(0xFFDBEAFE);
  static const Color bgLight = Color(0xFFEAEAEA);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color redPrimary = Color(0xFFF41515);
  static const Color blackText = Color(0xFF000000);

  Color _getStatusColor() {
    switch (lopHoc.trangThai) {

      case TrangThaiLopHoc.dangDienRa:
        return greenPrimary;

      case TrangThaiLopHoc.sapDienRa:
        return bluePrimary;
      case TrangThaiLopHoc.daKetThuc_DaDiemDanh:
        return greenPrimary;
      case TrangThaiLopHoc.daKetThuc_ChuaDiemDanh:
        return redPrimary;
    }
  }

  Color _getStatusBgColor() {
    switch (lopHoc.trangThai) {
      case TrangThaiLopHoc.dangDienRa:
        return greenlight;
      case TrangThaiLopHoc.sapDienRa:
        return bgBlueLight;
      case TrangThaiLopHoc.daKetThuc_DaDiemDanh:
      case TrangThaiLopHoc.daKetThuc_ChuaDiemDanh:
        return bgLight;
    }
  }

  String _getStatusText() {
    switch (lopHoc.trangThai) {
      case TrangThaiLopHoc.dangDienRa:
        return 'Đang diễn ra';
      case TrangThaiLopHoc.sapDienRa:
        return 'Sắp diễn ra';
      case TrangThaiLopHoc.daKetThuc_DaDiemDanh:
        return 'Đã kết thúc';
      case TrangThaiLopHoc.daKetThuc_ChuaDiemDanh:
        return 'Đã kết thúc';
    }
  }

  // If you later add a specific diem danh time in the model use that field;
  // for now we reuse lopHoc.thoiGian as shown in examples.
  String _getDiemDanhTime() {
    return lopHoc.thoiGian; // fallback to class time
  }

  bool get _isFinished =>
      lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_DaDiemDanh ||
      lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_ChuaDiemDanh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lopHoc.tenLop,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Medium
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    // For finished states the chip label should be black
                    color: _isFinished ? blackText : _getStatusColor(),
                    fontSize: 12,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${lopHoc.phong} • ${lopHoc.giangVien}',
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 12,
              color: gray500,
            ),
          ),
          const SizedBox(height: 8),

          // time row + (optional) QR button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // clock svg + class time (always visible)
              SvgPicture.asset(
                'assets/Dongho.svg',
                height: 16,
                width: 16,
                colorFilter: const ColorFilter.mode(gray500, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lopHoc.thoiGian,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12,
                    color: gray500,
                  ),
                ),
              ),

              // QR / action area on the right (smaller button)
              if (lopHoc.trangThai == TrangThaiLopHoc.dangDienRa) ...[
                ElevatedButton(
                  onPressed: () {
                    // QR scan / điểm danh action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bluePrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // smaller
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/MaQR.svg',
                        height: 14,
                        width: 14,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Điểm danh',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 11, // smaller font
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (lopHoc.trangThai == TrangThaiLopHoc.sapDienRa) ...[
                // disabled / grey QR button (no action) - smaller
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/MaQR.svg',
                        height: 14,
                        width: 14,
                        colorFilter: const ColorFilter.mode(gray400, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Quét QR',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 11,
                          color: gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // finished: no QR button here
              ],
            ],
          ),

          // If class is ongoing -> show Diem danh time below
          if (lopHoc.trangThai == TrangThaiLopHoc.dangDienRa) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: bluePrimary),
                const SizedBox(width: 8),
                Text(
                  'Điểm danh: ${_getDiemDanhTime()}',
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12,
                    color: bluePrimary,
                  ),
                ),
              ],
            ),
          ],

          // If finished -> show result (Đã điểm danh / Chưa điểm danh) aligned to right
          if (_isFinished) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_DaDiemDanh
                      ? 'assets/Tichdadiemdanh.svg'
                      : 'assets/Xchuadiemdanh.svg',
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(
                    lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_DaDiemDanh
                        ? greenPrimary
                        : redPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_DaDiemDanh
                      ? 'Đã điểm danh'
                      : 'Chưa điểm danh',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12,
                    color: lopHoc.trangThai == TrangThaiLopHoc.daKetThuc_DaDiemDanh
                        ? greenPrimary
                        : redPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
