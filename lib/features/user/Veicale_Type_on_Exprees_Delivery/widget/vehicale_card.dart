import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/models/vehicle_data_model.dart';
import 'package:flutter/material.dart';


class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
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
              // Vehicle image
              Image.asset(
                (vehicle.imageAsset.isNotEmpty)
                    ? vehicle.imageAsset
                    : IconPath.bike,
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
                    Text(
                      vehicle.subtitle ,
                      style: getTextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vehicle.details,
                      style: getTextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Check icon if selected
              if (isSelected) Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
