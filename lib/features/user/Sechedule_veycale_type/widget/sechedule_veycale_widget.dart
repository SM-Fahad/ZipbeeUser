import 'package:flutter/material.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import '../models/vehicle_data_model.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.asset(
          vehicle.imageAsset ?? IconPath.bike,
          width: 50,
        ),
        title: Text(
          vehicle.name,
          style: getTextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(vehicle.details),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Text(
                'S\$${vehicle.price.toStringAsFixed(0)}',
                style: getTextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final AdditionalService service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(service.name),
      trailing: Text('+ S\$${service.price}'),
    );
  }
}
