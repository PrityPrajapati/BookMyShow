import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/utils/motion_utils.dart';

class FloatingScoutOrb extends StatefulWidget {
  const FloatingScoutOrb({super.key});

  @override
  State<FloatingScoutOrb> createState() => _FloatingScoutOrbState();
}

class _FloatingScoutOrbState extends State<FloatingScoutOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orbButton = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.heavyImpact();
          context.go(AppRoutes.scout);
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.spotlightCoral,
                Color(0xFF8338EC),
                Color(0xFF3A86FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
              Positioned(
                bottom: 5,
                child: Text(
                  'AI',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (AppMotion.isReduceMotion(context)) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.spotlightCoral.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: orbButton,
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.spotlightCoral.withValues(
                  alpha: 0.35 * _pulseAnimation.value,
                ),
                blurRadius: 20 * _pulseAnimation.value,
                spreadRadius: 3 * _pulseAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: orbButton,
    );
  }
}
