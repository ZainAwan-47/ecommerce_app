import 'package:flutter/material.dart';
import 'tab_controller.dart';

final PageController appPageController = PageController();

final List<int> _tabHistory = [0];

Future<void> goToTab(int index) async {
  if (_tabHistory.isEmpty || _tabHistory.last != index) {
    _tabHistory.add(index);
  }

  selectedTab.value = index;

  await appPageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );
}

Future<void> goBackTab() async {
  if (_tabHistory.length <= 1) return;

  _tabHistory.removeLast();

  final previous = _tabHistory.last;

  selectedTab.value = previous;

  await appPageController.animateToPage(
    previous,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );
}