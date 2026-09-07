import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';

class LocationRowWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String address;
  final String? contactNumber;

  const LocationRowWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.address,
    this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    final hasContactNumber =
        contactNumber != null && contactNumber!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(iconPath, height: 20, width: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // নাম বড় হলে ডট দেখাবে
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subtitleFontColor,
                ),
                maxLines: 2, // এড্রেস ২ লাইন পর্যন্ত দেখাবে
                overflow: TextOverflow.ellipsis, // এর বেশি হলে ডট দেখাবে
              ),
              if (hasContactNumber) ...[
                const SizedBox(height: 2),
                Text(
                  'Contact: ${contactNumber!.trim()}',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtitleFontColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
