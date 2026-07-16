import 'package:flutter_test/flutter_test.dart';
import 'package:widget_spotlight/main.dart';

void main() {
  testWidgets('shows the example and opens a single overlay', (tester) async {
    await tester.pumpWidget(const SpotlightDemoApp());

    expect(find.text('Spotlight Playground'), findsOneWidget);
    expect(find.text('Single overlay'), findsOneWidget);
    expect(find.text('Multiple overlays'), findsOneWidget);
    expect(find.text('Guided tour'), findsOneWidget);

    await tester.tap(find.text('Single overlay'));
    await tester.pumpAndSettle();

    expect(find.text('Personalize Your Profile'), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Overlay completed'), findsOneWidget);
  });
}
