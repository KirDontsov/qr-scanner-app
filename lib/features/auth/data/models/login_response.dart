import '../../domain/entities/user.dart';

class LoginResponse {
  final String token;
  final User? user;

  LoginResponse({
    required this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}