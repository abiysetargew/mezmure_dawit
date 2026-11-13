abstract class AdService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;
  static void setInitialized() => _initialized = true;

  static Future<void> initialize() async {}

  static dynamic createBannerAd({required dynamic size, dynamic listener}) =>
      null;

  static Future<void> loadInterstitial() async {}

  static Future<void> showInterstitial() async {}
}
