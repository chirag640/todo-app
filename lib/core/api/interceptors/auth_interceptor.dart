import 'package:dio/dio.dart';
import '../../../features/auth/data/services/secure_storage_service.dart';
import '../../utils/logger.dart';

/// Adds authentication token to requests and handles token refresh on 401
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<Function> _requestsToRetry = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storage.getAccessToken();

    // List of auth endpoints that don't require authentication
    final publicAuthEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];

    // Add token to all requests except public auth endpoints
    final isPublicEndpoint =
        publicAuthEndpoints.any((endpoint) => options.path.contains(endpoint));

    if (token != null && !isPublicEndpoint) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug(
          'Added auth token to request: ${options.path}', 'AuthInterceptor');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // List of protected endpoints that should trigger token refresh on 401
    final protectedEndpoints = [
      '/auth/profile',
      '/auth/change-password',
      '/auth/logout',
      '/tasks',
    ];

    // Only attempt token refresh for 401 on protected endpoints
    // (not on login/register failures)
    final isProtectedEndpoint = protectedEndpoints
        .any((endpoint) => err.requestOptions.path.contains(endpoint));

    // Handle 401 Unauthorized - token expired
    if (response?.statusCode == 401 && isProtectedEndpoint) {
      AppLogger.warning(
          '401 Unauthorized - attempting token refresh', 'AuthInterceptor');

      // Prevent multiple simultaneous refresh attempts
      if (_isRefreshing) {
        AppLogger.debug('Token refresh already in progress, queuing request',
            'AuthInterceptor');
        // Queue this request to be retried after refresh completes
        try {
          await _waitForRefresh();
          final options = err.requestOptions;
          final retryResponse = await _retry(options);
          return handler.resolve(retryResponse);
        } catch (e) {
          return handler.reject(err);
        }
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh token
        final refreshToken = _storage.getRefreshToken();
        if (refreshToken == null) {
          AppLogger.error('No refresh token available', 'AuthInterceptor');
          await _storage.clearAuthSession();
          return handler.reject(err);
        }

        AppLogger.info('Refreshing access token', 'AuthInterceptor');

        // Call refresh endpoint
        final refreshResponse = await _dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {'Authorization': null}, // Don't use old token
          ),
        );

        final newAccessToken = refreshResponse.data['accessToken'] as String;
        final newRefreshToken = refreshResponse.data['refreshToken'] as String;

        // Update tokens
        await _storage.saveAccessToken(newAccessToken);
        await _storage.saveRefreshToken(newRefreshToken);

        AppLogger.info('Token refresh successful', 'AuthInterceptor');

        // Retry the original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _retry(options);

        // Retry all queued requests
        _retryQueuedRequests();

        return handler.resolve(retryResponse);
      } catch (e) {
        AppLogger.error('Token refresh failed: $e', 'AuthInterceptor');
        await _storage.clearAuthSession();
        // Clear queued requests
        _requestsToRetry.clear();
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Retry a request with updated token
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Wait for refresh to complete
  Future<void> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Retry all queued requests after successful refresh
  void _retryQueuedRequests() {
    for (final request in _requestsToRetry) {
      request();
    }
    _requestsToRetry.clear();
  }
}
