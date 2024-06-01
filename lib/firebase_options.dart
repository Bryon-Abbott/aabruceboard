// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAvZeVjt0Rx9oCGVOcfO1CmC-tg3RXNpr4',
    appId: '1:339334468602:web:04ee48f84dce4a9c988a43',
    messagingSenderId: '339334468602',
    projectId: 'aabruceboard',
    authDomain: 'aabruceboard.firebaseapp.com',
    storageBucket: 'aabruceboard.appspot.com',
    measurementId: 'G-C4GT9D5N9V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5HVh3ORVVli9WxAUOG_3S-ggQBj8GGFE',
    appId: '1:339334468602:android:757327f36b584486988a43',
    messagingSenderId: '339334468602',
    projectId: 'aabruceboard',
    storageBucket: 'aabruceboard.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcUHz0oWt4aX8tGRHv3HDf0ersF-1KuHQ',
    appId: '1:339334468602:ios:f6e4e152c7ccb74a988a43',
    messagingSenderId: '339334468602',
    projectId: 'aabruceboard',
    storageBucket: 'aabruceboard.appspot.com',
    iosBundleId: 'com.abbottavenue.aabruceboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAcUHz0oWt4aX8tGRHv3HDf0ersF-1KuHQ',
    appId: '1:339334468602:ios:f6e4e152c7ccb74a988a43',
    messagingSenderId: '339334468602',
    projectId: 'aabruceboard',
    storageBucket: 'aabruceboard.appspot.com',
    iosBundleId: 'com.abbottavenue.aabruceboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvZeVjt0Rx9oCGVOcfO1CmC-tg3RXNpr4',
    appId: '1:339334468602:web:1a465e40a29ae60e988a43',
    messagingSenderId: '339334468602',
    projectId: 'aabruceboard',
    authDomain: 'aabruceboard.firebaseapp.com',
    storageBucket: 'aabruceboard.appspot.com',
    measurementId: 'G-19NTMDX37Q',
  );

}