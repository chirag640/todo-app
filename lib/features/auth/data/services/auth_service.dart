import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// Auth service for all authentication operations
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthService(this._apiClient, this._storage);

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final requestData = request.toJson();
      AppLogger.info(
          'Attempting registration for: ${request.email}', 'AuthService');
      AppLogger.debug('Registration payload: $requestData', 'AuthService');

      final response = await _apiClient.post(
        '/auth/register',
        data: requestData,
      );

      AppLogger.debug(
          'Registration response data: ${response.data}', 'AuthService');

      // Extract data from backend response wrapper: {success, data, meta}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      final authResponse = AuthResponse.fromJson(data);

      // Save tokens and user data
      await _storage.saveAuthSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: authResponse.user,
        rememberMe: true,
      );

      AppLogger.info(
          'Registration successful for: ${request.email}', 'AuthService');
      return authResponse;
    } on DioException catch (e) {
      AppLogger.error('Registration failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error(
          'Unexpected error during registration: $e', 'AuthService');
      throw ServerFailure('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<AuthResponse> login(LoginRequest request,
      {bool rememberMe = true}) async {
    try {
      AppLogger.info('Attempting login for: ${request.email}', 'AuthService');

      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      AppLogger.debug('Login response data: ${response.data}', 'AuthService');

      // Extract data from backend response wrapper
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      final authResponse = AuthResponse.fromJson(data);

      // Save tokens and user data
      await _storage.saveAuthSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: authResponse.user,
        rememberMe: rememberMe,
      );

      AppLogger.info('Login successful for: ${request.email}', 'AuthService');
      return authResponse;
    } on DioException catch (e) {
      AppLogger.error('Login failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error during login: $e', 'AuthService');
      throw ServerFailure('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null) {
        throw UnauthorizedFailure('No refresh token available');
      }

      AppLogger.info('Attempting token refresh', 'AuthService');

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      // Update tokens
      await _storage.saveAccessToken(newAccessToken);
      await _storage.saveRefreshToken(newRefreshToken);

      // Get existing user data
      final user = _storage.getUser();
      if (user == null) {
        throw UnauthorizedFailure('User data not found');
      }

      AppLogger.info('Token refresh successful', 'AuthService');
      return AuthResponse(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        user: user,
      );
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed: ${e.message}', 'AuthService');
      // Clear invalid tokens
      await _storage.clearTokens();
      throw _handleError(e);
    } catch (e) {
      AppLogger.error(
          'Unexpected error during token refresh: $e', 'AuthService');
      await _storage.clearTokens();
      throw ServerFailure('Token refresh failed: ${e.toString()}');
    }
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    try {
      AppLogger.info('Fetching user profile', 'AuthService');

      final response = await _apiClient.get('/auth/profile');

      AppLogger.debug('Profile response data: ${response.data}', 'AuthService');

      // Extract data from backend response wrapper
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      final user = UserModel.fromJson(data);

      // Update local user data
      await _storage.saveUser(user);

      AppLogger.info('Profile fetched successfully', 'AuthService');
      return user;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch profile: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching profile: $e', 'AuthService');
      throw ServerFailure('Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken != null) {
        AppLogger.info('Attempting logout', 'AuthService');

        await _apiClient.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }

      // Clear local session regardless of API response
      await _storage.clearAuthSession();
      AppLogger.info('Logout successful', 'AuthService');
    } on DioException catch (e) {
      AppLogger.warning(
          'Logout API failed, clearing local session: ${e.message}',
          'AuthService');
      // Clear local session even if API fails
      await _storage.clearAuthSession();
    } catch (e) {
      AppLogger.error('Unexpected error during logout: $e', 'AuthService');
      // Clear local session even on unexpected errors
      await _storage.clearAuthSession();
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _storage.hasActiveSession();
  }

  /// Get current user from local storage
  UserModel? getCurrentUser() {
    return _storage.getUser();
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      AppLogger.info('Requesting password reset for: $email', 'AuthService');

      await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );

      AppLogger.info('Password reset email sent to: $email', 'AuthService');
    } on DioException catch (e) {
      AppLogger.error(
          'Password reset request failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error(
          'Unexpected error during password reset request: $e', 'AuthService');
      throw ServerFailure('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      AppLogger.info('Resetting password with token', 'AuthService');

      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      AppLogger.info('Password reset successful', 'AuthService');
    } on DioException catch (e) {
      AppLogger.error('Password reset failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error(
          'Unexpected error during password reset: $e', 'AuthService');
      throw ServerFailure('Password reset failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      AppLogger.info('Updating user profile', 'AuthService');

      final response = await _apiClient.patch(
        '/auth/profile',
        data: {
          'firstName': firstName,
          if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );

      AppLogger.debug(
          'Profile update response: ${response.data}', 'AuthService');

      // Extract data from backend response wrapper
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      final user = UserModel.fromJson(data);

      // Update local user data
      await _storage.saveUser(user);

      AppLogger.info('Profile updated successfully', 'AuthService');
      return user;
    } on DioException catch (e) {
      AppLogger.error('Profile update failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error updating profile: $e', 'AuthService');
      throw ServerFailure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Changing user password', 'AuthService');

      await _apiClient.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      AppLogger.info('Password changed successfully', 'AuthService');
    } on DioException catch (e) {
      AppLogger.error('Password change failed: ${e.message}', 'AuthService');
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error changing password: $e', 'AuthService');
      throw ServerFailure('Failed to change password: ${e.toString()}');
    }
  }

  /// Handle Dio errors and convert to Failures
  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        AppLogger.debug(
            'Response error data: ${error.response?.data}', 'AuthService');
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return ValidationFailure(message ?? 'Invalid request data.');
          case 401:
            return UnauthorizedFailure(
                message ?? 'Invalid credentials or session expired.');
          case 403:
            return UnauthorizedFailure(message ?? 'Access forbidden.');
          case 404:
            return ServerFailure(message ?? 'Resource not found.');
          case 409:
            return ValidationFailure(message ?? 'User already exists.');
          case 429:
            return ServerFailure(
                message ?? 'Too many requests. Please try again later.');
          case 500:
          case 502:
          case 503:
            return ServerFailure(
                message ?? 'Server error. Please try again later.');
          default:
            return ServerFailure(
                message ?? 'An error occurred. Please try again.');
        }

      case DioExceptionType.cancel:
        return NetworkFailure('Request cancelled.');

      case DioExceptionType.connectionError:
        return NetworkFailure(
            'No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return NetworkFailure('Security certificate error.');

      default:
        return NetworkFailure('Network error: ${error.message}');
    }
  }

  /// Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map<String, dynamic>) {
        // Handle backend error format: {success, error: {message: [...], ...}, meta}
        if (data['error'] is Map<String, dynamic>) {
          final error = data['error'] as Map<String, dynamic>;

          // Check if message is an array (NestJS validation errors)
          if (error['message'] is List) {
            final messages = error['message'] as List;
            return messages.isNotEmpty ? messages.first.toString() : null;
          }

          // Check if message is a string
          if (error['message'] is String) {
            return error['message'] as String;
          }
        }

        // Handle NestJS validation error format (direct message field)
        if (data['message'] is List) {
          final messages = data['message'] as List;
          return messages.isNotEmpty ? messages.first.toString() : null;
        }

        // Try different common error message fields
        if (data['message'] is String) {
          return data['message'] as String;
        }

        if (data['detail'] is String) {
          return data['detail'] as String;
        }

        // Handle array of errors
        if (data['errors'] is List) {
          final errors = data['errors'] as List;
          return errors.isNotEmpty ? errors.first.toString() : null;
        }
      }

      if (data is String) {
        return data;
      }
    } catch (e) {
      AppLogger.warning('Error extracting error message: $e', 'AuthService');
    }

    return null;
  }
}
