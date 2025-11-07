class SessionData {
  final String sessionId;
  final String classCode;
  final String subjectName;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final String date; // 🟢 thêm thuộc tính ngày học

  SessionData({
    required this.sessionId,
    required this.classCode,
    required this.subjectName,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  // 🧩 Parse từ JSON trả về của API
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      sessionId: json['sessionId'].toString(),
      classCode: json['classCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      roomName: json['roomName'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      // Nếu API có field riêng "date" → dùng trực tiếp
      // Nếu không, bạn có thể tách từ startTime:
      date: json['date'] ??
          DateTime.parse(json['startTime'])
              .toLocal()
              .toString()
              .split(' ')[0],
    );
  }

  // 🧾 Chuyển ngược lại JSON (nếu cần)
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'classCode': classCode,
    'subjectName': subjectName,
    'roomName': roomName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'date': date,
  };
}
