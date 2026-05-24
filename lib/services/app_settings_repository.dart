import 'package:online_thekedaar/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsRepository {
  static const _whatsappKey = 'online_thekedaar_whatsapp_number';

  Future<String> loadWhatsappNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_whatsappKey) ?? AppConfig.whatsappNumber;
  }

  Future<void> saveWhatsappNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_whatsappKey, number);
  }

  Future<void> resetWhatsappNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_whatsappKey);
  }
}
