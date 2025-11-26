import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// Automatically retries failed requests
class RetryInterceptor extends Interceptor {
  int _retryCount = 0;
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && _retryCount < AppConstants.maxRetries) {
      _retryCount++;
      AppLogger.warning(
        'Retrying request (attempt $_retryCount/${AppConstants.maxRetries})',
        'RetryInterceptor',
      );
      
      try {
        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(seconds: _retryCount));
        
        final response = await Dio().fetch(err.requestOptions);
        _retryCount = 0; // Reset on success
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    
    _retryCount = 0; // Reset counter
    return handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown;
  }
}

