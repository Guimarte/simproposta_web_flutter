class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? companyName;
  final String? primaryColor;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.companyName,
    this.primaryColor,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>?;
    return UserEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'SELLER',
      companyName: company?['name'] as String?,
      primaryColor: company?['primaryColor'] as String?,
    );
  }
}
