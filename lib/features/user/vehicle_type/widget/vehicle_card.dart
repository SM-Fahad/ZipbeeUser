import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import '../model/model.dart';

class StackedVehicleCard extends StatelessWidget {
  final StackVehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const StackedVehicleCard({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.amberAccent : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Vehicle image: choose icon based on API vehicle type grouping
              Image.asset(
                (() {
                  final vt = vehicle.type.toUpperCase();
                  if ([
                    'MOTORCYCLE',
                    'BICYCLE',
                    'ELECTRIC_SCOOTER',
                  ].contains(vt)) {
                    return IconPath.courierIcon;
                  } else if (['CAR'].contains(vt)) {
                    return IconPath.realCar;
                  } else if (['SUV'].contains(vt)) {
                    return IconPath.suv;
                  } else if (vt == 'VAN') {
                    return IconPath.trunk2;
                  } else if (vt == 'TRUCK') {
                    return IconPath.trunk3;
                  } else if (vehicle.imageAsset != null &&
                      vehicle.imageAsset!.isNotEmpty) {
                    return vehicle.imageAsset!;
                  } else {
                    return IconPath.bike;
                  }
                })(),
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (vehicle.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.description,
                        style: getTextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                    if ((vehicle.dimension?.isNotEmpty ?? false) ||
                        (vehicle.maxLoad?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (vehicle.dimension?.isNotEmpty ?? false)
                            '${vehicle.dimension} m',
                          if (vehicle.maxLoad?.isNotEmpty ?? false)
                            'Up to ${vehicle.maxLoad} kg',
                        ].join(' - '),
                        style: getTextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),

              // Check icon if selected
              if (isSelected)
                Icon(Icons.check_circle, color: Colors.green)
              else
                Icon(Icons.circle_outlined, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
