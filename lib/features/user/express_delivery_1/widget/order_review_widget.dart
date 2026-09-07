import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/Veicale_Type_on_Exprees_Delivery/controller/vehicle_secation_controller.dart';
import 'package:ZipBee/features/user/order/controller/order_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrderReviewWidget extends StatelessWidget {
  final VehicleController vehicleController;
  final OrderController orderController = Get.put(OrderController());
  final double total;
  final List<String> calculationHistory;

  final VoidCallback? onReviewOrderPressed;

  OrderReviewWidget({
    super.key,
    required this.vehicleController,
    required this.total,
    required this.calculationHistory,
    this.onReviewOrderPressed, 
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
          historyButton(context),
          SizedBox(width: 12),
          Expanded(child: _totalInfo()),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget historyButton(BuildContext context) {
    return IconButton(
      icon:  Icon(Icons.arrow_drop_up, size: 32, color: Colors.black54),
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
          'S\$${total.toStringAsFixed(2)}',
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
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
              "Total Amount:",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "S\$${total.toStringAsFixed(2)}",
              style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
