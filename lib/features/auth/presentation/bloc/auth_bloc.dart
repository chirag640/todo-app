import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<FetchProfileEvent>(_onFetchProfile);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  /// Check if user is already authenticated
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Checking auth status', 'AuthBloc');

      if (_authService.isAuthenticated()) {
        final user = _authService.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
          AppLogger.info('User is authenticated: ${user.email}', 'AuthBloc');
          return;
        }
      }

      emit(const AuthUnauthenticated());
      AppLogger.info('User is not authenticated', 'AuthBloc');
    } catch (e) {
      AppLogger.error('Error checking auth status: $e', 'AuthBloc');
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Logging in...'));
      AppLogger.info('Login attempt for: ${event.request.email}', 'AuthBloc');

      final authResponse = await _authService.login(
        event.request,
        rememberMe: event.rememberMe,
      );

      emit(AuthAuthenticated(authResponse.user));
      AppLogger.info(
          'Login successful for: ${event.request.email}', 'AuthBloc');
    } on Failure catch (e) {
      AppLogger.error('Login failed: ${e.message}', 'AuthBloc');
      emit(AuthError(e.message, canRetry: e is! ValidationFailure));
    } catch (e) {
      AppLogger.error('Unexpected login error: $e', 'AuthBloc');
      emit(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Handle registration
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Creating account...'));
      AppLogger.info(
          'Registration attempt for: ${event.request.email}', 'AuthBloc');

      final authResponse = await _authService.register(event.request);

      // Auto-login after registration (best practice)
      emit(AuthAuthenticated(authResponse.user));
      AppLogger.info(
          'Registration and auto-login successful for: ${event.request.email}',
          'AuthBloc');
    } on Failure catch (e) {
      AppLogger.error('Registration failed: ${e.message}', 'AuthBloc');
      emit(AuthError(e.message, canRetry: e is! ValidationFailure));
    } catch (e) {
      AppLogger.error('Unexpected registration error: $e', 'AuthBloc');
      emit(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Handle logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Logout initiated', 'AuthBloc');

      await _authService.logout();

      emit(const AuthUnauthenticated());
      AppLogger.info('Logout successful', 'AuthBloc');
    } catch (e) {
      AppLogger.error('Logout error: $e', 'AuthBloc');
      // Always emit unauthenticated even on error (local session is cleared)
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle token refresh
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        emit(AuthRefreshing(currentUser));
      }

      AppLogger.info('Token refresh initiated', 'AuthBloc');

      final authResponse = await _authService.refreshToken();

      emit(AuthAuthenticated(authResponse.user));
      AppLogger.info('Token refresh successful', 'AuthBloc');
    } on UnauthorizedFailure catch (e) {
      AppLogger.error(
          'Token refresh failed (unauthorized): ${e.message}', 'AuthBloc');
      emit(AuthSessionExpired(e.message));
    } on Failure catch (e) {
      AppLogger.error('Token refresh failed: ${e.message}', 'AuthBloc');
      emit(AuthSessionExpired(e.message));
    } catch (e) {
      AppLogger.error('Unexpected token refresh error: $e', 'AuthBloc');
      emit(const AuthSessionExpired('Session expired. Please login again.'));
    }
  }

  /// Handle fetch profile
  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Fetching user profile', 'AuthBloc');

      final user = await _authService.getProfile();

      emit(AuthAuthenticated(user));
      AppLogger.info('Profile fetched successfully', 'AuthBloc');
    } on UnauthorizedFailure catch (e) {
      AppLogger.error(
          'Profile fetch failed (unauthorized): ${e.message}', 'AuthBloc');
      emit(AuthSessionExpired(e.message));
    } on Failure catch (e) {
      AppLogger.error('Profile fetch failed: ${e.message}', 'AuthBloc');
      // Keep current auth state, just log error
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      AppLogger.error('Unexpected profile fetch error: $e', 'AuthBloc');
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    }
  }

  /// Handle password reset request
  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Sending reset email...'));
      AppLogger.info(
          'Password reset requested for: ${event.email}', 'AuthBloc');

      await _authService.requestPasswordReset(event.email);

      emit(const AuthPasswordResetRequested(
        'Password reset email sent. Please check your inbox.',
      ));
      AppLogger.info(
          'Password reset email sent to: ${event.email}', 'AuthBloc');

      // Return to unauthenticated after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      emit(const AuthUnauthenticated());
    } on Failure catch (e) {
      AppLogger.error(
          'Password reset request failed: ${e.message}', 'AuthBloc');
      emit(AuthError(e.message));

      // Return to unauthenticated after showing error
      await Future.delayed(const Duration(seconds: 2));
      emit(const AuthUnauthenticated());
    } catch (e) {
      AppLogger.error(
          'Unexpected password reset request error: $e', 'AuthBloc');
      emit(const AuthError('Failed to send reset email. Please try again.'));

      await Future.delayed(const Duration(seconds: 2));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle password reset
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Resetting password...'));
      AppLogger.info('Password reset with token', 'AuthBloc');

      await _authService.resetPassword(event.token, event.newPassword);

      emit(const AuthPasswordResetSuccess(
        'Password reset successful. Please login with your new password.',
      ));
      AppLogger.info('Password reset successful', 'AuthBloc');

      // Return to unauthenticated after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      emit(const AuthUnauthenticated());
    } on Failure catch (e) {
      AppLogger.error('Password reset failed: ${e.message}', 'AuthBloc');
      emit(AuthError(e.message));

      await Future.delayed(const Duration(seconds: 2));
      emit(const AuthUnauthenticated());
    } catch (e) {
      AppLogger.error('Unexpected password reset error: $e', 'AuthBloc');
      emit(const AuthError('Failed to reset password. Please try again.'));

      await Future.delayed(const Duration(seconds: 2));
      emit(const AuthUnauthenticated());
    }
  }
}
