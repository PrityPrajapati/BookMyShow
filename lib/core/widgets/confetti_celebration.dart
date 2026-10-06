import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/utils/motion_utils.dart';

/// Celebratory Confetti Animation Overlay
/// Exempt from standard ≤ 350ms duration limit (celebratory exception)
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({
    super.key,
    this.duration = const Duration(milliseconds: 2500),
    this.particleCount = 50,
    this.lottieAssetPath,
  });

  final Duration duration;
  final int particleCount;
  final String? lottieAssetPath;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    final random = math.Random();
    final colors = [
      AppColors.spotlightCoral,
      AppColors.marqueeAmber,
      AppColors.standardCyan,
      AppColors.primeViolet,
      AppColors.success,
      AppColors.lavender,
      Colors.pinkAccent,
      Colors.amber,
      Colors.lightBlueAccent,
    ];

    _particles = List.generate(widget.particleCount, (i) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1 - (random.nextDouble() * 0.4),
        size: 6.0 + random.nextDouble() * 8.0,
        speedX: (random.nextDouble() - 0.5) * 0.6,
        speedY: 0.7 + random.nextDouble() * 1.2,
        color: colors[random.nextInt(colors.length)],
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 6,
        shape: random.nextInt(3), // 0: rect, 1: circle, 2: strip
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduceMotion(context)) {
      return const SizedBox.shrink();
    }

    if (widget.lottieAssetPath != null) {
      return Lottie.asset(
        widget.lottieAssetPath!,
        repeat: false,
        errorBuilder: (_, __, ___) => _buildParticleCanvas(),
      );
    }

    return _buildParticleCanvas();
  }

  Widget _buildParticleCanvas() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });

  final double x;
  final double y;
  final double size;
  final double speedX;
  final double speedY;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final int shape;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentX = (p.x + (p.speedX * progress)) * size.width;
      final currentY = (p.y + (p.speedY * progress)) * size.height;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (currentY > size.height) continue;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + (p.rotationSpeed * progress));

      if (p.shape == 0) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      } else if (p.shape == 1) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * 0.3,
            height: p.size * 1.5,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
