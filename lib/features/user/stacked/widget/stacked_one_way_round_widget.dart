// Unused File
// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/features/user/stacked/stacked_collect_from/controller/controller.dart';
// import 'package:ZipBee/features/user/stacked/stacked_collect_from/screen/collect_from.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../stacked_controller/stacked_controller.dart';

// class StackedOneWayRoundWidget extends StatelessWidget {
//   final StackedLocationController controller;
//   final String title;
//   final String subtitle;
//   final Widget icon;

//   const StackedOneWayRoundWidget({
//     super.key,
//     required this.controller,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = Get.width;

//     final RxString currentTitle = title.obs;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         icon,
//         SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Obx(
//                 () => controller.isEditing.value
//                     ? TextField(
//                         autofocus: true,
//                         controller: TextEditingController(
//                           text: currentTitle.value,
//                         ),
//                         onChanged: (val) => currentTitle.value = val,
//                         style: getTextStyle(
//                           fontSize: screenWidth * 0.036,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: EdgeInsets.zero,
//                           border: InputBorder.none,
//                         ),
//                       )
//                     : Text(
//                         currentTitle.value,
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.036,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),
//               SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.03,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Obx(
//           () => GestureDetector(
//             onTap: () {
//               Get.to(
//                 () => StackedCollectFormScreen(
//                   controller: Get.put(StackedCollectFormController()),
//                 ),
//               );
//             },
//             child: Icon(
//               controller.isEditing.value ? Icons.check : Icons.edit,
//               color: controller.isEditing.value ? Colors.green : Colors.black,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
