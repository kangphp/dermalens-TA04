class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', // Berikan nilai default jika null
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'], // Sudah nullable
      avatar: json['avatar'], // Sudah nullable
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Berikan nilai default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Membuat salinan dengan nilai yang diperbarui
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
