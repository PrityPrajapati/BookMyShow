import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_typography.dart';

/// Navigation item definition for bottom navigation bar
class _NavItemData {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;

  const _NavItemData({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
  });
}

/// Custom Glassmorphic Bottom Navigation Scaffold with animated coral pill
/// and raised glowing 'Scout' center button.
class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  static const List<_NavItemData> _items = [
    _NavItemData(
      selectedIcon: Icons.home_rounded,
      unselectedIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItemData(
      selectedIcon: Icons.explore_rounded,
      unselectedIcon: Icons.explore_outlined,
      label: 'Explore',
    ),
    _NavItemData(
      selectedIcon: Icons.auto_awesome_rounded,
      unselectedIcon: Icons.auto_awesome_outlined,
      label: 'Scout',
    ),
    _NavItemData(
      selectedIcon: Icons.confirmation_number_rounded,
      unselectedIcon: Icons.confirmation_number_outlined,
      label: 'Tickets',
    ),
    _NavItemData(
      selectedIcon: Icons.person_rounded,
      unselectedIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  void _onTabTapped(int index) {
    AppHaptics.light();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Glassmorphic Bar Container
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.midnight.withValues(alpha: 0.82)
                          : AppColors.lightSurface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : AppColors.lightSurfaceBorder.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = constraints.maxWidth / 5;

                        return Stack(
                          children: [
                            // Animated Coral Indicator Pill for side tabs
                            if (currentIndex != 2)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                left: currentIndex * tabWidth + (tabWidth - 54) / 2,
                                top: 8,
                                width: 54,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.spotlightCoral.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),

                            // Tab Items Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(5, (index) {
                                if (index == 2) {
                                  // Scout Center Placeholder in row for spacing
                                  return SizedBox(
                                    width: tabWidth,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 48),
                                        Text(
                                          'Scout AI',
                                          style: AppTypography.caption12(
                                            color: currentIndex == 2
                                                ? AppColors.spotlightCoral
                                                : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                                            fontWeight: currentIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                                          ).copyWith(fontSize: 10),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                    ),
                                  );
                                }

                                final item = _items[index];
                                final isSelected = currentIndex == index;

                                return _buildTabItem(
                                  key: Key('nav_tab_$index'),
                                  context: context,
                                  width: tabWidth,
                                  item: item,
                                  isSelected: isSelected,
                                  isDark: isDark,
                                  onTap: () => _onTabTapped(index),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Raised Circular Center 'Scout' Button with Soft Pulsing Glow
              Positioned(
                top: -18,
                child: _buildCenterScoutButton(
                  key: const Key('nav_tab_scout'),
                  isSelected: currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    Key? key,
    required BuildContext context,
    required double width,
    required _NavItemData item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const activeColor = AppColors.spotlightCoral;
    final inactiveColor = isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight;

    return InkWell(
      key: key,
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: width,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? item.selectedIcon : item.unselectedIcon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTypography.caption12(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ).copyWith(fontSize: 11),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScoutButton({
    Key? key,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft Continuous Pulsing Glow using flutter_animate
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.12, 1.12),
                duration: 1600.ms,
                curve: Curves.easeInOutSine,
              )
              .boxShadow(
                begin: BoxShadow(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                end: BoxShadow(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.75),
                  blurRadius: 22,
                  spreadRadius: 5,
                ),
                duration: 1600.ms,
                curve: Curves.easeInOutSine,
              ),

          // Main Raised Center Button
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppColors.spotlightCoral,
                  Color(0xFFFF758F),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
