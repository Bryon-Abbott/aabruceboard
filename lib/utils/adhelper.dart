import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1626767512554657/2805129602';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1626767512554657/7647529181';
    } else {
      return 'undefined';
      //throw UnsupportedError('Unsupported platform');
    }
  }
}