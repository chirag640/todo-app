import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// Adds authentication token to requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  
  final LocalStorage _storage;
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storage.getString(AppConstants.keyAccessToken);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('Added auth token to request', 'AuthInterceptor');
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized - token might be expired', 'AuthInterceptor');
      // TODO: Implement token refresh logic here
    }
    
    handler.next(err);
  }
}

