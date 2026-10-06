import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/features/transfer/data/repositories/mock_transfer_repository.dart';
import 'package:showscape/features/transfer/domain/models/transfer.dart';
import 'package:showscape/features/transfer/domain/models/transfer_recipient.dart';
import 'package:showscape/features/transfer/domain/repositories/transfer_repository.dart';

/// Singleton instance provider for TransferRepository
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final offlineService = ref.watch(offlineTicketServiceProvider);
  return MockTransferRepository(offlineTicketService: offlineService);
});

/// Transfers stream / future for current authenticated user
final userTransfersProvider = FutureProvider<List<Transfer>>((ref) async {
  final repo = ref.watch(transferRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  final userId = user?.id ?? 'usr_001';
  return repo.getUserTransfers(userId);
});

/// Transfers for a specific booking
final bookingTransfersProvider =
    FutureProvider.family<List<Transfer>, String>((ref, bookingId) async {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.getTransfersForBooking(bookingId);
});

/// Recipient name lookup for a transferred ticket (e.g. "Rahul")
final transferredRecipientNameProvider =
    Provider.family<String?, String>((ref, ticketId) {
  final repo = ref.watch(transferRepositoryProvider);
  return repo.getRecipientNameForTicket(ticketId);
});

/// State of an in-flight transfer operation
class TransferState {
  const TransferState({
    this.isLoading = false,
    this.lastResult,
    this.error,
  });

  final bool isLoading;
  final TransferResult? lastResult;
  final String? error;

  TransferState copyWith({
    bool? isLoading,
    TransferResult? lastResult,
    String? error,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

/// Controller managing transfer operations and syncing ticket state
class TransferController extends StateNotifier<TransferState> {
  TransferController(this._ref, this._repository) : super(const TransferState());

  final Ref _ref;
  final TransferRepository _repository;

  Future<TransferResult> initiateTransfer({
    required String bookingId,
    required List<String> ticketIds,
    required TransferRecipient recipient,
    required DateTime showTime,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _ref.read(currentUserProvider.future);
    final userId = user?.id ?? 'usr_001';
    final userName = user?.name ?? 'Alex Turner';

    final result = await _repository.initiateTransfer(
      bookingId: bookingId,
      ticketIds: ticketIds,
      fromUserId: userId,
      fromUserName: userName,
      recipient: recipient,
      showTime: showTime,
      note: note,
    );

    state = state.copyWith(
      isLoading: false,
      lastResult: result,
      error: result.isSuccess ? null : result.errorMessage,
    );

    if (result.isSuccess) {
      // Invalidate tickets provider so UI immediately reflects pendingTransfer
      _ref.invalidate(allUserBookingsProvider);
      _ref.invalidate(ticketDetailProvider(bookingId));
      _ref.invalidate(userTransfersProvider);
      _ref.invalidate(bookingTransfersProvider(bookingId));
    }

    return result;
  }

  Future<TransferResult> cancelTransfer({
    required String transferId,
    required String bookingId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _ref.read(currentUserProvider.future);
    final userId = user?.id ?? 'usr_001';

    final result = await _repository.cancelTransfer(
      transferId: transferId,
      senderUid: userId,
    );

    state = state.copyWith(
      isLoading: false,
      lastResult: result,
      error: result.isSuccess ? null : result.errorMessage,
    );

    if (result.isSuccess) {
      _ref.invalidate(allUserBookingsProvider);
      _ref.invalidate(ticketDetailProvider(bookingId));
      _ref.invalidate(userTransfersProvider);
      _ref.invalidate(bookingTransfersProvider(bookingId));
    }

    return result;
  }

  Future<TransferResult> acceptTransfer({
    required String transferId,
    required String recipientUid,
    required String recipientName,
    required String bookingId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.acceptTransfer(
      transferId: transferId,
      recipientUid: recipientUid,
      recipientName: recipientName,
    );

    state = state.copyWith(
      isLoading: false,
      lastResult: result,
      error: result.isSuccess ? null : result.errorMessage,
    );

    if (result.isSuccess) {
      _ref.invalidate(allUserBookingsProvider);
      _ref.invalidate(ticketDetailProvider(bookingId));
      _ref.invalidate(userTransfersProvider);
      _ref.invalidate(bookingTransfersProvider(bookingId));
    }

    return result;
  }
}

final transferControllerProvider =
    StateNotifierProvider<TransferController, TransferState>((ref) {
  final repo = ref.watch(transferRepositoryProvider);
  return TransferController(ref, repo);
});
