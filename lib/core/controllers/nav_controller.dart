import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Holds per-tab scroll controllers so the nav bar can scroll any tab to top
/// without navigating away.
class NavController extends GetxController {
  final Map<int, ScrollController> _scrollControllers = {};

  void register(int tabIndex, ScrollController controller) {
    _scrollControllers[tabIndex] = controller;
  }

  void unregister(int tabIndex) {
    _scrollControllers.remove(tabIndex);
  }

  void scrollToTop(int tabIndex) {
    final ctrl = _scrollControllers[tabIndex];
    if (ctrl != null && ctrl.hasClients) {
      ctrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
