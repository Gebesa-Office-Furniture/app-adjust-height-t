class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://ouomdeb6xnkg.share.zrok.io/';
  }
}
