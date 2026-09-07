import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';

class PaymentInfoWidget extends StatelessWidget {
  final RiderController controller = Get.find<RiderController>();

  PaymentInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final payType = controller.paymentType.value;

        if (payType == 'ONLINE_PAY') {
          return Row(
            children: [
              Image.asset(IconPath.visa, height: 24),
              SizedBox(width: 8),
            ],
          );
        } else if (payType == 'WALLET') {
          return Row(
            children: [
              Image.asset(IconPath.wallet, height: 24),
              SizedBox(width: 8),
              Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        } else if (payType == 'COD') {
          return Row(
            children: [
              Icon(Icons.money, size: 24, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Cash',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
