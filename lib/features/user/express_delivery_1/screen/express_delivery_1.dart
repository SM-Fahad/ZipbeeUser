// // Unsed file now
// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/utils/constants/app_colors.dart';
// import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/controller/vehicle_secation_controller.dart';
// import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/screen/veichale_secation_page.dart';
// import 'package:ZipBee/features/user/express_delivery_1/controller/express_controller_1.dart';
// import 'package:ZipBee/features/user/express_delivery_1/order_express_delivery/controller/order_express_controller.dart';
// import 'package:ZipBee/features/user/express_delivery_1/widget/collect_time_widget.dart';
// import 'package:ZipBee/features/user/express_delivery_1/widget/order_reviw_button_static.dart';
// import 'package:ZipBee/features/user/express_delivery_1/widget/pick_date_time_dialog.dart';
// import 'package:ZipBee/features/user/express_delivery_1/widget/select_location_widget.dart';
// import 'package:ZipBee/features/user/express_delivery_1/widget/vehicle_type_widget.dart';
// import 'package:ZipBee/features/user/home/controller/home_controller.dart';
// import 'package:ZipBee/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ExpressDelivery1 extends StatelessWidget {
//   final ExpressDeliveryMain controller = Get.put(ExpressDeliveryMain());

//   final VehicleController vehicleController = Get.put(VehicleController());

//   final OrderControllerExpress orderControllerExpress = Get.put(
//     OrderControllerExpress(),
//   );
//   final HomeController homeCtrl = Get.find<HomeController>();

//   ExpressDelivery1({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroungColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Get.back(),
//         ),
//         centerTitle: true,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Obx(
//               () => Text(
//                 homeCtrl.parcelStatusText,
//                 style: getTextStyle(
//                   fontSize: 20,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),

//             SizedBox(width: 4.0),
//             IconButton(
//               icon: Icon(Icons.info_outline, color: Colors.black87, size: 20),
//               onPressed: () {
//                 Get.toNamed(AppRoutes.getexpressFaq());
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,

//             children: [
//               Text(
//                 'Select Location',
//                 style: getTextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               SelectLocationWidget(controller: controller),
//               SizedBox(height: 24),
//               Text(
//                 'Collect time',
//                 style: getTextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Obx(
//                 () => IntrinsicHeight(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       CollectTimeOption(
//                         title: "Now",
//                         selected: controller.isNowSelected.value,
//                         onTap: controller.selectNow,
//                       ),
//                       SizedBox(width: 16),
//                       CollectTimeOption(
//                         title: "Schedule",
//                         subtitle: "Pick Date and Time",
//                         selected: !controller.isNowSelected.value,
//                         onTap: () {
//                           FocusScope.of(context).unfocus();
//                           controller.selectSchedule();

//                           showDialog(
//                             context: context,
//                             builder: (_) => PickDateTimeDialog(),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 24),
//               Row(
//                 children: [
//                   Text(
//                     'Vehicle type',
//                     style: getTextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () async {
//                       final result = await Get.to(() => VehicleSelectionPage());
//                       if (result != null) {
//                         print('Value$result');
//                         controller.selectedVehicle.value =
//                             result['selectedVehicle'];
//                       }
//                       controller.totalAmount.value = result['totalAmount'];
//                     },
//                     icon: Icon(Icons.info_outline),
//                     color: Colors.black87,
//                     iconSize: 20,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 4),
//               VehicleTypeWidget(controller: controller),

//               SizedBox(height: 24),
//               OrderReviwButtonStatic(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
