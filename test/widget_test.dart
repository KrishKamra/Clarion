import 'package:flutter_test/flutter_test.dart';
import 'package:clarion/main.dart';

void main() {
  testWidgets('Clarion widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClarionApp());

    expect(find.text('Clarion'), findsOneWidget);
    expect(
      find.text('What are you looking to accomplish?'),
      findsOneWidget,
    );

    expect(find.text('94% Fit'), findsOneWidget);
    expect(find.text('88% Fit'), findsOneWidget);
    expect(find.text('81% Fit'), findsOneWidget);
  });
}
