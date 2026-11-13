import 'package:google_mobile_ads/google_mobile_ads.dart';

// NOTE: These are Google's official TEST ad unit IDs so the app is safe to
// click during development. Before publishing, replace them with your real
// AdMob unit IDs (and the APPLICATION_ID in android/app/src/main/AndroidManifest.xml).
class AdService {
  static bool _initialized = false;
  static InterstitialAd? _interstitialAd;
  static bool _interstitialLoaded = false;
  static bool _interstitialLoading = false;

  static const String _bannerUnitId =
      'ca-app-pub-3940256099942544/9214589741'; // test: anchored adaptive banner
  static const String _interstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // test: interstitial

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    // Pre-load the first interstitial so the first eligible trigger can show it.
    await loadInterstitial();
  }

  static BannerAd createBannerAd(
      {required AdSize size, BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: _bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener ?? _defaultBannerListener,
    );
  }

  static final BannerAdListener _defaultBannerListener = BannerAdListener(
    onAdLoaded: (_) {},
    onAdFailedToLoad: (ad, error) => ad.dispose(),
    onAdOpened: (_) {},
    onAdClosed: (_) {},
    onAdImpression: (_) {},
  );

  static Future<void> loadInterstitial() async {
    if (_interstitialLoaded || _interstitialLoading) return;
    _interstitialLoading = true;
    await InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
          _interstitialLoading = false;
          // Re-load after the user dismisses so the next trigger is ready.
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialLoaded = false;
          _interstitialLoading = false;
        },
      ),
    );
  }

  static Future<void> showInterstitial() async {
    if (_interstitialLoaded && _interstitialAd != null) {
      final ad = _interstitialAd!;
      _interstitialAd = null;
      _interstitialLoaded = false;
      await ad.show();
    } else {
      // Not ready yet; kick off a load so a later trigger can show it.
      await loadInterstitial();
    }
  }

  static int _verseInterstitialCount = 0;
  static const int _maxVerseInterstitials = 3;

  static void resetVerseInterstitialCount() {
    _verseInterstitialCount = 0;
  }

  static bool shouldShowVerseInterstitial() {
    return _verseInterstitialCount < _maxVerseInterstitials;
  }

  static Future<void> showVerseInterstitial() async {
    if (!shouldShowVerseInterstitial()) return;
    _verseInterstitialCount++;
    await showInterstitial();
  }
}
