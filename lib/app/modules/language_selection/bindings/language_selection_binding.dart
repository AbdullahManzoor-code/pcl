import 'package:get/get.dart';
import '../controllers/language_selection_controller.dart';

class LanguageSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageSelectionController>(
      () => LanguageSelectionController(),
    );
  }
}
