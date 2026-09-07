import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RaiderInfoWidget extends StatelessWidget {
  final RiderController controller = Get.find<RiderController>();
  final StackedOrderController orderController =
      Get.find<StackedOrderController>();

  RaiderInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if assign_rider data is available
      if (controller.assignRiderData.value == null) {
        return Center(child: Text('No rider information available'));
      }

      final assignRider = controller.assignRiderData.value;
      final registration =
          assignRider['registrations'] != null &&
              (assignRider['registrations'] as List).isNotEmpty
          ? assignRider['registrations'][0]
          : null;

      final riderName = registration?['raider_name'] ?? 'Unknown';
      final photoUrls = (registration?['driver_photos'] as List<dynamic>? ?? [])
          .map((photo) => photo.toString())
          .where((photo) => photo.isNotEmpty)
          .toList();
      final rating =
          (double.tryParse(controller.riderFormattedAverage.value) ?? 0.0)
              .clamp(0, 5)
              .toDouble();

      return Row(
        children: [
          _RiderAvatar(photoUrls: photoUrls),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: $riderName',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Order ID: ${orderController.orderNumber.value}',
                  style: getTextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Text(
                      'Rating: ',
                      style: getTextStyle(fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    ...List.generate(5, (index) {
                      final isFilled = index < rating.floor();
                      return Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        color: isFilled ? Colors.amber : Colors.grey,
                        size: 16,
                      );
                    }),
                    SizedBox(width: 8),
                    Text(
                      rating > 0 ? rating.toStringAsFixed(1) : '0.0',
                      style: getTextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _RiderAvatar extends StatelessWidget {
  final List<String> photoUrls;
  final RxInt currentPhotoIndex = 0.obs;

  _RiderAvatar({required this.photoUrls});

  void _showNextPhoto() {
    if (currentPhotoIndex.value >= photoUrls.length - 1) return;
    currentPhotoIndex.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPhoto =
          photoUrls.isNotEmpty &&
          currentPhotoIndex.value < photoUrls.length;

      return ClipOval(
        child: SizedBox(
          width: 72,
          height: 72,
          child: hasPhoto
              ? Image.network(
                  photoUrls[currentPhotoIndex.value],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showNextPhoto();
                    });
                    if (currentPhotoIndex.value >= photoUrls.length - 1) {
                      return Image.asset(
                        ImagePath.profileImage,
                        fit: BoxFit.cover,
                      );
                    }

                    return Container(color: Colors.grey.shade200);
                  },
                )
              : Image.asset(ImagePath.profileImage, fit: BoxFit.cover),
        ),
      );
    });
  }
}
