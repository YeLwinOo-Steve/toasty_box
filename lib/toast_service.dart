import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final AnimationController? controller;
  const CustomToast({
    super.key,
    required this.message,
    required this.controller,
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.controller!,
        builder: (context, _) {
          return Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: const Offset(0.0, 0.0),
              ).animate(
                CurvedAnimation(
                  parent: widget.controller!,
                  curve: Curves.bounceInOut,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                color: Colors.black,
                child: Text(
                  widget.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        });
  }
}

class ToastService {
  static OverlayEntry? overlayEntry;
  static OverlayState? overlayState;
  static AnimationController? controller;

  static void _reverseAnimation() {
    controller?.reverse().then((_) {
      overlayEntry?.remove();
      controller?.dispose();
    });
  }

  static void _forwardAnimation() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => overlayState?.insert(overlayEntry!));
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
