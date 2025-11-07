class ClassModel {
  final String code;
  final String name;
  final String room;
  final String lecturer;
  final String time;
  final String status;

  ClassModel({
    required this.code,
    required this.name,
    required this.room,
    required this.lecturer,
    required this.time,
    required this.status,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      code: (json['classCode'] as String?) ?? 'N/A',
      name: (json['subjectName'] as String?) ?? 'Chưa cập nhật',
      room: (json['room'] as String?) ?? 'N/A',
      lecturer: (json['lecturerName'] as String?) ?? 'Giảng viên ẩn danh',

      time: '${(json['startTime'] as String?) ?? '00:00'} - ${(json['endTime'] as String?) ?? '00:00'}',

      status: (json['status'] as String?) ?? 'unknown',
    );
  }
}