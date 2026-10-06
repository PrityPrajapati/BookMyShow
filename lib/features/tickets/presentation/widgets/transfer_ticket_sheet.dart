import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/transfer/domain/models/transfer_recipient.dart';
import 'package:showscape/features/transfer/presentation/providers/transfer_providers.dart';

/// Interactive 3-step modal sheet for Ticket Transfer:
/// Step 1: Choose which seats
/// Step 2: Choose recipient (contact picker, phone number, or share link)
/// Step 3: Confirmation sheet with 30-minute lock check and Cloud Function initiation
class TransferTicketSheet extends ConsumerStatefulWidget {
  const TransferTicketSheet({
    required this.booking,
    super.key,
    this.initialTicket,
  });

  final Booking booking;
  final Ticket? initialTicket;

  static Future<bool?> show(
    BuildContext context, {
    required Booking booking,
    Ticket? initialTicket,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransferTicketSheet(
        booking: booking,
        initialTicket: initialTicket,
      ),
    );
  }

  @override
  ConsumerState<TransferTicketSheet> createState() => _TransferTicketSheetState();
}

class _TransferTicketSheetState extends ConsumerState<TransferTicketSheet> {
  int _currentStep = 0; // 0: Seats, 1: Recipient, 2: Confirmation, 3: Success

  // Step 1: Selected seats
  final Set<String> _selectedTicketIds = {};

  // Step 2: Recipient method (0: Contacts, 1: Phone, 2: Share link)
  int _recipientMode = 0;
  TransferRecipient? _selectedContact;
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _contactSearchController = TextEditingController();
  String _contactSearchQuery = '';

  // Step 3 / 4: Result state
  bool _isLoading = false;
  String? _errorMessage;
  String? _generatedShareLink;

