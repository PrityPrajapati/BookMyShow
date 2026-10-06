import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for Analytics & Crashlytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Central Analytics & Crashlytics event tracking according to PRD §19
class AnalyticsService {
  FirebaseAnalytics? get _analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseCrashlytics? get _crashlytics {
    try {
      return FirebaseCrashlytics.instance;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // PRD §19 E-Commerce & Engagement Analytics Events
  // ---------------------------------------------------------------------------

  /// 1. view_item: User opens an Event Detail Screen
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
  }) async {
    debugPrint('[Analytics] view_item: $itemId ($itemName, $itemCategory)');
    try {
      await _analytics?.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
          ),
        ],
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log view_item');
    }
  }

  /// 2. select_item: User taps on an event card or banner
  Future<void> logSelectItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
    String? itemListName,
  }) async {
    debugPrint('[Analytics] select_item: $itemId from $itemListName');
    try {
      await _analytics?.logSelectItem(
        itemListName: itemListName,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
          ),
        ],
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log select_item');
    }
  }

  /// 3. select_showtime: User selects a movie/event showtime slot
  Future<void> logSelectShowtime({
    required String showtimeId,
    required String eventId,
    required String format,
    required String time,
  }) async {
    debugPrint('[Analytics] select_showtime: $showtimeId ($format at $time)');
    try {
      await _analytics?.logEvent(
        name: 'select_showtime',
        parameters: {
          'showtime_id': showtimeId,
          'event_id': eventId,
          'format': format,
          'time': time,
        },
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log select_showtime');
    }
  }

  /// 4. select_seats: User confirms seat selection
  Future<void> logSelectSeats({
    required String showId,
    required int seatCount,
    required double totalPrice,
    required List<String> seatCodes,
  }) async {
    debugPrint('[Analytics] select_seats: count=$seatCount, total=₹$totalPrice');
    try {
      await _analytics?.logEvent(
        name: 'select_seats',
        parameters: {
          'show_id': showId,
          'seat_count': seatCount,
          'total_price': totalPrice,
          'seat_codes': seatCodes.join(','),
        },
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log select_seats');
    }
  }

  /// 5. add_to_cart: User adds food combos or concessions
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    required int quantity,
  }) async {
    debugPrint('[Analytics] add_to_cart: $itemName x$quantity (₹$price)');
    try {
      await _analytics?.logAddToCart(
        value: price * quantity,
        currency: 'INR',
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            price: price,
            quantity: quantity,
          ),
        ],
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log add_to_cart');
    }
  }

  /// 6. begin_checkout: User lands on checkout breakdown screen
  Future<void> logBeginCheckout({
    required double value,
    required int itemCount,
    required String bookingDraftId,
  }) async {
    debugPrint('[Analytics] begin_checkout: draft=$bookingDraftId, value=₹$value');
    try {
      await _analytics?.logBeginCheckout(
        value: value,
        currency: 'INR',
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log begin_checkout');
    }
  }

  /// 7. apply_coupon: User applies promo code (e.g. TUESDAY50, GOLDVIP)
  Future<void> logApplyCoupon({
    required String couponCode,
    required double discountAmount,
    required bool isSuccess,
  }) async {
    debugPrint('[Analytics] apply_coupon: $couponCode (saving ₹$discountAmount, success=$isSuccess)');
    try {
      await _analytics?.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon_code': couponCode,
          'discount_amount': discountAmount,
          'success': isSuccess,
        },
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log apply_coupon');
    }
  }

  /// 8. purchase: Payment successfully completed
  Future<void> logPurchase({
    required String transactionId,
    required double totalAmount,
    required String paymentMethod,
    required bool isGoldMember,
  }) async {
    debugPrint('[Analytics] purchase: $transactionId, amount=₹$totalAmount via $paymentMethod');
    try {
      await _analytics?.logPurchase(
        transactionId: transactionId,
        value: totalAmount,
        currency: 'INR',
      );
      await _analytics?.logEvent(
        name: 'booking_completed',
        parameters: {
          'transaction_id': transactionId,
          'payment_method': paymentMethod,
          'is_gold': isGoldMember,
        },
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log purchase');
    }
  }

  /// 9. search & filter: Search queries and filters applied
  Future<void> logSearch({
    required String searchTerm,
    int? resultCount,
  }) async {
    debugPrint('[Analytics] search: "$searchTerm", results=$resultCount');
    try {
      await _analytics?.logSearch(searchTerm: searchTerm);
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log search');
    }
  }

  /// 10. mood_selected: Mood chip tapped on Home or Explore
  Future<void> logMoodSelected(String mood) async {
    debugPrint('[Analytics] mood_selected: $mood');
    try {
      await _analytics?.logEvent(
        name: 'mood_selected',
        parameters: {'mood': mood},
      );
    } catch (e, st) {
      recordNonFatalError(e, st, reason: 'Failed to log mood_selected');
    }
  }

  // ---------------------------------------------------------------------------
  // Crashlytics Non-Fatal Logging & Custom Breadcrumbs
  // ---------------------------------------------------------------------------

  void logBreadcrumb(String message) {
    debugPrint('[Crashlytics Log] $message');
    try {
      _crashlytics?.log(message);
    } catch (_) {}
  }

  void recordNonFatalError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    debugPrint('[Crashlytics Error] $reason: $error');
    try {
      _crashlytics?.recordError(error, stack, reason: reason, fatal: fatal);
    } catch (_) {}
  }
}
