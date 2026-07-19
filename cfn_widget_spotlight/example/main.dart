import 'dart:async';

import 'package:cfn_widget_spotlight/cfn_widget_spotlight.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SpotlightExample());

class SpotlightExample extends StatefulWidget {
  const SpotlightExample({super.key});

  @override
  State<SpotlightExample> createState() => _SpotlightExampleState();
}

class _SpotlightExampleState extends State<SpotlightExample> {
  final _announcementsKey = GlobalKey();
  final _thesesKey = GlobalKey();
  final _portfolioKey = GlobalKey();
  final _floatingButtonKey = GlobalKey();

  int _selectedTab = 0;

  Future<void> _startTour(BuildContext context) {
    return CfnWidgetSpotlight.showTour(
      context,
      steps: [
        _step(
          tabKey: _announcementsKey,
          tabTitle: 'Announcements',
          tabDescription: 'Stay informed and share updates.',
          actionTitle: 'Keep Members Updated',
          actionDescription: 'Tap here to publish an announcement.',
        ),
        _step(
          tabKey: _thesesKey,
          tabTitle: 'Theses',
          tabDescription: 'Explore and share investment ideas.',
          actionTitle: 'Share Investment Ideas',
          actionDescription: 'Tap the + button to publish your thesis.',
        ),
        _step(
          tabKey: _portfolioKey,
          tabTitle: 'Portfolio',
          tabDescription: 'Track and manage your space portfolio.',
          actionTitle: 'Manage Your Portfolio',
          actionDescription: 'Use this button to manage your positions.',
        ),
      ],
      onStepChanged: (index) {
        if (mounted && index != _selectedTab) {
          setState(() => _selectedTab = index);
        }
      },
      theme: const SpotlightThemeData().copyWith(primaryColor: Colors.indigo),
      barrierDismissible: true,
    ).then((_) {});
  }

  SpotlightStep _step({
    required GlobalKey tabKey,
    required String tabTitle,
    required String tabDescription,
    required String actionTitle,
    required String actionDescription,
  }) {
    return SpotlightStep(
      targets: [
        SpotlightTarget(
          key: tabKey,
          title: tabTitle,
          description: tabDescription,
          placement: SpotlightPlacement.below,
          borderRadius: BorderRadius.circular(100),
          showNavigation: false,
        ),
        SpotlightTarget(
          key: _floatingButtonKey,
          title: actionTitle,
          description: actionDescription,
          placement: SpotlightPlacement.above,
          shape: SpotlightShape.circle,
          showNavigation: true,
        ),
      ],
    );
  }

  IconData get _floatingIcon => switch (_selectedTab) {
    0 => Icons.campaign_outlined,
    1 => Icons.add,
    _ => Icons.swap_vert,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Multi-target tour')),
          body: Column(
            children: [
              Row(
                children: [
                  _tab(_announcementsKey, 'Announcements', 0),
                  _tab(_thesesKey, 'Theses', 1),
                  _tab(_portfolioKey, 'Portfolio', 2),
                ],
              ),
              Expanded(
                child: Center(
                  child: FilledButton(
                    onPressed: () => unawaited(_startTour(context)),
                    child: const Text('Start multi-target tour'),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: KeyedSubtree(
            key: _floatingButtonKey,
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(_floatingIcon),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(GlobalKey key, String label, int index) {
    final selected = index == _selectedTab;
    return Expanded(
      child: InkWell(
        key: key,
        onTap: () => setState(() => _selectedTab = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.indigo : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
