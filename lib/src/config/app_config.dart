class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://5tahkfmxb13y.share.zrok.io/';
  }
}
