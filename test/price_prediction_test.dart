import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/features/decision/application/price_prediction_engine.dart';
import 'package:clarion/features/decision/widgets/buy_or_wait_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PricePredictionEngine', () {
    test('recommends Buy Now when product price is near its 30-day low', () {
      // hp_pro: price 1899 vs avg 2350 (at 30d low)
      final product = MockCatalog.products.firstWhere((p) => p.id == 'hp_pro');
      final verdict = PricePredictionEngine.analyze(product);

      expect(verdict.shouldBuyNow, isTrue);
      expect(verdict.recommendation, BuyOrWaitRecommendation.buyNow);
      expect(verdict.estimatedSavings, equals(0));
      expect(verdict.confidence, PredictionConfidence.high);
      expect(verdict.confidencePercentage, greaterThanOrEqualTo(80));
    });

    test('recommends Wait when product price is above average in its band', () {
      // bp_metro: price 1749 vs avg 1720
      final product = MockCatalog.products.firstWhere((p) => p.id == 'bp_metro');
      final verdict = PricePredictionEngine.analyze(product);

      expect(verdict.shouldWait, isTrue);
      expect(verdict.recommendation, BuyOrWaitRecommendation.wait);
      expect(verdict.estimatedSavings, greaterThanOrEqualTo(0));
      expect(verdict.estimatedWaitWeeks, greaterThanOrEqualTo(1));
      expect(verdict.explanation, contains('Waiting'));
      expect(verdict.confidencePercentage, greaterThanOrEqualTo(50));
    });
  });

  group('BuyOrWaitCard Widget', () {
    testWidgets('renders BuyOrWaitCard with verdict and confidence meter', (tester) async {
      final product = MockCatalog.products.firstWhere((p) => p.id == 'hp_pro');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BuyOrWaitCard(product: product),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BUY NOW OR WAIT?'), findsOneWidget);
      expect(find.text('PREDICTION CONFIDENCE'), findsOneWidget);
    });
  });
}
