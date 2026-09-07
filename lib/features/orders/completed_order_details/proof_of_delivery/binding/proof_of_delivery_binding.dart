import 'package:get/get.dart';
import '../controller/proof_of_delivery_controller.dart';

class ProofOfDeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProofOfDeliveryController>(
      () => ProofOfDeliveryController(),
    );
  }
}
