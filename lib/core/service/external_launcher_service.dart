import 'package:url_launcher/url_launcher.dart';

class ExternalLauncherService {
  static Future<void> openDialer(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: _normalizePhoneNumber(phoneNumber),
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openSms(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: _normalizePhoneNumber(phoneNumber),
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String _normalizePhoneNumber(String rawPhoneNumber) {
    final trimmed = rawPhoneNumber.trim();
    if (trimmed.isEmpty) return '';

    final buffer = StringBuffer();
    for (var index = 0; index < trimmed.length; index++) {
      final char = trimmed[index];
      final isLeadingPlus = char == '+' && buffer.isEmpty;
      final isDigit = RegExp(r'\d').hasMatch(char);
      if (isLeadingPlus || isDigit) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}
