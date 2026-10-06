import 'package:flutter/material.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/widgets/shimmer_box.dart';

class HeroCarouselSkeleton extends StatelessWidget {
  const HeroCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerBox(
        height: 220,
        borderRadius: AppRadius.border20,
      ),
    );
  }
}

class EventRailSkeleton extends StatelessWidget {
  final String title;

  const EventRailSkeleton({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 140, height: 22, borderRadius: BorderRadius.circular(6)),
              ShimmerBox(width: 50, height: 16, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 140,
                    height: 190,
                    borderRadius: AppRadius.border16,
                  ),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 110, height: 14, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 4),
                  ShimmerBox(width: 70, height: 12, borderRadius: BorderRadius.circular(4)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class RestaurantRailSkeleton extends StatelessWidget {
  const RestaurantRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 160, height: 22, borderRadius: BorderRadius.circular(6)),
              ShimmerBox(width: 50, height: 16, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, __) {
              return ShimmerBox(
                width: 240,
                height: 200,
                borderRadius: AppRadius.border16,
              );
            },
          ),
        ),
      ],
    );
  }
}
