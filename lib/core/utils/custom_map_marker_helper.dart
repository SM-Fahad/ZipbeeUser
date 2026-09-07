// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapMarkerHelper {
  // Color Palette matching map marker color guide reference
  static const Color bluePinColor = Color(0xFF0D5C9E);   // #0D5C9E (RGB 13, 92, 158) - Pickup
  static const Color greenPinColor = Color(0xFF37C759);  // #37C759 (RGB 55, 199, 89) - User / Device Location
  static const Color yellowPinColor = Color(0xFFFFCC00); // #FFCC00 (RGB 255, 204, 0) - Driver/Rider
  static const Color redPinColor = Color(0xFFFF3B30);    // #FF3B30 (RGB 255, 59, 48) - Drop / Stops

  /// Anchor point positioning the pin tip at Lat/Lng
  static const Offset defaultAnchor = Offset(0.5, 0.925);

  /// Cache for generated BitmapDescriptors
  static final Map<String, BitmapDescriptor> _iconCache = {};

  /// Clear marker cache
  static void clearCache() {
    _iconCache.clear();
  }

  /// BLUE Marker - Pickup Location (#0D5C9E)
  static Future<BitmapDescriptor> getPickupMarker({double size = 120.0}) async {
    final cacheKey = 'pickup_${size.toInt()}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }
    final icon = await createCustomMarker(
      pinColor: bluePinColor,
      size: size,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// GREEN Marker - User Device Location (#37C759)
  static Future<BitmapDescriptor> getDeviceLocationMarker({double size = 120.0}) async {
    final cacheKey = 'device_location_${size.toInt()}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }
    final icon = await createCustomMarker(
      pinColor: greenPinColor,
      size: size,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// YELLOW Marker - Driver / Rider Location (#FFCC00)
  static Future<BitmapDescriptor> getRiderMarker({double size = 120.0}) async {
    final cacheKey = 'rider_${size.toInt()}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }
    final icon = await createCustomMarker(
      pinColor: yellowPinColor,
      size: size,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// RED Marker - Single Drop Location (#FF3B30)
  static Future<BitmapDescriptor> getDropMarker({double size = 120.0}) async {
    final cacheKey = 'drop_${size.toInt()}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }
    final icon = await createCustomMarker(
      pinColor: redPinColor,
      size: size,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// RED 1, RED 2, RED N Marker - Multi-drop Stop Number (#FF3B30)
  static Future<BitmapDescriptor> getNumberedDropMarker({
    required int number,
    double size = 120.0,
  }) async {
    final cacheKey = 'numbered_${number}_${size.toInt()}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }
    final icon = await createCustomMarker(
      pinColor: redPinColor,
      number: number,
      size: size,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// Custom Marker canvas drawing method matching map marker reference design
  static Future<BitmapDescriptor> createCustomMarker({
    required Color pinColor,
    int? number,
    double size = 120.0,
  }) async {
    final double width = size;
    final double height = size * 1.333;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double cx = width / 2.0;
    final double cy = width * 0.40;
    final double outerRadius = width * 0.35;
    final double outerTipY = height - (width * 0.10);

    // 1. Drop Shadow under tip
    final Paint shadowOvalPaint = Paint()
      ..color = Colors.black.withOpacity(0.20)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, outerTipY + 2.0),
        width: width * 0.42,
        height: width * 0.15,
      ),
      shadowOvalPaint,
    );

    // 2. Outer White Border Teardrop Path
    final Path borderPath = Path();
    borderPath.moveTo(cx, outerTipY);
    borderPath.cubicTo(
      cx - outerRadius * 0.85, cy + outerRadius * 1.2,
      cx - outerRadius, cy + outerRadius * 0.4,
      cx - outerRadius, cy,
    );
    borderPath.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: outerRadius),
      math.pi,
      math.pi,
      false,
    );
    borderPath.cubicTo(
      cx + outerRadius, cy + outerRadius * 0.4,
      cx + outerRadius * 0.85, cy + outerRadius * 1.2,
      cx, outerTipY,
    );
    borderPath.close();

    final Paint whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(borderPath, whiteBorderPaint);

    // 3. Inner Colored Pin Teardrop Path
    final double innerRadius = width * 0.30;
    final double innerTipY = outerTipY - (width * 0.067);

    final Path pinPath = Path();
    pinPath.moveTo(cx, innerTipY);
    pinPath.cubicTo(
      cx - innerRadius * 0.85, cy + innerRadius * 1.2,
      cx - innerRadius, cy + innerRadius * 0.4,
      cx - innerRadius, cy,
    );
    pinPath.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: innerRadius),
      math.pi,
      math.pi,
      false,
    );
    pinPath.cubicTo(
      cx + innerRadius, cy + innerRadius * 0.4,
      cx + innerRadius * 0.85, cy + innerRadius * 1.2,
      cx, innerTipY,
    );
    pinPath.close();

    final Paint pinPaint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(pinPath, pinPaint);

    // 4. White Inner Circle
    final double whiteCircleRadius = width * 0.175;
    final Offset centerOffset = Offset(cx, cy);

    final Paint whiteCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(centerOffset, whiteCircleRadius, whiteCirclePaint);

    // 5. Inner Content (Number Text or Center Colored Dot)
    if (number != null) {
      final String text = number.toString();
      final double fontSize = width * 0.22;
      final TextPainter textPainter = TextPainter(
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: pinColor,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      );
      textPainter.layout();

      final double textX = centerOffset.dx - (textPainter.width / 2.0);
      final double textY = centerOffset.dy - (textPainter.height / 2.0);
      textPainter.paint(canvas, Offset(textX, textY));
    } else {
      final double centerDotRadius = whiteCircleRadius * 0.52;
      final Paint centerDotPaint = Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(centerOffset, centerDotRadius, centerDotPaint);
    }

    // Convert Canvas to BitmapDescriptor Image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8List);
  }
}
