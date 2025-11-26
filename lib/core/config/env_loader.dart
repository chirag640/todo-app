import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, stage, prod }

class EnvLoader {
  static AppEnvironment currentEnvironment = AppEnvironment.dev;
  static bool _isLoaded = false;

  static Future<void> load({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName, mergeWith: {});
      final envName = dotenv.maybeGet('APP_ENV') ?? 'dev';
      currentEnvironment = AppEnvironment.values.firstWhere(
        (element) => element.name == envName,
        orElse: () => AppEnvironment.dev,
      );
      _isLoaded = true;
    } catch (e) {
      // .env file not found, use default values
      _isLoaded = false;
      currentEnvironment = AppEnvironment.dev;
    }
  }

  static String get apiBaseUrl {
    if (_isLoaded) {
      return dotenv.maybeGet('API_BASE_URL') ?? 'https://api.example.com';
    }
    return 'https://api.example.com';
  }
}
