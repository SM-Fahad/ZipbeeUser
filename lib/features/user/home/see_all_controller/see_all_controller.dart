// //Unsed File: lib/features/user/home/see_all_controller/see_all_controller.dart
// import 'package:ZipBee/features/user/home/controller/home_controller.dart';
// import 'package:ZipBee/features/user/stacked/order_stacked_delivery/service/order_service.dart';
// import 'package:ZipBee/features/user/stacked/vehicle_type/controller/controller.dart';
// import 'package:ZipBee/features/user/stacked/vehicle_type/screen/screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';

// import '../../stacked/stacked_controller/stacked_controller.dart';
// import '../../stacked/vehicle_type/model/model.dart';

// class SeeAllOrderController extends GetxController {
//   final HomeController homeCtrl = Get.find<HomeController>();
//   final StackedVehicleController vehCtrl =
//       Get.isRegistered<StackedVehicleController>()
//       ? Get.find<StackedVehicleController>()
//       : Get.put(StackedVehicleController());

//   /// Automatically selects the first available vehicle and creates order
//   Future<void> createOrderAuto() async {
//     if (vehCtrl.t1.isEmpty &&
//         vehCtrl.t2.isEmpty &&
//         vehCtrl.t3.isEmpty &&
//         vehCtrl.t4.isEmpty) {
//       EasyLoading.showError("No vehicles available");
//       return;
//     }

//     // Merge all vehicle lists
//     final allVehicles = <StackVehicle>[]
//       ..addAll(vehCtrl.t1)
//       ..addAll(vehCtrl.t2)
//       ..addAll(vehCtrl.t3)
//       ..addAll(vehCtrl.t4);

//     final vehicle = allVehicles[0]; // Pick the first vehicle

//     debugPrint("Auto selected vehicle: ${vehicle.name} (${vehicle.id})");

//     // Set it as selected in the controller
//     vehCtrl.selectedVehicle.value = vehicle;

//     // Prepare order payload
//     final deliveryType = homeCtrl.deliveryType.value.toUpperCase();
//     final payload = {
//       'route_type': 'ONE_WAY',
//       'isFixed': false,
//       'delivery_type': deliveryType,
//       'vehicle_type_id': vehicle.id,
//       'collect_time': 'ASAP',
//     };

//     // Try to get sender/receiver from StackedLocationController
//     try {
//       final locCtrl = Get.find<StackedLocationController>();
//       final destinations = <Map<String, dynamic>>[];

//       if (locCtrl.senderData.value != null) {
//         final sender = locCtrl.senderData.value!;
//         destinations.add({
//           'address': sender.address,
//           'floor_unit': sender.floorUnit,
//           'contact_name': sender.contactName,
//           'contact_number': sender.contactNumber,
//           'note_to_driver': sender.noteToDriver,
//           'is_saved': sender.isSaved,
//           'type': 'SENDER',
//         });
//       }

//       if (locCtrl.receiverData.value != null) {
//         final receiver = locCtrl.receiverData.value!;
//         destinations.add({
//           'address': receiver.address,
//           'floor_unit': receiver.floorUnit,
//           'contact_name': receiver.contactName,
//           'contact_number': receiver.contactNumber,
//           'note_to_driver': receiver.noteToDriver,
//           'is_saved': receiver.isSaved,
//           'type': 'RECEIVER',
//         });
//       }

//       if (destinations.isNotEmpty) payload['destinations'] = destinations;
//     } catch (_) {
//       debugPrint(
//         "No location controller available; proceeding without destinations",
//       );
//     }

//     // Call Order Service
//     try {
//       EasyLoading.show(status: 'Creating order...');
//       final res = await OrderService.createOrder(payload);
//       EasyLoading.dismiss();

//       final status = res['statusCode'] as int? ?? 500;
//       final body = res['body'] as Map<String, dynamic>? ?? {};

//       if (status == 201 && body['success'] == true) {
//         final orderData = body['data'] as Map<String, dynamic>?;
//         // EasyLoading.showSuccess(body['message']?.toString() ?? "Order Created");
//         debugPrint(body['message']?.toString() ?? "Order Created");
//         debugPrint("Created order data: $orderData");

//         // Navigate to StackedVehicleSelectionPage
//         if (orderData != null) {
//           Get.to(
//             () => const StackedVehicleSelectionPage(),
//             arguments: {'order': orderData},
//           );
//         }
//       } else {
//         final msgRaw = body['message'] ?? 'Failed to create order';
//         final msg = msgRaw is List ? msgRaw.join('\n') : msgRaw.toString();
//         EasyLoading.showError(msg);
//       }
//     } catch (e) {
//       debugPrint("Auto order creation error: $e");
//       EasyLoading.showError("Failed to create order");
//     }
//   }
// }
