import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore(this.preferences);
  final SharedPreferences preferences;
  Map<String, dynamic>? read(String key) {
    final value = preferences.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String key, Map<String, dynamic> value) async {
    if (!await preferences.setString(key, jsonEncode(value))) {
      throw StateError('Local storage write failed');
    }
  }
}
