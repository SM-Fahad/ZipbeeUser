import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';

import '../model/model.dart';

class StackedAdditionalServiceCard extends StatelessWidget {
  final StackedAdditionalService service;
  final bool isSelected;
  final VoidCallback onTap;

  const StackedAdditionalServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.yellow[100] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? Colors.yellow : Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          service.name,
          style: getTextStyle(
            fontWeight: FontWeight.w500, // Medium weight
            fontSize: 14, // Adjust size as needed
            color: Colors.black87, // Change color if needed
          ),
        ),

        trailing: Text(
          '+\$${service.price.toStringAsFixed(2)}',
          style: getTextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
