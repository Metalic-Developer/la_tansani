class AppUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'student',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
