import 'package:flutter/material.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import '../../../finding_raider/widget/location_row_widget.dart';

class OrderStopsList extends StatelessWidget {
  final List<Map<String, String>> pickupStops;
  final List<Map<String, String>> dropStops;
  final bool showReturnSection;

  const OrderStopsList({
    super.key,
    required this.pickupStops,
    required this.dropStops,
    this.showReturnSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Collected from (Multiple Pickups) ---
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pickupStops.length,
          itemBuilder: (context, index) {
            return LocationRowWidget(
              iconPath: IconPath.collectIcon,
              title: "Collected from : ${pickupStops[index]['name']}",
              address: pickupStops[index]['address']!,
            );
          },
        ),

        // স্টপগুলোর মধ্যে কানেক্টিং ডট বা গ্যাপ দেওয়ার জন্য
        if (pickupStops.isNotEmpty && dropStops.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: SizedBox(height: 20),
          ),

        // --- Deliver to (Multiple Drops) ---
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dropStops.length,
          itemBuilder: (context, index) {
            return LocationRowWidget(
              iconPath: IconPath.deliveredIcon,
              title: "Deliver to : ${dropStops[index]['name']}",
              address: dropStops[index]['address']!,
            );
          },
        ),

        if (showReturnSection && pickupStops.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
            child: SizedBox(height: 20),
          ),

        if (showReturnSection)
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pickupStops.length,
            itemBuilder: (context, index) {
              return LocationRowWidget(
                iconPath: IconPath.collectIcon,
                title: "Return : ${pickupStops[index]['name']}",
                address: pickupStops[index]['address']!,
              );
            },
          ),
      ],
    );
  }
}
