import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool get isTablet => screenWidth >= 600;

  double get horizontalPadding => (screenWidth * 0.05).clamp(16.0, 32.0);

  double get avatarRadius => (screenWidth * 0.13).clamp(40.0, 64.0);

  double get cardRadius => (screenWidth * 0.04).clamp(12.0, 20.0);

  double get buttonHeight => (screenHeight * 0.07).clamp(48.0, 60.0);

  Widget content({required Widget child}) {
    if (isTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      );
    }
    return child;
  }
}
