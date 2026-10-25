// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get back => 'वापस';

  @override
  String get share => 'शेयर करें';

  @override
  String get openInCompare => 'तुलना मैट्रिक्स में खोलें';

  @override
  String get undo => 'पहले जैसा करें';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get show => 'दिखाएँ';

  @override
  String get showMore => 'और दिखाएँ';

  @override
  String get showLess => 'कम दिखाएँ';

  @override
  String get navHorizon => 'होराइज़न';

  @override
  String get navCompare => 'तुलना';

  @override
  String get navGuardian => 'गार्डियन';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get homeRankedEyebrow => 'आपके लिए क्रम में';

  @override
  String get homeFitStream => 'आपके लिए सही चुनाव';

  @override
  String get browseAll => 'सभी देखें';

  @override
  String get priceMemoryEyebrow => 'कीमत की याद';

  @override
  String get radarTitle => 'रडार';

  @override
  String get watchingTitle => 'नज़र में';

  @override
  String get watchingCaption =>
      'वे प्रोडक्ट जिनकी कीमत पर आप लक्ष्य के साथ नज़र रख रहे हैं।';

  @override
  String get compareEyebrow => 'अंतर';

  @override
  String get compareTitle => 'तुलना मैट्रिक्स';

  @override
  String get comparePrioritiesEyebrow => 'आपकी प्राथमिकताएँ';

  @override
  String get comparePrioritiesTitle => 'सबसे ज़रूरी क्या है?';

  @override
  String get comparePrioritiesCaption =>
      'स्टार वाले मापदंड फ़ैसले में दोगुने गिने जाते हैं।';

  @override
  String get compareDiffEyebrow => 'सिर्फ़ अंतर';

  @override
  String get compareSpecMatrix => 'स्पेसिफ़िकेशन मैट्रिक्स';

  @override
  String compareReview(String brand) {
    return '$brand देखें';
  }

  @override
  String get cartEyebrow => 'बजट गार्डियन';

  @override
  String get cartTitle => 'स्मार्ट कार्ट';

  @override
  String get intentCart => 'इरादे की कार्ट';

  @override
  String get cartHint =>
      'हटाने के लिए बाईं ओर स्वाइप करें · फ़ैसला दोबारा देखने के लिए टैप करें';

  @override
  String get cartTotal => 'कार्ट का कुल';

  @override
  String get pastCeilingBy => 'सीमा से ज़्यादा';

  @override
  String get leftAfterCheckout => 'चेकआउट के बाद बचेगा';

  @override
  String checkoutMindfully(String amount) {
    return 'सोच-समझकर चेकआउट · $amount';
  }

  @override
  String get emptyCartTitle => 'यहाँ कुछ नहीं — और यह ठीक है';

  @override
  String get emptyCartBody =>
      'चीज़ें तभी जोड़ें जब वे किसी इरादे को पूरा करें। आपका बजट सुरक्षित है।';

  @override
  String get returnToHorizon => 'होराइज़न पर लौटें';

  @override
  String get mindfulCheckoutEyebrow => 'सोच-समझकर चेकआउट';

  @override
  String pastCeilingTitle(String amount) {
    return 'सीमा से $amount ज़्यादा';
  }

  @override
  String mindfulCheckoutBody(String limit) {
    return 'अभी चेकआउट करने से आप अपनी $limit की मासिक सीमा पार कर जाएँगे। आप फिर भी आगे बढ़ सकते हैं — Clarion बस चाहता है कि यह आदत नहीं, आपका फ़ैसला हो।';
  }

  @override
  String get reviewSwapsFirst => 'पहले बदलाव देखें';

  @override
  String get proceedAnyway => 'फिर भी आगे बढ़ें';

  @override
  String swappedTo(String brand, String amount) {
    return '$brand पर बदला। $amount आपके बजट में वापस।';
  }

  @override
  String removedItem(String title) {
    return '$title हटाया गया।';
  }

  @override
  String orderPlacedLeft(String amount) {
    return 'ऑर्डर हो गया। इस महीने $amount बचे हैं।';
  }

  @override
  String orderPlacedOver(String amount) {
    return 'ऑर्डर हो गया। इस महीने की सीमा से $amount ज़्यादा।';
  }

  @override
  String get track => 'ट्रैक करें';

  @override
  String get profileEyebrow => 'ख़र्च प्रोफ़ाइल';

  @override
  String get profileTitle => 'इस महीने';

  @override
  String get signedInEyebrow => 'साइन इन';

  @override
  String get account => 'खाता';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get deleteAccountShort => 'हटाएँ';

  @override
  String get displayEyebrow => 'डिस्प्ले';

  @override
  String get appearance => 'रूप';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get language => 'भाषा';

  @override
  String get helpEyebrow => 'मदद';

  @override
  String get appTour => 'ऐप टूर';

  @override
  String get replayTour => 'टूर फिर से देखें';

  @override
  String get impulseLetGo => 'जल्दबाज़ी की ख़रीद छोड़ी';

  @override
  String get keptByCoolingOff => 'ठहरकर बचाए';

  @override
  String get antiImpulseEyebrow => 'जल्दबाज़ी से बचाव';

  @override
  String get coolingOffTitle => 'ठहराव में';

  @override
  String get coolingOffCaption =>
      '24 घंटे के लिए रोका गया। मन शांत होने पर फ़ैसला करें।';

  @override
  String get historyEyebrow => 'इतिहास';

  @override
  String get sixMonthTrend => 'छह महीने का रुझान';

  @override
  String get sixMonthCaption => 'आपकी सीमा की तुलना में ख़र्च।';

  @override
  String get breakdownEyebrow => 'ब्योरा';

  @override
  String get whereItWent => 'पैसा कहाँ गया';

  @override
  String get browseEyebrow => 'कैटलॉग';

  @override
  String get browseTitle => 'ब्राउज़ करें';

  @override
  String get allCategories => 'सभी';

  @override
  String get categoryBags => 'बैग';

  @override
  String get categoryAudio => 'ऑडियो';

  @override
  String get categoryStudy => 'पढ़ाई';

  @override
  String get categoryEveryday => 'रोज़मर्रा';

  @override
  String get categoryPower => 'पावर';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नतीजे',
      one: '1 नतीजा',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'फ़िल्टर';

  @override
  String filtersActive(int count) {
    return 'फ़िल्टर · $count';
  }

  @override
  String get sortTitle => 'क्रम चुनें';

  @override
  String sortedBy(String order) {
    return 'क्रम: $order';
  }

  @override
  String get sortBestFit => 'सबसे सही';

  @override
  String get sortPriceLow => 'कीमत: कम से ज़्यादा';

  @override
  String get sortPriceHigh => 'कीमत: ज़्यादा से कम';

  @override
  String get sortRating => 'सबसे अच्छी रेटिंग';

  @override
  String get sortBiggestDip => 'सबसे बड़ी गिरावट';

  @override
  String get maxPrice => 'अधिकतम कीमत';

  @override
  String get anyPrice => 'कोई भी';

  @override
  String get minRating => 'रेटिंग';

  @override
  String get anyRating => 'कोई भी';

  @override
  String ratingAtLeast(String rating) {
    return '$rating+';
  }

  @override
  String get pickupNearby => 'पास में पिकअप';

  @override
  String get belowAverageFilter => '30 दिन के औसत से कम';

  @override
  String belowAverage(int percent) {
    return '30 दिन से −$percent%';
  }

  @override
  String showResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नतीजे दिखाएँ',
      one: '1 नतीजा दिखाएँ',
      zero: 'कोई नतीजा नहीं',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get noResultsTitle => 'इन फ़िल्टर से कुछ नहीं मिला';

  @override
  String get noResultsBody =>
      'Clarion कुछ दिखाने के लिए आपकी सीमाएँ नहीं खींचेगा। कोई एक फ़िल्टर ढीला करें।';

  @override
  String productSummary(String name, String price, int fit) {
    return '$name, $price, $fit प्रतिशत सही';
  }

  @override
  String get specifications => 'स्पेसिफ़िकेशन';

  @override
  String get alsoConsidered => 'इन पर भी विचार हुआ';

  @override
  String verifiedOwners(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString सत्यापित मालिक';
  }

  @override
  String shareProductText(String name, String price, int fit) {
    return '$name: $price, Clarion पर मेरे लिए $fit% सही।';
  }

  @override
  String shareBelowAverage(int percent) {
    return 'अभी अपने 30 दिन के औसत से $percent% सस्ता।';
  }

  @override
  String get ownerReviews => 'मालिकों की समीक्षाएँ';

  @override
  String ratingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString रेटिंग',
      one: '1 रेटिंग',
    );
    return '$_temp0';
  }

  @override
  String ratedOutOfFive(String rating) {
    return '5 में से $rating रेटिंग';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्टार',
      one: '1 स्टार',
    );
    return '$_temp0';
  }

  @override
  String starShare(int star, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      star,
      locale: localeName,
      other: '$star स्टार',
      one: '1 स्टार',
    );
    return '$_temp0: $percent%';
  }

  @override
  String get verifiedPurchase => 'सत्यापित ख़रीद';

  @override
  String ownedFor(String duration, String date) {
    return '$duration से इस्तेमाल · $date';
  }

  @override
  String get yourReview => 'आपकी समीक्षा';

  @override
  String get writeReview => 'समीक्षा लिखें';

  @override
  String get editReview => 'अपनी समीक्षा बदलें';

  @override
  String get deleteReview => 'समीक्षा हटाएँ';

  @override
  String get yourRating => 'आपकी रेटिंग';

  @override
  String get reviewTitleLabel => 'शीर्षक (वैकल्पिक)';

  @override
  String get reviewBodyLabel => 'आपकी समीक्षा';

  @override
  String get reviewBodyHint =>
      'इसके साथ रहना कैसा है? आप किसी दोस्त को क्या बताएँगे?';

  @override
  String reviewMoreChars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अक्षर और',
      one: '1 अक्षर और',
    );
    return '$_temp0';
  }

  @override
  String get postReview => 'समीक्षा पोस्ट करें';

  @override
  String get ordersEyebrow => 'ख़रीदारी';

  @override
  String get ordersTitle => 'ऑर्डर';

  @override
  String get orderEyebrow => 'ऑर्डर';

  @override
  String get noOrders =>
      'अभी कोई ऑर्डर नहीं। चेकआउट के बाद आप उन्हें यहाँ ट्रैक और वापस कर सकते हैं।';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String orderSummary(String id, String status) {
    return 'ऑर्डर $id, $status';
  }

  @override
  String get stagePlaced => 'ऑर्डर हुआ';

  @override
  String get stagePacked => 'स्टोर पर पैक हुआ';

  @override
  String get stageReady => 'पिकअप के लिए तैयार';

  @override
  String stageReadyAt(String area) {
    return '$area में पिकअप के लिए तैयार';
  }

  @override
  String get stageCollected => 'ले लिया गया';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get statusReturned => 'वापस किया';

  @override
  String get weWillTellYou =>
      'हम इसे एक घंटे में तैयार कर देंगे। तब तक कुछ करने की ज़रूरत नहीं।';

  @override
  String showAtCounter(String id) {
    return 'लेने के लिए काउंटर पर $id दिखाएँ।';
  }

  @override
  String get enjoyIt =>
      'ले लिया गया। कुछ हफ़्तों बाद बताइए कि यह ख़रीद सही थी या नहीं।';

  @override
  String get allItemsReturned => 'इस ऑर्डर का हर आइटम वापस हुआ, और पैसा भी।';

  @override
  String expectedAt(String time) {
    return 'अनुमानित $time';
  }

  @override
  String get markCollected => 'मैंने ले लिया';

  @override
  String get inThisOrder => 'इस ऑर्डर में';

  @override
  String get cancelPolicy =>
      'अभी लिया नहीं गया: कोई भी आइटम पूरे रिफ़ंड के साथ रद्द किया जा सकता है।';

  @override
  String returnPolicy(int days) {
    return 'मन बदल गया? पिकअप के $days दिन के भीतर कोई भी आइटम वापस करें।';
  }

  @override
  String get cancelItem => 'आइटम रद्द करें';

  @override
  String get returnItem => 'आइटम वापस करें';

  @override
  String get returnWhy => 'क्या हुआ?';

  @override
  String get reasonChangedMind => 'मन बदल गया';

  @override
  String get reasonNotAsDescribed => 'बताए जैसा नहीं';

  @override
  String get reasonPoorQuality => 'ख़राब क्वालिटी';

  @override
  String get reasonFoundBetter => 'बेहतर विकल्प मिला';

  @override
  String cancelExplainer(String amount) {
    return '$amount तुरंत इस महीने के बजट में वापस आ जाएगा।';
  }

  @override
  String returnExplainer(String amount, String store) {
    return 'इसे $store स्टोर पर जमा करें। $amount अभी इस महीने के बजट में लौटता है, और एक दिन में रिफ़ंड हो जाता है।';
  }

  @override
  String get yourStore => 'पिकअप';

  @override
  String get confirmCancel => 'यह आइटम रद्द करें';

  @override
  String get confirmReturn => 'यह आइटम वापस करें';

  @override
  String get returnInProgress => 'वापसी जारी है';

  @override
  String refunded(String amount) {
    return '$amount रिफ़ंड हुआ';
  }

  @override
  String get orderTotal => 'ऑर्डर का कुल';

  @override
  String get pickupLabel => 'पिकअप';

  @override
  String get pickupFree => 'मुफ़्त · उसी दिन';

  @override
  String get refundedLabel => 'रिफ़ंड';

  @override
  String get youPaid => 'आपने चुकाया';
}
