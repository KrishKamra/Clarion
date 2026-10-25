// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get share => 'Share';

  @override
  String get openInCompare => 'Open in Compare Matrix';

  @override
  String get undo => 'Undo';

  @override
  String get seeAll => 'See all';

  @override
  String get show => 'Show';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get navHorizon => 'Horizon';

  @override
  String get navCompare => 'Compare';

  @override
  String get navGuardian => 'Guardian';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeRankedEyebrow => 'Ranked for you';

  @override
  String get homeFitStream => 'Personal Fit Stream';

  @override
  String get browseAll => 'Browse all';

  @override
  String get priceMemoryEyebrow => 'Price memory';

  @override
  String get radarTitle => 'Radar';

  @override
  String get watchingTitle => 'Watching';

  @override
  String get watchingCaption =>
      'Products you are tracking against a target price.';

  @override
  String get compareEyebrow => 'Differential';

  @override
  String get compareTitle => 'Compare Matrix';

  @override
  String get comparePrioritiesEyebrow => 'Your priorities';

  @override
  String get comparePrioritiesTitle => 'What matters most?';

  @override
  String get comparePrioritiesCaption =>
      'Starred criteria count double toward the verdict.';

  @override
  String get compareDiffEyebrow => 'Differences only';

  @override
  String get compareSpecMatrix => 'Spec matrix';

  @override
  String compareReview(String brand) {
    return 'Review $brand';
  }

  @override
  String get cartEyebrow => 'Budget guardian';

  @override
  String get cartTitle => 'Smart Cart';

  @override
  String get intentCart => 'Intent cart';

  @override
  String get cartHint => 'Swipe left to remove · tap to revisit the decision';

  @override
  String get cartTotal => 'Cart total';

  @override
  String get pastCeilingBy => 'Past ceiling by';

  @override
  String get leftAfterCheckout => 'Left after checkout';

  @override
  String checkoutMindfully(String amount) {
    return 'Checkout mindfully · $amount';
  }

  @override
  String get emptyCartTitle => 'Nothing here — and that’s fine';

  @override
  String get emptyCartBody =>
      'Add items only when they serve an intent. Your envelope is safe.';

  @override
  String get returnToHorizon => 'Return to the horizon';

  @override
  String get mindfulCheckoutEyebrow => 'Mindful checkout';

  @override
  String pastCeilingTitle(String amount) {
    return '$amount past your ceiling';
  }

  @override
  String mindfulCheckoutBody(String limit) {
    return 'Checking out now takes you past your $limit monthly ceiling. You can still go ahead — Clarion just wants it to be a choice, not a reflex.';
  }

  @override
  String get reviewSwapsFirst => 'Review swaps first';

  @override
  String get proceedAnyway => 'Proceed anyway';

  @override
  String swappedTo(String brand, String amount) {
    return 'Swapped to $brand. $amount back in your envelope.';
  }

  @override
  String removedItem(String title) {
    return 'Removed $title.';
  }

  @override
  String orderPlacedLeft(String amount) {
    return 'Order placed. $amount left this month.';
  }

  @override
  String orderPlacedOver(String amount) {
    return 'Order placed. $amount past this month’s ceiling.';
  }

  @override
  String get track => 'Track';

  @override
  String get profileEyebrow => 'Spending profile';

  @override
  String get profileTitle => 'This month';

  @override
  String get signedInEyebrow => 'Signed in';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccountShort => 'Delete';

  @override
  String get displayEyebrow => 'Display';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get helpEyebrow => 'Help';

  @override
  String get appTour => 'App tour';

  @override
  String get replayTour => 'Replay the tour';

  @override
  String get impulseLetGo => 'Impulse buys let go';

  @override
  String get keptByCoolingOff => 'Kept by cooling off';

  @override
  String get antiImpulseEyebrow => 'Anti-impulse';

  @override
  String get coolingOffTitle => 'Cooling off';

  @override
  String get coolingOffCaption =>
      'Parked for 24h. Decide once the urge has passed.';

  @override
  String get historyEyebrow => 'History';

  @override
  String get sixMonthTrend => 'Six-month trend';

  @override
  String get sixMonthCaption => 'Settled spend against your ceiling.';

  @override
  String get breakdownEyebrow => 'Breakdown';

  @override
  String get whereItWent => 'Where it went';

  @override
  String get browseEyebrow => 'Catalogue';

  @override
  String get browseTitle => 'Browse';

  @override
  String get allCategories => 'All';

  @override
  String get categoryBags => 'Bags';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryEveryday => 'Everyday';

  @override
  String get categoryPower => 'Power';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String filtersActive(int count) {
    return 'Filters · $count';
  }

  @override
  String get sortTitle => 'Sort by';

  @override
  String sortedBy(String order) {
    return 'Sort: $order';
  }

  @override
  String get sortBestFit => 'Best fit';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortRating => 'Highest rated';

  @override
  String get sortBiggestDip => 'Biggest price dip';

  @override
  String get maxPrice => 'Maximum price';

  @override
  String get anyPrice => 'Any';

  @override
  String get minRating => 'Rating';

  @override
  String get anyRating => 'Any';

  @override
  String ratingAtLeast(String rating) {
    return '$rating+';
  }

  @override
  String get pickupNearby => 'Pickup nearby';

  @override
  String get belowAverageFilter => 'Below 30-day average';

  @override
  String belowAverage(int percent) {
    return '−$percent% vs 30d';
  }

  @override
  String showResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count results',
      one: 'Show 1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noResultsTitle => 'Nothing matches these filters';

  @override
  String get noResultsBody =>
      'Clarion won’t stretch your limits to show you something. Loosen one filter.';

  @override
  String productSummary(String name, String price, int fit) {
    return '$name, $price, $fit percent fit';
  }

  @override
  String get specifications => 'Specifications';

  @override
  String get alsoConsidered => 'Also considered';

  @override
  String verifiedOwners(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString verified owners';
  }

  @override
  String shareProductText(String name, String price, int fit) {
    return '$name: $price, a $fit% fit for me on Clarion.';
  }

  @override
  String shareBelowAverage(int percent) {
    return '$percent% below its 30-day average right now.';
  }

  @override
  String get ownerReviews => 'Owner reviews';

  @override
  String ratingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ratings',
      one: '1 rating',
    );
    return '$_temp0';
  }

  @override
  String ratedOutOfFive(String rating) {
    return 'Rated $rating out of 5';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String starShare(int star, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      star,
      locale: localeName,
      other: '$star stars',
      one: '1 star',
    );
    return '$_temp0: $percent%';
  }

  @override
  String get verifiedPurchase => 'Verified purchase';

  @override
  String ownedFor(String duration, String date) {
    return 'Owned $duration · $date';
  }

  @override
  String get yourReview => 'Your review';

  @override
  String get writeReview => 'Write a review';

  @override
  String get editReview => 'Edit your review';

  @override
  String get deleteReview => 'Delete review';

  @override
  String get yourRating => 'Your rating';

  @override
  String get reviewTitleLabel => 'Headline (optional)';

  @override
  String get reviewBodyLabel => 'Your review';

  @override
  String get reviewBodyHint =>
      'What is it like to live with? What would you tell a friend?';

  @override
  String reviewMoreChars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more characters',
      one: '1 more character',
    );
    return '$_temp0';
  }

  @override
  String get postReview => 'Post review';

  @override
  String get ordersEyebrow => 'Purchases';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get orderEyebrow => 'Order';

  @override
  String get noOrders =>
      'No orders yet. When you check out, you can track and return them here.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String orderSummary(String id, String status) {
    return 'Order $id, $status';
  }

  @override
  String get stagePlaced => 'Order placed';

  @override
  String get stagePacked => 'Packed at the store';

  @override
  String get stageReady => 'Ready for pickup';

  @override
  String stageReadyAt(String area) {
    return 'Ready for pickup in $area';
  }

  @override
  String get stageCollected => 'Picked up';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusReturned => 'Returned';

  @override
  String get weWillTellYou =>
      'We’ll have it ready within the hour. Nothing to do until then.';

  @override
  String showAtCounter(String id) {
    return 'Show $id at the counter to collect it.';
  }

  @override
  String get enjoyIt =>
      'Collected. Check in after a few weeks to say if it was worth it.';

  @override
  String get allItemsReturned =>
      'Every item in this order went back, and the money with it.';

  @override
  String expectedAt(String time) {
    return 'Expected $time';
  }

  @override
  String get markCollected => 'I’ve picked it up';

  @override
  String get inThisOrder => 'In this order';

  @override
  String get cancelPolicy =>
      'Not collected yet: any item can be cancelled for a full refund.';

  @override
  String returnPolicy(int days) {
    return 'Changed your mind? Return any item within $days days of pickup.';
  }

  @override
  String get cancelItem => 'Cancel item';

  @override
  String get returnItem => 'Return item';

  @override
  String get returnWhy => 'What happened?';

  @override
  String get reasonChangedMind => 'Changed my mind';

  @override
  String get reasonNotAsDescribed => 'Not as described';

  @override
  String get reasonPoorQuality => 'Poor quality';

  @override
  String get reasonFoundBetter => 'Found a better fit';

  @override
  String cancelExplainer(String amount) {
    return '$amount goes back to this month’s envelope straight away.';
  }

  @override
  String returnExplainer(String amount, String store) {
    return 'Drop it at the $store store. $amount goes back to this month’s envelope now, and is refunded within a day.';
  }

  @override
  String get yourStore => 'pickup';

  @override
  String get confirmCancel => 'Cancel this item';

  @override
  String get confirmReturn => 'Return this item';

  @override
  String get returnInProgress => 'Return in progress';

  @override
  String refunded(String amount) {
    return 'Refunded $amount';
  }

  @override
  String get orderTotal => 'Order total';

  @override
  String get pickupLabel => 'Pickup';

  @override
  String get pickupFree => 'Free · same day';

  @override
  String get refundedLabel => 'Refunded';

  @override
  String get youPaid => 'You paid';
}
