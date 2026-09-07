import 'package:ZipBee/features/user/home/model/delivery_type_model.dart';

class DeliveryTypeIconHelper {
  /// Maps delivery type icon string or delivery type name to one of the 5 fixed IconPath assets:
  /// - `additional_package` -> IconPath.additional_package
  /// - `express_delivery` -> IconPath.express_delivery
  /// - `helper_team` -> IconPath.helper_team
  /// - `scheduled_delivery` -> IconPath.scheduled_delivery
  /// - `wallet_pricing` -> IconPath.wallet_pricing
  static String? getDeliveryTypeIconPath(
    String? iconName, {
    String? deliveryType,
    int? deliveryTypeId,
  }) {
    return DeliveryTypeModel.getDeliveryTypeIconPath(
      iconName,
      deliveryType: deliveryType,
      deliveryTypeId: deliveryTypeId,
    );
  }
}
