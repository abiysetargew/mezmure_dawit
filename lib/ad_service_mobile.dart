import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;
  static InterstitialAd? _interstitialAd;
  static bool _interstitialLoaded = false;

  static const String _testBannerUnitId =
      'ca-app-pub-1229031769676783/9572233338';
  static const String _testInterstitialUnitId =
      'ca-app-pub-1229031769676783/4319906658';

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd(
      {required AdSize size, BannerAdListener? listener}) {
    return BannerAd(
      adUnitId: _testBannerUnitId,
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
    if (_interstitialLoaded && _interstitialAd != null) return;
    await InterstitialAd.load(
      adUnitId: _testInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
        },
        onAdFailedToLoad: (_) {
          _interstitialLoaded = false;
        },
      ),
    );
  }

  static Future<void> showInterstitial() async {
    if (_interstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _interstitialLoaded = false;
    } else {
      await loadInterstitial();
      if (_interstitialLoaded && _interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAd = null;
        _interstitialLoaded = false;
      }
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
