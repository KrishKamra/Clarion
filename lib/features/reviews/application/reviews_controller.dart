import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/catalog.dart';
import '../../../data/mock_reviews.dart';
import '../../../data/models/review_model.dart';
import '../../auth/application/auth_service.dart';

/// The account's own reviews, by product id. One review per product;
/// writing again replaces it.
class MyReviewsController extends Notifier<Map<String, Review>> {
  @override
  Map<String, Review> build() => {
    for (final r in ref.watch(initialReviewsProvider))
      r.productId: _toReview(
        rating: r.rating,
        title: r.title,
        body: r.body,
        date: r.createdAt,
      ),
  };

  void save(
    String productId, {
    required int rating,
    required String body,
    String? title,
  }) {
    final now = DateTime.now();
    final cleanTitle = title?.trim().isEmpty ?? true ? null : title!.trim();
    state = {
      ...state,
      productId: _toReview(
        rating: rating,
        title: cleanTitle,
        body: body.trim(),
        date: now,
      ),
    };
    _persist(
      ref.read(reviewRepositoryProvider)?.save((
        productId: productId,
        rating: rating,
        title: cleanTitle,
        body: body.trim(),
        createdAt: now,
      )),
    );
  }

  void remove(String productId) {
    state = {...state}..remove(productId);
    _persist(ref.read(reviewRepositoryProvider)?.remove(productId));
  }

  Review _toReview({
    required int rating,
    required String? title,
    required String body,
    required DateTime date,
  }) {
    final user = ref.read(currentUserProvider);
    final name = user?.displayName?.trim();
    return Review(
      author: name == null || name.isEmpty ? 'You' : name,
      rating: rating,
      title: title,
      body: body,
      ownedFor: '',
      date: date,
      mine: true,
    );
  }

  void _persist(Future<void>? write) {
    write?.catchError(
      (Object error, StackTrace stack) => developer.log(
        'Could not save review',
        error: error,
        stackTrace: stack,
      ),
    );
  }
}

final myReviewsProvider =
    NotifierProvider<MyReviewsController, Map<String, Review>>(
      MyReviewsController.new,
    );

/// A product's owner reviews: the account's own first, then the rest,
/// newest first.
final productReviewsProvider = Provider.family<List<Review>, String>((
  ref,
  productId,
) {
  final mine = ref.watch(myReviewsProvider)[productId];
  final others = [...MockReviews.forProduct(productId)]
    ..sort((a, b) => b.date.compareTo(a.date));
  return [?mine, ...others];
});

/// The product's rating spread, with the account's own rating counted in.
final ratingSummaryProvider = Provider.family<RatingSummary, String>((
  ref,
  productId,
) {
  final product = ref.watch(catalogProvider).byId(productId);
  final base = RatingSummary.estimate(product.rating, product.reviewCount);
  final mine = ref.watch(myReviewsProvider)[productId];
  if (mine == null) return base;
  final count = base.count + 1;
  return RatingSummary(
    (base.average * base.count + mine.rating) / count,
    count,
    [
      for (var star = 1; star <= 5; star++)
        base.histogram[star - 1] + (star == mine.rating ? 1 : 0),
    ],
  );
});
