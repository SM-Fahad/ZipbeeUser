// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/common/widgets/custom_button.dart';
// import 'package:ZipBee/core/utils/constants/app_colors.dart';
// import 'package:ZipBee/core/utils/constants/icon_path.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
//
// import '../widget/price_and_payment.dart';
// import '../widget/reviews_widget.dart';
// import '../widget/rider_details.dart';
// import '../widget/stop_item_widget.dart';
//
// class ActiveOrderDetailsScreen extends StatelessWidget {
//   const ActiveOrderDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroungColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               color: Color(0XFFFFCC00),
//               padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Container(
//               height: 200.h,
//               width: double.infinity,
//               color: Colors.grey.shade300,
//               alignment: Alignment.center,
//               child: Text("Needs Google Map API", style: getTextStyle()),
//             ),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroungColor,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(22),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 3,
//                         offset: Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RiderDetails(),
//                       SizedBox(height: 12),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           OutlinedButton.icon(
//                             onPressed: () {},
//                             icon: Image.asset(
//                               IconPath.message,
//                               height: 20.h,
//                               width: 20.w,
//                             ),
//                             label: Text(
//                               "Message",
//                               style: getTextStyle(fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                           OutlinedButton.icon(
//                             onPressed: () {},
//                             icon: Image.asset(
//                               IconPath.call,
//                               height: 20.h,
//                               width: 20.w,
//                             ),
//                             label: Text(
//                               "Call",
//                               style: getTextStyle(fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: 8),
//                       Reviews(),
//
//                       SizedBox(height: 16),
//                       PriceAndPayment(),
//                       SizedBox(height: 4),
//
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Text(
//                             "Date & Time: ",
//                             style: getTextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           Text(
//                             "25 August 2025 / 12:10 pm",
//                             style: getTextStyle(),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: 20),
//
//                       StopItem(
//                         iconPath: IconPath.locationBlue,
//                         title: "Collected from (Sender: Athena Lin)",
//                         address: "Blk 657 Ang Mo Kio Ave 9, S560657",
//                       ),
//                       StopItem(
//                         iconPath: IconPath.locationRed,
//                         title: "Deliver to (Joseph Low)",
//                         address: "Blk 222 Sengkang Ave 2, S530222",
//                       ),
//                       StopItem(
//                         iconPath: IconPath.locationRed,
//                         title: "Deliver to (Annie Tan)",
//                         address: "Blk 447 Sengkang Ave 4, S530447",
//                       ),
//                       StopItem(
//                         iconPath: IconPath.locationRed,
//                         title: "Deliver to (Tony Toh)",
//                         address: "Blk 244 Jurong East St 61, S600244",
//                       ),
//
//                       SizedBox(height: 20),
//
//                       CustomButton(
//                         label: 'Share Ride Information',
//                         onPressed: () {},
//                         color: AppColors.primaryButtonColor,
//                         textColor: AppColors.fontColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
