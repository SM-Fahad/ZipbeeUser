import 'dart:async';

class DrawerModel {
  final String iconUrl;
  final String iconname;
  final FutureOr<void> Function() ontap;

  DrawerModel({
    required this.iconUrl,
    required this.iconname,
    required this.ontap,
  });
}
