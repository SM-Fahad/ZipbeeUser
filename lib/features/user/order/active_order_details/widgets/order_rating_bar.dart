import 'package:flutter/material.dart';
import '../../../../../../core/common/styles/global_text_style.dart';

class OrderRatingBar extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final VoidCallback? onTap;

  const OrderRatingBar({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRating = rating.clamp(0, 5).toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ...List.generate(5, (index) {
              final starIndex = index + 1;
              IconData icon = Icons.star_border;

              if (normalizedRating >= starIndex) {
                icon = Icons.star;
              } else if (normalizedRating >= starIndex - 0.5) {
                icon = Icons.star_half;
              }

              return Icon(icon, color: Colors.amber, size: 20);
            }),
            const SizedBox(width: 8),
            Text(
              normalizedRating.toStringAsFixed(1),
              style: getTextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '($totalReviews Reviews)',
              style: getTextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
