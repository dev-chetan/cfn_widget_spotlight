import 'dart:async';

import 'package:cfn_widget_spotlight/cfn_widget_spotlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows and completes a single spotlight', (tester) async {
    final targetKey = GlobalKey();

    await tester.pumpWidget(
      _TestApp(
        targetKey: targetKey,
        onShow: (context) {
          unawaited(
            CfnWidgetSpotlight.show(
              context,
              target: SpotlightTarget(
                key: targetKey,
                title: 'Profile',
                description: 'Update your profile details.',
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('moves forward and backward through a tour', (tester) async {
    final firstKey = GlobalKey();
    final secondKey = GlobalKey();

    await tester.pumpWidget(
      _TwoTargetApp(
        firstKey: firstKey,
        secondKey: secondKey,
        onShow: (context) {
          unawaited(
            CfnWidgetSpotlight.showTour(
              context,
              steps: [
                SpotlightStep.single(
                  SpotlightTarget(key: firstKey, title: 'First'),
                ),
                SpotlightStep.single(
                  SpotlightTarget(key: secondKey, title: 'Second'),
                ),
              ],
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('2 of 2'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
  });

  testWidgets('supports multiple simultaneous targets and custom content', (
    tester,
  ) async {
    final firstKey = GlobalKey();
    final secondKey = GlobalKey();

    await tester.pumpWidget(
      _TwoTargetApp(
        firstKey: firstKey,
        secondKey: secondKey,
        onShow: (context) {
          unawaited(
            CfnWidgetSpotlight.showMultiple(
              context,
              targets: [
                SpotlightTarget(
                  key: firstKey,
                  title: 'Information only',
                  showNavigation: false,
                ),
                SpotlightTarget(
                  key: secondKey,
                  contentBuilder: (context, details) => Material(
                    child: Text('Custom target ${details.targetIndex + 1}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Information only'), findsOneWidget);
    expect(find.text('Custom target 2'), findsOneWidget);
  });

  testWidgets('customizes the default card, button, and navigation row', (
    tester,
  ) async {
    final targetKey = GlobalKey();
    SpotlightResult? result;

    await tester.pumpWidget(
      _TestApp(
        targetKey: targetKey,
        onShow: (context) async {
          result = await CfnWidgetSpotlight.show(
            context,
            target: SpotlightTarget(
              key: targetKey,
              title: 'Styled card',
              bodyBuilder: (context, details) => const Text('Rich body'),
              cardColor: Colors.black,
              cardBorderRadius: BorderRadius.circular(36),
              cardPadding: const EdgeInsets.all(24),
              navigationBuilder: (context, navigation) => FilledButton(
                onPressed: navigation.next,
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Custom action'),
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Styled card'), findsOneWidget);
    expect(find.text('Rich body'), findsOneWidget);
    expect(find.text('Custom action'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.color == Colors.black &&
            widget.borderRadius == BorderRadius.circular(36),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Custom action'));
    await tester.pumpAndSettle();
    expect(result?.completed, isTrue);
  });

  testWidgets('can dismiss by tapping the barrier', (tester) async {
    final targetKey = GlobalKey();
    SpotlightResult? result;

    await tester.pumpWidget(
      _TestApp(
        targetKey: targetKey,
        onShow: (context) async {
          result = await CfnWidgetSpotlight.show(
            context,
            target: SpotlightTarget(key: targetKey, title: 'Dismiss me'),
            barrierDismissible: true,
          );
        },
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(result?.reason, SpotlightDismissReason.barrierTap);
    expect(find.text('Dismiss me'), findsNothing);
  });

  testWidgets('can pass taps through the highlighted cutout', (tester) async {
    await tester.pumpWidget(const _InteractiveTargetApp());

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Target 0'));
    await tester.pump();

    expect(find.text('Target 1'), findsOneWidget);
    expect(find.text('Tap the target'), findsOneWidget);
  });

  testWidgets('flips an explicit placement when the card would overlap', (
    tester,
  ) async {
    final targetKey = GlobalKey();
    final cardKey = GlobalKey();

    await tester.pumpWidget(
      _BottomTargetApp(targetKey: targetKey, cardKey: cardKey),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final targetRect = tester.getRect(find.byKey(targetKey));
    final cardRect = tester.getRect(find.byKey(cardKey));
    expect(cardRect.overlaps(targetRect), isFalse);
  });

  testWidgets('keeps guide content above the software keyboard', (
    tester,
  ) async {
    final targetKey = GlobalKey();
    final cardKey = GlobalKey();
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      _KeyboardTargetApp(targetKey: targetKey, cardKey: cardKey),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final targetRect = tester.getRect(find.byKey(targetKey));
    final cardRect = tester.getRect(find.byKey(cardKey));
    final keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio - 300;
    expect(cardRect.bottom, lessThanOrEqualTo(keyboardTop));
    expect(cardRect.overlaps(targetRect), isFalse);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.targetKey, required this.onShow});

  final GlobalKey targetKey;
  final ValueChanged<BuildContext> onShow;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                key: targetKey,
                onPressed: () {},
                child: const Text('Target'),
              ),
              ElevatedButton(
                onPressed: () => onShow(context),
                child: const Text('Show'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoTargetApp extends StatelessWidget {
  const _TwoTargetApp({
    required this.firstKey,
    required this.secondKey,
    required this.onShow,
  });

  final GlobalKey firstKey;
  final GlobalKey secondKey;
  final ValueChanged<BuildContext> onShow;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                key: firstKey,
                onPressed: () {},
                child: const Text('Target one'),
              ),
              const Spacer(),
              ElevatedButton(
                key: secondKey,
                onPressed: () {},
                child: const Text('Target two'),
              ),
              ElevatedButton(
                onPressed: () => onShow(context),
                child: const Text('Show'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveTargetApp extends StatefulWidget {
  const _InteractiveTargetApp();

  @override
  State<_InteractiveTargetApp> createState() => _InteractiveTargetAppState();
}

class _InteractiveTargetAppState extends State<_InteractiveTargetApp> {
  final _targetKey = GlobalKey();
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                key: _targetKey,
                onPressed: () => setState(() => _count++),
                child: Text('Target $_count'),
              ),
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    CfnWidgetSpotlight.show(
                      context,
                      target: SpotlightTarget(
                        key: _targetKey,
                        title: 'Tap the target',
                        allowTargetInteraction: true,
                      ),
                    ),
                  );
                },
                child: const Text('Show'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTargetApp extends StatelessWidget {
  const _BottomTargetApp({required this.targetKey, required this.cardKey});

  final GlobalKey targetKey;
  final GlobalKey cardKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    CfnWidgetSpotlight.show(
                      context,
                      target: SpotlightTarget(
                        key: targetKey,
                        placement: SpotlightPlacement.below,
                        contentBuilder: (context, details) => SizedBox(
                          key: cardKey,
                          width: 240,
                          height: 140,
                          child: const ColoredBox(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show'),
              ),
              const Spacer(),
              SizedBox(
                key: targetKey,
                width: 160,
                height: 80,
                child: const ColoredBox(color: Colors.blue),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardTargetApp extends StatelessWidget {
  const _KeyboardTargetApp({required this.targetKey, required this.cardKey});

  final GlobalKey targetKey;
  final GlobalKey cardKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    CfnWidgetSpotlight.show(
                      context,
                      target: SpotlightTarget(
                        key: targetKey,
                        placement: SpotlightPlacement.below,
                        contentBuilder: (context, details) => SizedBox(
                          key: cardKey,
                          width: 240,
                          height: 140,
                          child: const ColoredBox(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Show'),
              ),
              const SizedBox(height: 160),
              SizedBox(
                key: targetKey,
                width: 160,
                height: 48,
                child: const ColoredBox(color: Colors.blue),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
