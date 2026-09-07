// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/utils/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// import '../controller/orders_controller.dart';
// import '../widgets/active_order_card.dart';
// import '../widgets/cancelled_order_card.dart';
// import '../widgets/completed_order_card.dart';
//
// class OrdersScreen extends StatelessWidget {
//   const OrdersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(OrdersController());
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroungColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroungColor,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "Orders",
//           style: getTextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Obx(
//               () => Container(
//                 padding: EdgeInsets.all(3),
//                 height: 42,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.amber.shade200, width: 1.5),
//                 ),
//                 child: Row(
//                   children: [
//                     _buildTab(controller, 0, "Active"),
//                     _buildTab(controller, 1, "Completed"),
//                     _buildTab(controller, 2, "Cancelled"),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 20),
//
//             Expanded(
//               child: Obx(() {
//                 final tab = controller.selectedTab.value;
//                 switch (tab) {
//                   case 0:
//                     return ListView.builder(
//                       itemCount: 2,
//                       itemBuilder: (_, index) => ActiveOrderCard(),
//                     );
//                   case 1:
//                     return CompletedOrderCard();
//                   case 2:
//                     return ListView.builder(
//                       itemCount: 3,
//                       itemBuilder: (_, index) => CancelledOrderCard(),
//                     );
//                   default:
//                     return SizedBox();
//                 }
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Expanded _buildTab(OrdersController controller, int index, String label) {
//     final isSelected = controller.selectedTab.value == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => controller.changeTab(index),
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.amber : Colors.transparent,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Text(
//             label,
//             style: getTextStyle(
//               fontWeight: FontWeight.w600,
//               color: isSelected ? Colors.black : Colors.grey,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
