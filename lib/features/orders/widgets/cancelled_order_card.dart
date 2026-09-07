import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';


class CancelledOrderCard extends StatelessWidget {
  const CancelledOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroungColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Thu, Oct 2, 10:36 PM",
                style: getTextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Spacer(),
              Text(
                "Re-Order",
                style: getTextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.radio_button_off, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text("625 Ang Mo Kio Avenue 9", style: getTextStyle()),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text("Tuas View Dormitory", style: getTextStyle()),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text("Car", style: getTextStyle(fontWeight: FontWeight.w500)),
              Spacer(),
              Text("S\$0.00", style: getTextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 16),
              SizedBox(width: 6),
              Text("Delivery", style: getTextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}
