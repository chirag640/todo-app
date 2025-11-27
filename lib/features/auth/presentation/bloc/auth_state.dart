import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

/// Base class for all auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking authentication status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication in progress (login/register/refresh)
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authentication failed
class AuthError extends AuthState {
  final String message;
  final bool canRetry;

  const AuthError(this.message, {this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

/// Registration success (before auto-login)
class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent
class AuthPasswordResetRequested extends AuthState {
  final String message;

  const AuthPasswordResetRequested(this.message);

  @override
  List<Object?> get props => [message];
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  final String message;

  const AuthPasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Token refresh in progress (silent, don't show loading UI)
class AuthRefreshing extends AuthState {
  final UserModel user;

  const AuthRefreshing(this.user);

  @override
  List<Object?> get props => [user];
}

/// Session expired (401 error)
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile update successful
class AuthProfileUpdated extends AuthState {
  final UserModel user;
  final String message;

  const AuthProfileUpdated(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

/// Password change successful
class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}
