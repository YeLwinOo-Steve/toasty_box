import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_toast.dart';

class ToastService {
  static List<OverlayEntry?> overlayEntries = [];
  static final List<double> _overlayPositions = [];
  static List<AnimationController?> controllers = [];
  static final Set<int> _disposedControllerIndexList = {};
  static OverlayState? overlayState;

  static void _reverseAnimation(int index) {
    if (!_disposedControllerIndexList.contains(index)) {
      controllers[index]?.reverse().then((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        _removeOverlayEntry(index);
      });
    }
  }

  static void _removeOverlayEntry(int index) {
    overlayEntries[index]?.remove();
    controllers[index]?.dispose();
    _disposedControllerIndexList.add(index);
  }

  static void _forwardAnimation(int index) {
    overlayState?.insert(overlayEntries[index]!);
    controllers[index]?.forward();
  }

  static double _calculatePosition(int index) {
    return _overlayPositions[index];
  }

  static void _addOverlayPosition(int index) {
    _overlayPositions.add(30);
  }

  static bool _isToastInFront(int index) =>
      index > _overlayPositions.length - 6;
  static void _updateOverlayPositions({bool isReverse = false}) {
    for (int i = 0; i < _overlayPositions.length; i++) {
      if (_isToastInFront(i)) {
        _overlayPositions[i] =
            isReverse ? _overlayPositions[i] - 14 : _overlayPositions[i] + 14;
        overlayEntries[i]?.markNeedsBuild();
      }
    }
  }

  static Future<void> showToast(BuildContext context, String message) async {
    if (context.mounted) {
      overlayState = Overlay.of(context);
      final controller = AnimationController(
        vsync: overlayState!,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000),
      );
      controllers.add(controller);
      int controllerIndex = controllers.indexOf(controller);
      _addOverlayPosition(controllerIndex);
      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedPositioned(
          bottom: _calculatePosition(controllerIndex),
          left: 5,
          right: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceOut,
          child: Dismissible(
            key: Key(message),
            direction: DismissDirection.down,
            onDismissed: (_) {
              _removeOverlayEntry(controllers.indexOf(controller));
              _updateOverlayPositions(isReverse: true);
            },
            child: AnimatedPadding(
              padding: EdgeInsets.symmetric(
                horizontal: max(_calculatePosition(controllerIndex) - 35, 0.0),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceOut,
              child: CustomToast(
                message: message,
                isInFront: _isToastInFront(controllers.indexOf(controller)),
                controller: controller,
              ),
            ),
          ),
        ),
      );
      overlayEntries.add(overlayEntry);
      _updateOverlayPositions();
      _forwardAnimation(controllers.indexOf(controller));
      await Future.delayed(const Duration(seconds: 6));
      _reverseAnimation(controllers.indexOf(controller));
    }
  }
}
