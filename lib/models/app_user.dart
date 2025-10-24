/// Represents an authenticated user in the app
class AppUser {
  final String id;
  final String email;
  final String role; // 'customer' or 'vendor'

  AppUser({
    required this.id,
    required this.email,
    required this.role,
  });

  bool get isVendor => role == 'vendor';
  bool get isCustomer => role == 'customer';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() => 'AppUser(id: $id, email: $email, role: $role)';
}
