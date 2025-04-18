import 'dart:math';

import 'package:flutter/material.dart';

import 'toast_enums.dart';
import 'custom_toast.dart';
import 'toast_manager.dart';

class ToastService {
  static final ToastViewManager<int> _expandedIndex = ToastViewManager<int>(-1);
  static final List<OverlayEntry?> _overlayEntries = [];
  static final List<double> _overlayPositions = [];
  static final List<int> _overlayIndexList = [];
  static final List<AnimationController?> _animationControllers = [];
  static OverlayState? _overlayState;

  static int? _showToastNumber;
  static double _paddingTop = 0;

  static final _cache = <dynamic, AnimationController>{};

  static void showToastNumber(int val) {
    assert(val > 0,
        "Show toast number can't be negative or zero. Default show toast number is 5.");
    if (val > 0) {
      _showToastNumber = val;
    }
  }

  static Future _reverseAnimation(int index,
      {bool isRemoveOverlay = true}) async {
    if (_overlayIndexList.contains(index)) {
      await _animationControllers[index]?.reverse();
      await Future.delayed(const Duration(milliseconds: 50));
      if (isRemoveOverlay) {
        _removeOverlayEntry(index);
      }
      _cache.removeWhere((_, value) => value == _animationControllers[index]);
    }
  }

  static void _removeOverlayEntry(int index) {
    _overlayEntries[index]?.remove();
    _animationControllers[index]?.dispose();
    _overlayIndexList.remove(index);
  }

  static void _forwardAnimation(int index) {
    _overlayState?.insert(_overlayEntries[index]!);
    _animationControllers[index]?.forward();
  }

  static double _calculatePosition(int index) {
    return _overlayPositions[index];
  }

