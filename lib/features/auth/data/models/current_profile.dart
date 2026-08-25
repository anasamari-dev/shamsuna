/// بيانات المستخدم والصلاحية القادمة من profiles.
class CurrentProfile {
  const CurrentProfile({
    required this.userId,
    required this.displayName,
    required this.role,
  });

  final String userId;
  final String displayName;
  final String role;

  bool get isAdmin => role == 'admin';

  factory CurrentProfile.fromMap(Map<String, dynamic> map) {
    return CurrentProfile(
      userId: '${map['user_id']}',
      displayName: '${map['display_name'] ?? 'المستخدم'}',
      role: '${map['role'] ?? 'user'}',
    );
  }
}
