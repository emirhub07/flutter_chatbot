class User {
  final String id;
  final String email;
  final String role;
  final String? token;
  final String? name;

  User({required this.id, required this.email, required this.role, this.token, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'name': name,
    };
  }
}