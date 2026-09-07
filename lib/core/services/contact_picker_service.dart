import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class PickedPhoneContactData {
  const PickedPhoneContactData({
    required this.name,
    required this.phoneNumber,
  });

  final String name;
  final String phoneNumber;
}

class ContactPickerService {
  static final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  static Future<PickedPhoneContactData?> pickPhoneContact() async {
    try {
      final contact = await _contactPicker.selectPhoneNumber();
      if (contact == null) return null;

      final name = (contact.fullName ?? '').trim();
      final phoneNumber = _normalizePhoneNumber(
        contact.selectedPhoneNumber ??
            (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty
                ? contact.phoneNumbers!.first
                : null),
      );

      if (phoneNumber.isEmpty) {
        EasyLoading.showError('Selected contact has no phone number.');
        return null;
      }

      return PickedPhoneContactData(name: name, phoneNumber: phoneNumber);
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('cancel')) {
        return null;
      }

      debugPrint('ContactPickerService.pickPhoneContact error: $e');
      EasyLoading.showError('Could not load contact.');
      return null;
    }
  }

  static String _normalizePhoneNumber(String? rawPhoneNumber) {
    if (rawPhoneNumber == null) return '';

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
