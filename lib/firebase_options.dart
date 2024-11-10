// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyB7zAGH4uwl1XzzYgPIRfGRdyc35di6DEk',
    appId: '1:592050950634:web:fd31488a05cbdbc50e6293',
    messagingSenderId: '592050950634',
    projectId: 'flutter-vinted-municchi',
    authDomain: 'flutter-vinted-municchi.firebaseapp.com',
    storageBucket: 'flutter-vinted-municchi.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAypVuUmrRfoVKJDo6P95fFcahaQ5xv6o8',
    appId: '1:592050950634:android:5211f1ba312506aa0e6293',
    messagingSenderId: '592050950634',
    projectId: 'flutter-vinted-municchi',
    storageBucket: 'flutter-vinted-municchi.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDz6IrbBudnQfxWdl_p-KSq6RJrzpWD_uI',
    appId: '1:592050950634:ios:bcd5056fe7a6c1930e6293',
    messagingSenderId: '592050950634',
    projectId: 'flutter-vinted-municchi',
    storageBucket: 'flutter-vinted-municchi.appspot.com',
    iosBundleId: 'com.example.flutterVinted',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDz6IrbBudnQfxWdl_p-KSq6RJrzpWD_uI',
    appId: '1:592050950634:ios:bcd5056fe7a6c1930e6293',
    messagingSenderId: '592050950634',
    projectId: 'flutter-vinted-municchi',
    storageBucket: 'flutter-vinted-municchi.appspot.com',
    iosBundleId: 'com.example.flutterVinted',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7zAGH4uwl1XzzYgPIRfGRdyc35di6DEk',
    appId: '1:592050950634:web:cb7c34383922a8d10e6293',
    messagingSenderId: '592050950634',
    projectId: 'flutter-vinted-municchi',
    authDomain: 'flutter-vinted-municchi.firebaseapp.com',
    storageBucket: 'flutter-vinted-municchi.appspot.com',
  );
}
