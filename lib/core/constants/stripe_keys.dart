import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stripe API Keys Configuration
/// Secure key storage for Stripe payment processing
class StripeKeys {
  // Stripe Secret Key (Backend use only)
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  // Stripe Public Key (Client side)
  static String get stripePublicKey => dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';

  // Merchant display name
  static String get merchantDisplayName =>
      dotenv.env['STRIPE_MERCHANT_DISPLAY_NAME'] ?? 'ZipBee Delivery';

  /// Validate keys are properly configured
  static bool isConfigured() {
    return stripeSecretKey.isNotEmpty &&
        stripePublicKey.isNotEmpty &&
        stripePublicKey.startsWith('pk_');
  }
}
