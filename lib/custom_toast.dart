import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final AnimationController? controller;
  final bool isInFront;
  const CustomToast({
    super.key,
    this.isInFront = false,
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
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.elasticOut,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: widget.isInFront ? 10 : 3,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                ),
              ),
            ),
          );
        });
  }
}
