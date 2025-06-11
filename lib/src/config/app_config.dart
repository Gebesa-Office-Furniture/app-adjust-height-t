class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://g1ql72y3mxsh.share.zrok.io/';
  }
}
