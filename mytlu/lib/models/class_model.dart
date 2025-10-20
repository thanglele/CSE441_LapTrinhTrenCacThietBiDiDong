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
      code: json['code'] as String,
      name: json['name'] as String,
      room: json['room'] as String,
      lecturer: json['lecturer'] as String,
      time: '${json['startTime']} - ${json['endTime']}',
      status: json['status'] as String,
    );
  }
}