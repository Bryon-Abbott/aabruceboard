// import 'dart:io';

import 'dart:developer';

import 'package:bruceboard/utils/adhelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AaBannerAd extends StatefulWidget {
  /// The requested size of the banner. Defaults to [AdSize.banner].
  final AdSize adSize;

  /// The AdMob ad unit to show.
  ///
  /// TODO: replace this test ad unit with your own ad unit
  // final String adUnitId = Platform.isAndroid
  // // Use this ad unit on Android...
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  // // ... or this one on iOS.
  //
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //final String adUnitId = adHelper.bannerAdUnitId;
  // final String adUnitId;

  const AaBannerAd({super.key, this.adSize = AdSize.banner,});

  @override
  State<AaBannerAd> createState() => _AaBannerAdState();
}

class _AaBannerAdState extends State<AaBannerAd> {
  /// The banner ad to show. This is `null` until the ad is actually loaded.
  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: _bannerAd == null
        // Nothing to render yet.
            ? SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("BruceBoard ",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text("\u208D\u209C\u2098\u208E",
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
            )
        // The actual ad.
            : AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            log("Loading Banner Ad", name: '${runtimeType.toString()}:_loadAd():onAdLoaded()');
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }
}

class AdContainer extends StatelessWidget {
  const AdContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        height: 54,
        child: (kIsWeb)
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("BruceBoard...",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                // Text("\u207D\u1D40\u1D39\u207E",
                //   style: Theme.of(context).textTheme.titleLarge,
                // )
              ],
            )
            : const Padding(
          padding: EdgeInsets.fromLTRB(0,2,0,0),
          child: AaBannerAd(),
        ),
      );
  }
}
