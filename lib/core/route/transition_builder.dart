import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Universal dark transition builder to prevent white flash during page transitions
/// This applies a consistent dark background to all screen transitions throughout the app
class DarkTransitionBuilder extends PageTransitionsBuilder {
  const DarkTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Wrap the transition with a dark background container
    return Container(
      color: const Color(0xFF0A0A0C), // Match app's dark theme
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Global CustomTransition for GetX to ensure all Get.to() calls use the dark background
class GlobalDarkTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Container(
      color: const Color(0xFF0A0A0C), // Match app's dark theme
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
