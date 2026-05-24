import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingNumberService {
  static final Random _random = Random.secure();
  static const _lastIdKey = 'last_tracking_id';

  static String generate() {
    final number = 100000 + _random.nextInt(900000);
    return 'OT-$number';
  }

  static Future<void> saveLastTrackingId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastIdKey, id);
  }

  static Future<String?> getLastTrackingId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastIdKey);
  }
}
