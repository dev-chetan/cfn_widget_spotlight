import 'package:flutter/material.dart';
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

  testWidgets('opens the keyboard rich-content thesis tour', (tester) async {
    await tester.pumpWidget(const SpotlightDemoApp());

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keyboard & rich content'));
    await tester.pumpAndSettle();
    expect(find.text('Asset Thesis'), findsOneWidget);

    await tester.tap(find.byTooltip('Start spotlight tour'));
    await tester.pumpAndSettle();
    expect(find.text('Attach an Asset'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('What’s your outlook?'), findsOneWidget);
    expect(find.text('Bullish'), findsOneWidget);
    expect(find.text('Bearish'), findsOneWidget);
    expect(find.text('Neutral'), findsOneWidget);
  });

  testWidgets('shows a tab and shared FAB in each tour step', (tester) async {
    await tester.pumpWidget(const SpotlightDemoApp());

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shared FAB multi-target tour'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Start shared FAB tour'));
    await tester.pumpAndSettle();

    expect(find.text('Keep Members Updated'), findsOneWidget);
    expect(find.text('Stay informed and share updates.'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Share Investment Ideas'), findsOneWidget);
    expect(find.text('Explore and share investment ideas.'), findsOneWidget);
    expect(find.text('2 of 3'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
