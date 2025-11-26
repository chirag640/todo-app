import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/config/env_loader.dart';
import 'core/database/hive_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables (optional)
    await EnvLoader.load();
  } catch (e) {
    debugPrint('Environment file not found, using defaults: $e');
  }

  try {
    // Initialize Hive database
    await HiveDatabase.instance.init();
  } catch (e) {
    debugPrint('Failed to initialize database: $e');
  }

  runApp(const App());
}
