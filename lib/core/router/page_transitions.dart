import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/utils/motion_utils.dart';

enum SharedAxisDirection {
  horizontal,
  vertical,
}

/// Shared-Axis Page Transition with Reduce Motion support
/// Capped at 280ms duration (≤ 350ms requirement)
Page<dynamic> buildSharedAxisTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  SharedAxisDirection direction = SharedAxisDirection.horizontal,
}) {
  if (AppMotion.isReduceMotion(context)) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isHorizontal = direction == SharedAxisDirection.horizontal;
      final beginOffset = isHorizontal
          ? const Offset(0.12, 0.0)
          : const Offset(0.0, 0.08);

      final slideIn = Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fadeIn = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ));

      return SlideTransition(
        position: slideIn,
        child: FadeTransition(
          opacity: fadeIn,
          child: child,
        ),
      );
    },
  );
}
