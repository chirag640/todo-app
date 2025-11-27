import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class UserService {
  final ApiClient apiClient;

  UserService(this.apiClient);

  /// Send FCM token to backend
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await apiClient.patch(
        '/users/me/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      // Log error but don't throw - FCM token update is not critical
      print('Failed to update FCM token: ${e.message}');
    }
  }
}
