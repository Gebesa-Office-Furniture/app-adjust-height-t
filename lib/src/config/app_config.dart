class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://j18xiogv0fw9.share.zrok.io/';
  }
}
