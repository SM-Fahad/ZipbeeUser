import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresetAmountsCacheService {
  static const String _cacheKey = 'preset_amounts_cache';

  static Future<List<double>> getCachedAmounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);

      if (cached == null || cached.isEmpty) {
        return [10, 20, 40, 100];
      }

      final amounts = cached
          .split(',')
          .map((e) => double.tryParse(e) ?? 0)
          .where((e) => e > 0)
          .toList();

      return amounts.length > 4
          ? amounts.sublist(amounts.length - 4)
          : amounts;
    } catch (e) {
      return [10, 20, 40, 100];
    }
  }

  static Future<void> addAmount(double amount) async {
    try {
      if (amount <= 0) return;

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);

      List<double> amounts = [];

      if (cached != null && cached.isNotEmpty) {
        amounts = cached
            .split(',')
            .map((e) => double.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toList();
      }

      amounts.removeWhere((a) => a == amount);
      amounts.add(amount);

      if (amounts.length > 4) {
        amounts = amounts.sublist(amounts.length - 4);
      }

      await prefs.setString(_cacheKey, amounts.join(','));
    } catch (e) {
      debugPrint("Cache Error: $e");
    }
  }
}
