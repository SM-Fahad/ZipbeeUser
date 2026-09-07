import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_app_bar_user.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/notification/model/notification1_model.dart';
// import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
// import 'package:get/get_core/get_core.dart';
// import 'package:get/route_manager.dart';

class PromotionDetailsScreen extends StatelessWidget {
  final Notification1Model item;

  const PromotionDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: Column(
        children: [
          CustomAppBarUser(
            title: "Promotion Details", 
            style: getTextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.subtitleFontColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.onboardingIndicatorActive,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.title,
                            style: getTextStyle(
                              fontSize: 16,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.date,
                          style: getTextStyle(
                            fontSize: 13,
                            color: AppColors.subtitleFontColor,
                          ),
                        ),
                        Text(
                          item.time,
                          style: getTextStyle(
                            fontSize: 13,
                            color: AppColors.subtitleFontColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (item.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Container(
                              height: 170,
                              width: double.infinity,
                              color: const Color(0xFFF3F3F3),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 170,
                                width: double.infinity,
                                color: const Color(0xFFF3F3F3),
                                alignment: Alignment.center,
                                child: Text(
                                  "Image not available",
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: AppColors.subtitleFontColor,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      "Message",
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.onboardingIndicatorActive.withValues(
                          alpha: 0.28,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.subTitle,
                        style: getTextStyle(
                          fontSize: 12,
                          color: AppColors.primaryFontColor,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 12),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 0,
                    //       backgroundColor: AppColors.onboardingIndicatorActive,
                    //       foregroundColor: AppColors.primaryFontColor,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(6),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Get.offNamed(
                    //         AppRoutes.bottomNavbarScreen,
                    //         arguments: {'index': 0},
                    //       );
                    //     },
                    //     child: Text(
                    //       "Use It Now",
                    //       style: getTextStyle(fontWeight: FontWeight.w600),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
