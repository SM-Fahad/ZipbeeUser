import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/my_riders/widgets/delete_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_riders_controller.dart';
import 'add_riders_widget.dart';

class RidersListWidget extends StatelessWidget {
  const RidersListWidget({super.key, required this.controller});

  final MyRidersController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 28),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: EdgeInsets.only(bottom: 20),
          itemCount: controller.ridersList.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.ridersList.length) {
              return Center(
                child: GestureDetector(
                  onTap: () => showAddRiderDialog(controller),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryButtonColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Add Rider',
                          style: getTextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final rider = controller.ridersList[index];
            final name = rider['name'] ?? '';
            final myRaiderId = rider['myRaiderId'] ?? 0;
            final image = (rider['image'] ?? '').toString();

            return Dismissible(
              key: Key(myRaiderId.toString()),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: Image.asset(IconPath.delete, height: 34, width: 34),
              ),
              confirmDismiss: (direction) async {
                final shouldDelete = await Get.dialog<bool>(
                  DeleteRiderDialog(
                    riderName: name,
                    onConfirm: () async {
                      await controller.deleteRider(myRaiderId);
                      Get.back(result: true);
                    },
                  ),
                  barrierDismissible: false,
                );
                return shouldDelete ?? false;
              },
              onUpdate: (details) =>
                  controller.updateSwipeProgress(name, details.progress),
              child: Obx(() {
                final progress = controller.swipeProgress[name] ?? 0.0;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: Color.lerp(
                    AppColors.backgroungColor,
                    Color.fromARGB(255, 230, 189, 28),
                    progress,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade400,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildRiderImage(image),
                      ),
                    ),
                    title: Text(
                      name,
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Obx(() {
                      final isFav = controller.loveState[myRaiderId] ?? false;
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                          color: isFav ? Colors.black : Colors.grey,
                        ),
                        onPressed: () =>
                            controller.toggleFavoriteApi(myRaiderId, name),
                      );
                    }),
                  ),
                );
              }),
            );
          },
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey, thickness: 1),
        );
      }),
    );
  }

  Widget _buildRiderImage(String image) {
    final fallback = Image.asset(
      ImagePath.profileImage,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
    );

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (image.isNotEmpty) {
      return Image.asset(
        image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return fallback;
  }
}
