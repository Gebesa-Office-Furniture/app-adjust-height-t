class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://lpsqc80wa3kb.share.zrok.io/';
  }
}
