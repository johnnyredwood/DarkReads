class User {
  final String id;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Serialización JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
