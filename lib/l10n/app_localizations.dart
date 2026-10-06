import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShowScape'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navScout.
  ///
  /// In en, this message translates to:
  /// **'Scout'**
  String get navScout;

  /// No description provided for @navTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get navTickets;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search movies, concerts, comedy, dining...'**
  String get searchPlaceholder;

  /// No description provided for @nowShowing.
  ///
  /// In en, this message translates to:
  /// **'Now Showing'**
  String get nowShowing;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @trendingInCity.
  ///
  /// In en, this message translates to:
  /// **'Trending in Mumbai'**
  String get trendingInCity;

  /// No description provided for @exploreMoods.
  ///
  /// In en, this message translates to:
  /// **'Explore by Mood'**
  String get exploreMoods;

  /// No description provided for @pickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for You'**
  String get pickedForYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @moodChill.
  ///
  /// In en, this message translates to:
  /// **'Chill'**
  String get moodChill;

  /// No description provided for @moodLaugh.
  ///
  /// In en, this message translates to:
  /// **'Laugh'**
  String get moodLaugh;

  /// No description provided for @moodThrill.
  ///
  /// In en, this message translates to:
  /// **'Thrill'**
  String get moodThrill;

  /// No description provided for @moodDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date Night'**
  String get moodDateNight;

  /// No description provided for @moodFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get moodFamily;

  /// No description provided for @moodMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get moodMusic;

  /// No description provided for @aboutEvent.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutEvent;

  /// No description provided for @castCrew.
  ///
  /// In en, this message translates to:
  /// **'Cast & Crew'**
  String get castCrew;

  /// No description provided for @whatPeopleSay.
  ///
  /// In en, this message translates to:
  /// **'What people say'**
  String get whatPeopleSay;

  /// No description provided for @reviewsAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'20 Reviews analyzed'**
  String get reviewsAnalyzed;

  /// No description provided for @spoilerFreeVerdict.
  ///
  /// In en, this message translates to:
  /// **'Spoiler-Free Verdict'**
  String get spoilerFreeVerdict;

  /// No description provided for @bookTickets.
  ///
  /// In en, this message translates to:
  /// **'Book Tickets'**
  String get bookTickets;

  /// No description provided for @selectShowtime.
  ///
  /// In en, this message translates to:
  /// **'Select Showtime'**
  String get selectShowtime;

  /// No description provided for @screenFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get screenFormat;

  /// No description provided for @screenThisWay.
  ///
  /// In en, this message translates to:
  /// **'SCREEN THIS WAY'**
  String get screenThisWay;

  /// No description provided for @bestForYou.
  ///
  /// In en, this message translates to:
  /// **'Best for you'**
  String get bestForYou;

  /// No description provided for @selectedSeats.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedSeats;

  /// No description provided for @availableSeats.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableSeats;

  /// No description provided for @soldSeats.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldSeats;

  /// No description provided for @primeTier.
  ///
  /// In en, this message translates to:
  /// **'Prime'**
  String get primeTier;

  /// No description provided for @classicTier.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classicTier;

  /// No description provided for @reclinerTier.
  ///
  /// In en, this message translates to:
  /// **'Recliner'**
  String get reclinerTier;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @snacksAndCombos.
  ///
  /// In en, this message translates to:
  /// **'Snacks & Combos'**
  String get snacksAndCombos;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'ADDED'**
  String get added;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @foodPickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get foodPickedForYou;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @ticketTotal.
  ///
  /// In en, this message translates to:
  /// **'Ticket Total'**
  String get ticketTotal;

  /// No description provided for @convenienceFee.
  ///
  /// In en, this message translates to:
  /// **'Convenience Fee'**
  String get convenienceFee;

  /// No description provided for @goldFeeWaiver.
  ///
  /// In en, this message translates to:
  /// **'Gold Member Fee Waiver'**
  String get goldFeeWaiver;

  /// No description provided for @taxesAndGst.
  ///
  /// In en, this message translates to:
  /// **'Integrated GST (18%)'**
  String get taxesAndGst;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get couponDiscount;

  /// No description provided for @amountPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Amount Payable'**
  String get amountPayable;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get paymentSuccess;

  /// No description provided for @viewTicket.
  ///
  /// In en, this message translates to:
  /// **'View Ticket'**
  String get viewTicket;

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @gate.
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get gate;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// No description provided for @seat.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get seat;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap ticket to flip for venue guide & terms'**
  String get tapToFlip;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Venue Guidelines'**
  String get termsAndConditions;

  /// No description provided for @parkingPass.
  ///
  /// In en, this message translates to:
  /// **'Parking Pass Included'**
  String get parkingPass;

  /// No description provided for @shareTicket.
  ///
  /// In en, this message translates to:
  /// **'Share Ticket'**
  String get shareTicket;

  /// No description provided for @transferTicket.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ticket'**
  String get transferTicket;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @profileGoldMember.
  ///
  /// In en, this message translates to:
  /// **'ShowScape Gold Member'**
  String get profileGoldMember;

  /// No description provided for @profileJoinGold.
  ///
  /// In en, this message translates to:
  /// **'Join Gold - Zero Booking Fees'**
  String get profileJoinGold;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @largeTextSimpleMode.
  ///
  /// In en, this message translates to:
  /// **'Large text & simple mode'**
  String get largeTextSimpleMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkMode;

  /// No description provided for @aiDebugger.
  ///
  /// In en, this message translates to:
  /// **'AI Summaries & Mood Debugger'**
  String get aiDebugger;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
