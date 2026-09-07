// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../completed_order_details/completed_order_details_screen/screen/completed_order_details_screen.dart';
//
// class CompletedOrderCard extends StatelessWidget {
//   const CompletedOrderCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(CompletedOrderDetailsScreen());
//       },
//       child: Container(
//         decoration: BoxDecoration(),
//         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "1. #1266 Pick-up Date & Timer 25 Aug 25,",
//               style: getTextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "  Collect from (Athena Lin)",
//               style: getTextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             Text(
//               "  Deliver to 3 destinations",
//               style: getTextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             Text(
//               "  (Joseph Low, Annie Tan, Tony Toh)",
//               style: getTextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             Text(
//               "  Vehicle Type: Motorbike",
//               style: getTextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             SizedBox(height: 5),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Send e-receipt",
//                   style: getTextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   "Total: S\$24.00",
//                   style: getTextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
