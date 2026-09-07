import 'dart:math';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/home/service/dashboard_popup_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';



class PopupController extends GetxController with WidgetsBindingObserver {
  static bool _hasShownPopupThisSession = false;

  static void resetPopupState() {
    _hasShownPopupThisSession = false;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _hasShownPopupThisSession = false;
    } else if (state == AppLifecycleState.resumed) {
      final context = Get.context;
      if (context != null) {
        checkAndShowPopup(context);
      }
    }
  }

  Future<void> checkAndShowPopup(BuildContext context) async {
    if (_hasShownPopupThisSession || Get.isDialogOpen == true) return;

    final response = await DashboardPopupService.fetchPopups(
      activeOnly: true,
      limit: 1,
    );
    if (response['success'] == true &&
        response['data'] != null &&
        response['data'] is List) {
      List activePopups = (response['data'] as List)
          .where((p) => p['isActive'] == true)
          .toList();
      if (activePopups.isNotEmpty) {
        final selectedPopup =
            activePopups[Random().nextInt(activePopups.length)];
        _hasShownPopupThisSession = true;

        final rawId = selectedPopup['id'];
        if (rawId != null) {
          final int? popupId = int.tryParse(rawId.toString());
          if (popupId != null) {
            DashboardPopupService.markPopupAsSeen(popupId);
          }
        }

        if (!context.mounted) return;
        _showPopupDialog(context, selectedPopup);
      }
    }
  }

  void _showPopupDialog(BuildContext context, Map<String, dynamic> data) {
    final String? title = data['title'];
    final String? desc = data['desc'] ?? data['description'];
    final String? imageLink =
        data['image_link'] ?? data['image'] ?? data['ad_image'];
    final String? redirectLink = data['redirect_link'] ?? data['link'];

    final bool hasImage = imageLink != null && imageLink.toString().isNotEmpty;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Main Container with Yellow Border
            GestureDetector(
              onTap: () {
                Get.back();
                _launchURL(redirectLink);
              },
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 520,
                  maxWidth: 340,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD700), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(64),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Section
                        if (hasImage)
                          Image.network(
                            imageLink.toString(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              IconPath.gift_Ad,
                              fit: BoxFit.contain,
                              height: 140,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Image.asset(
                              IconPath.gift_Ad,
                              fit: BoxFit.contain,
                              height: 100,
                            ),
                          ),

                        // Text Section (Title & Description)
                        if ((title != null && title.trim().isNotEmpty) ||
                            (desc != null && desc.trim().isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (title != null && title.trim().isNotEmpty)
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (title != null &&
                                    title.trim().isNotEmpty &&
                                    desc != null &&
                                    desc.trim().isNotEmpty)
                                  const SizedBox(height: 8),
                                if (desc != null && desc.trim().isNotEmpty)
                                  Text(
                                    desc,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Right Close Button ('X')
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final formattedUrl = url.startsWith('http://') || url.startsWith('https://')
        ? url
        : 'https://$url';
    final Uri uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $url');
    }
  }
}


