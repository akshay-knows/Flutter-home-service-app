import 'package:day35/services/app_settings_repository.dart';
import 'package:flutter/services.dart';

class WhatsappService {
  static const MethodChannel _channel = MethodChannel(
    'online_thekedaar/whatsapp',
  );

  static Future<bool> sendToBusiness(String message) async {
    final phone = await AppSettingsRepository().loadWhatsappNumber();
    final launched = await _channel.invokeMethod<bool>('sendWhatsAppMessage', {
      'phone': phone,
      'message': message,
    });
    return launched ?? false;
  }

  static Future<bool> requestStatusUpdate(String trackingNumber) {
    final message =
        'Hello Online Thekedaar, I would like an update on my booking. My Tracking Number is: $trackingNumber';
    return sendToBusiness(message);
  }
}
