import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/widget/schedule_recepent_widget_st.dart';
import 'package:ZipBee/features/user/stacked/stacked_controller/stacked_controller.dart';
import 'package:ZipBee/features/user/stacked/stacked_collect_from/model/model.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/controller/recepent_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class StackedSchedulRecepmenteScreen extends StatelessWidget {
  final StackedAddressModel? address;

  const StackedSchedulRecepmenteScreen({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isAdditionalStop = args?['isAdditionalStop'] ?? false;
    final controllerTag = isAdditionalStop ? 'additional_stop' : 'primary';
    final controller = Get.isRegistered<RecipientController>(tag: controllerTag)
        ? Get.find<RecipientController>(tag: controllerTag)
        : Get.put(RecipientController(), tag: controllerTag);

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// MAP Section
              SizedBox(
                height: 400,
                width: double.infinity,
                child: GoogleMapWidget(
                  mode: GoogleMapWidgetMode.addressPicker,
                  initialQuery: controller.postalCodeController.text.isNotEmpty
                      ? controller.postalCodeController.text
                      : controller.addressController.text,
                  onLocationConfirmed: controller.applyResolvedLocation,
                ),
              ),

              /// FORM Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroungColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ScheduleRecipientWidgetST(
                  title: 'Recipient',
                  address: address,
                  isAdditionalStop: isAdditionalStop,
                  onPressed: () async {
                    final orderController = Get.find<StackedOrderController>();
                    final orderId = orderController.lastOrderId;

                    if (orderId == null) {
                      EasyLoading.showError(
                        'Order ID not found. Please try again.',
                      );
                      return;
                    }

                    final res = await controller.saveDestination(
                      type: 'RECEIVER',
                      orderId: orderId,
                    );
                    if (res != null) {
                      final data = res;

                      // 🔥 Fetch updated total cost from API after address saved
                      await orderController.fetchOrderTotalCost();

                      // Update total cost in order controller
                      if (controller.totalCost.value > 0) {
                        orderController.totalAmount.value =
                            controller.totalCost.value;
                      }

                      // Extract and store data in StackedLocationController
                      final locationController =
                          Get.find<StackedLocationController>();

                      final savedAddress = AddressData(
                        id: (data['id'] as int?) ?? 0,
                        address:
                            data['address'] ??
                            controller.addressController.text,
                        addressFromApr:
                            data['address'] ??
                            controller.addressController.text,
                        floorUnit:
                            data['floor_unit'] ??
                            controller.floorController.text,
                        contactName:
                            data['contact_name'] ??
                            controller.nameController.text,
                        contactNumber:
                            data['contact_number'] ??
                            controller.fullContactNumber,
                        noteToDriver:
                            data['note_to_driver'] ??
                            controller.noteController.text,
                        isSaved:
                            (data['is_saved'] as bool?) ??
                            controller.saveAddress.value,
                        type: data['type'] ?? 'RECEIVER',
                      );

                      if (args != null && args['addAsStop'] == true) {
                        // Add as additional recipient stop
                        locationController.addRecipientStop(savedAddress);
                        // Return to stacked screen
                        Get.until((route) => route.settings.name == '/stackedScreen');
                      } else {
                        // Primary receiver update
                        locationController.updateReceiverData(savedAddress);
                        Get.until((route) => route.settings.name == '/stackedScreen');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
