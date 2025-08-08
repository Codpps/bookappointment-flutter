class UserModel {
  final int userId;
  final String name;
  final String token;

  UserModel({
    required this.userId,
    required this.name,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
