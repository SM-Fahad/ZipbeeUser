import 'package:ZipBee/features/user/home/model/delivery_type_model.dart';

class OrderModel {
  final String orderId;
  final String status;
  final String date;
  final String pickupAddress;
  final String senderName;
  final String recipientName;
  final String dropOffAddress;
  final String deliveryLocation;
  final String vehicleType;
  final double total;
  final bool showReceipt;
  final String assignRiderName;
  final String assignRiderPhone;
  final String assignRiderImage;
  final double assignRiderRating;
  final int assignRiderReviews;
  final int? riderId;
  final int? assignedRiderId;
  final int? assignRiderUserId;
  final String assignRiderRank;
  final int assignRiderCompletedTrips;
  final bool hasRiderRatings;
  final String scheduledTime;
  final String placedAt;
  final String createdAt;
  final String updatedAt;
  final String paymentType;
  final String routeType;
  final String deliveryTypeName;
  final String? deliveryTypeIcon;
  final String collectTime;
  final String collectUnit;
  final bool isPriorited;
  final double priorityFee;
  final int? savedRiderId;
  final bool isSavedRiderFavorite;
  final bool isAutoConfirmation;
  final bool raiderConfirmation;
  final String? userConfirmationAt;

  String? get deliveryTypeIconPath {
    return DeliveryTypeModel.getDeliveryTypeIconPath(
      deliveryTypeIcon,
      deliveryType: deliveryTypeName,
    );
  }

  final double? pickupLat;
  final double? pickupLong;
  final double? dropOffLat;
  final double? dropOffLong;

  final List? rawOrderStops;

