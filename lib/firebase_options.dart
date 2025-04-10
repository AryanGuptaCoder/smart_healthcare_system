import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyDhTuyViW4BgIsQQ50RuoqKbeHVZJrcUxQ',
    appId: '1:995810339603:web:d9da47e4b83dd77f3288e6',
    messagingSenderId: '995810339603',
    projectId: 'smart-healthcare-c124a',
    authDomain: 'smart-healthcare-c124a.firebaseapp.com',
    storageBucket: 'smart-healthcare-c124a.firebasestorage.app',
    measurementId: 'G-H22N04LMJH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBImn_nVXNquGG6WQBHmuGyb12hHoqxpqQ',
    appId: '1:995810339603:android:778caa6fcede954d3288e6',
    messagingSenderId: '995810339603',
    projectId: 'smart-healthcare-c124a',
    storageBucket: 'smart-healthcare-c124a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjCK3AAsGwTOy-F2bfbXPxoNlaz4zf-_Q',
    appId: '1:995810339603:ios:3db633c125b64f743288e6',
    messagingSenderId: '995810339603',
    projectId: 'smart-healthcare-c124a',
    storageBucket: 'smart-healthcare-c124a.firebasestorage.app',
    iosBundleId: 'com.example.smartHealthcare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjCK3AAsGwTOy-F2bfbXPxoNlaz4zf-_Q',
    appId: '1:995810339603:ios:3db633c125b64f743288e6',
    messagingSenderId: '995810339603',
    projectId: 'smart-healthcare-c124a',
    storageBucket: 'smart-healthcare-c124a.firebasestorage.app',
    iosBundleId: 'com.example.smartHealthcare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhTuyViW4BgIsQQ50RuoqKbeHVZJrcUxQ',
    appId: '1:995810339603:web:3b0806077d13e9de3288e6',
    messagingSenderId: '995810339603',
    projectId: 'smart-healthcare-c124a',
    authDomain: 'smart-healthcare-c124a.firebaseapp.com',
    storageBucket: 'smart-healthcare-c124a.firebasestorage.app',
    measurementId: 'G-01Q1BRW3R1',
  );

}
