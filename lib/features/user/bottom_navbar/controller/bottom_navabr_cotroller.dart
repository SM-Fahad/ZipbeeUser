import 'package:get/get.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';

class BottomNavbarController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    if (index == 0) {
      final homeCtrl = Get.put(HomeController());
      homeCtrl.resetHomeSelection();
      homeCtrl.refreshBalanceAndCoin();
    }
    currentIndex.value = index;
  }
}
