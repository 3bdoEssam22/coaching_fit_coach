import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  static const double wideBreakpoint = 600.0;

  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;

  bool get hasWideLayout => screenWidth >= wideBreakpoint;

  double get horizontalPadding => (screenWidth * 0.05).clamp(16.0, 32.0);

  double get avatarRadius => (screenWidth * 0.13).clamp(40.0, 64.0);

  double get cardRadius => (screenWidth * 0.04).clamp(12.0, 20.0);

  double get buttonHeight => hasWideLayout ? 56.0 : 52.0;

  Widget content({required Widget child}) {
    if (hasWideLayout) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      );
    }
    return child;
  }

  static bool isWide(BoxConstraints constraints) =>
      constraints.maxWidth >= wideBreakpoint;
}
