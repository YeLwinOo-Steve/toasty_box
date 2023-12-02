import 'dart:math';

import 'package:flutter/material.dart';

import 'toast_enums.dart';
import 'custom_toast.dart';
import 'toast_manager.dart';

class ToastService {
  static final ToastViewManager<int> _expandedIndex = ToastViewManager<int>(-1);
  static final List<OverlayEntry?> _overlayEntries = [];
  static final List<double> _overlayPositions = [];
  static final List<AnimationController?> _animationControllers = [];
  static final Set<int> _disposedControllerIndexList = {};
  static OverlayState? _overlayState;

  static double? _expandedHeight;

  static set expandedHeight(double val) {
    if (val > 0.0) {
      _expandedHeight = val;
    }
  }

  static double get expandedHeight => (_expandedHeight ?? 100);

  static void _reverseAnimation(int index) {
    if (!_disposedControllerIndexList.contains(index)) {
      _animationControllers[index]?.reverse().then((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        _removeOverlayEntry(index);
      });
    }
  }

  static void _removeOverlayEntry(int index) {
    _overlayEntries[index]?.remove();
    _animationControllers[index]?.dispose();
    _disposedControllerIndexList.add(index);
  }

  static void _forwardAnimation(int index) {
    _overlayState?.insert(_overlayEntries[index]!);
    _animationControllers[index]?.forward();
  }

  static double _calculatePosition(int index) {
    return _overlayPositions[index];
  }

  static void _addOverlayPosition(int index, double? initialHeight) {
    _overlayPositions.add(initialHeight ?? 30);
  }

  static bool _isToastInFront(int index) =>
      index > _overlayPositions.length - 5;

  static void _updateOverlayPositions({bool isReverse = false, int pos = 0}) {
    if (isReverse) {
      _reverseUpdatePositions(pos: pos);
    } else {
      _forwardUpdatePositions();
    }
  }

  static void _rebuildPositions() {
    for (int i = 0; i < _overlayPositions.length; i++) {
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static void _reverseUpdatePositions({int pos = 0}) {
    for (int i = pos - 1; i >= 0; i--) {
      _overlayPositions[i] = _overlayPositions[i] - 10;
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static void _forwardUpdatePositions() {
    for (int i = 0; i < _overlayPositions.length; i++) {
      _overlayPositions[i] = _overlayPositions[i] + 10;
      _overlayEntries[i]?.markNeedsBuild();
    }
  }

  static double _calculateOpacity(int index) {
    // print(_disposedControllerIndexList);
    // print(_overlayPositions);
    return 1;
  }

  static void _toggleExpand(int index) {
    if (_expandedIndex.value == index) {
      _expandedIndex.value = -1;
    } else {
      _expandedIndex.value = index;
    }
    _rebuildPositions();
  }

  static Duration _toastDuration(ToastLength length) {
    switch (length) {
      case ToastLength.short:
        return const Duration(milliseconds: 2000);
      case ToastLength.medium:
        return const Duration(milliseconds: 3500);
      case ToastLength.long:
        return const Duration(milliseconds: 5000);
      default:
        return const Duration(minutes: 15);
    }
  }

  static Future<void> showToast(
    BuildContext context, {
    String? message,
    Widget? child,
    double? initialHeight,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.bounceOut,
    ToastLength duration = ToastLength.short,
  }) async {
    if (context.mounted) {
      _overlayState = Overlay.of(context);
      final controller = AnimationController(
        vsync: _overlayState!,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000),
      );
      _animationControllers.add(controller);
      int controllerIndex = _animationControllers.indexOf(controller);
      _addOverlayPosition(controllerIndex, initialHeight);
      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedPositioned(
          bottom: _calculatePosition(controllerIndex) +
              (_expandedIndex.value == controllerIndex ? expandedHeight : 0.0),
          left: 10,
          right: 10,
          duration: const Duration(milliseconds: 500),
          curve: positionCurve,
          child: Dismissible(
            key: Key(UniqueKey().toString()),
            direction: DismissDirection.down,
            onDismissed: (_) {
              _removeOverlayEntry(_animationControllers.indexOf(controller));
              _updateOverlayPositions(
                isReverse: true,
                pos: _animationControllers.indexOf(controller),
              );
            },
            child: AnimatedPadding(
              padding: EdgeInsets.symmetric(
                horizontal: (_expandedIndex.value == controllerIndex
                    ? 10
                    : max(_calculatePosition(controllerIndex) - 35, 0.0)),
              ),
              duration: const Duration(milliseconds: 500),
              curve: positionCurve,
              child: AnimatedOpacity(
                opacity: _calculateOpacity(controllerIndex),
                duration: const Duration(milliseconds: 500),
                child: CustomToast(
                  message: message,
                  backgroundColor: backgroundColor,
                  shadowColor: shadowColor,
                  curve: slideCurve,
                  isInFront: _isToastInFront(
                      _animationControllers.indexOf(controller)),
                  controller: controller,
                  onTap: () => _toggleExpand(controllerIndex),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
      _overlayEntries.add(overlayEntry);
      _updateOverlayPositions();
      _forwardAnimation(_animationControllers.indexOf(controller));
      await Future.delayed(_toastDuration(duration));
      _reverseAnimation(_animationControllers.indexOf(controller));
    }
  }
}
