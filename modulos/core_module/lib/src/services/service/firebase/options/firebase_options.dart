import 'package:dependencies_module/dependencies_module.dart';

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
    apiKey: 'AIzaSyC3D1_62nOgcFeeSw5Pm4XVWjI2nJQxJ0k',
    appId: '1:971198538208:web:0806f8a89d8d6087b88b85',
    messagingSenderId: '971198538208',
    projectId: 'protocolo-mob-eco-release',
    authDomain: 'protocolo-mob-eco-release.firebaseapp.com',
    storageBucket: 'protocolo-mob-eco-release.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfUSrmkBfQMLJ1tAeA0D4O7VqA1uqHT8A',
    appId: '1:971198538208:android:68d8bdcf059b2716b88b85',
    messagingSenderId: '971198538208',
    projectId: 'protocolo-mob-eco-release',
    storageBucket: 'protocolo-mob-eco-release.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDO31QtvxR-EDaht31fnqlSGTQWi_oXg7U',
    appId: '1:971198538208:ios:1ed2d3d9e865a805b88b85',
    messagingSenderId: '971198538208',
    projectId: 'protocolo-mob-eco-release',
    storageBucket: 'protocolo-mob-eco-release.appspot.com',
    iosClientId:
        '971198538208-vtcfv7pgv98a4hqhhobvq5etu281b56a.apps.googleusercontent.com',
    iosBundleId: 'br.com.protocolomobeco.appClienteProtocoloMobEco',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDO31QtvxR-EDaht31fnqlSGTQWi_oXg7U',
    appId: '1:971198538208:ios:1ed2d3d9e865a805b88b85',
    messagingSenderId: '971198538208',
    projectId: 'protocolo-mob-eco-release',
    storageBucket: 'protocolo-mob-eco-release.appspot.com',
    iosClientId:
        '971198538208-vtcfv7pgv98a4hqhhobvq5etu281b56a.apps.googleusercontent.com',
    iosBundleId: 'br.com.protocolomobeco.appClienteProtocoloMobEco',
  );
}
