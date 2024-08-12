import 'dart:convert';

import 'package:locket_uploader/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  LocalService._();
  static LocalService? _instance;
  static Future<LocalService> ensureInitialized() async {
    if (_instance == null) {
      _instance = LocalService._();
      await _instance!.init();
    }
    return _instance!;
  }

  static LocalService getInstanceSync() {
    if (_instance == null) {
      throw Exception('LocalService not initialized');
    }
    return _instance!;
  }

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserProfile? getLocalUserProfile() {
    final userData = _prefs.getString('userProfile');
    if (userData == null) {
      return null;
    }
    return UserProfile.fromJson(json.decode(userData));
  }

  void saveLocalUserProfile(UserProfile? userProfile) {
    if (userProfile == null) {
      _prefs.remove('userProfile');
      return;
    }
    _prefs.setString('userProfile', json.encode(userProfile.toJson()));
  }
}

