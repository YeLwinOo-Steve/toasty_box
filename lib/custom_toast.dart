import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String? message;
  final Widget? child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final AnimationController? controller;
  final bool isInFront;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final Curve? curve;
  const CustomToast({
    super.key,
    this.isInFront = false,
    required this.onTap,
    this.onClose,
    this.message,
    this.child,
    this.backgroundColor,
    this.shadowColor,
    required this.controller,
    this.curve,
  }) : assert((message != null || message != '') || child != null);

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
                  curve: widget.curve ?? Curves.elasticOut,
                  reverseCurve: widget.curve ?? Curves.elasticOut,
                ),
              ),
              child: Stack(
                children: [
                  InkWell(
                    onTap: widget.onTap,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: widget.backgroundColor ?? Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: widget.isInFront ? 0.5 : 0.0,
                            offset: const Offset(0.0, -1.0),
                            color: widget.shadowColor ?? Colors.grey.shade400,
                          ),
                          BoxShadow(
                            blurRadius: widget.isInFront ? 12 : 3,
                            offset: const Offset(0.0, 7.0),
                            color: widget.shadowColor ?? Colors.grey.shade400,
                          ),
                        ],
                      ),
                      child: widget.message == null
                          ? widget.child
                          : Text(
                              widget.message!,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 16,
                    bottom: 0,
                    child: InkWell(
                      onTap: widget.onClose,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
