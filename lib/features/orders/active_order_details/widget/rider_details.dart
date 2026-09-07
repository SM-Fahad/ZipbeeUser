import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:flutter/material.dart';

class RiderDetails extends StatelessWidget {
  const RiderDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage(ImagePath.profileImage),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Christine Jason",
                style: getTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Vehicle type: Motorbike",
                style: getTextStyle(fontSize: 13),
              ),
              Text(
                "Order 1266",
                style: getTextStyle(fontSize: 13),
              ),
              Text(
                "Scheduled to your pick-up time",
                style: getTextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
