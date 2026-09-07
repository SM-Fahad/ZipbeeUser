import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../../../../../core/utils/constants/icon_path.dart';
import '../../model/order_model.dart';

class PaymentAndTimeInfo extends StatelessWidget {
  final OrderModel order;
  const PaymentAndTimeInfo({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: getTextStyle(fontSize: 12)),
                Text(
                  'S\$${order.total.toStringAsFixed(2)}',
                  style:
                      getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            _buildPaymentDisplay(),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date & Time', style: getTextStyle(fontSize: 14)),
            Text(
              _formatDateTime(order.placedAt),
              style: getTextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDisplay() {
    final String payType = "COD"; // অথবা order.paymentType যদি আপনার মডেলে থাকে

    if (payType == 'ONLINE_PAY' || payType == 'STRIPE') {
      return Image.asset(IconPath.visa, height: 24);
    } else if (payType == 'WALLET') {
      return Row(
        children: [
          Image.asset(IconPath.wallet, height: 24),
          const SizedBox(width: 8),
          const Text('Wallet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.money, size: 24, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Cash',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      );
    }
  }

  String _formatDateTime(String isoString) {
    if (isoString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}