  @override
  void initState() {
    super.initState();
    final activeTickets = widget.booking.tickets
        .where((t) => t.status == TicketStatus.active)
        .toList();

    if (widget.initialTicket != null &&
        widget.initialTicket!.status == TicketStatus.active) {
      _selectedTicketIds.add(widget.initialTicket!.id);
    } else if (activeTickets.isNotEmpty) {
      _selectedTicketIds.add(activeTickets.first.id);
    }

    // Default contact preset to Rahul Sharma for seamless demonstration
    if (sampleContacts.isNotEmpty) {
      _selectedContact = sampleContacts.first;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _contactSearchController.dispose();
    super.dispose();
  }

  bool get _isWithin30Minutes {
    final now = DateTime.now();
    final diff = widget.booking.showTime.difference(now);
    return diff.inMinutes <= 30;
  }

  TransferRecipient _resolveCurrentRecipient() {
    if (_recipientMode == 0 && _selectedContact != null) {
      return _selectedContact!;
    } else if (_recipientMode == 1) {
      return TransferRecipient(
        name: _nameController.text.trim().isEmpty
            ? 'Recipient'
            : _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        isContact: false,
      );
    } else {
      return const TransferRecipient(
        name: 'Friend via Share Link',
        phoneNumber: 'Direct Link',
        isContact: false,
      );
    }
  }

  Future<void> _handleConfirmTransfer() async {
    if (_isWithin30Minutes) {
      setState(() {
        _errorMessage = 'Transfers are locked within 30 minutes of showtime.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await HapticFeedback.mediumImpact();

    final recipient = _resolveCurrentRecipient();

    final result =
        await ref.read(transferControllerProvider.notifier).initiateTransfer(
              bookingId: widget.booking.id,
              ticketIds: _selectedTicketIds.toList(),
              recipient: recipient,
              showTime: widget.booking.showTime,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isSuccess) {
        setState(() {
          _currentStep = 3; // Success state
          _generatedShareLink = result.shareLink;
        });
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Failed to initiate transfer.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Row with Step Indicator
          _buildHeader(context),
          const SizedBox(height: 16),

          // Active Step View
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentStepContent(context),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Controls
          if (_currentStep < 3) _buildBottomButtons(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // Header with Progress Pills
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    final stepTitles = ['Select Seats', 'Choose Recipient', 'Confirmation'];
    final title = _currentStep < 3 ? stepTitles[_currentStep] : 'Transfer Initiated!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.coral,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    widget.booking.eventTitle ?? 'Event Booking',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(_currentStep == 3),
            ),
          ],
        ),
        if (_currentStep < 3) ...[
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (idx) {
              final isActive = _currentStep >= idx;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: idx < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.coral : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectSeats(context);
      case 1:
        return _buildStep2ChooseRecipient(context);
      case 2:
        return _buildStep3Confirmation(context);
      case 3:
      default:
        return _buildSuccessState(context);
    }
  }

  // ===========================================================================
  // Step 1: Choose Which Seats
  // ===========================================================================

  Widget _buildStep1SelectSeats(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTickets = widget.booking.tickets;

    return Column(
      key: const ValueKey('step_1_seats'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the seats you want to transfer:',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You can transfer single or multiple seats from this booking.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allTickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final ticket = allTickets[index];
            final isEligible = ticket.status == TicketStatus.active;
            final isSelected = _selectedTicketIds.contains(ticket.id);

            return InkWell(
              onTap: isEligible
                  ? () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected) {
                          _selectedTicketIds.remove(ticket.id);
                        } else {
                          _selectedTicketIds.add(ticket.id);
                        }
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.coral.withValues(alpha: 0.1)
                      : (isDark ? AppColors.surfaceLight : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.coral
                        : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Checkbox
                    Checkbox(
                      value: isSelected,
                      activeColor: AppColors.coral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: isEligible
                          ? (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedTicketIds.add(ticket.id);
                                } else {
                                  _selectedTicketIds.remove(ticket.id);
                                }
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),

                    // Seat details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Seat ${ticket.seatNumber}',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.coral.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ticket.category,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.coral,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Row ${ticket.row} • ₹${ticket.price.toStringAsFixed(0)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge if already transferred / pending
                    if (ticket.status == TicketStatus.pendingTransfer)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pending',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (ticket.status == TicketStatus.transferred)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Transferred',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // Step 2: Choose Recipient (Contact picker, Phone number, or Share link)
  // ===========================================================================

  Widget _buildStep2ChooseRecipient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('step_2_recipient'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode Selector: Contact picker, Phone number, Share link
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceLight : AppColors.lightSurfaceBorder.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Row(
            children: [
              _buildRecipientTab(0, 'Contacts', Icons.contacts_rounded),
              _buildRecipientTab(1, 'Phone', Icons.phone_rounded),
              _buildRecipientTab(2, 'Share Link', Icons.link_rounded),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_recipientMode == 0) ...[
          // Contact Picker
          TextField(
            controller: _contactSearchController,
            onChanged: (val) => setState(() => _contactSearchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),

          Builder(
            builder: (context) {
              final filteredContacts = sampleContacts.where((c) {
                if (_contactSearchQuery.isEmpty) return true;
                return c.name.toLowerCase().contains(_contactSearchQuery) ||
                    c.phoneNumber.contains(_contactSearchQuery);
              }).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredContacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final isSelected = _selectedContact?.phoneNumber == contact.phoneNumber;

                  return InkWell(
                    key: Key('contact_tile_${contact.name.split(' ').first}'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedContact = contact);
                    },
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.coral.withValues(alpha: 0.12)
                            : (isDark ? AppColors.surfaceLight : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(AppRadius.r12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.coral
                              : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isSelected
                                ? AppColors.coral
                                : AppColors.coral.withValues(alpha: 0.15),
                            child: Text(
                              contact.avatarInitials,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.coral,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  contact.phoneNumber,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.coral, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ] else if (_recipientMode == 1) ...[
          // Direct Phone Number
          Text(
            'Recipient Name',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g. Rahul Sharma',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Mobile Phone Number *',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+91 98765 43210',
              prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
            ),
          ),
        ] else ...[
          // Share Link Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.coral, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Instant Transfer Link',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A secure one-time claim link will be created. Share it via WhatsApp, SMS, or Telegram. '
                  'The first person to claim will receive the HMAC-signed tickets.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Optional personal note
        Text(
          'Personal Note (Optional)',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enjoy the show! 🍿',
            prefixIcon: const Icon(Icons.notes_rounded, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12),
              borderSide: BorderSide(
                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientTab(int index, String label, IconData icon) {
    final isSelected = _recipientMode == index;
    return Expanded(
      child: GestureDetector(
        key: Key('recipient_tab_$index'),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _recipientMode = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.coral : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Step 3: Confirmation Sheet
  // ===========================================================================

  Widget _buildStep3Confirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipient = _resolveCurrentRecipient();
    final selectedSeats = widget.booking.tickets
        .where((t) => _selectedTicketIds.contains(t.id))
        .map((t) => t.seatNumber)
        .join(', ');

    return Column(
      key: const ValueKey('step_3_confirmation'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error banner if any
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSFER SUMMARY',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              _buildSummaryRow('Event', widget.booking.eventTitle ?? 'Movie'),
              _buildSummaryRow(
                'Showtime',
                DateFormat('EEE, d MMM • hh:mm a').format(widget.booking.showTime),
              ),
              _buildSummaryRow('Seats ($selectedSeats)', selectedSeats),
              _buildSummaryRow('Recipient', '${recipient.name} (${recipient.phoneNumber})'),
              if (_noteController.text.trim().isNotEmpty)
                _buildSummaryRow('Note', _noteController.text.trim()),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 30-Minute Showtime Lock Rule Indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isWithin30Minutes
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(
              color: _isWithin30Minutes
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.amber.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _isWithin30Minutes
                    ? Icons.lock_clock_rounded
                    : Icons.schedule_rounded,
                color: _isWithin30Minutes ? AppColors.error : AppColors.amber,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isWithin30Minutes
                          ? 'Transfers Locked (Under 30m to Showtime)'
                          : 'Transfers Lock 30m Before Showtime',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isWithin30Minutes ? AppColors.error : AppColors.amber,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isWithin30Minutes
                          ? 'Per venue security policy, tickets cannot be transferred within 30 minutes of show commencement.'
                          : 'You can cancel this transfer anytime before the recipient accepts.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Fraud & Cryptographic Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cloud Function transferTicket will mark your ticket ‘pendingTransfer’ and send an FCM push notification. '
                  'On accept, a new cryptographic HMAC-SHA256 signature is issued and the old QR is invalidated.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 4: Success View
  // ===========================================================================

  Widget _buildSuccessState(BuildContext context) {
    final recipient = _resolveCurrentRecipient();

    return Column(
      key: const ValueKey('step_4_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'Transfer Sent Successfully!',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Original pass is now Pending Transfer.\nFCM notification dispatched to ${recipient.name}.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        if (_generatedShareLink != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppColors.coral, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _generatedShareLink!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy link',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedShareLink!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transfer claim link copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        ElevatedButton(
          key: const Key('transfer_success_done_button'),
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
          ),
          child: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Bottom Buttons: Back & Next / Confirm
  // ===========================================================================

  Widget _buildBottomButtons(BuildContext context) {
    final canProceed = _currentStep == 0
        ? _selectedTicketIds.isNotEmpty
        : _currentStep == 1
            ? (_recipientMode == 0
                ? _selectedContact != null
                : _recipientMode == 1
                    ? _phoneController.text.trim().isNotEmpty
                    : true)
            : !_isWithin30Minutes;

    return Row(
      children: [
        if (_currentStep > 0) ...[
          OutlinedButton(
            onPressed: _isLoading ? null : () => setState(() => _currentStep--),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
            ),
            child: const Text('Back'),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            key: Key(_currentStep == 2 ? 'confirm_transfer_cta' : 'next_transfer_step_cta'),
            onPressed: canProceed && !_isLoading
                ? () {
                    if (_currentStep == 2) {
                      _handleConfirmTransfer();
                    } else {
                      HapticFeedback.selectionClick();
                      setState(() => _currentStep++);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _currentStep == 2
                        ? 'Confirm & Transfer'
                        : _currentStep == 0
                            ? 'Next: Choose Recipient'
                            : 'Next: Review & Confirm',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
