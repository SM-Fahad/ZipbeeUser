import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/common/widgets/custom_app_bar_user.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/notification/controller/user_notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class UserNotification extends StatelessWidget {
  const UserNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserNotificationController());

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      body: Column(
        children: [
          CustomAppBarUser(title: "Notifications", style: getTextStyle()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Obx(
                () => Column(
                  children: [
                    /// ------------------- Tabs -------------------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          controller.notificationTabs.length,
                          (index) {
                            final isSelected =
                                controller.selectNotificationListIndex.value ==
                                index;

                            return GestureDetector(
                              onTap: () => controller.changeTab(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.subtitleFontColor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: isSelected
                                      ? AppColors.onboardingIndicatorActive
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  controller.notificationTabs[index],
                                  style: getTextStyle(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ------------------- Notification List -------------------
                    Expanded(
                      child:
                          controller.isLoading.value &&
                              controller.notificationList.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : controller.notificationList.isEmpty
                          ? Center(
                              child: Text(
                                "No ${controller.notificationTabs[controller.selectNotificationListIndex.value]} Found",
                                style: getTextStyle(
                                  color: AppColors.subtitleFontColor,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => controller.fetchNotifications(),
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollInfo) {
                                  if (!controller.isLoading.value &&
                                      scrollInfo.metrics.pixels >=
                                          scrollInfo.metrics.maxScrollExtent -
                                              80) {
                                    controller.fetchNotifications(
                                      loadMore: true,
                                    );
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount:
                                      controller.notificationList.length +
                                      (controller.isLoading.value &&
                                              controller
                                                  .notificationList
                                                  .isNotEmpty
                                          ? 1
                                          : 0),
                                  itemBuilder: (_, index) {
                                    if (index >=
                                        controller.notificationList.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final item =
                                        controller.notificationList[index];
                                    final isRead = item.isRead;
                                    final borderColor = isRead
                                        ? Colors.transparent
                                        : AppColors.onboardingIndicatorActive;
                                    final titleColor = isRead
                                        ? AppColors.subtitleFontColor
                                        : Colors.black87;
                                    final subtitleColor = isRead
                                        ? Colors.grey
                                        : const Color(0xFF6B6B6B);
                                    final cardColor = isRead
                                        ? const Color(0xFFF3F3F3)
                                        : Colors.white;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: Slidable(
                                        key: ValueKey(item.id),
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          extentRatio: 0.25,
                                          children: [
                                            CustomSlidableAction(
                                              onPressed: (_) {
                                                controller.confirmDelete(
                                                  item.id,
                                                );
                                              },
                                              backgroundColor:
                                                  AppColors.backgroungColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.delete_forever_outlined,
                                                  size: 32,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          onTap: () => controller
                                              .onNotificationTap(item),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: cardColor,
                                              border: Border.all(
                                                color: borderColor,
                                                width: isRead ? 0 : 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 12,
                                                      color: isRead
                                                          ? Colors.grey
                                                          : AppColors
                                                                .onboardingIndicatorActive,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        item.title,
                                                        style: getTextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: titleColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // if (item
                                                //     .imageUrl
                                                //     .isNotEmpty) ...[
                                                //   const SizedBox(height: 12),
                                                //   ClipRRect(
                                                //     borderRadius:
                                                //         BorderRadius.circular(
                                                //           8,
                                                //         ),
                                                //     child: Image.network(
                                                //       item.imageUrl,
                                                //       height: 140,
                                                //       width: double.infinity,
                                                //       fit: BoxFit.cover,
                                                //       loadingBuilder:
                                                //           (
                                                //             context,
                                                //             child,
                                                //             loadingProgress,
                                                //           ) {
                                                //             if (loadingProgress ==
                                                //                 null) {
                                                //               return child;
                                                //             }

                                                //             return Container(
                                                //               height: 140,
                                                //               width: double
                                                //                   .infinity,
                                                //               color:
                                                //                   const Color(
                                                //                     0xFFF3F3F3,
                                                //                   ),
                                                //               alignment:
                                                //                   Alignment
                                                //                       .center,
                                                //               child:
                                                //                   const CircularProgressIndicator(),
                                                //             );
                                                //           },
                                                //       errorBuilder:
                                                //           (
                                                //             context,
                                                //             error,
                                                //             stackTrace,
                                                //           ) => Container(
                                                //             height: 140,
                                                //             width:
                                                //                 double.infinity,
                                                //             color: const Color(
                                                //               0xFFF3F3F3,
                                                //             ),
                                                //             alignment: Alignment
                                                //                 .center,
                                                //             child: Column(
                                                //               mainAxisAlignment:
                                                //                   MainAxisAlignment
                                                //                       .center,
                                                //               children: [
                                                //                 Icon(
                                                //                   Icons
                                                //                       .image_not_supported_outlined,
                                                //                   color: Colors
                                                //                       .grey
                                                //                       .shade600,
                                                //                   size: 30,
                                                //                 ),
                                                //                 const SizedBox(
                                                //                   height: 8,
                                                //                 ),
                                                //                 Text(
                                                //                   'Image not available',
                                                //                   style: getTextStyle(
                                                //                     fontSize:
                                                //                         12,
                                                //                     color: AppColors
                                                //                         .subtitleFontColor,
                                                //                   ),
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //     ),
                                                //   ),
                                                // ],
                                                // const SizedBox(height: 12),
                                                Text(
                                                  item.subTitle,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: getTextStyle(
                                                    fontSize: 12,
                                                    color: subtitleColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.date,
                                                      style: getTextStyle(
                                                        fontSize: 12,
                                                        color: subtitleColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      item.time,
                                                      style: getTextStyle(
                                                        fontSize: 12,
                                                        color: subtitleColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
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
