import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/parking/presentation/widgets/parking_lot_card.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  final String venueId;

  const ParkingScreen({super.key, required this.venueId});

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  final TextEditingController _vehicleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ParkingLot? _selectedLot;
  bool _touchedVehicleInput = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    if (draft.parking != null) {
      _selectedLot = draft.parking!.lot;
      _vehicleController.text = draft.parking!.vehicleNumber;
    }
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  /// Indian vehicle registration number format validation:
  /// Standard: State (2 letters) + RTO (1-2 digits) + Series (1-3 letters) + Number (4 digits)
  /// e.g. MH12AB1234, DL01A1234, KA05MH9999 (spaces optional)
  /// BH Series: Year (2 digits) + BH + 4 digits + 1-2 letters (e.g. 22BH1234AA)
  bool _validateIndianPlate(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    final standardRegex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$');
    final bhRegex = RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$');
    return standardRegex.hasMatch(cleaned) || bhRegex.hasMatch(cleaned);
  }

  void _skipParking() {
    HapticFeedback.lightImpact();
    ref.read(bookingDraftProvider.notifier).clearParking();
    context.push(AppRoutes.checkout);
  }

  void _reserveAndProceed(int durationMinutes) {
    if (_selectedLot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a parking slot or tap "Skip parking"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _touchedVehicleInput = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();

    // Auto-calculate charge based on duration
    final hours = (durationMinutes / 60.0).ceil();
    final charge = _selectedLot!.hourlyRate > 0
        ? (_selectedLot!.hourlyRate * (hours > 0 ? hours : 1))
        : _selectedLot!.flatRate;

    final parkingSelection = ParkingSelection(
      lot: _selectedLot!,
      vehicleNumber: _vehicleController.text.trim().toUpperCase(),
      durationMinutes: durationMinutes,
      charge: charge,
    );

    ref.read(bookingDraftProvider.notifier).setParking(parkingSelection);
    context.push(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final venueAsync = ref.watch(venueDetailProvider(widget.venueId));

    // Show duration + 30 mins buffer auto-calculated
    final showRuntime = draft.durationMinutes > 0 ? draft.durationMinutes : 150;
    final totalDuration = showRuntime + 30; // auto-calculated: show duration + 30 mins
    final durationHours = (totalDuration / 60.0).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lavender),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Parking',
              style: AppTypography.heading20().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Guaranteed reserved slot with contactless valet',
              style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _skipParking,
            child: Text(
              'Skip parking',
              style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: venueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading parking: $err')),
        data: (venue) {
          final lots = venue?.parkingLots ?? [];

          if (lots.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_parking_rounded,
                      size: 64,
                      color: AppColors.lavenderMuted,
                    ),
                    AppSpacing.vertical16,
                    Text(
                      'No Parking Available',
                      style: AppTypography.heading20().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vertical8,
                    Text(
                      'This venue does not offer reserved on-site parking.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body14(color: AppColors.lavenderMuted),
                    ),
                    AppSpacing.vertical24,
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.checkout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spotlightCoral,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.border12,
                        ),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sortedLots = List<ParkingLot>.from(lots)
            ..sort((a, b) => a.vehicleType.index.compareTo(b.vehicleType.index));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Duration Banner: Auto-calculated Show + 30 mins
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.surface,
                                AppColors.surfaceElevated,
                              ],
                            ),
                            borderRadius: AppRadius.border20,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.marqueeAmber.withOpacity(0.12),
                                  borderRadius: AppRadius.border12,
                                ),
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: AppColors.marqueeAmber,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auto-calculated Parking Duration: ${totalDuration}m (~$durationHours hrs)',
                                      style: AppTypography.heading20().copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    AppSpacing.vertical4,
                                    Text(
                                      'Show runtime ($showRuntime mins) + 30 minutes buffer included',
                                      style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.vertical20,

                        // Vehicle Number Input with Indian format validation
                        Text(
                          'Vehicle Registration Number',
                          style: AppTypography.heading20().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vertical4,
                        Text(
                          'Enter registration plate number (e.g. MH12AB1234, spaces optional)',
                          style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                            fontSize: 11,
                          ),
                        ),
                        AppSpacing.vertical8,

                        TextFormField(
                          controller: _vehicleController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                            LengthLimitingTextInputFormatter(13),
                          ],
                          style: AppTypography.heading20(color: AppColors.lavender).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                          ),
                          decoration: InputDecoration(
                            hintText: 'MH 12 AB 1234',
                            hintStyle: AppTypography.heading20(
                              color: AppColors.lavenderMuted.withOpacity(0.5),
                            ).copyWith(
                              fontSize: 18,
                              letterSpacing: 2.0,
                            ),
                            prefixIcon: const Icon(
                              Icons.pin_rounded,
                              color: AppColors.spotlightCoral,
                            ),
                            suffixIcon: _vehicleController.text.isNotEmpty
                                ? Icon(
                                    _validateIndianPlate(_vehicleController.text)
                                        ? Icons.check_circle_rounded
                                        : Icons.error_outline_rounded,
                                    color: _validateIndianPlate(_vehicleController.text)
                                        ? AppColors.success
                                        : AppColors.error,
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.border12,
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.border12,
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.border12,
                              borderSide: const BorderSide(
                                color: AppColors.spotlightCoral,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: AppRadius.border12,
                              borderSide: const BorderSide(color: AppColors.error),
                            ),
                          ),
                          onChanged: (_) {
                            if (_touchedVehicleInput) {
                              setState(() {});
                            }
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your vehicle number';
                            }
                            if (!_validateIndianPlate(val)) {
                              return 'Enter a valid Indian vehicle number (e.g. MH12AB1234)';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.vertical24,

                        // Parking Lots Cards Header
                        Text(
                          'Select Parking Lot',
                          style: AppTypography.heading20().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vertical12,

                        // Lots List
                        ...sortedLots.map((lot) {
                          return ParkingLotCard(
                            lot: lot,
                            isSelected: _selectedLot?.id == lot.id,
                            durationMinutes: totalDuration,
                            onSelect: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedLot = lot);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(
                    top: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Skip Parking Text/Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _skipParking,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.lavenderMuted,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border20,
                            ),
                          ),
                          child: const Text('Skip parking'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Reserve & Continue Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _reserveAndProceed(totalDuration),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.spotlightCoral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border20,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedLot != null
                                    ? 'Add Parking • Proceed'
                                    : 'Proceed to Checkout',
                                style: AppTypography.buttonLabel(color: Colors.white).copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
