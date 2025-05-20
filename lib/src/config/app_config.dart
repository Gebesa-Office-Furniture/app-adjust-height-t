class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://a5ptrl2mi6t9.share.zrok.io/';
  }
}
