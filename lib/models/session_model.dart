class SessionModel {
  final String id;
  final String userId;
  final String ipAddress;
  final String userAgent;
  final DateTime lastActivity;

  SessionModel({
    required this.id,
    required this.userId,
    required this.ipAddress,
    required this.userAgent,
    required this.lastActivity,
  });

  // Konversi dari JSON ke model
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      userId: json['user_id'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      lastActivity: DateTime.parse(json['last_activity']),
    );
  }

  // Konversi dari model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'last_activity': lastActivity.toIso8601String(),
    };
  }
}
