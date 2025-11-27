import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/config/app_config.dart';
import '../core/api/api_client.dart';
import '../features/home/presentation/bloc/task_bloc.dart';
import '../features/home/data/services/task_service.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/data/services/auth_service.dart';
import '../features/auth/data/services/secure_storage_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    final config = AppConfig.load();

    // Initialize secure storage
    final secureStorage = SecureStorageService();

    // Initialize API client with secure storage
    final apiClient = ApiClient(config, secureStorage);

    // Initialize services
    final taskService = TaskService(apiClient);
    final authService = AuthService(apiClient, secureStorage);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            // Auth BLoC - check auth status on app start
            BlocProvider(
              create: (context) =>
                  AuthBloc(authService)..add(const CheckAuthStatusEvent()),
            ),
            // Task BLoC
            BlocProvider(
              create: (context) => TaskBloc(taskService),
            ),
          ],
          child: MaterialApp(
            title: 'Todo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            initialRoute: AppRouter.splash,
            onGenerateRoute: router.onGenerateRoute,
          ),
        );
      },
    );
  }
}
