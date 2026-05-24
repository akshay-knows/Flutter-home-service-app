import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const appName = 'Online Thekedaar';
  static const tagline = 'Expert Home Services';
  
  static String get whatsappNumber => 
      dotenv.get('ADMIN_WHATSAPP_NUMBER', fallback: '918878976452');

  static const logoAssetPath = 'assets/logo.png';
  
  // Brand Colors
  static const primaryColor = Color(0xFFF2AA4C); // Modern Yellow/Gold
  static const secondaryColor = Color(0xFF101820); // Deep Dark Gray/Black
  static const backgroundColor = Color(0xFFF8F9FB);
}
