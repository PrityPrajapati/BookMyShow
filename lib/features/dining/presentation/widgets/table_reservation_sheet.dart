import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';

/// Interactive Table Reservation Bottom Sheet with party size, dates, time slots,
/// and booking tie-in for "Night Out" itinerary grouping.
class TableReservationSheet extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  final String? initialTimeSlot;
  final String? linkedBookingId;
  final int initialPartySize;
  final String? reservationType; // 'Dine before', 'Dine after', 'Standard'

  const TableReservationSheet({
    required this.restaurant,
    this.initialTimeSlot,
    this.linkedBookingId,
    this.initialPartySize = 2,
    this.reservationType,
    super.key,
  });

  @override
  ConsumerState<TableReservationSheet> createState() =>
      _TableReservationSheetState();
}

class _TableReservationSheetState extends ConsumerState<TableReservationSheet> {
  late int _partySize;
  late DateTime _selectedDate;
  late String _selectedSlot;
  final TextEditingController _specialRequestsController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(text: 'Aditya Sharma');
  final TextEditingController _phoneController =
      TextEditingController(text: '+91 98765 43210');
  bool _isSuccess = false;
  Reservation? _confirmedReservation;

  final List<String> _availableSlots = [
    '12:30 PM',
    '01:15 PM',
    '02:00 PM',
    '05:30 PM',
    '06:45 PM',
    '07:30 PM',
    '08:15 PM',
    '09:00 PM',
    '09:45 PM',
    '10:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _partySize = widget.initialPartySize;
    _selectedDate = DateTime.now();

    // Use initial slot if passed and add to available slots if not present
    if (widget.initialTimeSlot != null && widget.initialTimeSlot!.isNotEmpty) {
      _selectedSlot = widget.initialTimeSlot!;
      if (!_availableSlots.contains(_selectedSlot)) {
        _availableSlots.insert(0, _selectedSlot);
      }
    } else {
      _selectedSlot = '08:15 PM';
    }
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: _isSuccess ? _buildSuccessView() : _buildFormView(isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        AppSpacing.vertical16,

        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.table_restaurant_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserve a Table',
                    style: AppTypography.heading18().copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.restaurant.name,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        if (widget.reservationType != null) ...[
          AppSpacing.vertical12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withAlpha(50),
              borderRadius: AppRadius.border12,
              border: Border.all(color: Colors.amber.shade700, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.reservationType} slot aligned to your movie showtime (+15m walking buffer)',
                    style: AppTypography.caption.copyWith(
                      color: Colors.amber.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        AppSpacing.vertical20,

        // 1. Party Size
        Text(
          'PARTY SIZE',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        AppSpacing.vertical8,
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final guests = index + 1;
              final isSelected = _partySize == guests;
              return ChoiceChip(
                selected: isSelected,
                label: Text('$guests ${guests == 1 ? "Guest" : "Guests"}'),
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: isDark ? AppColors.surfaceElevated : Colors.grey.shade100,
                selectedColor: AppColors.primary,
                onSelected: (val) {
                  if (val) setState(() => _partySize = guests);
                },
              );
            },
          ),
        ),

        AppSpacing.vertical16,

        // 2. Date Selection (Today / Tomorrow)
        Text(
          'SELECT DATE',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        AppSpacing.vertical8,
        Row(
          children: [
            Expanded(
              child: _DateCard(
                title: 'Today',
                dateStr: DateFormat('d MMM').format(DateTime.now()),
                isSelected: _isSameDay(_selectedDate, DateTime.now()),
                onTap: () => setState(() => _selectedDate = DateTime.now()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateCard(
                title: 'Tomorrow',
                dateStr: DateFormat('d MMM').format(DateTime.now().add(const Duration(days: 1))),
                isSelected: _isSameDay(
                  _selectedDate,
                  DateTime.now().add(const Duration(days: 1)),
                ),
                onTap: () => setState(
                  () => _selectedDate = DateTime.now().add(const Duration(days: 1)),
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vertical16,

        // 3. Time Slots Grid
        Text(
          'AVAILABLE TIME SLOTS',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        AppSpacing.vertical8,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSlots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return InkWell(
              borderRadius: AppRadius.border12,
              onTap: () => setState(() => _selectedSlot = slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceElevated : Colors.grey.shade100),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Text(
                  slot,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        AppSpacing.vertical16,

        // 4. Special Requests
        TextField(
          controller: _specialRequestsController,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Special requests (optional)',
            hintText: 'e.g. Window seat, anniversary, high chair',
            filled: true,
            fillColor: isDark ? AppColors.surfaceElevated : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: AppRadius.border12,
              borderSide: BorderSide.none,
            ),
          ),
        ),

        AppSpacing.vertical20,

        // Confirm Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.border16),
              elevation: 4,
            ),
            onPressed: _submitReservation,
            child: Text(
              'Confirm Reservation ($_partySize Guests, $_selectedSlot)',
              style: AppTypography.buttonLabel(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final res = _confirmedReservation!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSpacing.vertical12,
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
        ),
        AppSpacing.vertical16,
        Text(
          'Table Reserved!',
          style: AppTypography.heading20().copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vertical4,
        Text(
          'Reservation ID: ${res.id}',
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vertical16,

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.border16,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            children: [
              _InfoRow(label: 'Restaurant', value: res.restaurantName ?? widget.restaurant.name),
              const Divider(height: 16),
              _InfoRow(label: 'Guests', value: '${res.partySize} Guests'),
              const Divider(height: 16),
              _InfoRow(label: 'Date & Time', value: '${DateFormat("d MMM yyyy").format(res.date)} at ${res.timeSlot}'),
              if (widget.linkedBookingId != null) ...[
                const Divider(height: 16),
                _InfoRow(
                  label: 'Linked Show',
                  value: 'ShowScape Night Out Pass',
                  isHighlighted: true,
                ),
              ],
            ],
          ),
        ),

        AppSpacing.vertical20,
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.border12),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _submitReservation() {
    final bookingMetadata = widget.linkedBookingId != null
        ? 'BOOKING:${widget.linkedBookingId};TYPE:${widget.reservationType ?? "dining"}'
        : '';
    final fullSpecialRequests = [
      if (bookingMetadata.isNotEmpty) bookingMetadata,
      if (_specialRequestsController.text.trim().isNotEmpty)
        _specialRequestsController.text.trim(),
    ].join(' | ');

    final reservation = Reservation(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      restaurantId: widget.restaurant.id,
      restaurantName: widget.restaurant.name,
      userId: 'usr_001',
      guestName: _nameController.text.trim(),
      guestPhone: _phoneController.text.trim(),
      partySize: _partySize,
      date: _selectedDate,
      timeSlot: _selectedSlot,
      status: ReservationStatus.confirmed,
      specialRequests: fullSpecialRequests.isEmpty ? null : fullSpecialRequests,
    );

    // Save to user reservations provider
    ref.read(userReservationsProvider.notifier).addReservation(reservation);

    setState(() {
      _isSuccess = true;
      _confirmedReservation = reservation;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String dateStr;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.dateStr,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.border12,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceElevated,
          borderRadius: AppRadius.border12,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              dateStr,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
