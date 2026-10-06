import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Expandable About Section with 'Read more' / 'Show less' toggle
class AboutSection extends StatefulWidget {
  final Event event;

  const AboutSection({super.key, required this.event});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = widget.event.type == EventType.movie
        ? 'About the Movie'
        : (widget.event.type == EventType.sports
            ? 'About the Match'
            : 'About the Experience');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.heading20(
              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
            ).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.event.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body14(
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ).copyWith(height: 1.5),
            ),
            secondChild: Text(
              widget.event.description,
              style: AppTypography.body14(
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ).copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Show less' : 'Read more',
                    style: AppTypography.caption12(
                      color: AppColors.spotlightCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.spotlightCoral,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
