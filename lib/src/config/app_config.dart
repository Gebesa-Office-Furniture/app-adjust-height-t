class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://umlm4pl3yfk4.share.zrok.io/';
  }
}