  OrderModel({
    required this.orderId,
    required this.status,
    required this.date,
    required this.pickupAddress,
    required this.senderName,
    this.recipientName = "",
    required this.dropOffAddress,
    required this.deliveryLocation,
    required this.vehicleType,
    required this.total,
    required this.showReceipt,
    this.assignRiderName = "",
    this.assignRiderPhone = "",
    this.assignRiderImage = "",
    this.assignRiderRating = 0.0,
    this.assignRiderReviews = 0,
    this.riderId,
    this.assignedRiderId,
    this.assignRiderUserId,
    this.assignRiderRank = "",
    this.assignRiderCompletedTrips = 0,
    this.hasRiderRatings = false,
    required this.scheduledTime,
    this.placedAt = "",
    required this.createdAt,
    required this.updatedAt,
    required this.paymentType,
    required this.routeType,
    this.deliveryTypeName = "",
    this.deliveryTypeIcon,
    this.collectTime = "",
    this.collectUnit = "",
    this.isPriorited = false,
    this.priorityFee = 0.0,
    this.savedRiderId,
    this.isSavedRiderFavorite = false,
    this.isAutoConfirmation = false,
    this.raiderConfirmation = false,
    this.userConfirmationAt,
    this.pickupLat,
    this.pickupLong,
    this.dropOffLat,
    this.dropOffLong,
    this.rawOrderStops,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final collectTimeRaw = (json['collect_time'] ?? '').toString();
    final scheduledTimeRaw = (json['scheduled_time'] ?? '').toString();
    final orderStops = json['orderStops'] is List ? json['orderStops'] : [];

    // For date display
    String displayDate =
        collectTimeRaw == "ASAP" ? "Pick-up ASAP" : collectTimeRaw;
    if (collectTimeRaw == "SCHEDULED" &&
        scheduledTimeRaw != "null" &&
        scheduledTimeRaw.isNotEmpty) {
      displayDate = "Pick-up Scheduled";
    }

    Map<String, dynamic>? pickupStop;
    Map<String, dynamic>? dropStop;

    for (var stop in orderStops) {
      if (stop is Map<String, dynamic>) {
        if (stop['type'] == 'PICKUP') pickupStop = stop;
        if (stop['type'] == 'DROP') dropStop = stop;
      }
    }

    // Vehicle safe
    final vehicle = json['vehicle'];
    final vehicleMap = vehicle is Map<String, dynamic> ? vehicle : null;

    // Rider safe
    final rider = json['assign_rider'];
    final riderMap = rider is Map<String, dynamic> ? rider : null;

    final riderRegistrations =
        riderMap?['registrations'] is List ? riderMap!['registrations'] : [];
    final riderRatings =
        riderMap?['raider_ratings'] is List ? riderMap!['raider_ratings'] : [];
    final rateRider = json['rate_raiders'];
    final rateRiderMap = rateRider is Map<String, dynamic> ? rateRider : null;
    final savedRider = json['savedRider'];
    final savedRiderMap =
        savedRider is Map<String, dynamic> ? savedRider : null;

    final riderData =
        riderRegistrations.isNotEmpty ? riderRegistrations.first : null;

    final List<dynamic> driverPhotos = riderData is Map<String, dynamic>
        ? (riderData['driver_photos'] is List ? riderData['driver_photos'] : [])
        : [];
    final String riderImageFromOrder =
        driverPhotos.isNotEmpty ? (driverPhotos.last ?? '').toString() : '';

    final deliveryType = json['delivery_type'];
    final deliveryTypeMap =
        deliveryType is Map<String, dynamic> ? deliveryType : null;
    final dynamic vehicleTypeIdRaw = json['vehicle_type_id'];
    final int? vehicleTypeId = vehicleTypeIdRaw is int
        ? vehicleTypeIdRaw
        : int.tryParse(vehicleTypeIdRaw?.toString() ?? '');
    final List<dynamic> deliveryVehicleTypes =
        deliveryTypeMap?['vehicle_types'] is List
            ? deliveryTypeMap!['vehicle_types']
            : [];

    String resolvedVehicleName = '';
    for (final item in deliveryVehicleTypes) {
      if (item is! Map<String, dynamic>) continue;
      final currentVehicleTypeId = item['vehicle_type_id'] is int
          ? item['vehicle_type_id'] as int
          : int.tryParse(item['vehicle_type_id']?.toString() ?? '');

      if (currentVehicleTypeId == vehicleTypeId) {
        final vehicleType = item['vehicle_type'];
        if (vehicleType is Map<String, dynamic>) {
          resolvedVehicleName = (vehicleType['vehicle_name'] ?? '').toString();
        }
        break;
      }
    }

    final String placedAtRaw = (json['placed_at'] ?? '').toString();
    final String createdAtRaw = (json['created_at'] ?? '').toString();
    final String placedAtValue = placedAtRaw != 'null' && placedAtRaw.isNotEmpty
        ? placedAtRaw
        : createdAtRaw;

    final String timeValue = (json['scheduled_time'] != null &&
            json['scheduled_time'].toString() != "null")
        ? json['scheduled_time'].toString()
        : createdAtRaw;

    return OrderModel(
      orderId: (json['id'] ?? '').toString(),
      status: (json['order_status'] ?? json['status'] ?? '').toString(),
      date: displayDate,
      pickupAddress:
          (pickupStop?['address'] ?? json['pickup_address'] ?? "").toString(),
      senderName: (pickupStop?['destination']?['contact_name'] ??
              json['sender_name'] ??
              "")
          .toString(),
      recipientName: (dropStop?['destination']?['contact_name'] ??
              json['recipient_name'] ??
              "")
          .toString(),
      dropOffAddress:
          (dropStop?['address'] ?? json['drop_off_address'] ?? "").toString(),
      deliveryLocation: (json['delivery_location'] ?? "").toString(),
      vehicleType: resolvedVehicleName.isNotEmpty
          ? resolvedVehicleName
          : (vehicleMap?['vehicle_type'] ?? "").toString(),
      total: double.tryParse((json['total_cost'] ?? '0').toString()) ?? 0,
      showReceipt: (json['order_status'] ?? json['status'] ?? '').toString() ==
          "COMPLETED",
      riderId: json['assign_rider_id'] is int
          ? json['assign_rider_id']
          : int.tryParse((json['assign_rider_id'] ?? '').toString()),
      assignedRiderId: riderMap?['id'] is int
          ? riderMap!['id']
          : int.tryParse(riderMap?['id']?.toString() ?? ''),
      assignRiderRank: (riderMap?['tier']?['name'] ?? '').toString(),
      assignRiderCompletedTrips: riderMap?['completed_orders'] is int
          ? riderMap!['completed_orders'] as int
          : int.tryParse(riderMap?['completed_orders']?.toString() ?? '0') ?? 0,
      hasRiderRatings: (rateRiderMap != null && rateRiderMap.isNotEmpty) ||
          riderRatings.isNotEmpty,
      scheduledTime: timeValue,
      placedAt: placedAtValue,
      createdAt: createdAtRaw,
      updatedAt: (json['updated_at'] ?? '').toString(),
      paymentType: (json['pay_type'] ?? '').toString(),
      routeType: (json['route_type'] ?? '').toString(),
      deliveryTypeName: (deliveryTypeMap?['name'] ?? '').toString(),
      deliveryTypeIcon: (deliveryTypeMap?['icon'] ?? json['delivery_type_icon'] ?? json['icon'])?.toString(),
      collectTime: collectTimeRaw,
      collectUnit: (deliveryTypeMap?['collection_unit'] ?? '').toString(),
      priorityFee: (double.tryParse(
                json['priority_fee']?.toString() ??
                    (json['pricingSummary'] is Map
                        ? (json['pricingSummary'] as Map)['priorityFee']
                            ?.toString()
                        : null) ??
                    '0',
              ) ??
              0.0),
      isPriorited: json['isPriorited'] == true ||
          json['is_priorited'] == true ||
          json['isPriorited']?.toString() == 'true' ||
          json['is_priorited']?.toString() == 'true' ||
          (double.tryParse(
                    json['priority_fee']?.toString() ??
                        (json['pricingSummary'] is Map
                            ? (json['pricingSummary'] as Map)['priorityFee']
                                ?.toString()
                            : null) ??
                        '0',
                  ) ??
                  0.0) >
              0,
      savedRiderId: savedRiderMap?['id'] is int
          ? savedRiderMap!['id']
          : int.tryParse(savedRiderMap?['id']?.toString() ?? ''),
      isSavedRiderFavorite: savedRiderMap?['is_fav'] == true ||
          savedRiderMap?['is_fav']?.toString() == 'true',
      isAutoConfirmation: json['is_auto_confirmation'] == true ||
          json['is_auto_confirmation']?.toString() == 'true',
      raiderConfirmation: json['raider_confirmation'] == true ||
          json['raider_confirmation']?.toString() == 'true',
      userConfirmationAt: json['user_confirmation_at']?.toString() == 'null'
          ? null
          : json['user_confirmation_at']?.toString(),
      pickupLat: double.tryParse(
        pickupStop?['latitude']?.toString() ??
            json['pickup_lat']?.toString() ??
            '',
      ),
      pickupLong: double.tryParse(
        pickupStop?['longitude']?.toString() ??
            json['pickup_long']?.toString() ??
            '',
      ),
      dropOffLat: double.tryParse(
        dropStop?['latitude']?.toString() ??
            json['drop_off_lat']?.toString() ??
            '',
      ),
      dropOffLong: double.tryParse(
        dropStop?['longitude']?.toString() ??
            json['drop_off_long']?.toString() ??
            '',
      ),
      assignRiderName: (riderData?['raider_name'] ?? "").toString(),
      assignRiderPhone: (riderData?['contact_number'] ?? "").toString(),
      assignRiderImage: riderImageFromOrder,
      assignRiderRating:
          double.tryParse((json['formattedAverage'] ?? '0').toString()) ?? 0.0,
      assignRiderReviews:
          int.tryParse(riderMap?['reviews_count']?.toString() ?? '0') ?? 0,
      assignRiderUserId: riderMap?['userId'] is int
          ? riderMap!['userId']
          : int.tryParse(riderMap?['userId']?.toString() ?? ''),
      rawOrderStops: orderStops,
    );
  }

  OrderModel copyWith({
    String? assignRiderName,
    String? assignRiderPhone,
    String? assignRiderImage,
    double? assignRiderRating,
    int? assignRiderReviews,
    int? assignRiderUserId,
    String? assignRiderRank,
    int? assignRiderCompletedTrips,
    bool? hasRiderRatings,
    double? pickupLat,
    double? pickupLong,
    double? dropOffLat,
    double? dropOffLong,
    String? recipientName,
    List? rawOrderStops,
    String? deliveryTypeName,
    String? deliveryTypeIcon,
    String? collectTime,
    String? collectUnit,
    String? placedAt,
    bool? isPriorited,
    int? savedRiderId,
    bool? isSavedRiderFavorite,
    bool? isAutoConfirmation,
    bool? raiderConfirmation,
    String? userConfirmationAt,
  }) {
    return OrderModel(
      orderId: orderId,
      status: status,
      date: date,
      pickupAddress: pickupAddress,
      senderName: senderName,
      recipientName: recipientName ?? this.recipientName,
      dropOffAddress: dropOffAddress,
      deliveryLocation: deliveryLocation,
      vehicleType: vehicleType,
      total: total,
      showReceipt: showReceipt,
      assignRiderName: assignRiderName ?? this.assignRiderName,
      assignRiderPhone: assignRiderPhone ?? this.assignRiderPhone,
      assignRiderImage: assignRiderImage ?? this.assignRiderImage,
      assignRiderRating: assignRiderRating ?? this.assignRiderRating,
      assignRiderReviews: assignRiderReviews ?? this.assignRiderReviews,
      riderId: riderId,
      assignedRiderId: assignedRiderId,
      assignRiderUserId: assignRiderUserId ?? this.assignRiderUserId,
      assignRiderRank: assignRiderRank ?? this.assignRiderRank,
      assignRiderCompletedTrips:
          assignRiderCompletedTrips ?? this.assignRiderCompletedTrips,
      hasRiderRatings: hasRiderRatings ?? this.hasRiderRatings,
      scheduledTime: scheduledTime,
      placedAt: placedAt ?? this.placedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      paymentType: paymentType,
      routeType: routeType,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      deliveryTypeIcon: deliveryTypeIcon ?? this.deliveryTypeIcon,
      collectTime: collectTime ?? this.collectTime,
      collectUnit: collectUnit ?? this.collectUnit,
      isPriorited: isPriorited ?? this.isPriorited,
      savedRiderId: savedRiderId ?? this.savedRiderId,
      isSavedRiderFavorite: isSavedRiderFavorite ?? this.isSavedRiderFavorite,
      isAutoConfirmation: isAutoConfirmation ?? this.isAutoConfirmation,
      raiderConfirmation: raiderConfirmation ?? this.raiderConfirmation,
      userConfirmationAt: userConfirmationAt ?? this.userConfirmationAt,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLong: pickupLong ?? this.pickupLong,
      dropOffLat: dropOffLat ?? this.dropOffLat,
      dropOffLong: dropOffLong ?? this.dropOffLong,
      rawOrderStops: rawOrderStops ?? this.rawOrderStops,
    );
  }
}
