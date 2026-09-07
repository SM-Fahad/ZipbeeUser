import 'package:flutter/material.dart';

class PaymentOptionModel {
  final String title;
  final String subtitle;
  final String? assetPath;
  final IconData? icon;

  PaymentOptionModel({
    required this.title,
    required this.subtitle,
    this.assetPath,
    this.icon,
  });
}
