import 'dart:io';

class AdConfig {
  // Set this to false for production builds
  static const bool isTestMode = true;

  // Test Ad Unit IDs (provided by Google for testing)
  static const String _testAndroidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testIOSBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  // Production Ad Unit IDs (replace these with your actual ad unit IDs)
  // You can create these in your AdMob console
  static const String _prodAndroidBannerAdUnitId =
      'ca-app-pub-4127049131309678/5403270458'; // Android banner ad unit ID
  static const String _prodIOSBannerAdUnitId =
      'ca-app-pub-4127049131309678/7593060342'; // iOS banner ad unit ID

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isTestMode
          ? _testAndroidBannerAdUnitId
          : _prodAndroidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return isTestMode ? _testIOSBannerAdUnitId : _prodIOSBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
