import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewRating extends StatelessWidget {
  final double size;
  final RiderController controller = Get.find<RiderController>();

  ReviewRating({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final isSelected = index < controller.rating.value;

          return GestureDetector(
            onTap: () {
              controller.setRating(index + 1);
            },
            child: Icon(
              Icons.star,
              size: size,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
