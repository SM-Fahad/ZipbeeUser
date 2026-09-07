import 'package:ZipBee/features/user/finding_raider/model/payment_option_model.dart';
import 'package:flutter/material.dart';

class PaymentOptionWidget extends StatelessWidget {
  final int index;
  final PaymentOptionModel option;
  final bool selected;
  final VoidCallback onTap;

  const PaymentOptionWidget({
    super.key,
    required this.index,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        color: Colors.white,
        child: Row(
          children: [
            if (option.assetPath != null)
              Image.asset(option.assetPath!, width: 30, height: 30)
            else if (option.icon != null)
              Icon(option.icon, size: 30, color: Colors.black),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (option.subtitle.isNotEmpty)
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.amber : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
