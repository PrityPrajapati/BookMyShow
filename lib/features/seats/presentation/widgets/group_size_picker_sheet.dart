import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';

class VehicleOption {
  final int count;
  final String title;
  final String emoji;
  final String subtitle;

  const VehicleOption(this.count, this.title, this.emoji, this.subtitle);
}

/// 'How many seats?' Modal Sheet with 1-10 illustrated transport/group icons
class GroupSizePickerSheet extends StatefulWidget {
  final int initialCount;
  final ValueChanged<int> onCountSelected;

  const GroupSizePickerSheet({
    super.key,
    this.initialCount = 2,
    required this.onCountSelected,
  });

  static const List<VehicleOption> options = [
    VehicleOption(1, 'Solo Ride', '🚲', 'Cycle'),
    VehicleOption(2, 'Couple', '🛵', 'Scooter'),
    VehicleOption(3, 'Trio', '🛺', 'Auto'),
    VehicleOption(4, 'Squad', '🚗', 'Hatchback'),
    VehicleOption(5, 'Family', '🚘', 'Sedan'),
    VehicleOption(6, 'Gang', '🚙', 'SUV'),
    VehicleOption(7, 'Big Group', '🚐', 'MPV'),
    VehicleOption(8, 'Party', '🚌', 'Minibus'),
    VehicleOption(9, 'Tour', '🚐', 'Luxury Van'),
    VehicleOption(10, 'Festival', '🚍', 'Party Bus'),
  ];

  @override
  State<GroupSizePickerSheet> createState() => _GroupSizePickerSheetState();
}

class _GroupSizePickerSheetState extends State<GroupSizePickerSheet> {
  late int _selectedCount;

  @override
  void initState() {
    super.initState();
    _selectedCount = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnight : AppColors.lightBackground,
        borderRadius: AppRadius.sheetTop28,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),

          // Title
          Text(
            'How many seats?',
            style: AppTypography.heading20(
              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'We will automatically find the best contiguous seats for you',
            style: AppTypography.caption12(
              color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Illustrated Transport Grid/Row (Horizontal scroll of 1-10 vehicles)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GroupSizePickerSheet.options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final opt = GroupSizePickerSheet.options[index];
                final isSelected = opt.count == _selectedCount;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCount = opt.count;
                    });
                  },
                  borderRadius: AppRadius.border16,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.spotlightCoral,
                                AppColors.spotlightCoralDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppColors.surface : AppColors.lightSurface),
                      borderRadius: AppRadius.border16,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          opt.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${opt.count}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
                          ),
                        ),
                        Text(
                          opt.title,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Primary Select Seats Button
          PrimaryButton(
            text: 'Select $_selectedCount ${_selectedCount == 1 ? "Seat" : "Seats"}',
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCountSelected(_selectedCount);
            },
          ),
        ],
      ),
    );
  }
}
