// This file defines the UserModel class, which represents a user in the system.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // e.g., 'admin', 'technician', 'reporter'
  final String subRole; // type of technician
  final String? profileImageUrl; // optional profile picture
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.subRole,
    this.profileImageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from JSON (e.g., when fetching from Firebase or REST API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'reporter',
      subRole: json['subRole'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON (e.g., when saving to Firebase or a server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'subRole': subRole,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
