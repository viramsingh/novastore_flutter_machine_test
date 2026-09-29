import 'package:flutter_riverpod/flutter_riverpod.dart';

class DockNavigationState {
  final int selectedIndex;
  final int? bouncingIndex;

  const DockNavigationState({
    this.selectedIndex = 0,
    this.bouncingIndex,
  });

  DockNavigationState copyWith({
    int? selectedIndex,
    int? bouncingIndex,
    bool clearBouncing = false,
  }) {
    return DockNavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      bouncingIndex: clearBouncing ? null : (bouncingIndex ?? this.bouncingIndex),
    );
  }
}

class DockNavigationNotifier extends Notifier<DockNavigationState> {
  @override
  DockNavigationState build() {
    return const DockNavigationState(selectedIndex: 0);
  }

  void selectTab(int index) {
    state = state.copyWith(selectedIndex: index, bouncingIndex: index);
    // Auto reset bouncing after animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (state.bouncingIndex == index) {
        state = state.copyWith(clearBouncing: true);
      }
    });
  }

  void triggerBounce(int index) {
    state = state.copyWith(bouncingIndex: index);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (state.bouncingIndex == index) {
        state = state.copyWith(clearBouncing: true);
      }
    });
  }
}

final dockNavigationProvider =
    NotifierProvider<DockNavigationNotifier, DockNavigationState>(DockNavigationNotifier.new);
