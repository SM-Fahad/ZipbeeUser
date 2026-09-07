import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/refer_and_earn/controller/refer_and_earn_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ReferralCard extends StatelessWidget {
  const ReferralCard({super.key, required this.ctrl});

  final ReferAndEarnController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your referral code:',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => Text(
                            ctrl.referralCode.value,
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: ctrl.copyCode,
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ],
              ),

              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your referral link:',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => Text(
                            ctrl.referralLink.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: ctrl.copyLink,
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
