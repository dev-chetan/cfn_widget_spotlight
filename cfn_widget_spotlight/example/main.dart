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
  final _profileKey = GlobalKey();
  final _createKey = GlobalKey();

  Future<void> _startTour(BuildContext context) {
    return CfnWidgetSpotlight.showTour(
      context,
      steps: [
        SpotlightStep.single(
          SpotlightTarget(
            key: _profileKey,
            title: 'Your profile',
            description: 'Manage your public details and preferences here.',
            placement: SpotlightPlacement.below,
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _createKey,
            title: 'Create something',
            description: 'Use this action whenever you are ready to publish.',
            placement: SpotlightPlacement.above,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
      theme: const SpotlightThemeData().copyWith(primaryColor: Colors.indigo),
      barrierDismissible: true,
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Spotlight example'),
            actions: [
              IconButton(
                key: _profileKey,
                onPressed: () {},
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
          body: Center(
            child: FilledButton(
              onPressed: () => unawaited(_startTour(context)),
              child: const Text('Start tour'),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: _createKey,
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ),
      ),
    );
  }
}
