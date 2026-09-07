import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/user_support/help_center/controller/dispute_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DisputeScreen extends StatelessWidget {
  const DisputeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DisputeController>()
        ? Get.find<DisputeController>()
        : Get.put(DisputeController());

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
          'Support & Dispute',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.disputes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDisputes,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!controller.isLoadingMore.value &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 120) {
                controller.loadMoreDisputes();
              }
              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: controller.openCreateDispute,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4C2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_task_outlined,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Report an Issue',
                                  style: getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryFontColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Report an issue with your order and upload proof if needed.',
                                  style: getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dispute History',
                                    style: getTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Track your previous dispute requests here.',
                                    style: getTextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4C2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${controller.totalCount.value}',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.disputes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE9E0BC)),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 42,
                                  color: Colors.black45,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No dispute history found',
                                  style: getTextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (controller.disputes.isNotEmpty)
                        ...List.generate(controller.disputes.length, (index) {
                          final dispute = controller.disputes[index];
                          return Column(
                            children: [
                              if (index != 0)
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _DisputeHistoryCard(dispute: dispute),
                              ),
                            ],
                          );
                        }),
                      if (controller.isLoadingMore.value)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _DisputeHistoryCard extends StatelessWidget {
  const _DisputeHistoryCard({required this.dispute});

  final Map<String, dynamic> dispute;

  @override
  Widget build(BuildContext context) {
    final disputeType = dispute['disputeType'] as Map<String, dynamic>? ?? {};
    final issueType = disputeType['name']?.toString() ?? 'Unknown';
    final status = dispute['status']?.toString() ?? 'UNKNOWN';
    final orderId = dispute['orderId']?.toString() ?? '-';
    final description = dispute['description']?.toString() ?? '';
    final createdAt = _formatDate(dispute['created_at']?.toString());
    final refundAmount = dispute['refundAmount']?.toString();
    final adminNote = dispute['adminNote']?.toString();
    final evidence = (dispute['evidence'] as List?)
            ?.map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList() ??
        <String>[];
    final shouldShowRefund = status.toUpperCase() == 'RESOLVED' &&
        refundAmount != null &&
        refundAmount.isNotEmpty;
    final hasAdminNote = adminNote != null && adminNote.trim().isNotEmpty;
    final shouldShowAdminNote = status.toUpperCase() != 'PENDING';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #$orderId',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryFontColor,
                  ),
                ),
              ),
              _StatusBadge(label: status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Issue', value: issueType),
          const SizedBox(height: 8),
          _InfoRow(label: 'Created', value: createdAt),
          if (shouldShowRefund) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Refund', value: '\$$refundAmount'),
          ],
          SizedBox(height: 8),
          _InfoRow(label: 'Description', value: description),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Proof',
              valueWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: evidence
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              _extractFileName(item),
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showImagePreview(context, item),
                              child: Text(
                                'Click to view',
                                style: getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (shouldShowAdminNote) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Admin Note',
              value: hasAdminNote ? adminNote.trim() : 'N/A',
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return value;
    }
  }

  String _extractFileName(String value) {
    final uri = Uri.tryParse(value);
    final segments = uri?.pathSegments ?? const <String>[];
    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }
    return value;
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 220,
                        alignment: Alignment.center,
                        child: Text(
                          'Unable to load image',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Get.back(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value = '', this.valueWidget});

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: valueWidget ??
              Text(
                value,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}
