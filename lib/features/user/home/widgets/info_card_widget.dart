// Unused file

// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/utils/constants/app_colors.dart';
// import 'package:flutter/material.dart';

// Widget borderedInfoCard({
//   required String title,
//   required String Function() valueBuilder,
//   IconData? icon,
//   String? iconPath,
//   Color? iconBgColor,
//   double iconSize = 20,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: AppColors.backgroungColor,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: AppColors.subtitleFontColor),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: iconBgColor ?? Colors.white,
//             shape: BoxShape.circle,
//           ),
//           child: iconPath != null
//               ? Image.asset(iconPath, height: iconSize, width: iconSize)
//               : Icon(icon, size: iconSize, color: Colors.white),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           title,
//           style: getTextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: AppColors.primaryFontColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           valueBuilder(),
//           style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//         ),
//       ],
//     ),
//   );
// }