import 'package:dependencies_module/dependencies_module.dart';

class SplashController extends GetxController {
  final counter = 0.obs;
  void incrementCounter() async {
    final _firestore =
        await FirebaseFirestore.instance.collection('likes').get();

    counter.value++;
  }
}
