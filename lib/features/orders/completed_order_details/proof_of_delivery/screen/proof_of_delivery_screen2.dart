import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/proof_of_delivery_controller.dart';

class ProofOfDeliveryScreen2 extends GetView<ProofOfDeliveryController> {
  const ProofOfDeliveryScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Proof of Delivery",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  /// Main Image
                  Positioned.fill(
                    child: controller.selectedImage.isEmpty
                        ? const SizedBox()
                        : Image.network(
                            controller.selectedImage.value,
                            fit: BoxFit.cover,
                          ),
                  ),

                  /// Overlay
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tracking Number: ${controller.trackingNumber.value}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Delivered on ${controller.deliveredAt.value}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            controller.location.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          /// Thumbnails
                          SizedBox(
                            height: 78.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.images.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 10.w),
                              itemBuilder: (context, index) {
                                final image = controller.images[index];
                                return GestureDetector(
                                  onTap: () => controller.changeImage(image),
                                  child: Container(
                                    width: 78.w,
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color:
                                            controller.selectedImage.value ==
                                                image
                                            ? const Color(0xFFFFB000)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
