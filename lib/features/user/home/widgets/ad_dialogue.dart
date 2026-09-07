import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/home/service/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> ad;

  const AdDetailsDialog({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final String title = ad['ad_title'] ?? '';
    final String image = ad['ad_image'] ?? '';
    final String link = ad['redirect_link'] ?? '';

    return Dialog(
      backgroundColor: AppColors.backgroungColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20,),
          /// ================= IMAGE =================
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    height: 220,
                    // width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 60),
                  ),
          ),

          const SizedBox(height: 20),

          /// ================= TITLE =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 24),

          /// ================= BUTTON =================
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final rawId = ad['id'];
                final int? adId =
                    rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
                if (adId != null) {
                  AdsService.recordClick(adId);
                }

                if (link.isNotEmpty) {
                  final formattedLink =
                      link.startsWith('http://') || link.startsWith('https://')
                          ? link
                          : 'https://$link';
                  final uri = Uri.parse(formattedLink);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: const Text(
                "Click Here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


