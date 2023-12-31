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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDn3RNdNo_I7vtzHv53nESBU71urRI_ydA',
    appId: '1:538965249027:web:761b791a161ef1c0859236',
    messagingSenderId: '538965249027',
    projectId: 'seev-606ab',
    authDomain: 'seev-606ab.firebaseapp.com',
    storageBucket: 'seev-606ab.appspot.com',
    measurementId: 'G-SN4CQ89V1P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlYiDTrIqXkcnCPeVfdyRlrl_TF6BSbeo',
    appId: '1:538965249027:android:ac289c5595067f23859236',
    messagingSenderId: '538965249027',
    projectId: 'seev-606ab',
    storageBucket: 'seev-606ab.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAy4oQdX5DvoG2I98U-gANv4ZZ5J1BFCC8',
    appId: '1:538965249027:ios:900fe680aba80051859236',
    messagingSenderId: '538965249027',
    projectId: 'seev-606ab',
    storageBucket: 'seev-606ab.appspot.com',
    iosBundleId: 'com.example.seev',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAy4oQdX5DvoG2I98U-gANv4ZZ5J1BFCC8',
    appId: '1:538965249027:ios:c178a7d993158c1b859236',
    messagingSenderId: '538965249027',
    projectId: 'seev-606ab',
    storageBucket: 'seev-606ab.appspot.com',
    iosBundleId: 'com.example.seev.RunnerTests',
  );
}
