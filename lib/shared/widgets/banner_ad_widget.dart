import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:encore_gamesheet/constants/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;
  bool _bannerAdFailedToLoad = false;

  static String get _adUnitId => AdConfig.bannerAdUnitId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd(context);
    }
  }

  void _loadAd(BuildContext context) {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$BannerAd loaded.');
          if (mounted) {
            setState(() {
              _bannerAdIsLoaded = true;
              _bannerAdFailedToLoad = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          // Dispose the ad here to free resources.
          debugPrint('$BannerAd failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAdIsLoaded = false;
              _bannerAdFailedToLoad = true;
            });
          }
        },
      ),
      request: const AdRequest(
        // Request configuration to prefer static content
        nonPersonalizedAds: false,
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the ad failed to load, don't show anything
    if (_bannerAdFailedToLoad) {
      return const SizedBox.shrink();
    }

    // If the ad is still loading, show a loading indicator with label
    if (!_bannerAdIsLoaded) {
      return Column(
        children: [
          Text(
            'Advertisement',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 468,
            height: 60, // Full banner height
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          'Advertisement',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          decoration: BoxDecoration(
            // Add a subtle border to help define the shape
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: AdWidget(ad: _bannerAd!),
        ),
      ],
    );
  }
}
