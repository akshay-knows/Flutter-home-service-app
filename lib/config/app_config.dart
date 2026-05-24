class AppConfig {
  static const appName = 'Online Thekedaar';
  static const tagline = 'Expert Home Services';
  static const defaultWhatsappBusinessNumber = String.fromEnvironment(
    'OT_WHATSAPP_NUMBER',
    defaultValue: '918878976452',
  );

  // Replace this with your real logo later, for example: assets/logo.png
  static const logoAssetPath = 'assets/logo.png';
}
