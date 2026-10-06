import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';

class BookingDraftNotifier extends StateNotifier<BookingDraft> {
  BookingDraftNotifier()
      : super(
          const BookingDraft(
            id: 'default_draft',
            showId: 'show_001',
            seatPrices: [320.0, 320.0],
            seatIds: ['E-5', 'E-6'],
          ),
        );

  void setDraft(BookingDraft draft) {
    state = draft;
  }

  void initForShow({
    required String draftId,
    required String showId,
    String? venueId,
    String? eventId,
    String? eventTitle,
    String? venueName,
    DateTime? showTime,
    bool isMovie = true,
    bool isGold = false,
    double occupancyPct = 50.0,
    int durationMinutes = 150,
    List<String> seatIds = const [],
    List<double> seatPrices = const [],
  }) {
    state = state.copyWith(
      id: draftId,
      showId: showId,
      venueId: venueId,
      eventId: eventId,
      eventTitle: eventTitle,
      venueName: venueName,
      showTime: showTime,
      isMovie: isMovie,
      isGold: isGold,
      occupancyPct: occupancyPct,
      durationMinutes: durationMinutes,
      seatIds: seatIds,
      seatPrices: seatPrices,
    );
  }

  void updateSeats(List<String> seatIds, List<double> seatPrices) {
    state = state.copyWith(
      seatIds: seatIds,
      seatPrices: seatPrices,
    );
  }

  void addFnbCartItem(FnbCartItem item) {
    final existingIndex = state.fnbItems.indexWhere((i) {
      if (item.isCombo && i.isCombo) {
        return i.combo?.id == item.combo?.id;
      }
      return i.item?.id == item.item?.id &&
          i.size == item.size &&
          i.flavour == item.flavour;
    });

    if (existingIndex >= 0) {
      final updatedList = List<FnbCartItem>.from(state.fnbItems);
      final existing = updatedList[existingIndex];
      updatedList[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      state = state.copyWith(fnbItems: updatedList);
    } else {
      state = state.copyWith(fnbItems: [...state.fnbItems, item]);
    }
  }

  void updateFnbQuantity(String cartItemId, int newQty) {
    if (newQty <= 0) {
      removeFnbItem(cartItemId);
      return;
    }
    final updated = state.fnbItems.map((i) {
      if (i.id == cartItemId) {
        return i.copyWith(quantity: newQty);
      }
      return i;
    }).toList();
    state = state.copyWith(fnbItems: updated);
  }

  void removeFnbItem(String cartItemId) {
    state = state.copyWith(
      fnbItems: state.fnbItems.where((i) => i.id != cartItemId).toList(),
    );
  }

  void setPickupTiming(PickupTiming timing) {
    state = state.copyWith(pickupTiming: timing);
  }

  void setParking(ParkingSelection? parking) {
    if (parking == null) {
      state = state.copyWith(clearParking: true);
    } else {
      state = state.copyWith(parking: parking);
    }
  }

  void clearParking() {
    state = state.copyWith(clearParking: true);
  }

  void setDiningReservation(Reservation? reservation) {
    if (reservation == null) {
      state = state.copyWith(clearDiningReservation: true);
    } else {
      state = state.copyWith(diningReservation: reservation);
    }
  }

  void clearDiningReservation() {
    state = state.copyWith(clearDiningReservation: true);
  }

  void clearFnb() {
    state = state.copyWith(fnbItems: const []);
  }

  void reset() {
    state = const BookingDraft(
      id: 'default_draft',
      showId: 'show_001',
    );
  }
}

final bookingDraftProvider =
    StateNotifierProvider<BookingDraftNotifier, BookingDraft>((ref) {
  return BookingDraftNotifier();
});
