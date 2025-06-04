class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://5eljesx5dlmi.share.zrok.io/';
  }
}
