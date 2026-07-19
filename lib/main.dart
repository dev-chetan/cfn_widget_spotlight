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

  void _openThesisDemo() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ThesisSpotlightDemo()),
    );
  }

  void _openSharedFabDemo() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SharedFabSpotlightDemo()),
    );
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
          const SizedBox(height: 10),
          _DemoButton(
            icon: Icons.control_point_duplicate_outlined,
            title: 'Shared FAB multi-target tour',
            subtitle:
                'Highlight a tab and one shared floating button per step.',
            onTap: _openSharedFabDemo,
          ),
          const SizedBox(height: 10),
          _DemoButton(
            icon: Icons.keyboard_alt_outlined,
            title: 'Keyboard & rich content',
            subtitle: 'Try a five-step thesis tour while typing.',
            onTap: _openThesisDemo,
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

class SharedFabSpotlightDemo extends StatefulWidget {
  const SharedFabSpotlightDemo({super.key});

  @override
  State<SharedFabSpotlightDemo> createState() => _SharedFabSpotlightDemoState();
}

class _SharedFabSpotlightDemoState extends State<SharedFabSpotlightDemo> {
  final _announcementsKey = GlobalKey();
  final _thesesKey = GlobalKey();
  final _portfolioKey = GlobalKey();
  final _floatingButtonKey = GlobalKey();

  int _selectedTab = 0;

  static const _tabLabels = ['Announcements', 'Theses', 'Portfolio'];

  SpotlightThemeData get _theme => const SpotlightThemeData().copyWith(
    barrierColor: const Color(0xA90B1220),
    blurSigma: 3,
    primaryColor: const Color(0xFF087BFF),
    highlightBorderColor: const Color(0xFF8AC5FF),
    cardBorderRadius: BorderRadius.circular(22),
  );

  Future<void> _startTour() async {
    if (_selectedTab != 0) {
      setState(() => _selectedTab = 0);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;

    await CfnWidgetSpotlight.showTour(
      context,
      theme: _theme,
      barrierDismissible: true,
      onStepChanged: (index) {
        if (mounted && _selectedTab != index) {
          setState(() => _selectedTab = index);
        }
      },
      steps: [
        _buildStep(
          tabKey: _announcementsKey,
          tabTitle: 'Announcements',
          tabDescription: 'Stay informed and share updates.',
          actionTitle: 'Keep Members Updated',
          actionDescription:
              'Share announcements, events, and important notices.',
        ),
        _buildStep(
          tabKey: _thesesKey,
          tabTitle: 'Theses',
          tabDescription: 'Explore and share investment ideas.',
          actionTitle: 'Share Investment Ideas',
          actionDescription:
              'Browse member theses, then tap the + button to publish yours.',
        ),
        _buildStep(
          tabKey: _portfolioKey,
          tabTitle: 'Portfolio',
          tabDescription: 'Track and manage your space portfolio.',
          actionTitle: 'Manage Your Space Portfolio',
          actionDescription:
              'Use the transact button to place trades and manage positions.',
        ),
      ],
    );
  }

  SpotlightStep _buildStep({
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          showNavigation: false,
        ),
        SpotlightTarget(
          key: _floatingButtonKey,
          title: actionTitle,
          description: actionDescription,
          placement: SpotlightPlacement.above,
          shape: SpotlightShape.circle,
          padding: const EdgeInsets.all(6),
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

  String get _pageTitle => switch (_selectedTab) {
    0 => 'Latest announcements',
    1 => 'Investment theses',
    _ => 'Space portfolio',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shared FAB Tour',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Start shared FAB tour',
            onPressed: () => unawaited(_startTour()),
            icon: const Icon(Icons.play_circle_outline),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: List.generate(_tabLabels.length, (index) {
                final keys = [_announcementsKey, _thesesKey, _portfolioKey];
                final selected = index == _selectedTab;
                return Expanded(
                  child: InkWell(
                    key: keys[index],
                    onTap: () => setState(() => _selectedTab = index),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEAF3FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border(
                          bottom: BorderSide(
                            width: 3,
                            color: selected
                                ? const Color(0xFF087BFF)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabLabels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF087BFF)
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_floatingIcon, size: 72, color: const Color(0xFF87BFFF)),
                  const SizedBox(height: 16),
                  Text(
                    _pageTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Press play to start the multi-target tour.'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: KeyedSubtree(
        key: _floatingButtonKey,
        child: FloatingActionButton(
          heroTag: 'shared-fab-demo',
          onPressed: () {},
          backgroundColor: const Color(0xFF087BFF),
          foregroundColor: Colors.white,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(_floatingIcon, key: ValueKey(_selectedTab)),
          ),
        ),
      ),
    );
  }
}

class ThesisSpotlightDemo extends StatefulWidget {
  const ThesisSpotlightDemo({super.key});

  @override
  State<ThesisSpotlightDemo> createState() => _ThesisSpotlightDemoState();
}

class _ThesisSpotlightDemoState extends State<ThesisSpotlightDemo> {
  final _assetKey = GlobalKey();
  final _sentimentKey = GlobalKey();
  final _targetKey = GlobalKey();
  final _thesisKey = GlobalKey();
  final _continueKey = GlobalKey();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _startTour() async {
    _focusNode.requestFocus();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final result = await CfnWidgetSpotlight.showTour(
      context,
      theme: const SpotlightThemeData().copyWith(
        primaryColor: const Color(0xFF087BFF),
        cardBorderRadius: BorderRadius.circular(24),
        avoidKeyboard: true,
      ),
      barrierDismissible: true,
      steps: [
        SpotlightStep.single(
          SpotlightTarget(
            key: _assetKey,
            title: 'Attach an Asset',
            description:
                'Connect the investment or company this thesis is about.',
            placement: SpotlightPlacement.below,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _thesisKey,
            title: 'Write Your Thesis',
            description:
                'Explain your view clearly so other investors can understand '
                'your reasoning.',
            placement: SpotlightPlacement.above,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _sentimentKey,
            title: 'What’s your outlook?',
            placement: SpotlightPlacement.below,
            borderRadius: BorderRadius.circular(100),
            cardBorderRadius: BorderRadius.circular(24),
            bodyBuilder: (context, details) => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OutlookRow(
                  color: Color(0xFF16A34A),
                  icon: Icons.trending_up,
                  title: 'Bullish',
                  subtitle: 'Price will go up',
                ),
                _OutlookRow(
                  color: Color(0xFFEF233C),
                  icon: Icons.trending_down,
                  title: 'Bearish',
                  subtitle: 'Price will go down',
                ),
                _OutlookRow(
                  color: Color(0xFFFFB000),
                  icon: Icons.horizontal_rule,
                  title: 'Neutral',
                  subtitle: 'Price will stay within a range',
                ),
              ],
            ),
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _targetKey,
            title: 'Set your thesis target (Optional)',
            description: 'You can specify:',
            placement: SpotlightPlacement.below,
            borderRadius: BorderRadius.circular(100),
            cardBorderRadius: BorderRadius.circular(24),
            bodyBuilder: (context, details) => const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DefinitionRow('Current Price', 'The current market price'),
                _DefinitionRow('Entry Price', 'Your ideal entry price'),
                _DefinitionRow('Target Price', 'Your expected target price'),
                _DefinitionRow('Time Horizon', 'The timeframe for your thesis'),
              ],
            ),
          ),
        ),
        SpotlightStep.single(
          SpotlightTarget(
            key: _continueKey,
            title: 'Publish Your Thesis',
            description:
                'Review your selections, then continue when you are ready.',
            placement: SpotlightPlacement.below,
            borderRadius: BorderRadius.circular(100),
            nextLabel: 'Finish',
          ),
        ),
      ],
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.completed ? 'Thesis tour completed' : 'Tour closed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset Thesis',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            key: _continueKey,
            onPressed: () {},
            child: const Text('Continue'),
          ),
          IconButton(
            tooltip: 'Start spotlight tour',
            onPressed: () => unawaited(_startTour()),
            icon: const Icon(Icons.play_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            'What’s your investment thesis?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ThesisChip(
                targetKey: _assetKey,
                icon: Icons.attach_money,
                label: 'Asset',
              ),
              const SizedBox(width: 8),
              _ThesisChip(
                targetKey: _sentimentKey,
                icon: Icons.bar_chart,
                label: 'Sentiment',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThesisChip(
                  targetKey: _targetKey,
                  icon: Icons.ads_click,
                  label: 'Target (opt.)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            key: _thesisKey,
            focusNode: _focusNode,
            autofocus: true,
            minLines: 5,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'What makes you believe in this investment?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => unawaited(_startTour()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start thesis tour'),
          ),
        ],
      ),
    );
  }
}

class _ThesisChip extends StatelessWidget {
  const _ThesisChip({
    required this.targetKey,
    required this.icon,
    required this.label,
  });

  final GlobalKey targetKey;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: targetKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFD8E5F4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF58708F)),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF58708F)),
          ),
        ],
      ),
    );
  }
}

class _OutlookRow extends StatelessWidget {
  const _OutlookRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF7A8CA8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefinitionRow extends StatelessWidget {
  const _DefinitionRow(this.title, this.description);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(description),
        ],
      ),
    );
  }
}
