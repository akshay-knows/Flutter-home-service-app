import 'package:day35/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsRepository {
  static const _whatsappNumberKey = 'online_thekedaar_whatsapp_number';

  Future<String> loadWhatsappNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString(_whatsappNumberKey)?.trim();
    if (savedNumber == null || savedNumber.isEmpty) {
      return AppConfig.defaultWhatsappBusinessNumber;
    }
    return savedNumber;
  }

  Future<void> saveWhatsappNumber(String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_whatsappNumberKey, cleanNumber);
  }

  Future<void> resetWhatsappNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_whatsappNumberKey);
  }
}
