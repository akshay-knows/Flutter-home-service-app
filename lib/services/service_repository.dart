import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ServiceRepository {
  static const _servicesKey = 'online_thekedaar_services';

  static const defaultServices = [
    '🔧 Plumber',
    '💡 Electrician',
    '🪚 Carpenter',
    '🎨 Painter',
    '🧱 Mistri',
    '🚚 Shifting / Movers',
    '❄️ AC Repair',
  ];

  Future<List<String>> loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_servicesKey);
    if (raw == null || raw.isEmpty) return [...defaultServices];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final services = decoded.whereType<String>().toList();
        if (services.isNotEmpty) return services;
      }
    } catch (_) {
      return [...defaultServices];
    }

    return [...defaultServices];
  }

  Future<void> saveServices(List<String> services) async {
    final cleanServices = services
        .map((service) => service.trim())
        .where((service) => service.isNotEmpty)
        .toSet()
        .toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_servicesKey, jsonEncode(cleanServices));
  }

  Future<void> resetServices() async {
    await saveServices(defaultServices);
  }
}
