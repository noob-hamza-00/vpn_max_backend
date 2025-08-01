import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get preferences => _preferences;

  // Boolean methods
  static Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  static bool getBoolWithDefault(String key, bool defaultValue) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  // String methods
  static Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  static String? getString(String key) {
    return _preferences.getString(key);
  }

  static String getStringWithDefault(String key, String defaultValue) {
    return _preferences.getString(key) ?? defaultValue;
  }

  // Integer methods
  static Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  static int? getInt(String key) {
    return _preferences.getInt(key);
  }

  static int getIntWithDefault(String key, int defaultValue) {
    return _preferences.getInt(key) ?? defaultValue;
  }

  // Double methods
  static Future<void> setDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  static double getDoubleWithDefault(String key, double defaultValue) {
    return _preferences.getDouble(key) ?? defaultValue;
  }

  // String List methods
  static Future<void> setStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  static List<String> getStringListWithDefault(String key, List<String> defaultValue) {
    return _preferences.getStringList(key) ?? defaultValue;
  }

  // Utility methods
  static Future<void> clear() async {
    await _preferences.clear();
  }

  static Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  static bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  static Set<String> getKeys() {
    return _preferences.getKeys();
  }

  // Method to reload preferences (useful after clearing)
  static Future<void> reload() async {
    await _preferences.reload();
  }

  // Debug method to print all stored preferences
  static void debugPrintAll() {
    print('=== All Stored Preferences ===');
    final keys = _preferences.getKeys();
    for (String key in keys) {
      final value = _preferences.get(key);
      print('$key: $value');
    }
    print('==============================');
  }

  // Method to get all preferences as a Map
  static Map<String, dynamic> getAll() {
    final Map<String, dynamic> result = {};
    final keys = _preferences.getKeys();
    for (String key in keys) {
      result[key] = _preferences.get(key);
    }
    return result;
  }
}