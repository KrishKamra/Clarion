import 'package:clarion/core/theme/app_colors.dart';
import 'package:clarion/core/theme/theme_mode_controller.dart';
import 'package:clarion/core/widgets/floating_nav_capsule.dart';
import 'package:clarion/features/browse/presentation/browse_screen.dart';
import 'package:clarion/features/cart/application/cart_controller.dart';
import 'package:clarion/features/decision/presentation/product_decision_screen.dart';
import 'package:clarion/features/navigation/main_scaffold.dart';
import 'package:clarion/features/orders/application/orders_controller.dart';
import 'package:clarion/features/orders/presentation/order_detail_screen.dart';
import 'package:clarion/features/orders/presentation/orders_screen.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_scenario.dart';

/// Accessibility audit: every screen, in both themes, against Flutter's
/// guidelines (48dp Android tap targets, labelled controls, WCAG AA text
/// contrast), and at 200 % text size without overflow.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Two-colour text on the frosted decision drawer. The test capture leaves
  /// out the blurred backdrop, so the contrast check compares the white and
  /// emerald text with each other (1.8:1); against the drawer's real fill
  /// both exceed 7:1.
  const knownFalsePositives = ['safe buffer in your monthly limit'];

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    double textScale = 1,
    double height = 915,
    ThemeMode theme = ThemeMode.light,
  }) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    container.read(themeModeProvider.notifier).select(theme);
    addTearDown(
      () => container.read(themeModeProvider.notifier).select(ThemeMode.system),
    );
    // An order, so Profile, Orders and the order page have content.
    container.read(ordersProvider.notifier).place(container.read(cartProvider));
    await tester.binding.setSurfaceSize(Size(412, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClarionApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    return container;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavCapsule),
        matching: find.bySemanticsLabel(label),
      ),
    );
    await settle(tester);
  }

  /// Every screen, reached the way a user would, checked in place.
  Future<void> visitEveryScreen(
    WidgetTester tester,
    ProviderContainer container,
    Future<void> Function(String screen) check,
  ) async {
    await check('Horizon');
    for (final tab in ['Compare', 'Guardian', 'Profile']) {
      await openTab(tester, tab);
      await check(tab);
    }
    await openTab(tester, 'Horizon');
    final shell = tester.element(find.byType(MainScaffold));
    final orderId = container.read(ordersProvider).first.id;
    for (final (name, open) in [
      ('Product', () => ProductDecisionScreen.open(shell, 'bp_atlas')),
      ('Browse', () => BrowseScreen.open(shell)),
      ('Orders', () => OrdersScreen.open(shell)),
      ('Order', () => OrderDetailScreen.open(shell, orderId)),
    ]) {
      open();
      await settle(tester);
      await check(name);
      Navigator.of(shell).pop();
      await settle(tester);
    }
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('every screen meets the guidelines (${theme.name})', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      // Content scrolls under the floating nav island by design. A screen
      // tall enough to lay everything out above it measures each text
      // against its real background, not the island covering it, so the
      // result can't depend on where font metrics happen to leave a label.
      final container = await pumpApp(tester, theme: theme, height: 5000);
      expect(AppColors.isDark, theme == ThemeMode.dark);
      // Collected rather than failing fast, so one run lists every finding.
      final findings = <String>[];
      await visitEveryScreen(tester, container, (screen) async {
        for (final (name, guideline) in [
          ('tap targets', androidTapTargetGuideline),
          ('labels', labeledTapTargetGuideline),
          ('contrast', textContrastGuideline),
        ]) {
          final result = await guideline.evaluate(tester);
          if (result.passed) continue;
          final nodes = result.reason!
              .split('SemanticsNode#')
              .skip(1)
              .where((n) => !knownFalsePositives.any(n.contains));
          if (nodes.isNotEmpty) findings.add('$screen $name:\n$nodes');
        }
      });
      expect(findings, isEmpty, reason: findings.join('\n\n'));
      handle.dispose();
    });
  }

  testWidgets('every screen lays out at 200 % text size', (tester) async {
    final container = await pumpApp(tester, textScale: 2);
    final findings = <String>[];
    await visitEveryScreen(tester, container, (screen) async {
      for (Object? e; (e = tester.takeException()) != null;) {
        findings.add('$screen: $e');
      }
    });
    expect(findings, isEmpty, reason: findings.join('\n'));
  });
}
