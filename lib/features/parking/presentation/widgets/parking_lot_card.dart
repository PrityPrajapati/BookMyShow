import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';

class ParkingLotCard extends StatelessWidget {
  final ParkingLot lot;
  final bool isSelected;
  final int durationMinutes;
  final VoidCallback onSelect;

  const ParkingLotCard({
    super.key,
    required this.lot,
    required this.isSelected,
    required this.durationMinutes,
    required this.onSelect,
  });

  bool get isSoldOut => lot.available <= 0;

  double get calculatedCharge {
    if (lot.flatRate > 0 && lot.hourlyRate == 0) {
      return lot.flatRate;
    }
    final hours = (durationMinutes / 60.0).ceil();
    return lot.hourlyRate * (hours > 0 ? hours : 1);
  }

  IconData get _icon {
    switch (lot.vehicleType) {
      case VehicleType.twoWheeler:
        return Icons.two_wheeler_rounded;
      case VehicleType.fourWheeler:
        return Icons.directions_car_rounded;
      case VehicleType.ev:
        return Icons.electric_car_rounded;
    }
  }

  String get _displayType {
    switch (lot.vehicleType) {
      case VehicleType.twoWheeler:
        return '2-Wheeler Parking';
      case VehicleType.fourWheeler:
        return '4-Wheeler Parking';
      case VehicleType.ev:
        return 'EV Charging & Parking';
    }
  }

  String get _walkingDistance {
    switch (lot.vehicleType) {
      case VehicleType.twoWheeler:
        return '2 min walk • Level -1, Bay A';
      case VehicleType.fourWheeler:
        return '3 min walk • Level -2, Lift Lobby 3';
      case VehicleType.ev:
        return '4 min walk • Level -2, 60kW DC Fast Hub';
    }
  }

  @override
  Widget build(BuildContext context) {
    final availabilityPct = lot.capacity > 0
        ? (lot.available / lot.capacity).clamp(0.0, 1.0)
        : 0.0;

    Color progressColor;
    if (availabilityPct > 0.3) {
      progressColor = AppColors.success;
    } else if (availabilityPct > 0.1) {
      progressColor = AppColors.marqueeAmber;
    } else {
      progressColor = AppColors.error;
    }

    final hours = (durationMinutes / 60.0).ceil();

    return Opacity(
      opacity: isSoldOut ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.spotlightCoral.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: AppRadius.border20,
          border: Border.all(
            color: isSelected
                ? AppColors.spotlightCoral
                : (isSoldOut ? AppColors.surfaceBorder.withOpacity(0.5) : AppColors.surfaceBorder),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.spotlightCoral.withOpacity(0.18),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSoldOut ? null : onSelect,
            borderRadius: AppRadius.border20,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon, Title, Selection / Sold-out badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.spotlightCoral
                              : AppColors.surfaceElevated,
                          borderRadius: AppRadius.border12,
                        ),
                        child: Icon(
                          _icon,
                          size: 24,
                          color: isSelected ? Colors.white : AppColors.lavender,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _displayType,
                                  style: AppTypography.heading20().copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (lot.hasValet) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.marqueeAmber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'VALET',
                                      style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            AppSpacing.vertical4,
                            Text(
                              lot.name,
                              style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Radio or Sold-out pill
                      if (isSoldOut)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: AppRadius.pill,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Text(
                            'Sold Out',
                            style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.spotlightCoral
                                  : AppColors.lavenderMuted,
                              width: 2,
                            ),
                            color: isSelected ? AppColors.spotlightCoral : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                    ],
                  ),

                  AppSpacing.vertical12,

                  // Live Availability with Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSoldOut
                            ? '0 of ${lot.capacity} slots left'
                            : '${lot.available} of ${lot.capacity} left',
                        style: AppTypography.caption12(color: progressColor).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${(availabilityPct * 100).toInt()}% available',
                        style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: availabilityPct,
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),

                  AppSpacing.vertical12,

                  // Walking Distance and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Walking distance
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk_rounded,
                            size: 14,
                            color: AppColors.lavenderMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _walkingDistance,
                            style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      // Charge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${calculatedCharge.toInt()}',
                            style: AppTypography.heading20().copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.spotlightCoral
                                  : AppColors.lavender,
                            ),
                          ),
                          Text(
                            lot.hourlyRate > 0
                                ? '₹${lot.hourlyRate.toInt()}/hr × ${hours}h'
                                : 'Flat show rate',
                            style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
