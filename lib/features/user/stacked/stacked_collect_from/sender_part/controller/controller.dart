import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StackedSenderController extends GetxController {
  // Text Editing Controllers for each input field
  final addressController = TextEditingController();
  final floorController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final noteController = TextEditingController();

  // Observable boolean to track if the form is valid
  final isFormValid = false.obs;

  // Observable boolean for the checkbox
  final saveAddress = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to required fields to trigger validation on change
    addressController.addListener(validateForm);
    floorController.addListener(validateForm);
    nameController.addListener(validateForm);
    numberController.addListener(validateForm);
  }

  // Checks if all required fields are non-empty
  void validateForm() {
    final isValid =
        addressController.text.isNotEmpty &&
            floorController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            numberController.text.isNotEmpty;
    isFormValid.value = isValid;
  }

  // Clean up the controllers when the controller is disposed
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
