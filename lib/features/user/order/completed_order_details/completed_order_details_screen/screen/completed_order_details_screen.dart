import 'package:ZipBee/features/user/order/active_order_details/widgets/message_call_section.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/order_rating_bar.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/order_stops_list.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/payment_and_time_info.dart';
import 'package:ZipBee/features/user/order/active_order_details/widgets/rider_details_card.dart';
import 'package:ZipBee/features/user/finding_raider/services/share_reward_service.dart';
import 'package:ZipBee/features/user/finding_raider/utils/ride_share_message_builder.dart';
import 'package:ZipBee/features/user/user_support/help_center/controller/create_dispute_controller.dart';
import 'package:ZipBee/features/user/user_support/help_center/widgets/create_dispute_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../../core/common/styles/global_text_style.dart';
import '../../../../../../core/common/widgets/custom_button.dart';
import '../../../../../../core/utils/constants/app_colors.dart';
import '../../../../finding_raider/screnn/review_view.dart';
import '../../../controller/order_controller.dart';
import '../../../model/order_model.dart';

class CompletedOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const CompletedOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Controller ইনিশিয়ালাইজেশন
    final OrderController controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());

    // এপিআই কল
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrderDetail(order.orderId);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isDetailLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final liveOrder = controller.singleOrder.value ?? order;

          return Column(
            children: [
              // --- header ---
              _buildHeader(liveOrder),

              // --- content ---
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Reusable: rider details
                        RiderDetailsCard(
                          order: liveOrder,
                          showFavoriteIcon: true,
                          isFavorite: liveOrder.isSavedRiderFavorite,
                          isFavoriteLoading:
                              controller.isFavoriteUpdating.value,
                          onFavoriteTap: () =>
                              controller.toggleSavedRiderFavorite(liveOrder),
                        ),

                        const SizedBox(height: 16),

                        // ✅ Reusable: Message and Call
                        MessageCallSection(order: liveOrder),

                        const SizedBox(height: 12),

                        // ✅ Reusable: Star Rating and Review
                        OrderRatingBar(
                          rating: liveOrder.assignRiderRating,
                          totalReviews: liveOrder.assignRiderReviews,
                          onTap: () {
                            Get.to(
                              () => ReviewView(
                                orderId: liveOrder.orderId,
                                riderId: liveOrder.riderId,
                              ),
                            );
                          },
                        ),

                        const Divider(height: 32),

                        // ✅ Reusable Payment and Time
                        PaymentAndTimeInfo(order: liveOrder),

                        const SizedBox(height: 24),

                        // ✅ Reusable: multiple stops
                        OrderStopsList(
                          pickupStops: controller.getPickupStops(liveOrder),
                          dropStops: controller.getDropStops(liveOrder),
                        ),

                        const SizedBox(height: 16),

                        // --- ৩. স্পেশাল পার্ট (Proof of Delivery) ---
                        _buildProofOfDelivery(liveOrder),

                        const SizedBox(height: 32),
                        // Spacer(),

                        // --- ৪. একশন বাটনস ---
                        CustomButton(
                          label: 'Share Ride Information',
                          onPressed: () async {
                            final shareMessage = RideShareMessageBuilder.build(
                              orderId: '#${liveOrder.orderId}',
                              assignedRiderId: (liveOrder.assignedRiderId ??
                                          liveOrder.riderId)
                                      ?.toString() ??
                                  'N/A',
                              riderName: liveOrder.assignRiderName.isNotEmpty
                                  ? liveOrder.assignRiderName
                                  : 'Not Assigned',
                              totalFare: liveOrder.total.toStringAsFixed(2),
                              paymentType:
                                  RideShareMessageBuilder.paymentMethodLabel(
                                liveOrder.paymentType,
                              ),
                              pickupStops: controller.getPickupStops(liveOrder),
                              dropStops: controller.getDropStops(liveOrder),
                              routeType: liveOrder.routeType,
                              scheduledDateTime: RideShareMessageBuilder
                                  .scheduledDateTimeLabel(
                                scheduledTime: liveOrder.scheduledTime,
                                fallbackCreatedAt: liveOrder.placedAt,
                              ),
                              jobAcceptedTime:
                                  RideShareMessageBuilder.formatDateTime(
                                liveOrder.updatedAt,
                              ),
                            );

                            await ShareRewardService.share();
                            await SharePlus.instance.share(
                              ShareParams(text: shareMessage),
                            );
                          },
                          color: AppColors.primaryButtonColor,
                          textColor: AppColors.fontColor,
                        ),
                        const SizedBox(height: 12),

                        // Rating & Review Button
                        if (!liveOrder.hasRiderRatings) ...[
                          CustomButton(
                            label: 'Rating & Review',
                            onPressed: () {
                              Get.to(
                                () => ReviewView(
                                  orderId: liveOrder.orderId,
                                  riderId: liveOrder.riderId,
                                  showRatingFormOnly: true,
                                ),
                              );
                            },
                            color: AppColors.primaryButtonColor,
                            textColor: AppColors.fontColor,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Header
  Widget _buildHeader(OrderModel liveOrder) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE0E0E0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Text(
                "Order #${liveOrder.orderId} is ${liveOrder.status.toLowerCase()}",
                style: getTextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  // Proof of Delivery
  Widget _buildProofOfDelivery(OrderModel liveOrder) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(
            '/ProofOfDeliveryScreen2',
            arguments: liveOrder.orderId,
          ),
          child: Row(
            children: [
              const Icon(Icons.image_outlined, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                "View Proof of Delivery",
                style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            if (Get.isRegistered<CreateDisputeController>()) {
              Get.delete<CreateDisputeController>(force: true);
            }

            await Get.to<bool>(
              () => CreateDisputeScreen(
                initialOrderId: liveOrder.orderId,
                lockOrderId: true,
              ),
            );
          },
          child: Text(
            'Report an Issue',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
