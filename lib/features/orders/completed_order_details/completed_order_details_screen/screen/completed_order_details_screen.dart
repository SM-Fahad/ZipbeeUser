// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/common/widgets/custom_button.dart';
// import 'package:ZipBee/core/utils/constants/app_colors.dart';
// import 'package:ZipBee/core/utils/constants/icon_path.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
//
// import '../../proof_of_delivery_screen/proof_of_delivery_screen.dart';
//
// class CompletedOrderDetailsScreen extends StatelessWidget {
//   const CompletedOrderDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               color: AppColors.primaryButtonColor,
//               width: double.infinity,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Get.back(),
//                     child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//                   ),
//                   SizedBox(width: 10),
//                   Text(
//                     "Order #1266 is pending for collection",
//                     style: getTextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundImage: AssetImage(
//                             "assets/images/profileImage.jpg",
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Dylan Simpson",
//                                 style: getTextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 "Vehicle type: Truck",
//                                 style: getTextStyle(fontSize: 13),
//                               ),
//                               Text(
//                                 "Order 1233",
//                                 style: getTextStyle(fontSize: 13),
//                               ),
//                               Text(
//                                 "Est. Delivery time: 30 min",
//                                 style: getTextStyle(fontSize: 13),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 12),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         OutlinedButton.icon(
//                           onPressed: () {},
//                           icon: Image.asset(
//                             IconPath.message,
//                             height: 20.h,
//                             width: 20.w,
//                           ),
//                           label: Text(
//                             "Message",
//                             style: getTextStyle(color: AppColors.fontColor),
//                           ),
//                         ),
//                         OutlinedButton.icon(
//                           onPressed: () {},
//                           icon: Image.asset(
//                             IconPath.call,
//                             height: 20.h,
//                             width: 20.w,
//                           ),
//                           label: Text(
//                             "Call",
//                             style: getTextStyle(color: AppColors.fontColor),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber, size: 18),
//                         Icon(Icons.star, color: Colors.amber, size: 18),
//                         Icon(Icons.star, color: Colors.amber, size: 18),
//                         Icon(Icons.star, color: Colors.amber, size: 18),
//                         Icon(Icons.star, color: Colors.amber, size: 18),
//                         SizedBox(width: 6),
//                         Text("5/5", style: getTextStyle()),
//                         SizedBox(width: 6),
//                         Spacer(),
//                         Text(
//                           "(243 Reviews)",
//                           style: getTextStyle(color: Colors.lightBlue),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Total",
//                           style: getTextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         Text(
//                           "\$24.00",
//                           style: getTextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Image.asset(IconPath.visa, height: 24.h, width: 28.w),
//                         SizedBox(width: 4.w),
//                         Text("****456", style: getTextStyle(fontSize: 13)),
//                       ],
//                     ),
//
//                     SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Text(
//                           "Date & Time: ",
//                           style: getTextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         Text("24 Aug 2025 / 9:40 am", style: getTextStyle()),
//                       ],
//                     ),
//
//                     SizedBox(height: 20),
//
//                     Text(
//                       "Order has been placed",
//                       style: getTextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     SizedBox(height: 12),
//
//                     _buildStop(
//                       icon: IconPath.locationBlue,
//                       color: Colors.blue,
//                       title: "Collected from (Sender: Athena Lin)",
//                       address: "Blk 657 Ang Mo Kio Ave 9, S560657",
//                       date: "24 Aug 09:30",
//                     ),
//                     _buildStop(
//                       icon: IconPath.locationRed,
//                       color: Colors.red,
//                       title: "Delivered to (Joseph Low)",
//                       address: "Blk 222 Sengkang Ave 2, S530222",
//                       date: "24 Aug 10:15",
//                     ),
//
//                     SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: () => Get.to(() => ProofOfDeliveryScreen()),
//                       child: Text(
//                         "View Proof of Delivery",
//                         style: getTextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 24),
//
//                     CustomButton(
//                       label: 'Share Ride Information',
//                       onPressed: () {},
//                       color: AppColors.primaryButtonColor,
//                       textColor: AppColors.primaryFontColor,
//                     ),
//                     SizedBox(height: 10),
//                     CustomButton(
//                       label: 'Place Order Again',
//                       onPressed: () {},
//                       color: AppColors.primaryButtonColor,
//                       textColor: AppColors.primaryFontColor,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStop({
//     required String icon,
//     required Color color,
//     required String title,
//     required String address,
//     required String date,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.asset(icon, height: 28.h, width: 18.w),
//           SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: getTextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Text(address, style: getTextStyle(fontSize: 13)),
//                 Text(
//                   date,
//                   style: getTextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.withValues(alpha: .6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
