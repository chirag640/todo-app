import 'package:equatable/equatable.dart';

/// Login request matching backend LoginDto
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, password];
}
