class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://cwy1x0ovo9p0.share.zrok.io/';
  }
}
