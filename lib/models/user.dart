class AppUser {
  final String? id;
  final String name;
  final String email;
  final DateTime createdAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}