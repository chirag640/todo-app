import 'package:equatable/equatable.dart';

/// Register request matching backend RegisterDto
class RegisterRequest extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String? lastName;
  final List<String>? roles;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    this.lastName,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
      'firstName': firstName.trim(),
      if (lastName != null && lastName!.isNotEmpty)
        'lastName': lastName!.trim(),
      if (roles != null) 'roles': roles,
    };
  }

  @override
  List<Object?> get props => [email, password, firstName, lastName, roles];
}
