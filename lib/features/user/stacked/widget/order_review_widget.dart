import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/controller/stacked_order_controller.dart';
import 'package:ZipBee/features/user/stacked/order_stacked_delivery/widget/order_confirmation_dialog.dart';
import 'package:ZipBee/features/user/vehicle_type/controller/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderReviewWidget extends StatelessWidget {
  final StackedVehicleController vehicleController;
  final StackedOrderController orderController = Get.put(
    StackedOrderController(),
  );
  final double total;
  final List<String> calculationHistory;

  // New: reusable callback
  final VoidCallback? onReviewOrderPressed;

  OrderReviewWidget({
    super.key,
    required this.vehicleController,
    required this.total,
    required this.calculationHistory,
    this.onReviewOrderPressed, // optional: pass your own function
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 70),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _historyButton(context),
          SizedBox(width: 12),
          Expanded(child: _totalInfo()),
          SizedBox(width: 12),
          _reviewOrderButton(),
        ],
      ),
    );
  }

  Widget _historyButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_drop_up, size: 32, color: Colors.black54),
      onPressed: () => _openHistoryPopup(context),
    );
  }

  Widget _totalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total (incl. GST):',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Reusable review order button
  Widget _reviewOrderButton() {
    return FilledButton(
      onPressed: onReviewOrderPressed ?? _defaultReviewOrderAction,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        'Review Order',
        style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Default action if no callback is passed
  void _defaultReviewOrderAction() {
    // Call the reusable dialog function
    StackedOrderConfirmationDialog.show();
  }

  void _openHistoryPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              "Calculation History",
              style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: calculationHistory.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (_, index) => ListTile(
                  leading: Icon(Icons.check, color: Colors.amber),
                  title: Text(calculationHistory[index]),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "SubTotal:",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
