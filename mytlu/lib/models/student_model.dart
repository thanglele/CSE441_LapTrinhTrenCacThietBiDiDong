class Student {
  final String id;
  final String name;
  final String className;
  final String imageUrl;
  final bool isRegistered; // true = Đã đăng ký, false = Chưa

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.imageUrl,
    required this.isRegistered,
  });
}