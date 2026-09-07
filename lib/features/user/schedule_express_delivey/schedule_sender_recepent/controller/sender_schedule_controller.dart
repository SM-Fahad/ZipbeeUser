import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SenderScheduleController extends GetxController {
  final addressController = TextEditingController();
  final floorController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final noteController = TextEditingController();

  final isFormValid = false.obs;
  final saveAddress = false.obs;

  @override
  void onInit() {
    super.onInit();
    addressController.addListener(validateForm);
    floorController.addListener(validateForm);
    nameController.addListener(validateForm);
    numberController.addListener(validateForm);
  }

  void validateForm() {
    final isValid =
        addressController.text.isNotEmpty &&
        floorController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        numberController.text.isNotEmpty;
    isFormValid.value = isValid;
  }

  @override
  void onClose() {
    addressController.dispose();
    floorController.dispose();
    nameController.dispose();
    numberController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
