import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1626767512554657/2805129602';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1626767512554657/2634203200';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}