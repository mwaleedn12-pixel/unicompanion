class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? userType;
  final bool onboardingCompleted;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.userType,
    this.onboardingCompleted = false,
    this.avatarUrl,
  });
}