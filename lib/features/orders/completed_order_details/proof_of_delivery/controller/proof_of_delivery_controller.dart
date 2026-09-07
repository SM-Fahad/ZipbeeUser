import 'dart:convert';
import 'package:get/get.dart';
import '../model/proof_of_delivery_model.dart';
import '../service/proof_of_delivery_api_service.dart';

class ProofOfDeliveryController extends GetxController {
  final apiService = ProofOfDeliveryApiService();
  // Order id is received via Get.arguments in onInit. (Removed invalid `Get.args;` statement)

  final isLoading = true.obs;

  final images = <String>[].obs;
  final selectedImage = ''.obs;

  final trackingNumber = ''.obs;
  final deliveredAt = ''.obs;
  final location = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Safely read `Get.arguments` which may be null or not an int.
    final args = Get.arguments;
    if (args == null) {
      print('No orderId provided to ProofOfDeliveryController');
      return;
    }

    int? orderId;
    if (args is int) {
      orderId = args;
    } else {
      orderId = int.tryParse(args.toString());
    }

    if (orderId == null) {
      print('Invalid orderId argument: $args');
      return;
    }

    fetchOrder(orderId);
  }

  Future<void> fetchOrder(int orderId) async {
    try {
      isLoading.value = true;

      final response = await apiService.getOrderDetails(orderId);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedData = jsonDecode(response.body);
        final data = decodedData['data'];

        final model = ProofOfDeliveryModel.fromJson(data);

        trackingNumber.value = model.trackingNumber;
        deliveredAt.value = model.deliveredAt;
        location.value = model.location;

        images.assignAll(model.proofImages);

        if (images.isNotEmpty) {
          selectedImage.value = images.first;
        }
      } else {
        throw Exception("Server returned status code ${response.statusCode}");
      }
    } catch (e) {
      print("❌ POD ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void changeImage(String image) {
    selectedImage.value = image;
  }
}
