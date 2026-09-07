import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,

      /// ✅ APP BAR CENTER TITLE
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                /// 🔥 PROFILE IMAGE WITH EDIT ICON
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: controller.profileImage.value != null
                            ? Image.file(
                                controller.profileImage.value!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : controller.userModel.value.image.isNotEmpty
                            ? Image.network(
                                controller.userModel.value.image,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    ImagePath.profileImage,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                ImagePath.profileImage,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                      );
                    }),

                    /// EDIT ICON OVERLAY
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _showImagePicker(context, controller);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    /// TICK MARK FOR UPLOAD
                    Obx(() {
                      if (controller.profileImage.value != null) {
                        return Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: controller.saveProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔽 PROFILE INFO SECTION
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(child: Text(controller.errorMessage.value));
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          controller.profileItem.length +
                          3, // +3: First, Last, DOB
                      itemBuilder: (_, index) {
                        return Obx(() {
                          final isEditing =
                              controller.editingIndex.value == index;

                          /// ---------- TITLE ----------
                          String title;
                          if (index == 0) {
                            title = "First Name";
                          } else if (index == 1) {
                            title = "Last Name";
                          } else if (index == 2) {
                            title = "Date of Birth";
                          } else {
                            title = controller.profileItem[index - 3].title;
                          }

                          /// ---------- SUBTITLE ----------
                          String subtitle;
                          if (index == 0) {
                            subtitle =
                                controller
                                    .userModel
                                    .value
                                    .userProfile
                                    ?.firstName ??
                                '';
                          } else if (index == 1) {
                            subtitle =
                                controller
                                    .userModel
                                    .value
                                    .userProfile
                                    ?.lastName ??
                                '';
                          } else if (index == 2) {
                            subtitle = controller.formatIsoToDmy(
                              controller
                                  .userModel
                                  .value
                                  .userProfile
                                  ?.dateOfBirth,
                            );
                          } else {
                            subtitle =
                                controller.profileItem[index - 3].subtitle;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: getTextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          isEditing
                                              ? TextFormField(
                                                  autofocus: true,
                                                  controller: controller
                                                      .getControllerForIndex(
                                                        index,
                                                      ),
                                                  keyboardType: index == 3
                                                      ? TextInputType
                                                            .emailAddress
                                                      : index == 4
                                                      ? TextInputType.phone
                                                      : TextInputType.text,
                                                  decoration:
                                                      const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        isDense: true,
                                                      ),
                                                )
                                              : Text(
                                                  subtitle.isEmpty
                                                      ? "Not set"
                                                      : subtitle,
                                                  style: getTextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    /// EDIT / SAVE BUTTON
                                    isEditing
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: controller.cancelEditing,
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () {
                                                  controller.updateUserProfile(
                                                    firstName: index == 0
                                                        ? controller
                                                              .firstNameController
                                                              .text
                                                        : null,
                                                    lastName: index == 1
                                                        ? controller
                                                              .lastNameController
                                                              .text
                                                        : null,
                                                    dateOfBirth: index == 2
                                                        ? controller
                                                              .dobController
                                                              .text
                                                        : null,
                                                    username: index == 3
                                                        ? controller
                                                              .usernameController
                                                              .text
                                                        : null,
                                                    email: index == 4
                                                        ? controller
                                                              .emailController
                                                              .text
                                                        : null,
                                                    phone: index == 5
                                                        ? controller
                                                              .phoneController
                                                              .text
                                                        : null,
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          )
                                        : GestureDetector(
                                            onTap: () =>
                                                controller.startEditing(index),
                                            child: Image.asset(
                                              IconPath.editIcon,
                                              height: 18,
                                              width: 18,
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const Divider(thickness: 0.7),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  controller.pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  controller.pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
