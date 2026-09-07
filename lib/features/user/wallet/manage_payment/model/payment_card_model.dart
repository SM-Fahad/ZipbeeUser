class PaymentCardModel {
  final int id;
  final String stripeMethodId;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  PaymentCardModel({
    required this.id,
    required this.stripeMethodId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      stripeMethodId: json['stripeMethodId']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      last4: json['last4']?.toString() ?? '',
      expMonth: json['exp_month'] is int
          ? json['exp_month']
          : int.tryParse('${json['exp_month']}') ?? 0,
      expYear: json['exp_year'] is int
          ? json['exp_year']
          : int.tryParse('${json['exp_year']}') ?? 0,
      isDefault: json['isDefault'] == true,
    );
  }

  String get brandLabel {
    if (brand.isEmpty) return 'Card';
    return brand[0].toUpperCase() + brand.substring(1).toLowerCase();
  }

  String get expiryLabel {
    final month = expMonth.toString().padLeft(2, '0');
    return '$month/$expYear';
  }
}
