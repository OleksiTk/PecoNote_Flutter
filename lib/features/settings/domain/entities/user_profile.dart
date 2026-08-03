class UserProfile {
  const UserProfile({
    required this.username,
    required this.email,
    this.phoneNumber,
    this.avatarPath,
  });

  final String username;
  final String email;
  final String? phoneNumber;
  final String? avatarPath;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return UserProfile(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      avatarPath: profile is Map ? profile['image'] as String? : null,
    );
  }

  String get initial => username.isNotEmpty ? username[0].toUpperCase() : '?';
}
