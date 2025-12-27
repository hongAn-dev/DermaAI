import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      // On web, use wider thresholds
      if (width >= 1100) return DeviceType.desktop;
      if (width >= 700) return DeviceType.tablet;
      return DeviceType.mobile;
    } else {
      // Mobile/desktop native thresholds
      if (width >= 1000) return DeviceType.desktop;
      if (width >= 600) return DeviceType.tablet;
      return DeviceType.mobile;
    }
  }

  static double scaleFactor(BuildContext context) {
    final device = deviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.12;
      case DeviceType.desktop:
        return 1.25;
    }
  }

  static double scale(BuildContext context, double value) =>
      value * scaleFactor(context);

  static double fontSize(BuildContext context, double base) =>
      base * scaleFactor(context);

  static double avatarRadius(BuildContext context, {double base = 30.0}) =>
      base * scaleFactor(context);

  static EdgeInsetsGeometry padding(BuildContext context,
          {double base = 16.0}) =>
      EdgeInsets.all(base * scaleFactor(context));
}
