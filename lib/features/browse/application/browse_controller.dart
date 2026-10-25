import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import '../../home/application/intent_controller.dart';

/// Orders the Browse list. Best fit is the default: Clarion ranks by what
/// suits the user, not by what sells.
enum BrowseSort { bestFit, priceLow, priceHigh, rating, biggestDip }

/// What the Browse list is narrowed to. Every field is optional; the
/// default shows the whole catalogue.
@immutable
class BrowseFilters {
  const BrowseFilters({
    this.category,
    this.maxPrice,
    this.minRating,
    this.pickupOnly = false,
    this.belowAverageOnly = false,
    this.sort = BrowseSort.bestFit,
  });

  final String? category;
  final double? maxPrice;
  final double? minRating;

  /// Only products a nearby store has in stock.
  final bool pickupOnly;

  /// Only products priced under their 30-day average.
  final bool belowAverageOnly;
  final BrowseSort sort;

  /// Filters beyond the category and sort, for the "Filters · 2" badge.
  int get activeCount => [
    maxPrice != null,
    minRating != null,
    pickupOnly,
    belowAverageOnly,
  ].where((on) => on).length;

  BrowseFilters copyWith({
    ValueGetter<String?>? category,
    ValueGetter<double?>? maxPrice,
    ValueGetter<double?>? minRating,
    bool? pickupOnly,
    bool? belowAverageOnly,
    BrowseSort? sort,
  }) => BrowseFilters(
    category: category == null ? this.category : category(),
    maxPrice: maxPrice == null ? this.maxPrice : maxPrice(),
    minRating: minRating == null ? this.minRating : minRating(),
    pickupOnly: pickupOnly ?? this.pickupOnly,
    belowAverageOnly: belowAverageOnly ?? this.belowAverageOnly,
    sort: sort ?? this.sort,
  );

  /// Clears the filters but keeps the category and sort.
  BrowseFilters cleared() => BrowseFilters(category: category, sort: sort);

  /// Narrows and orders [products]. [fitOf] gives each product's live fit
  /// score, used for [BrowseSort.bestFit] and to break ties.
  List<Product> apply(List<Product> products, int Function(Product) fitOf) {
    final result = products
        .where(
          (p) =>
              (category == null || p.category == category) &&
              (maxPrice == null || p.price <= maxPrice!) &&
              (minRating == null || p.rating >= minRating!) &&
              (!pickupOnly || p.pickup != null) &&
              (!belowAverageOnly || p.discountVsAverage > 0),
        )
        .toList();
    int byFit(Product a, Product b) => fitOf(b).compareTo(fitOf(a));
    result.sort(
      (a, b) => switch (sort) {
        BrowseSort.bestFit => byFit(a, b),
        BrowseSort.priceLow => a.price.compareTo(b.price),
        BrowseSort.priceHigh => b.price.compareTo(a.price),
        BrowseSort.rating => b.rating.compareTo(a.rating),
        BrowseSort.biggestDip => b.discountVsAverage.compareTo(
          a.discountVsAverage,
        ),
      }.orElse(() => byFit(a, b)),
    );
    return result;
  }
}

extension on int {
  int orElse(int Function() next) => this == 0 ? next() : this;
}

class BrowseController extends Notifier<BrowseFilters> {
  @override
  BrowseFilters build() => const BrowseFilters();

  void set(BrowseFilters filters) => state = filters;

  /// Opens Browse on one category with no other filters, e.g. from a link.
  void showCategory(String? category) =>
      state = BrowseFilters(category: category, sort: state.sort);
}

final browseProvider = NotifierProvider<BrowseController, BrowseFilters>(
  BrowseController.new,
);

/// Catalogue categories in the order they first appear.
final categoriesProvider = Provider<List<String>>((ref) {
  return {for (final p in ref.watch(catalogProvider).products) p.category}
      .toList();
});

/// The highest price in the catalogue, the top of the price filter.
final priceCeilingProvider = Provider<double>((ref) {
  return ref
      .watch(catalogProvider)
      .products
      .fold<double>(0, (max, p) => p.price > max ? p.price : max);
});

final browseResultsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(catalogProvider).products;
  final scores = {
    for (final p in products) p.id: ref.watch(fitProvider(p.id)).score,
  };
  return ref
      .watch(browseProvider)
      .apply(products, (p) => scores[p.id] ?? p.fitScore);
});
