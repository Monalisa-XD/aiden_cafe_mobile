class User {
  final int id;
  final String name;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN';
  bool get canManage => isOwner || isAdmin;

  factory User.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'] as int;
      } else {
        parsedId = int.tryParse(json['id'].toString()) ?? 0;
      }
    }

    return User(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString().toUpperCase() ?? 'CUSTOMER',
    );
  }

  dynamic operator [](String key) {
    if (key == 'id') return id;
    if (key == 'name') return name;
    if (key == 'email') return email;
    if (key == 'role') return role;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
