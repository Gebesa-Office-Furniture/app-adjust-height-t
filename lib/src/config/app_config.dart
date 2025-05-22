class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://nmvcjem52cpx.share.zrok.io/';
  }
}
