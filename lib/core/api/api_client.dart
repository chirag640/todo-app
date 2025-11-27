import 'package:dio/dio.dart';
import '../../features/auth/data/services/secure_storage_service.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  ApiClient(this.config, this.storage) {
    _initializeDio();
  }

  final AppConfig config;
  final SecureStorageService storage;
  late final Dio dio;

  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order (auth interceptor now receives dio for token refresh)
    dio.interceptors.addAll([
      AuthInterceptor(storage, dio),
      RetryInterceptor(),
      LoggerInterceptor(),
    ]);
  }

  /// Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
