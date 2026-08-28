class LoginResponse {
  final String token;
  final int userId;
  final String username;
  final String role;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.username,
    required this.role,
  });

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  bool get isAdmin =>
      role.toLowerCase() == 'admin';

  bool get isEmployee =>
      role.toLowerCase() == 'employee';
}