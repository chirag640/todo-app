import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences for type-safe storage
class LocalStorage {
  LocalStorage._();
  
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs!.getString(key);
  }
  
  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }
  
  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }
  
  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }
  
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }
  
  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }
  
  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }
  
  // Remove operation
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }
  
  // Clear all
  Future<bool> clear() async {
    return await _prefs!.clear();
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}

