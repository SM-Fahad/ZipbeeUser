import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/features/user/collect_form_on_express_delivery/controller/collect_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddressListWidget extends StatelessWidget {
  final CollectFormController controller;

  const AddressListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.addressList.isEmpty) {
          return Center(child: Text("No addresses found."));
        }

        return ListView.separated(
          itemCount: controller.addressList.length,
          itemBuilder: (context, index) {
            final address = controller.addressList[index];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: address.iconPath.isNotEmpty
                  ? Image.asset(
                      address.iconPath,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.location_on),
                    )
                  : SizedBox(width: 24, height: 24),
              title: Text(
                address.title,
                style: getTextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                address.subtitle,
                style: getTextStyle(color: Colors.grey.shade600),
              ),
              onTap: () {
                // controller.onAddressTap(address);
              },
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      }),
    );
  }
}
