class ProfileModel {
  final String id;
  final String userId;
  final String? avatar; // Nullable
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.userId,
    this.avatar,
    required this.createdAt,
  });

  // Konversi dari JSON ke model
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      userId: json['user_id'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Konversi dari model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
