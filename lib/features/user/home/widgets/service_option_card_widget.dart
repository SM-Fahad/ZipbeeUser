// Unused file

// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:flutter/material.dart';

// Widget buildServiceOptionCard({
//   required String title,
//   required String subtitle,
//   required bool selected,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//       decoration: BoxDecoration(
//         color: selected ? Colors.orange.shade100 : const Color(0xFFFFEEBB),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: selected ? Colors.orange : Colors.transparent,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w400),
//             textAlign: TextAlign.center,
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     ),
//   );
// }