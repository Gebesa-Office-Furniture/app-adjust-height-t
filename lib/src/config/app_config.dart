class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://ykb55vy4ricd.share.zrok.io/';
  }
}
