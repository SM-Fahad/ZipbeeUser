import 'package:ZipBee/features/user/saved_places/add_places/controller/saved_places_controller.dart';
import 'package:ZipBee/features/user/saved_places/controller/saved_places_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/google_map/widget/google_map_widget.dart';

class AddPlaceScreen extends StatelessWidget {
  // final AddPlaceController controller = Get.put(AddPlaceController());
  final controller = Get.put(AddPlaceController());
  final savedPlaceController = Get.isRegistered<SavedPlaceController>()
      ? Get.find<SavedPlaceController>()
      : Get.put(SavedPlaceController());

  AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        title: Text(
          savedPlaceController.isEditing ? 'Edit Place' : 'Add Place',
          style: getTextStyle(fontSize: 20.sp),
        ),
        backgroundColor: AppColors.backgroungColor,
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, color: Colors.amber.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search by postal code, building, or road. You can also tap the map and press Use to continue.',
                      style: getTextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GoogleMapWidget(
                  mode: GoogleMapWidgetMode.addressPicker,
                  initialQuery:
                      savedPlaceController.selectedPostalCode.value.isNotEmpty
                      ? savedPlaceController.selectedPostalCode.value
                      : savedPlaceController.selectedAddress.value,
                  onLocationConfirmed: controller.onLocationSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
