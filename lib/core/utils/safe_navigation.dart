import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fly/routes/app_routes.dart';

/// Pops the current route when the stack allows it; otherwise replaces the stack
/// with [fallbackRoute] (default [AppRoutes.Home]). Use for AppBar / toolbar
/// back when the screen may be root (e.g. after [Get.offAllNamed] from bottom nav).
void popOrGoHome(
  BuildContext context, {
  String fallbackRoute = AppRoutes.Home,
  Object? result,
}) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop(result);
    return;
  }
  Get.offAllNamed(fallbackRoute);
}

/// Wraps [child] so the system back gesture/button uses the same behavior as
/// [popOrGoHome] instead of leaving a black screen when there is nothing to pop.
class SafePopScope extends StatelessWidget {
  const SafePopScope({
    super.key,
    required this.child,
    this.fallbackRoute = AppRoutes.Home,
  });

  final Widget child;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        popOrGoHome(context, fallbackRoute: fallbackRoute);
      },
      child: child,
    );
  }
}
