import 'package:equatable/equatable.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is already authenticated on app start
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event to login user
class LoginEvent extends AuthEvent {
  final LoginRequest request;
  final bool rememberMe;

  const LoginEvent(this.request, {this.rememberMe = true});

  @override
  List<Object?> get props => [request, rememberMe];
}

/// Event to register new user
class RegisterEvent extends AuthEvent {
  final RegisterRequest request;

  const RegisterEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to logout user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event to refresh access token
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

/// Event to fetch user profile
class FetchProfileEvent extends AuthEvent {
  const FetchProfileEvent();
}

/// Event to request password reset
class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event to reset password with token
class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent(this.token, this.newPassword);

  @override
  List<Object?> get props => [token, newPassword];
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final String firstName;
  final String? lastName;
  final String? email;

  const UpdateProfileEvent({
    required this.firstName,
    this.lastName,
    this.email,
  });

  @override
  List<Object?> get props => [firstName, lastName, email];
}

/// Event to change password
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
