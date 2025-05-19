class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://3p6g4gvfafd8.share.zrok.io/';
  }
}
