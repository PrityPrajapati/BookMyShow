import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/core/theme/app_radius.dart';

class TuesdayDealsBanner extends ConsumerWidget {
  const TuesdayDealsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isDemoTuesday = ref.watch(isDemoTuesdayProvider);
    final isTuesday = isDemoTuesday || (now.weekday == DateTime.tuesday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4A3408),
              Color(0xFF2E1F03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.border20,
          border: Border.all(
            color: AppColors.marqueeAmber.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.marqueeAmber.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Graphic / Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.marqueeAmber.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Content Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.marqueeAmber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isTuesday ? 'LIVE TODAY' : 'COMING SOON',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.marqueeAmber,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTuesday ? 'Tuesday Deals' : 'Next Tuesday',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTuesday
                        ? 'Flat 50% off 2nd ticket + free tub popcorn! Code: TUESDAYMAGIC'
                        : 'Next Tuesday: up to 70% off cinema tickets & dining combos!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Pill
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTuesday
                          ? 'Coupon code TUESDAYMAGIC copied to clipboard!'
                          : 'Reminder set for Next Tuesday deals!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: AppRadius.pill,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.marqueeAmber,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  isTuesday ? 'Apply' : 'Remind',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