  static void _addOverlayPosition(int index) {
    _overlayPositions.add(30);
    _overlayIndexList.add(index);
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
    int noOfShowToast = _showToastNumber ?? 5;
    if (_overlayIndexList.length <= noOfShowToast) return 1;
    final isFirstFiveToast = _overlayIndexList
        .sublist(_overlayIndexList.length - noOfShowToast)
        .contains(index);
    return isFirstFiveToast ? 1 : 0;
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
      case ToastLength.ages:
        return const Duration(minutes: 2);
      default:
        return const Duration(hours: 24);
    }
  }

  static Future<void> _showToast(
    BuildContext context, {
    dynamic tag,
    String? message,
    TextStyle? messageStyle,
    Widget? leading,
    Widget? child,
    bool isClosable = false,
    bool isAutoDismiss = true,
    bool isTop = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    assert(expandedHeight >= 0.0,
        "Expanded height should not be a negative number!");
    if (context.mounted) {
      if (_paddingTop == 0) {
        _paddingTop = MediaQuery.of(context).padding.top;
      }
      _overlayState = Overlay.of(context);
      final controller = AnimationController(
        vsync: _overlayState!,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000),
      );
      _animationControllers.add(controller);
      int controllerIndex = _animationControllers.indexOf(controller);
      _addOverlayPosition(controllerIndex);
      final overlayEntry = OverlayEntry(
        builder: (context) {
          final position = _calculatePosition(controllerIndex) +
              (_expandedIndex.value == controllerIndex
                  ? expandedHeight
                  : 0.0);
          return AnimatedPositioned(
            top: isTop
                ? _paddingTop -position
                : null,
            bottom: isTop
                ? null
                : position,
            left: 10,
            right: 10,
            duration: const Duration(milliseconds: 500),
            curve: positionCurve,
            child: Dismissible(
              key: Key(UniqueKey().toString()),
              direction: dismissDirection,
              onDismissed: (_) {
                _close(controller);
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
                    messageStyle: messageStyle,
                    backgroundColor: backgroundColor,
                    shadowColor: shadowColor,
                    iconColor: iconColor,
                    curve: slideCurve,
                    isClosable: isClosable,
                    isTop: isTop,
                    isInFront: _isToastInFront(
                        _animationControllers.indexOf(controller)),
                    controller: controller,
                    onTap: () => _toggleExpand(controllerIndex),
                    onClose: () {
                      _close(controller);
                    },
                    leading: leading,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      );
      _overlayEntries.add(overlayEntry);
      _updateOverlayPositions();
      _forwardAnimation(_animationControllers.indexOf(controller));
      _cache.putIfAbsent(tag, () => controller);
      if (isAutoDismiss) {
        await Future.delayed(_toastDuration(length));
        await _reverseAnimation(_animationControllers.indexOf(controller),
            isRemoveOverlay: false);
        _close(controller);
      }
    }
  }

  static void _close(AnimationController controller) {
    _removeOverlayEntry(_animationControllers.indexOf(controller));
    _updateOverlayPositions(
      isReverse: true,
      pos: _animationControllers.indexOf(controller),
    );
    _cache.removeWhere((_, value) => value == controller);
  }

  static Future<void> showToast(
    BuildContext context, {
    dynamic tag,
    String? message,
    TextStyle? messageStyle,
    Widget? leading,
    bool isClosable = false,
    bool isAutoDismiss = true,
    bool isTop = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    _showToast(
      context,
      tag: tag,
      message: message,
      messageStyle: messageStyle,
      isTop: isTop,
      isClosable: isClosable,
      isAutoDismiss: isAutoDismiss,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      iconColor: iconColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: leading,
    );
  }

  static Future<void> showWidgetToast(
    BuildContext context, {
    dynamic tag,
    Widget? child,
    bool isTop = false,
    bool isClosable = false,
    bool isAutoDismiss = true,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    _showToast(
      context,
      tag: tag,
      isTop: isTop,
      isClosable: isClosable,
      isAutoDismiss: isAutoDismiss,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      iconColor: iconColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      child: child,
    );
  }

  static Future<void> showSuccessToast(
    BuildContext context, {
    dynamic tag,
    String? message,
    Widget? child,
    Widget? leading,
    bool isClosable = false,
    bool isAutoDismiss = true,
    bool isTop = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    _showToast(
      context,
      tag: tag,
      message: message,
      messageStyle: const TextStyle(
        color: Colors.white,
      ),
      isTop: isTop,
      isClosable: isClosable,
      isAutoDismiss: isAutoDismiss,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? Colors.green,
      shadowColor: shadowColor ?? Colors.green.shade500,
      iconColor: iconColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: leading ??
          const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
      child: child,
    );
  }

  static Future<void> showErrorToast(
    BuildContext context, {
    dynamic tag,
    String? message,
    Widget? child,
    bool isClosable = false,
    bool isAutoDismiss = true,
    bool isTop = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    _showToast(
      context,
      tag: tag,
      message: message,
      messageStyle: const TextStyle(
        color: Colors.white,
      ),
      isTop: isTop,
      isClosable: isClosable,
      isAutoDismiss: isAutoDismiss,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? Colors.red,
      shadowColor: shadowColor ?? Colors.red.shade500,
      iconColor: iconColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: const Icon(
        Icons.error,
        color: Colors.white,
      ),
      child: child,
    );
  }

  static Future<void> showWarningToast(
    BuildContext context, {
    dynamic tag,
    String? message,
    Widget? child,
    bool isClosable = false,
    bool isAutoDismiss = true,
    bool isTop = false,
    double expandedHeight = 100,
    Color? backgroundColor,
    Color? shadowColor,
    Color? iconColor,
    Curve? slideCurve,
    Curve positionCurve = Curves.elasticOut,
    ToastLength length = ToastLength.short,
    DismissDirection dismissDirection = DismissDirection.down,
  }) async {
    _showToast(
      context,
      tag: tag,
      message: message,
      messageStyle: const TextStyle(
        color: Colors.white,
      ),
      isClosable: isClosable,
      isTop: isTop,
      isAutoDismiss: isAutoDismiss,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor ?? Colors.orange,
      shadowColor: shadowColor ?? Colors.orange.shade500,
      iconColor: iconColor,
      positionCurve: positionCurve,
      length: length,
      dismissDirection: dismissDirection,
      leading: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
      child: child,
    );
  }

  ///dismiss
  ///[tag]: dismiss specific toast, if null dismiss all
  static Future dismiss({dynamic tag}) async {
    if (tag != null) {
      final controller = _cache[tag];
      await _reverseAnimation(_animationControllers.indexOf(controller));
    } else {
      for (int index = 0; index < _animationControllers.length; index++) {
        await _reverseAnimation(index);
      }
    }
  }
}
