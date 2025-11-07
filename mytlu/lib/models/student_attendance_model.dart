enum AttendanceStatus { present, late, absent }

class StudentAttendance {
  final String id;
  final String name;
  final String className;
  final AttendanceStatus status;

  StudentAttendance({
    required this.id,
    required this.name,
    required this.className,
    required this.status,
  });
}