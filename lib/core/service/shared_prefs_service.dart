import 'dart:convert';

import 'package:bili_sense/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  final SharedPreferences _prefs;

  SharedPreferenceHelper(this._prefs);

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _defaultUser = 'user_model';

  Future<void> setIsLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_keyUserEmail, email);
  }

  UserModel get userModel {
    return _prefs.containsKey(_defaultUser)
        ? UserModel.fromJson(jsonDecode(_prefs.getString(_defaultUser)!))
        : UserModel(email: '', name: '');
  }

  Future<void> setUserModel(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_defaultUser,jsonString);
  }

  String? get userEmail => _prefs.getString(_keyUserEmail);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
