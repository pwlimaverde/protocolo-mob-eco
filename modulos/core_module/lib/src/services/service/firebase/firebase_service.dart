import 'package:dependencies_module/dependencies_module.dart';
import 'options/firebase_options.dart';

class FirebaseService extends GetxService {
  Future<FirebaseApp> init() async {
    final firebase = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return firebase;
  }
}
