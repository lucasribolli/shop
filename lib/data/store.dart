import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await saveString(key, json.encode(value));
  }

  static Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getString(key));
  }
  
  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      String? mapEncoded = await getString(key);
      Map<String, dynamic>? map = json.decode(mapEncoded);
      if(map == null) {
        return {};
      }
      return map;
    } catch(_) {
      return {};
    }
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}