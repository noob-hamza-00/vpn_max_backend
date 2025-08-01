// ignore_for_file: non_constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreference {
  static Future<String> SaveString(String key, String value) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final isSaved = await _prefs.setString(key, value);
    if (isSaved) {
      return value;
    } else {
      return "";
    }
  }

  static Future<List<String>> SaveStringList(
      String key, List<String> values) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final isSaved = await _prefs.setStringList(key, values);
    if (isSaved) {
      return values;
    } else {
      return [];
    }
  }

  // static Future<List<ApplicationModel>> SaveApplicationList(
  //     String key, List<ApplicationModel> values) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   String encodedJson = jsonEncode(
  //     values
  //         .map<Map<String, dynamic>>((val) => ApplicationModel.toJson(val))
  //         .toList(),
  //   );
  //   final isSaved = await _prefs.setString(key, encodedJson);
  //   if (isSaved) {
  //     return values;
  //   } else {
  //     return [];
  //   }
  // }

  // static Future<List<ApplicationModel>> GetApplicationList(String key) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   final value = _prefs.getString(key);
  //   if (value == null) {
  //     return [];
  //   } else {
  //     return (json.decode(value) as List<dynamic>)
  //         .map<ApplicationModel>((item) => ApplicationModel.fromJson(item))
  //         .toList();
  //   }
  // }

  static Future<String> GetString(String key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final value = _prefs.getString(key);
    if (value == null) {
      return "";
    } else {
      return value;
    }
  }

  static Future<List<String>> GetStringList(String key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final values = _prefs.getStringList(key);
    if (values == null) {
      return [];
    } else {
      return values;
    }
  }
}
