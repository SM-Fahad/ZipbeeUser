import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StopItem extends StatelessWidget {
  final String title;
  final String address;
  final String iconPath;

  const StopItem({
    super.key,
    required this.title,
    required this.address,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconPath.isNotEmpty
              ? Image.asset(iconPath, height: 18.h, width: 18.w)
              : Icon(Icons.location_on, size: 18.h),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: getTextStyle(fontWeight: FontWeight.w600)),
                Text(address, style: getTextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
