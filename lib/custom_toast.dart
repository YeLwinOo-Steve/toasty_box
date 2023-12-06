import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String? message;
  final TextStyle? messageStyle;
  final Widget? child;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? shadowColor;
  final AnimationController? controller;
  final bool isInFront;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final Curve? curve;
  final bool? isClosable;
  const CustomToast({
    super.key,
    this.isInFront = false,
    required this.onTap,
    this.onClose,
    this.message,
    this.messageStyle,
    this.leading,
    this.child,
    this.isClosable,
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
                    borderRadius: BorderRadius.circular(15),
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
                      child: (widget.child != null)
                          ? widget.child
                          : Row(
                              children: [
                                if (widget.leading != null) ...[
                                  widget.leading!,
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                                if (widget.message != null)
                                  Expanded(
                                    child: Text(
                                      widget.message!,
                                      style: widget.messageStyle,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  if (widget.isClosable ?? false)
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
