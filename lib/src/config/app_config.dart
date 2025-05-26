class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://9fzer9t8nu08.share.zrok.io/';
  }
}
