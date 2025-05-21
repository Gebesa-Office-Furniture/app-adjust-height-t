class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://i2wkdtstrpv0.share.zrok.io/';
  }
}
