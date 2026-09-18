/// Central place for the backend base URL. Swap this when you move from
/// the dev IP to a proper domain.
///
/// Override at build time:
///   flutter build apk --dart-define=API_BASE=https://gotabgaa.digital
class ApiConfig {
  static const String base = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://69.30.235.169:8090',
  );

  static String v1(String path) => '$base/api/v1${path.startsWith('/') ? path : '/$path'}';

  /// HLS stream URL fetched from CMS `settings.tvStreamUrl`, but if that fails
  /// we fall back to the proxy directly.
  static String get proxyFallback => '$base/api/proxy.php';
}
