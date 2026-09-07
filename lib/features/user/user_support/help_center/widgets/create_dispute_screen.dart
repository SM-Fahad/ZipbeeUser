import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_button.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/user_support/help_center/controller/create_dispute_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateDisputeScreen extends StatelessWidget {
  final String? initialOrderId;
  final bool lockOrderId;

  const CreateDisputeScreen({
    super.key,
    this.initialOrderId,
    this.lockOrderId = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CreateDisputeController>()
        ? Get.find<CreateDisputeController>()
        : Get.put(CreateDisputeController());

    if (initialOrderId != null && initialOrderId!.trim().isNotEmpty) {
      controller.configureOrderId(initialOrderId!, lock: lockOrderId);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Report an Issue',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4C2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.report_gmailerrorred_outlined,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create a dispute',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Share the order details, select the issue type, and add proof if you have any.',
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormGroup(
                        title: 'Why are you disputing?',
                        child: controller.isLoadingDisputeTypes.value
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                initialValue:
                                    controller.selectedDisputeTypeId.value,
                                isExpanded: true,
                                decoration: _inputDecoration(
                                  'Select issue type',
                                ),
                                items: controller.disputeTypes
                                    .map(
                                      (item) => DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Text(
                                          item.name,
                                          style: getTextStyle(
                                            fontSize: 13,
                                            color: AppColors.primaryFontColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedDisputeTypeId.value =
                                        value;
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 14),
                      _FormGroup(
                        title: 'Order ID',
                        child: TextFormField(
                          controller: controller.orderIdController,
                          keyboardType: TextInputType.number,
                          readOnly: controller.isOrderIdLocked.value,
                          decoration: _inputDecoration('Enter order ID'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FormGroup(
                        title: 'What Happened?',
                        child: TextFormField(
                          controller: controller.descriptionController,
                          minLines: 5,
                          maxLines: 7,
                          decoration: _inputDecoration(
                            'Describe the issue clearly',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF0E2A2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: _SectionLabel(
                                    title: 'Add Proof (Optional)',
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: controller.isUploadingImages.value
                                      ? null
                                      : controller.pickAndUploadImages,
                                  icon: controller.isUploadingImages.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                  label: Text(
                                    controller.isUploadingImages.value
                                        ? 'Uploading...'
                                        : 'Upload',
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Upload screenshots or photos as supporting proof.',
                              style: getTextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (controller.evidenceUrls.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE9E0BC),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Colors.black45,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No proof added yet',
                                      style: getTextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (controller.evidenceUrls.isNotEmpty) ...[
                              SizedBox(
                                height: 92,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.evidenceUrls.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final imageFile =
                                        controller.pickedImages[index];
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 92,
                                          height: 92,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE9E0BC),
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(imageFile),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () => controller
                                                .removeEvidence(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black87,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: List.generate(
                              //     controller.evidenceUrls.length,
                              //     (index) => Padding(
                              //       padding: const EdgeInsets.only(bottom: 6),
                              //       child: Text(
                              //         controller.evidenceUrls[index],
                              //         style: getTextStyle(
                              //           fontSize: 11,
                              //           color: Colors.blueGrey,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: controller.isSubmitting.value
                      ? 'Submitting...'
                      : 'Submit For Review',
                  onPressed: controller.isSubmitting.value
                      ? () {}
                      : controller.submitDispute,
                  color: AppColors.primaryButtonColor,
                  textColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: getTextStyle(fontSize: 13, color: Colors.black45),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryButtonColor),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: getTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryFontColor,
      ),
    );
  }
}

class _FormGroup extends StatelessWidget {
  const _FormGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: title),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
