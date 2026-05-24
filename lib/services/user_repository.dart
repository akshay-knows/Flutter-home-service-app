import 'dart:convert';
import 'package:online_thekedaar/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const _userKey = 'ot_user_profile';

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(profile.toJson()));
  }
}
