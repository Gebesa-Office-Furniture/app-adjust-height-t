class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://wqg167lv7a7r.share.zrok.io/';
  }
}
