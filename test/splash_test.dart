import 'package:clarion/core/theme/app_spacing.dart';
import 'package:clarion/features/splash/clarion_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(BootStage stage, VoidCallback onDone, {bool reduced = false}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: ClarionSplash(stage: stage, onDone: onDone),
      );

  testWidgets('the splash waits for the app, however long it takes', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(host(BootStage.starting, () => done = true));
    await tester.pump(AppMotion.arrival * 3);
    expect(done, isFalse);
    expect(find.text('WARMING UP'), findsOneWidget);

    await tester.pumpWidget(host(BootStage.opening, () => done = true));
    await tester.pump(AppMotion.arrival);
    expect(done, isFalse);
    expect(find.text('OPENING YOUR LEDGER'), findsOneWidget);

    await tester.pumpWidget(host(BootStage.ready, () => done = true));
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });

  testWidgets('a ready app still lets the arrival finish first', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(host(BootStage.ready, () => done = true));
    await tester.pump(AppMotion.arrival ~/ 2);
    expect(done, isFalse);
    await tester.pump(AppMotion.arrival);
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });

  testWidgets('under reduced motion it shows the lockup and fades out', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(
      host(BootStage.ready, () => done = true, reduced: true),
    );
    expect(find.text('Clarion'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });
}
