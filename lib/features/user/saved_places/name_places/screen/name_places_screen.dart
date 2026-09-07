import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/saved_places/controller/saved_places_controller.dart';
import 'package:ZipBee/features/user/saved_places/screen/saved_place_screenn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NamePlaceScreen extends StatelessWidget {
  NamePlaceScreen({super.key});

  final SavedPlaceController controller = Get.isRegistered<SavedPlaceController>()
      ? Get.find<SavedPlaceController>()
      : Get.put(SavedPlaceController());
  final TextEditingController nameController = TextEditingController();

  String _formatDisplayText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
    final isAllUppercase = hasLetters && trimmed == trimmed.toUpperCase();
    if (!isAllUppercase) return trimmed;

    return trimmed.split(RegExp(r'(\s+)')).map((part) {
      if (part.trim().isEmpty) return part;

      return part
          .split('-')
          .map((segment) {
            if (segment.isEmpty) return segment;
            final lower = segment.toLowerCase();
            return '${lower[0].toUpperCase()}${lower.substring(1)}';
          })
          .join('-');
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isEditing && nameController.text.isEmpty) {
      nameController.text = controller.editingPlaceName.value;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        title: Text(
          controller.isEditing ? 'Edit Contact' : 'Add Contact',
          style: getTextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.backgroungColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Contact Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                hintText: 'Contact Name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            Obx(() {
              final address = controller.selectedAddress.value;

              return ListTile(
                leading: const Icon(Icons.location_on, color: Colors.amber),
                title: Text(
                  address.isNotEmpty
                      ? _formatDisplayText(address.split(',').first)
                      : 'No address selected',
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  address.isNotEmpty ? _formatDisplayText(address) : '',
                  style: getTextStyle(fontSize: 12),
                ),
              );
            }),

            const Spacer(),

            CustomButton(
              label: controller.isEditing ? 'Update Contact' : 'Save Contact',
              color: AppColors.primaryButtonColor,
              textColor: AppColors.primaryFontColor,
              onPressed: () async {
                FocusScope.of(context).unfocus();

                final name = nameController.text.trim();

                if (name.isEmpty) {
                  EasyLoading.showError('Enter contact name');
                  return;
                }

                if (controller.selectedAddress.value.isEmpty) {
                  EasyLoading.showError('Address not selected');
                  return;
                }

                final ok = await controller.savePlace(name);
                if (ok) {
                  Get.offAll(() => SavedPlaceScreen());
                }
              },
            ),

            SizedBox(height: 90.h),
          ],
        ),
      ),
    );
  }
}
