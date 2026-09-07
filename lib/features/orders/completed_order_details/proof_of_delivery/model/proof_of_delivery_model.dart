class ProofOfDeliveryModel {
  final String trackingNumber;
  final String deliveredAt;
  final String location;
  final List<String> proofImages;

  ProofOfDeliveryModel({
    required this.trackingNumber,
    required this.deliveredAt,
    required this.location,
    required this.proofImages,
  });

  factory ProofOfDeliveryModel.fromJson(Map<String, dynamic> json) {
    final List stops = json['orderStops'] ?? [];

    final List<String> images = [];
    for (final stop in stops) {
      if (stop['proofs'] != null) {
        images.addAll(List<String>.from(stop['proofs']));
      }
    }

    return ProofOfDeliveryModel(
      trackingNumber: "SPXSG${json['id']}",
      deliveredAt: json['updated_at'] ?? '',
      location: stops.isNotEmpty ? stops.first['address'] : '',
      proofImages: images,
    );
  }
}
