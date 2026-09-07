import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:ZipBee/features/user/home/service/ads_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'ad_dialogue.dart';

class SmallHorizontalSlider extends StatefulWidget {
  const SmallHorizontalSlider({
    super.key,
    required this.width,
    required this.ads,
  });

  final double width;
  final List<Map<String, dynamic>> ads;

  @override
  State<SmallHorizontalSlider> createState() => _SmallHorizontalSliderState();
}

class _SmallHorizontalSliderState extends State<SmallHorizontalSlider> {
  final Set<int> _recordedAdIds = {};

  @override
  void initState() {
    super.initState();
    _recordImpressionForIndex(0);
  }

  @override
  void didUpdateWidget(covariant SmallHorizontalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads) {
      _recordedAdIds.clear();
      _recordImpressionForIndex(0);
    }
  }

  void _recordImpressionForIndex(int index) {
    if (widget.ads.isEmpty || index < 0 || index >= widget.ads.length) return;

    final ad = widget.ads[index];
    final rawId = ad['id'];
    final int? adId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (adId != null && !_recordedAdIds.contains(adId)) {
      _recordedAdIds.add(adId);
      AdsService.recordImpression(adId);
    }
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            "Find out more",
            style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 125,
          child: CarouselSlider.builder(
            itemCount: widget.ads.length,
            itemBuilder: (context, index, realIndex) {
              final ad = widget.ads[index];

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AdDetailsDialog(ad: ad),
                  );
                },
                child: Container(
                  width: widget.width,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE16B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ad['ad_title'] ?? 'Buy GPS',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ad['ad_image'] != null
                            ? Image.network(
                                ad['ad_image'],
                                height: 125,
                                // width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  IconPath.mappin,
                                  height: 70,
                                  width: 70,
                                ),
                              )
                            : Image.asset(
                                IconPath.mappin,
                                height: 70,
                                width: 70,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 125,
              viewportFraction: 1,
              enlargeCenterPage: false,
              autoPlay: widget.ads.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              enableInfiniteScroll: widget.ads.length > 1,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                _recordImpressionForIndex(index);
              },
            ),
          ),
        ),
      ],
    );
  }
}

