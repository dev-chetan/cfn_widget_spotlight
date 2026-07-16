import 'dart:async';

import 'package:cfn_widget_spotlight/cfn_widget_spotlight.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SpotlightDemoApp());

class SpotlightDemoApp extends StatelessWidget {
  const SpotlightDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Widget Spotlight Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087BFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
      ),
      home: const SpotlightDemoScreen(),
    );
  }
}

class SpotlightDemoScreen extends StatefulWidget {
  const SpotlightDemoScreen({super.key});

  @override
  State<SpotlightDemoScreen> createState() => _SpotlightDemoScreenState();
}

class _SpotlightDemoScreenState extends State<SpotlightDemoScreen> {
  final _profileKey = GlobalKey();
  final _announcementsKey = GlobalKey();
  final _analyticsKey = GlobalKey();
  final _createKey = GlobalKey();

  SpotlightThemeData get _spotlightTheme => const SpotlightThemeData().copyWith(
    barrierColor: const Color(0xA90B1220),
    blurSigma: 3,
    primaryColor: const Color(0xFF087BFF),
    highlightBorderColor: const Color(0xFF8AC5FF),
    cardBorderRadius: BorderRadius.circular(22),
  );

  Future<void> _showSingleOverlay() async {
    final result = await CfnWidgetSpotlight.show(
      context,
      theme: _spotlightTheme,
      barrierDismissible: true,
      target: SpotlightTarget(
        key: _profileKey,
        title: 'Personalize Your Profile',
        description:
            'Update your details, manage visibility preferences, and choose '
            'what information you would like to share.',
        placement: SpotlightPlacement.below,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderRadius: BorderRadius.circular(28),
        nextLabel: 'Continue',
      ),
    );
    _showResult(result);
  }

  Future<void> _showMultipleOverlays() async {
    final result = await CfnWidgetSpotlight.showMultiple(
      context,
      theme: _spotlightTheme,
      targets: [
        SpotlightTarget(
          key: _announcementsKey,
          title: 'Announcements',
          description: 'Stay informed and share important updates.',
          placement: SpotlightPlacement.below,
          showNavigation: false,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        SpotlightTarget(
          key: _profileKey,
          title: 'Your Profile',
          description:
              'Open your profile to update personal details and preferences.',
          placement: SpotlightPlacement.below,
          shape: SpotlightShape.circle,
          padding: const EdgeInsets.all(8),
          nextLabel: 'Got it',
        ),
      ],
    );
    _showResult(result);
  }

  Future<void> _showTour() async {
    final result = await CfnWidgetSpotlight.showTour(
      context,
      theme: _spotlightTheme,
      barrierDismissible: true,
      steps: [
        SpotlightStep.single(
          SpotlightTarget(
            key: _profileKey,
            title: 'Welcome to Your Space',
            description:
                'Start here to manage your public profile and preferences.',
            placement: SpotlightPlacement.below,
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _announcementsKey,
            title: 'Share Announcements',
            description: 'Keep everyone aligned with timely updates.',
            placement: SpotlightPlacement.below,
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _analyticsKey,
            title: 'Understand Engagement',
            description:
                'See member activity and measure how your space is growing.',
            placement: SpotlightPlacement.above,
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _createKey,
            title: 'Create Something New',
            description: 'You are ready—tap here whenever you want to publish.',
            placement: SpotlightPlacement.above,
            shape: SpotlightShape.roundedRectangle,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.all(6),
            nextLabel: 'Finish tour',
          ),
        ),
      ],
    );
    _showResult(result);
  }

  void _showResult(SpotlightResult result) {
    if (!mounted) return;
    final message = switch (result.reason) {
      SpotlightDismissReason.completed => 'Overlay completed',
      SpotlightDismissReason.barrierTap => 'Overlay dismissed',
      SpotlightDismissReason.skipped => 'Tour skipped',
      SpotlightDismissReason.programmatic => 'Overlay closed',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Spotlight Playground',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              key: _profileKey,
              backgroundColor: const Color(0xFFDCEBFF),
              child: const Icon(Icons.person_outline, color: Color(0xFF087BFF)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
        children: [
          const _IntroCard(),
          const SizedBox(height: 22),
          const Text(
            'Try an overlay',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _DemoButton(
            icon: Icons.filter_1_outlined,
            title: 'Single overlay',
            subtitle: 'Highlight the profile action with one guide card.',
            onTap: () => unawaited(_showSingleOverlay()),
          ),
          const SizedBox(height: 10),
          _DemoButton(
            icon: Icons.layers_outlined,
            title: 'Multiple overlays',
            subtitle: 'Show two highlights and guide cards at the same time.',
            onTap: () => unawaited(_showMultipleOverlays()),
          ),
          const SizedBox(height: 10),
          _DemoButton(
            icon: Icons.route_outlined,
            title: 'Guided tour',
            subtitle: 'Move through four targets using next and back.',
            onTap: () => unawaited(_showTour()),
          ),
          const SizedBox(height: 24),
          const Text(
            'Example space',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  targetKey: _announcementsKey,
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  value: '12 updates',
                  color: const Color(0xFF087BFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FeatureCard(
                  targetKey: _analyticsKey,
                  icon: Icons.insights_outlined,
                  title: 'Analytics',
                  value: '68% active',
                  color: const Color(0xFF7657E8),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: _createKey,
        onPressed: () {},
        backgroundColor: const Color(0xFF087BFF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087BFF), Color(0xFF7657E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33087BFF),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.highlight_alt, color: Colors.white, size: 32),
          SizedBox(height: 16),
          Text(
            'Explore every overlay mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'These examples use the linked cfn_widget_spotlight package.',
            style: TextStyle(color: Color(0xFFEAF3FF), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF087BFF)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.targetKey,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final GlobalKey targetKey;
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: targetKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
