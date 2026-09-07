import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndPoint {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://api.zipbee.sg/api/v1';
  static String get socketUrl =>
      dotenv.env['SOCKET_URL'] ?? 'https://api.zipbee.sg';

  // Authentication endpoints
  static String get login => '$baseUrl/auth/login';
  static String get upload => '$baseUrl/auth/upload';
  static String get signUp => '$baseUrl/auth/signup';
  static String get verifyOtp => '$baseUrl/auth/verify';
  static String get forgetPass => '$baseUrl/auth/forgot-password';
  static String get logOut => '$baseUrl/auth/logout';
  static String get resetPass => '$baseUrl/auth/forgot/reset-password';
  static String get shareReward => '$baseUrl/auth/reward/share';
  static String get refreshToken => '$baseUrl/auth/refresh';

  // Notification endpoints
  static String get notificationID => '$baseUrl/notifications/{id}';
  static String get notification => '$baseUrl/notifications';
  static String deleteNotificationById(String id) =>
      '$baseUrl/notifications/admin/$id';
  static String notificationMarkAsRead(String Id) =>
      '$baseUrl/notifications/$Id/mark-read';
  static String get notificationCount => '$baseUrl/notifications/unread-count';
  static String get notificationFCM => '$baseUrl/notifications/fcm-token';

  static String get order => '$baseUrl/order/mine';
  static String get addRaider => '$baseUrl/my-raider';
  static String get getRaider => '$baseUrl/my-raider/my-raider';
  static String get deleteRaider => '$baseUrl/my-raider';

  // User Profile endpoints
  static String get profile => '$baseUrl/users/me';
  static String get updateProfile => '$baseUrl/users/{id}';
  static String get userProfile => '$baseUrl/users/{id}';

  static String get coinBasePrice => '$baseUrl/coin-management/base-price';
  static String get redeemCoin => '$baseUrl/coin-management/redeem-coin';
  static String coinAccHistory(String userId) =>
      '$baseUrl/coin-management/coin-acc-history/$userId';
  static String get referLoyalty => '$baseUrl/referloyality';
  static String get vehicleTypes => '$baseUrl/admin/vehicle-types';
  static String get serviceZone => '$baseUrl/service-zone';

  static String get support =>
      '$baseUrl/additional-services/service-email-number';
  static String get addRider => '$baseUrl/my-raider';
  static String get getDestination => '$baseUrl/destination';
  static String get homePageAd => '$baseUrl/advertise/role-based';
  static String get adImpression => '$baseUrl/advertise/{id}/impression';
  static String get adClick => '$baseUrl/advertise/{id}/click';
  static String get walletHistory =>
      '$baseUrl/wallet/user/walletHistory/{userId}';
  static String get createOrder => '$baseUrl/order/indivitual';

  // Canonical create order endpoint (public)
  static String get orderCreate => '$baseUrl/order';
  static String get orderUpdateDetails => '$baseUrl/order/{id}/update-details';
  static String get orderId => '$baseUrl/order/{id}';
  static String get discount => '$baseUrl/order/{order_id}/apply-discount';
  static String get orderEstimate => '$baseUrl/coin-management/redeem-coin';

  // Destination endpoints
  static String get createDestination => '$baseUrl/destination';
  static String get addDestinationToOrder =>
      '$baseUrl/order/{orderId}/destinations/add';
  static String destinationById(int id) => '$baseUrl/destination/$id';

  // Order GET endpoints
  static String get getOrder => '$baseUrl/order/{orderId}';
  static String get additionalService => '$baseUrl/additional-services';
  static String get additionOrder =>
      '$baseUrl/order/{order_id}/apply-addition/{serviceId}';
  static String get additionOrderD =>
      '$baseUrl/order/{order_id}/remove-addition/{serviceId}';
  static String get cancelOrder => '$baseUrl/order/{orderId}/cancel';
  static String get notifyOrder => '$baseUrl/order/{orderId}/notify-rider';
  static String get notifyFavoriteRider =>
      '$baseUrl/order/{orderId}/notify-fav-rider';
  static String get isFirstOrder => '$baseUrl/order/{orderId}/is-first-order';
  static String raiderConfirmation(String orderId) =>
      '$baseUrl/order/raider-confirmation/$orderId';
  static String userConfirmation(String orderId) =>
      '$baseUrl/order/user-confirmation/$orderId';

  static String get getUserProfile => '$baseUrl/users/me';
  static String get rating => '$baseUrl/ratings';
  static String get ratingId => '$baseUrl/ratings/{type}/{id}';
  static String get faq => '$baseUrl/faq';
  static String get tip => '$baseUrl/tips/{order_id}/tip';
  static String get faqRole => '$baseUrl/faq/faqs-by-role';

  // Help Center endpoints
  static String get aboutUs => '$baseUrl/aboutus';
  static String get helpArticles => '$baseUrl/article';
  static String get contentManagement => '$baseUrl/content-management';
  static String get disputes => '$baseUrl/disputes';
  static String disputesPaginated({required int page, required int limit}) =>
      '$baseUrl/disputes?page=$page&limit=$limit&participantType=user';
  static String disputesByUser(String userId) =>
      '$baseUrl/disputes?userId=$userId';

  // Order discount & promo endpoints
  static String get applyDiscount => '$baseUrl/order/{orderId}/apply-discount';
  static String removeDiscount({
    required int orderId,
    required String type,
  }) => '$baseUrl/order/$orderId/remove-discount?type=$type';
  static String get notifyRider => '$baseUrl/order/{orderId}/notify-rider';
  static String get followedRider =>
      '$baseUrl/order/followed-rider/order/{orderId}';

  // Stripe endpoints
  static String get stripeCredentials => '$baseUrl/stripe/credentials';
  static String get placeOrder => '$baseUrl/order/{orderId}/place';

  static String get addMoney => '$baseUrl/wallet/add-money/mobile';
  static String get addMoneyDirect => '$baseUrl/wallet/add-money';
  static String get confirmSetupIntent =>
      '$baseUrl/wallet/confirm-setup-intent';

  static String get createSetupIntent => '$baseUrl/wallet/create-setup-intent';

  static String get saveCard => '$baseUrl/wallet/save-card';
  static String get getSavedCard => "$baseUrl/wallet/get-saved-card";
  static String get walletCards => '$baseUrl/wallet/wallet/cards';
  static String walletCardById(int id) => '$baseUrl/wallet/wallet/cards/$id';

  //redeem-point
  static String get redeemPoint => '$baseUrl/referloyality/redeem-point';
  //make favorite
  static String get makeFavorite => '$baseUrl/my-raider/makefav/{id}';
  static String get impression => '$baseUrl/advertise/{id}/impression';
  //
  static String get supportChat => '$baseUrl/users/admin';
  static String get chatHistory => '$baseUrl/chat/messages';
  static String chatMarkAsRead(String conversationId) =>
      '$baseUrl/chat/read/$conversationId';

  // Delivery types
  static String get deliveryTypes => '$baseUrl/delivery-types?is_active=true';
  static String get supportContact =>
      '$baseUrl/additional-services/service-email-number';
}
