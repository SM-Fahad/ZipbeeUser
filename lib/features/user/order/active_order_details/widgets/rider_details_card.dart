import 'package:flutter/material.dart';
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../../../../../core/utils/constants/image_path.dart';
import '../../model/order_model.dart';

class RiderDetailsCard extends StatelessWidget {
  final OrderModel order;
  final bool showFavoriteIcon;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback? onFavoriteTap;

  const RiderDetailsCard({
    super.key,
    required this.order,
    this.showFavoriteIcon = false,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final riderName = order.assignRiderName.isNotEmpty
        ? order.assignRiderName
        : 'Rider Not Assigned';
    final riderImage = order.assignRiderImage.trim();
    final hasRiderInfo = order.assignRiderName.isNotEmpty ||
        riderImage.isNotEmpty ||
        order.assignRiderRank.isNotEmpty ||
        order.assignRiderCompletedTrips > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasRiderInfo ? () => _showRiderProfileDialog(context) : null,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: riderImage.isNotEmpty
                  ? Image.network(
                      riderImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        ImagePath.profileImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      ImagePath.profileImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                riderName,
                style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                "Vehicle Type: ${order.vehicleType}",
                style: getTextStyle(fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    "Delivery Type: ${order.deliveryTypeName}",
                    style: getTextStyle(fontSize: 14),
                  ),
                  if (order.deliveryTypeIconPath != null) ...[
                    const SizedBox(width: 6),
                    Image.asset(
                      order.deliveryTypeIconPath!,
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
              Text("Order: ${order.orderId}",
                  style: getTextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (showFavoriteIcon)
          SizedBox(
            width: 40,
            height: 40,
            child: isFavoriteLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: onFavoriteTap,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.black : Colors.grey,
                      size: 24,
                    ),
                  ),
          ),
      ],
    );
  }

  void _showRiderProfileDialog(BuildContext context) {
    final riderName =
        order.assignRiderName.isNotEmpty ? order.assignRiderName : 'N/A';
    final riderRank =
        order.assignRiderRank.isNotEmpty ? order.assignRiderRank : 'N/A';
    final riderImage = order.assignRiderImage.trim();
    final reviewCount = order.assignRiderReviews;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: riderImage.isNotEmpty
                        ? Image.network(
                            riderImage,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              ImagePath.profileImage,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            ImagePath.profileImage,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  riderName,
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileInfoRow(label: 'Rank', value: riderRank),
                const SizedBox(height: 10),
                _ProfileInfoRow(
                  label: 'Rating',
                  value: order.assignRiderRating.toStringAsFixed(1),
                ),
                const SizedBox(height: 10),
                _ProfileInfoRow(label: 'Review', value: '$reviewCount'),
                const SizedBox(height: 10),
                _ProfileInfoRow(
                  label: 'Completed Trips',
                  value: order.assignRiderCompletedTrips.toString(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
