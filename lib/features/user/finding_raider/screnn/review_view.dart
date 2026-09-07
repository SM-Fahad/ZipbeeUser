import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/core/utils/constants/image_path.dart';
import 'package:ZipBee/features/user/finding_raider/controller/review_controller.dart';
import 'package:ZipBee/features/user/finding_raider/controller/rider_controller.dart';
import 'package:ZipBee/features/user/finding_raider/model/review_model.dart';
import 'package:ZipBee/features/user/finding_raider/screnn/rate_rider_tip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewView extends StatelessWidget {
  final String orderId;
  final int? riderId;
  final bool showRatingFormOnly;

  ReviewView({
    super.key,
    required this.orderId,
    required this.riderId,
    this.showRatingFormOnly = false,
  }) {
    if (!Get.isRegistered<RiderController>()) {
      Get.put(RiderController());
    }
    if (Get.isRegistered<ReviewController>()) {
      Get.delete<ReviewController>(force: true);
    }
  }

  late final ReviewController controller = Get.put(
    ReviewController(orderId: orderId, riderId: riderId),
  );

  final Color kPrimaryYellow = Color(0xFFFFC107);
  final Color kGreen = Color(0xFF2ECC71);
  final Color kLime = Color(0xFFCDDC39);
  final Color kOrange = Color(0xFFFFA726);
  final Color kRed = Color(0xFFFF3D00);
  final Color kGreyText = Colors.grey;
  final List<Map<String, String>> deliveryQualityOptions = const [
    {"value": "EXCELLENT", "label": "Excellent"},
    {"value": "GOOD", "label": "Good"},
    {"value": "AVERAGE", "label": "Average"},
    {"value": "POOR", "label": "Poor"},
  ];
  final List<Map<String, String>> deliveryStatusOptions = const [
    {"value": "ON_TIME", "label": "On time"},
    {"value": "LATE", "label": "Late"},
    {"value": "DAMAGED", "label": "Damaged"},
    {"value": "CANCELLED", "label": "Cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reviews',
          style: getTextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (!showRatingFormOnly) ...[
              Obx(
                () => Center(
                  child: Column(
                    children: [
                      Text(
                        controller.averageRating.value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildStarRow(controller.averageRating.value, size: 24),
                      const SizedBox(height: 5),
                      Text(
                        "Based on ${controller.totalReviews.value} reviews",
                        style: TextStyle(color: kGreyText, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                final percentages = controller.getRatingPercentages();
                return Column(
                  children: [
                    buildProgressBar(
                      "Excellent",
                      percentages["Excellent"] ?? 0,
                      kGreen,
                    ),
                    buildProgressBar("Good", percentages["Good"] ?? 0, kLime),
                    buildProgressBar(
                      "Average",
                      percentages["Average"] ?? 0,
                      kOrange,
                    ),
                    buildProgressBar("Poor", percentages["Poor"] ?? 0, kRed),
                  ],
                );
              }),
            // ],
            if (showRatingFormOnly) _buildRateRiderSection(),
            SizedBox(height: 30),
            Obx(
              () => ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.reviews.length,
                separatorBuilder: (_, __) => Column(
                  children: [
                    SizedBox(height: 5),
                    Divider(thickness: 1, color: Colors.grey),
                    SizedBox(height: 5),
                  ],
                ),
                itemBuilder: (context, index) {
                  final review = controller.reviews[index];
                  return buildReviewCard(review);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateRiderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          "Rate Rider",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "Your feedback helps us to improve your experience!",
          style: TextStyle(color: kGreyText, fontSize: 13),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Obx(() => buildInteractiveStars(controller.inputRating.value)),
            SizedBox(width: 10),
            Text("Rate to earn", style: TextStyle(color: kGreyText)),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "What influenced your rating?",
          style: TextStyle(color: kGreyText, fontSize: 14),
        ),
        SizedBox(height: 10),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.commentController,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Delivery quality",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: deliveryQualityOptions
                .map(
                  (option) => _SelectionChip(
                    label: option["label"]!,
                    isSelected: controller.selectedDeliveryQuality.value ==
                        option["value"],
                    onTap: () =>
                        controller.selectDeliveryQuality(option["value"]!),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 18),
        Text(
          "Delivery status",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: deliveryStatusOptions
                .map(
                  (option) => _SelectionChip(
                    label: option["label"]!,
                    isSelected: controller.selectedDeliveryStatus.value ==
                        option["value"],
                    onTap: () =>
                        controller.selectDeliveryStatus(option["value"]!),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              final isSuccess = await controller.submitReview();
              if (isSuccess) {
                Get.to(() => RateRiderTip());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              "Submit Review",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ Helper Widgets ------------------

  Widget buildReviewCard(Review review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: review.imageUrl.isNotEmpty
                  ? Image.network(
                      review.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        ImagePath.profileImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(ImagePath.profileImage, fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  buildStarRow(review.rating, size: 16),
                  SizedBox(width: 8),
                  Text(
                    review.rating.toString(),
                    style: TextStyle(color: kGreyText, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                review.comment,
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProgressBar(String label, double percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStarRow(double rating, {double size = 20}) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(Icon(Icons.star, color: kPrimaryYellow, size: size));
      } else if (i - 0.5 <= rating) {
        stars.add(Icon(Icons.star_half, color: kPrimaryYellow, size: size));
      } else {
        stars.add(
          Icon(Icons.star_border, color: Colors.grey.shade300, size: size),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Widget buildInteractiveStars(double currentRating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            controller.inputRating.value = index + 1.0;
          },
          child: Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Icon(
              index < currentRating ? Icons.star : Icons.star_border,
              color:
                  index < currentRating ? kPrimaryYellow : Colors.grey.shade300,
              size: 30,
            ),
          ),
        );
      }),
    );
  }

  Widget buildRadioItem(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryYellow : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryYellow,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4C2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC107) : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
