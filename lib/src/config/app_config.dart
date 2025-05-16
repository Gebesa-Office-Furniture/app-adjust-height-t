class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return 'https://xr7b1i0wy239.share.zrok.io/';
  }
}
