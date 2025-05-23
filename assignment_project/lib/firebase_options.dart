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
    apiKey: 'AIzaSyAL6lEZgZ7itIIvngQA0QR5Q_60pNzq9po',
    appId: '1:443120906046:web:4d5c46451230debc38866f',
    messagingSenderId: '443120906046',
    projectId: 'finalproject467',
    authDomain: 'finalproject467.firebaseapp.com',
    storageBucket: 'finalproject467.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHHNcZ5EWN6roJQ9kAZM4AIMOSAp1sG_Y',
    appId: '1:443120906046:android:b1c9b06d1656832538866f',
    messagingSenderId: '443120906046',
    projectId: 'finalproject467',
    storageBucket: 'finalproject467.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAaq-g_SU6AqBRbeuiW7O8MLIVwlX8AMbc',
    appId: '1:443120906046:ios:20daf88b6987155d38866f',
    messagingSenderId: '443120906046',
    projectId: 'finalproject467',
    storageBucket: 'finalproject467.appspot.com',
    iosClientId:
        '443120906046-an4d2a0prhi9nbdddl3htsqqqqk1seh8.apps.googleusercontent.com',
    iosBundleId: 'com.example.assignmentProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAaq-g_SU6AqBRbeuiW7O8MLIVwlX8AMbc',
    appId: '1:443120906046:ios:dd3b80a842de327f38866f',
    messagingSenderId: '443120906046',
    projectId: 'finalproject467',
    storageBucket: 'finalproject467.appspot.com',
    iosClientId:
        '443120906046-sl0kvds84pm7bfctjc7q80mebgkumg9h.apps.googleusercontent.com',
    iosBundleId: 'com.example.assignmentProject.RunnerTests',
  );
}
