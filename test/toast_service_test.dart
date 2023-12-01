import 'package:flutter/material.dart';

import '../lib/custom_toast.dart';

class ToastServiceTest {
  static OverlayEntry? overlayEntry;
  static OverlayState? overlayState;
  static AnimationController? controller;

  static void _reverseAnimation() {
    controller?.reverse().then((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      overlayEntry?.remove();
      controller?.dispose();
    });
  }

  static void _forwardAnimation() {
    overlayState?.insert(overlayEntry!);
    controller?.forward();
  }

  static Future<void> showToast(BuildContext context, String message) async {
    if (context.mounted) {
      overlayState = Overlay.of(context);
      controller = AnimationController(
        vsync: overlayState!,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000),
      );
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 30.0,
          left: 0,
          right: 0,
          child: Dismissible(
            key: Key(message),
            direction: DismissDirection.down,
            onDismissed: (_) {
              _reverseAnimation();
            },
            child: CustomToast(
              message: message,
              controller: controller,
            ),
          ),
        ),
      );

      if (overlayEntry != null) {
        _forwardAnimation();
        await Future.delayed(const Duration(milliseconds: 3000));
        _reverseAnimation();
      }
    }
  }
}
