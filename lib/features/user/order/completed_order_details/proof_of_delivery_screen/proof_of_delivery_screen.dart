// import 'package:ZipBee/core/common/styles/global_text_style.dart';
// import 'package:ZipBee/core/utils/constants/image_path.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ProofOfDeliveryScreen extends StatelessWidget {
//   const ProofOfDeliveryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.asset(ImagePath.deliveryBox, fit: BoxFit.cover),
//             ),
//             Positioned(
//               top: 16,
//               left: 16,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//                 onPressed: () => Get.back(),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.transparent, Colors.black87],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Tracking Number: SPXSG057083664199",
//                       style: getTextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "Delivered on 23-09-2025 13:47",
//                       style: getTextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "23-September-2025",
//                       style: getTextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                     Text(
//                       "Singapore",
//                       style: getTextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "1.0178°N 103.051°E",
//                       style: getTextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     Text(
//                       "SPXSG057083664199 (1B6618CBD4-Main-SMR)",
//                       style: getTextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     SizedBox(height: 12),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
