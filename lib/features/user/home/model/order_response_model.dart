class OrderResponseModel {
  final bool? success;
  final String? message;
  final OrderData? data;

  OrderResponseModel({this.success, this.message, this.data});

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? "Something went wrong",
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }
}

class OrderData {
  final int? id;
  final String? deliveryType;
  final Map<String, dynamic>? rawJson;

  OrderData({this.id, this.deliveryType, this.rawJson});

  factory OrderData.fromJson(Map<String, dynamic> json) {
    final rawDeliveryType = json['delivery_type'];

    return OrderData(
      id: json['id'],
      deliveryType: rawDeliveryType is Map<String, dynamic>
          ? rawDeliveryType['name']?.toString()
          : rawDeliveryType?.toString(),
      rawJson: json,
    );
  }
}
