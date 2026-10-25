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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hi'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @openInCompare.
  ///
  /// In en, this message translates to:
  /// **'Open in Compare Matrix'**
  String get openInCompare;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @navHorizon.
  ///
  /// In en, this message translates to:
  /// **'Horizon'**
  String get navHorizon;

  /// No description provided for @navCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get navCompare;

  /// No description provided for @navGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get navGuardian;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeRankedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Ranked for you'**
  String get homeRankedEyebrow;

  /// No description provided for @homeFitStream.
  ///
  /// In en, this message translates to:
  /// **'Personal Fit Stream'**
  String get homeFitStream;

  /// No description provided for @browseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get browseAll;

  /// No description provided for @priceMemoryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Price memory'**
  String get priceMemoryEyebrow;

  /// No description provided for @radarTitle.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get radarTitle;

  /// No description provided for @watchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get watchingTitle;

  /// No description provided for @watchingCaption.
  ///
  /// In en, this message translates to:
  /// **'Products you are tracking against a target price.'**
  String get watchingCaption;

  /// No description provided for @compareEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Differential'**
  String get compareEyebrow;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare Matrix'**
  String get compareTitle;

  /// No description provided for @comparePrioritiesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your priorities'**
  String get comparePrioritiesEyebrow;

  /// No description provided for @comparePrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'What matters most?'**
  String get comparePrioritiesTitle;

  /// No description provided for @comparePrioritiesCaption.
  ///
  /// In en, this message translates to:
  /// **'Starred criteria count double toward the verdict.'**
  String get comparePrioritiesCaption;

  /// No description provided for @compareDiffEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Differences only'**
  String get compareDiffEyebrow;

  /// No description provided for @compareSpecMatrix.
  ///
  /// In en, this message translates to:
  /// **'Spec matrix'**
  String get compareSpecMatrix;

  /// No description provided for @compareReview.
  ///
  /// In en, this message translates to:
  /// **'Review {brand}'**
  String compareReview(String brand);

  /// No description provided for @cartEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Budget guardian'**
  String get cartEyebrow;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Cart'**
  String get cartTitle;

  /// No description provided for @intentCart.
  ///
  /// In en, this message translates to:
  /// **'Intent cart'**
  String get intentCart;

  /// No description provided for @cartHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to remove · tap to revisit the decision'**
  String get cartHint;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Cart total'**
  String get cartTotal;

  /// No description provided for @pastCeilingBy.
  ///
  /// In en, this message translates to:
  /// **'Past ceiling by'**
  String get pastCeilingBy;

  /// No description provided for @leftAfterCheckout.
  ///
  /// In en, this message translates to:
  /// **'Left after checkout'**
  String get leftAfterCheckout;

  /// No description provided for @checkoutMindfully.
  ///
  /// In en, this message translates to:
  /// **'Checkout mindfully · {amount}'**
  String checkoutMindfully(String amount);

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here — and that’s fine'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartBody.
  ///
  /// In en, this message translates to:
  /// **'Add items only when they serve an intent. Your envelope is safe.'**
  String get emptyCartBody;

  /// No description provided for @returnToHorizon.
  ///
  /// In en, this message translates to:
  /// **'Return to the horizon'**
  String get returnToHorizon;

  /// No description provided for @mindfulCheckoutEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Mindful checkout'**
  String get mindfulCheckoutEyebrow;

  /// No description provided for @pastCeilingTitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} past your ceiling'**
  String pastCeilingTitle(String amount);

  /// No description provided for @mindfulCheckoutBody.
  ///
  /// In en, this message translates to:
  /// **'Checking out now takes you past your {limit} monthly ceiling. You can still go ahead — Clarion just wants it to be a choice, not a reflex.'**
  String mindfulCheckoutBody(String limit);

  /// No description provided for @reviewSwapsFirst.
  ///
  /// In en, this message translates to:
  /// **'Review swaps first'**
  String get reviewSwapsFirst;

  /// No description provided for @proceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed anyway'**
  String get proceedAnyway;

  /// No description provided for @swappedTo.
  ///
  /// In en, this message translates to:
  /// **'Swapped to {brand}. {amount} back in your envelope.'**
  String swappedTo(String brand, String amount);

  /// No description provided for @removedItem.
  ///
  /// In en, this message translates to:
  /// **'Removed {title}.'**
  String removedItem(String title);

  /// No description provided for @orderPlacedLeft.
  ///
  /// In en, this message translates to:
  /// **'Order placed. {amount} left this month.'**
  String orderPlacedLeft(String amount);

  /// No description provided for @orderPlacedOver.
  ///
  /// In en, this message translates to:
  /// **'Order placed. {amount} past this month’s ceiling.'**
  String orderPlacedOver(String amount);

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @profileEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Spending profile'**
  String get profileEyebrow;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get profileTitle;

  /// No description provided for @signedInEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedInEyebrow;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountShort;

  /// No description provided for @displayEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displayEyebrow;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpEyebrow;

  /// No description provided for @appTour.
  ///
  /// In en, this message translates to:
  /// **'App tour'**
  String get appTour;

  /// No description provided for @replayTour.
  ///
  /// In en, this message translates to:
  /// **'Replay the tour'**
  String get replayTour;

  /// No description provided for @impulseLetGo.
  ///
  /// In en, this message translates to:
  /// **'Impulse buys let go'**
  String get impulseLetGo;

  /// No description provided for @keptByCoolingOff.
  ///
  /// In en, this message translates to:
  /// **'Kept by cooling off'**
  String get keptByCoolingOff;

  /// No description provided for @antiImpulseEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Anti-impulse'**
  String get antiImpulseEyebrow;

  /// No description provided for @coolingOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooling off'**
  String get coolingOffTitle;

  /// No description provided for @coolingOffCaption.
  ///
  /// In en, this message translates to:
  /// **'Parked for 24h. Decide once the urge has passed.'**
  String get coolingOffCaption;

  /// No description provided for @historyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyEyebrow;

  /// No description provided for @sixMonthTrend.
  ///
  /// In en, this message translates to:
  /// **'Six-month trend'**
  String get sixMonthTrend;

  /// No description provided for @sixMonthCaption.
  ///
  /// In en, this message translates to:
  /// **'Settled spend against your ceiling.'**
  String get sixMonthCaption;

  /// No description provided for @breakdownEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdownEyebrow;

  /// No description provided for @whereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get whereItWent;

  /// No description provided for @browseEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get browseEyebrow;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTitle;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @categoryBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get categoryBags;

  /// No description provided for @categoryAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get categoryAudio;

  /// No description provided for @categoryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categoryStudy;

  /// No description provided for @categoryEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get categoryEveryday;

  /// No description provided for @categoryPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get categoryPower;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultCount(int count);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'Filters · {count}'**
  String filtersActive(int count);

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortTitle;

  /// No description provided for @sortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sort: {order}'**
  String sortedBy(String order);

  /// No description provided for @sortBestFit.
  ///
  /// In en, this message translates to:
  /// **'Best fit'**
  String get sortBestFit;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get sortRating;

  /// No description provided for @sortBiggestDip.
  ///
  /// In en, this message translates to:
  /// **'Biggest price dip'**
  String get sortBiggestDip;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price'**
  String get maxPrice;

  /// No description provided for @anyPrice.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyPrice;

  /// No description provided for @minRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get minRating;

  /// No description provided for @anyRating.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyRating;

  /// No description provided for @ratingAtLeast.
  ///
  /// In en, this message translates to:
  /// **'{rating}+'**
  String ratingAtLeast(String rating);

  /// No description provided for @pickupNearby.
  ///
  /// In en, this message translates to:
  /// **'Pickup nearby'**
  String get pickupNearby;

  /// No description provided for @belowAverageFilter.
  ///
  /// In en, this message translates to:
  /// **'Below 30-day average'**
  String get belowAverageFilter;

  /// No description provided for @belowAverage.
  ///
  /// In en, this message translates to:
  /// **'−{percent}% vs 30d'**
  String belowAverage(int percent);

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{Show 1 result} other{Show {count} results}}'**
  String showResults(int count);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Clarion won’t stretch your limits to show you something. Loosen one filter.'**
  String get noResultsBody;

  /// No description provided for @productSummary.
  ///
  /// In en, this message translates to:
  /// **'{name}, {price}, {fit} percent fit'**
  String productSummary(String name, String price, int fit);

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @alsoConsidered.
  ///
  /// In en, this message translates to:
  /// **'Also considered'**
  String get alsoConsidered;

  /// No description provided for @verifiedOwners.
  ///
  /// In en, this message translates to:
  /// **'{count} verified owners'**
  String verifiedOwners(int count);

  /// No description provided for @shareProductText.
  ///
  /// In en, this message translates to:
  /// **'{name}: {price}, a {fit}% fit for me on Clarion.'**
  String shareProductText(String name, String price, int fit);

  /// No description provided for @shareBelowAverage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% below its 30-day average right now.'**
  String shareBelowAverage(int percent);

  /// No description provided for @ownerReviews.
  ///
  /// In en, this message translates to:
  /// **'Owner reviews'**
  String get ownerReviews;

  /// No description provided for @ratingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rating} other{{count} ratings}}'**
  String ratingCount(int count);

  /// No description provided for @ratedOutOfFive.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5'**
  String ratedOutOfFive(String rating);

  /// No description provided for @starCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String starCount(int count);

  /// No description provided for @starShare.
  ///
  /// In en, this message translates to:
  /// **'{star, plural, =1{1 star} other{{star} stars}}: {percent}%'**
  String starShare(int star, int percent);

  /// No description provided for @verifiedPurchase.
  ///
  /// In en, this message translates to:
  /// **'Verified purchase'**
  String get verifiedPurchase;

  /// No description provided for @ownedFor.
  ///
  /// In en, this message translates to:
  /// **'Owned {duration} · {date}'**
  String ownedFor(String duration, String date);

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get deleteReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @reviewTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Headline (optional)'**
  String get reviewTitleLabel;

  /// No description provided for @reviewBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get reviewBodyLabel;

  /// No description provided for @reviewBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What is it like to live with? What would you tell a friend?'**
  String get reviewBodyHint;

  /// No description provided for @reviewMoreChars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more character} other{{count} more characters}}'**
  String reviewMoreChars(int count);

  /// No description provided for @postReview.
  ///
  /// In en, this message translates to:
  /// **'Post review'**
  String get postReview;

  /// No description provided for @ordersEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get ordersEyebrow;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @orderEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderEyebrow;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet. When you check out, you can track and return them here.'**
  String get noOrders;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order {id}, {status}'**
  String orderSummary(String id, String status);

  /// No description provided for @stagePlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get stagePlaced;

  /// No description provided for @stagePacked.
  ///
  /// In en, this message translates to:
  /// **'Packed at the store'**
  String get stagePacked;

  /// No description provided for @stageReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get stageReady;

  /// No description provided for @stageReadyAt.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup in {area}'**
  String stageReadyAt(String area);

  /// No description provided for @stageCollected.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get stageCollected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @weWillTellYou.
  ///
  /// In en, this message translates to:
  /// **'We’ll have it ready within the hour. Nothing to do until then.'**
  String get weWillTellYou;

  /// No description provided for @showAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Show {id} at the counter to collect it.'**
  String showAtCounter(String id);

  /// No description provided for @enjoyIt.
  ///
  /// In en, this message translates to:
  /// **'Collected. Check in after a few weeks to say if it was worth it.'**
  String get enjoyIt;

  /// No description provided for @allItemsReturned.
  ///
  /// In en, this message translates to:
  /// **'Every item in this order went back, and the money with it.'**
  String get allItemsReturned;

  /// No description provided for @expectedAt.
  ///
  /// In en, this message translates to:
  /// **'Expected {time}'**
  String expectedAt(String time);

  /// No description provided for @markCollected.
  ///
  /// In en, this message translates to:
  /// **'I’ve picked it up'**
  String get markCollected;

  /// No description provided for @inThisOrder.
  ///
  /// In en, this message translates to:
  /// **'In this order'**
  String get inThisOrder;

  /// No description provided for @cancelPolicy.
  ///
  /// In en, this message translates to:
  /// **'Not collected yet: any item can be cancelled for a full refund.'**
  String get cancelPolicy;

  /// No description provided for @returnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Changed your mind? Return any item within {days} days of pickup.'**
  String returnPolicy(int days);

  /// No description provided for @cancelItem.
  ///
  /// In en, this message translates to:
  /// **'Cancel item'**
  String get cancelItem;

  /// No description provided for @returnItem.
  ///
  /// In en, this message translates to:
  /// **'Return item'**
  String get returnItem;

  /// No description provided for @returnWhy.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get returnWhy;

  /// No description provided for @reasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get reasonChangedMind;

  /// No description provided for @reasonNotAsDescribed.
  ///
  /// In en, this message translates to:
  /// **'Not as described'**
  String get reasonNotAsDescribed;

  /// No description provided for @reasonPoorQuality.
  ///
  /// In en, this message translates to:
  /// **'Poor quality'**
  String get reasonPoorQuality;

  /// No description provided for @reasonFoundBetter.
  ///
  /// In en, this message translates to:
  /// **'Found a better fit'**
  String get reasonFoundBetter;

  /// No description provided for @cancelExplainer.
  ///
  /// In en, this message translates to:
  /// **'{amount} goes back to this month’s envelope straight away.'**
  String cancelExplainer(String amount);

  /// No description provided for @returnExplainer.
  ///
  /// In en, this message translates to:
  /// **'Drop it at the {store} store. {amount} goes back to this month’s envelope now, and is refunded within a day.'**
  String returnExplainer(String amount, String store);

  /// No description provided for @yourStore.
  ///
  /// In en, this message translates to:
  /// **'pickup'**
  String get yourStore;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel this item'**
  String get confirmCancel;

  /// No description provided for @confirmReturn.
  ///
  /// In en, this message translates to:
  /// **'Return this item'**
  String get confirmReturn;

  /// No description provided for @returnInProgress.
  ///
  /// In en, this message translates to:
  /// **'Return in progress'**
  String get returnInProgress;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded {amount}'**
  String refunded(String amount);

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order total'**
  String get orderTotal;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLabel;

  /// No description provided for @pickupFree.
  ///
  /// In en, this message translates to:
  /// **'Free · same day'**
  String get pickupFree;

  /// No description provided for @refundedLabel.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refundedLabel;

  /// No description provided for @youPaid.
  ///
  /// In en, this message translates to:
  /// **'You paid'**
  String get youPaid;
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
    'that was used.',
  );
}
