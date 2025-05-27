class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://kgsi8n1htvpo.share.zrok.io/';
  }
}
