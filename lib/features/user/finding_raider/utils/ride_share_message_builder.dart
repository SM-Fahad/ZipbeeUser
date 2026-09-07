class RideShareMessageBuilder {
  static String build({
    required String orderId,
    required String assignedRiderId,
    required String riderName,
    required String totalFare,
    required String paymentType,
    required List<Map<String, String>> pickupStops,
    required List<Map<String, String>> dropStops,
    required String routeType,
    required String scheduledDateTime,
    required String jobAcceptedTime,
  }) {
    final pickup = pickupStops.isNotEmpty
        ? (pickupStops.first['address'] ?? 'N/A')
        : 'N/A';

    final dropLines = dropStops.isNotEmpty
        ? dropStops
              .asMap()
              .entries
              .map(
                (entry) =>
                    'Stop ${entry.key + 1}: ${entry.value['address'] ?? 'N/A'}',
              )
              .join('\n')
        : 'Stop 1: N/A';

    final shouldShowReturn =
        routeType.toUpperCase() == 'ROUND' && pickupStops.isNotEmpty;
    final returnLine = shouldShowReturn ? '\nReturn: $pickup' : '';

    return '''
Order ID: $orderId
Assigned Rider ID: $assignedRiderId
Rider Name: $riderName
Total Fare: \$$totalFare ($paymentType)
Pickup: $pickup
$dropLines$returnLine
Scheduled Date & Time: $scheduledDateTime
Job Accepted Time: $jobAcceptedTime
''';
  }

  static String paymentMethodLabel(String payType) {
    switch (payType.toUpperCase()) {
      case 'COD':
        return 'Cash on Delivery';
      case 'WALLET':
        return 'Wallet';
      case 'ONLINE_PAY':
        return 'Online Payment';
      default:
        return payType.isEmpty ? 'N/A' : payType;
    }
  }

  static String formatDateTime(String isoString) {
    if (isoString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(isoString);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      var hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      final hourString = hour12.toString().padLeft(2, '0');

      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} $hourString:$minute $period';
    } catch (_) {
      return isoString;
    }
  }

  static String scheduledDateTimeLabel({
    required String scheduledTime,
    required String fallbackCreatedAt,
  }) {
    if (scheduledTime.isEmpty) {
      return fallbackCreatedAt.isEmpty
          ? 'ASAP'
          : formatDateTime(fallbackCreatedAt);
    }

    final normalized = scheduledTime.trim().toUpperCase();
    if (normalized == 'ASAP' || normalized == 'PICK-UP ASAP') {
      return 'ASAP';
    }

    return formatDateTime(scheduledTime);
  }
}
