import 'package:get/get.dart';
import 'package:ZipBee/core/controllers/app_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put<AppController>(AppController());
    // Get.lazyPut<HomeController>(() => HomeController());
  }
}
