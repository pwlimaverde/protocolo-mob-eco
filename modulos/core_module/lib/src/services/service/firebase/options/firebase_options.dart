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
    apiKey: 'AIzaSyAeRnchWN8oH5HBpM-i7Yav77jhLcfzq38',
    appId: '1:942956893989:web:10c271d6d4988719c5accc',
    messagingSenderId: '942956893989',
    projectId: 'protocolo-mob-ser',
    authDomain: 'protocolo-mob-ser.firebaseapp.com',
    storageBucket: 'protocolo-mob-ser.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEx3zFbgAIQlXK9WhTZw2Js6ZzsSe1b-A',
    appId: '1:942956893989:android:6abd447c7eedf55ac5accc',
    messagingSenderId: '942956893989',
    projectId: 'protocolo-mob-ser',
    storageBucket: 'protocolo-mob-ser.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5nZb83xE8Wvc9Y-huC4hkrmhTiMBn9YE',
    appId: '1:942956893989:ios:ba17009411521a3ec5accc',
    messagingSenderId: '942956893989',
    projectId: 'protocolo-mob-ser',
    storageBucket: 'protocolo-mob-ser.appspot.com',
    iosClientId:
        '942956893989-8h5vnjsml55d7i039540j9td2h080isl.apps.googleusercontent.com',
    iosBundleId: 'br.com.protocolomobser.appClienteProtocoloMobSer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB5nZb83xE8Wvc9Y-huC4hkrmhTiMBn9YE',
    appId: '1:942956893989:ios:ba17009411521a3ec5accc',
    messagingSenderId: '942956893989',
    projectId: 'protocolo-mob-ser',
    storageBucket: 'protocolo-mob-ser.appspot.com',
    iosClientId:
        '942956893989-8h5vnjsml55d7i039540j9td2h080isl.apps.googleusercontent.com',
    iosBundleId: 'br.com.protocolomobser.appClienteProtocoloMobSer',
  );
}
