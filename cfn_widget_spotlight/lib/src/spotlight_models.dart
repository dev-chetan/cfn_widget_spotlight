import 'package:flutter/material.dart';

import 'spotlight_controller.dart';

/// Where a target's content card should be placed.
enum SpotlightPlacement {
  /// Chooses the side with enough available space automatically.
  auto,

  /// Places the content card above the target when possible.
  above,

  /// Places the content card below the target when possible.
  below,

  /// Places the content card to the left of the target when possible.
  left,

  /// Places the content card to the right of the target when possible.
  right,
}

/// How a card is aligned along the edge of its target.
enum SpotlightAlignment {
  /// Aligns the leading edge of the card and target.
  start,

  /// Centers the card along the target edge.
  center,

  /// Aligns the trailing edge of the card and target.
  end,
}

/// The shape cut out around a highlighted widget.
enum SpotlightShape {
  /// Uses [SpotlightTarget.borderRadius] to create a rounded rectangle.
  roundedRectangle,

  /// Uses a rectangle with square corners.
  rectangle,

  /// Uses a circle based on the target's shortest dimension.
  circle,

  /// Uses an oval that fills the target bounds.
  oval,
}

/// Why a spotlight overlay was closed.
enum SpotlightDismissReason {
  /// The user advanced through the final step.
  completed,

  /// The tour was closed with [SpotlightController.skip].
  skipped,

  /// A dismissible backdrop was tapped.
  barrierTap,

  /// The tour was closed with [SpotlightController.dismiss].
  programmatic,
}

/// The result returned when a spotlight tour closes.
@immutable
class SpotlightResult {
  /// Creates the result returned by a closed spotlight session.
  const SpotlightResult({required this.reason, required this.lastStepIndex});

  /// The action that closed the overlay.
  final SpotlightDismissReason reason;

  /// The zero-based step index that was visible when the overlay closed.
  final int lastStepIndex;

  /// Whether the user advanced through the final tour step.
  bool get completed => reason == SpotlightDismissReason.completed;
}

/// Information passed to a custom target content builder.
@immutable
class SpotlightContentDetails {
  /// Creates details supplied to a [SpotlightContentBuilder].
  const SpotlightContentDetails({
    required this.controller,
    required this.stepIndex,
    required this.stepCount,
    required this.targetIndex,
    required this.targetCount,
    required this.targetRect,
  });

  /// Controls navigation and dismissal for the active tour.
  final SpotlightController controller;

  /// The zero-based index of the active tour step.
  final int stepIndex;

  /// The total number of steps in the tour.
  final int stepCount;

  /// The zero-based index of this target within its step.
  final int targetIndex;

  /// The number of targets displayed in the active step.
  final int targetCount;

  /// The measured overlay-space bounds of the highlighted target.
  final Rect targetRect;

  /// Whether the active step is the first step in the tour.
  bool get isFirstStep => stepIndex == 0;

  /// Whether the active step is the final step in the tour.
  bool get isLastStep => stepIndex == stepCount - 1;
}

/// Builds fully custom content for a [SpotlightTarget].
///
/// Use [SpotlightContentDetails.controller] to provide custom navigation
/// controls from the returned widget.
typedef SpotlightContentBuilder =
    Widget Function(BuildContext context, SpotlightContentDetails details);

/// Builds rich body content inside the package's default card.
///
/// Unlike [SpotlightContentBuilder], this preserves the default card surface,
/// title, navigation row, and all card/button styling.
typedef SpotlightBodyBuilder =
    Widget Function(BuildContext context, SpotlightContentDetails details);

/// Information passed to a custom navigation-row builder.
@immutable
class SpotlightNavigationDetails {
  /// Creates navigation details for the default spotlight card.
  const SpotlightNavigationDetails({
    required this.controller,
    required this.stepIndex,
    required this.stepCount,
    required this.nextLabel,
    required this.backLabel,
  });

  /// Controls the active spotlight tour.
  final SpotlightController controller;

  /// The zero-based index of the active tour step.
  final int stepIndex;

  /// The total number of tour steps.
  final int stepCount;

  /// The resolved label for the next or done action.
  final String nextLabel;

  /// The resolved label for the back action.
  final String backLabel;

  /// A ready-to-display progress label such as `2 of 4`.
  String get progressLabel => '${stepIndex + 1} of $stepCount';

  /// Whether the back action should be available.
  bool get canGoBack => stepIndex > 0;

  /// Whether the active step is the final step.
  bool get isLastStep => stepIndex == stepCount - 1;

  /// Advances the tour or completes it from the final step.
  void next() => controller.next();

  /// Returns to the previous step when [canGoBack] is true.
  void back() => controller.previous();

  /// Closes the active tour as skipped.
  void skip() => controller.skip();
}

/// Builds a completely custom navigation row inside the default card.
typedef SpotlightNavigationBuilder =
    Widget Function(BuildContext context, SpotlightNavigationDetails details);

/// A widget to highlight and the content associated with it.
@immutable
class SpotlightTarget {
  /// Creates a target and its associated guide content.
  ///
  /// At least one of [title], [description], or [contentBuilder] is required.
  const SpotlightTarget({
    required this.key,
    this.title,
    this.description,
    this.contentBuilder,
    this.bodyBuilder,
    this.navigationBuilder,
    this.placement = SpotlightPlacement.auto,
    this.alignment = SpotlightAlignment.center,
    this.shape = SpotlightShape.roundedRectangle,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.gap = 8,
    this.offset = Offset.zero,
    this.maxContentWidth = 360,
    this.showPointer = true,
    this.showNavigation = true,
    this.allowTargetInteraction = false,
    this.onTargetTap,
    this.nextLabel,
    this.backLabel,
    this.semanticLabel,
    this.cardColor,
    this.cardBorderRadius,
    this.cardBorderSide,
    this.cardPadding,
    this.cardElevation,
    this.titleStyle,
    this.descriptionStyle,
    this.progressStyle,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
  }) : assert(
         title != null ||
             description != null ||
             contentBuilder != null ||
             bodyBuilder != null ||
             navigationBuilder != null,
         'Provide title, description, contentBuilder, bodyBuilder, or '
         'navigationBuilder.',
       );

  /// The key of a mounted widget to spotlight.
  final GlobalKey key;

  /// The heading displayed by the default content card.
  final String? title;

  /// The body displayed by the default content card.
  final String? description;

  /// Replaces the package's default card completely.
  final SpotlightContentBuilder? contentBuilder;

  /// Adds rich content between the default description and navigation row.
  final SpotlightBodyBuilder? bodyBuilder;

  /// Replaces only the progress and button row in the default card.
  final SpotlightNavigationBuilder? navigationBuilder;

  /// The preferred side on which to place the content card.
  final SpotlightPlacement placement;

  /// The card alignment along the selected target edge.
  final SpotlightAlignment alignment;

  /// The cutout shape used to reveal the target.
  final SpotlightShape shape;

  /// Space added around the measured target bounds.
  final EdgeInsets padding;

  /// Corner radii used when [shape] is rounded rectangle.
  final BorderRadius borderRadius;

  /// Minimum distance between the target, pointer, and content card.
  final double gap;

  /// A final positional adjustment applied to the card and pointer.
  final Offset offset;

  /// The maximum width allowed for the content card.
  final double maxContentWidth;

  /// Whether to draw a pointer between the card and target.
  final bool showPointer;

  /// Whether the default card includes progress and next/back controls.
  final bool showNavigation;

  /// Lets pointer events inside the cutout reach the highlighted widget.
  ///
  /// This is ignored when [onTargetTap] is supplied because the overlay handles
  /// the tap in that case.
  final bool allowTargetInteraction;

  /// Handles taps in the highlighted region instead of passing them through.
  final VoidCallback? onTargetTap;

  /// Overrides the next or done label in the default card.
  final String? nextLabel;

  /// Overrides the back label in the default card.
  final String? backLabel;

  /// Describes this target to accessibility services.
  final String? semanticLabel;

  /// Overrides [SpotlightThemeData.cardColor] for this target.
  final Color? cardColor;

  /// Overrides [SpotlightThemeData.cardBorderRadius] for this target.
  final BorderRadius? cardBorderRadius;

  /// Overrides [SpotlightThemeData.cardBorderSide] for this target.
  final BorderSide? cardBorderSide;

  /// Overrides [SpotlightThemeData.cardPadding] for this target.
  final EdgeInsets? cardPadding;

  /// Overrides [SpotlightThemeData.cardElevation] for this target.
  final double? cardElevation;

  /// Overrides [SpotlightThemeData.titleStyle] for this target.
  final TextStyle? titleStyle;

  /// Overrides [SpotlightThemeData.descriptionStyle] for this target.
  final TextStyle? descriptionStyle;

  /// Overrides [SpotlightThemeData.progressStyle] for this target.
  final TextStyle? progressStyle;

  /// Overrides the primary next or done button style for this target.
  final ButtonStyle? primaryButtonStyle;

  /// Overrides the secondary back button style for this target.
  final ButtonStyle? secondaryButtonStyle;
}

/// One page in a tour. A page can highlight one or many widgets at once.
@immutable
class SpotlightStep {
  /// Creates a step that displays one or more targets simultaneously.
  SpotlightStep({required List<SpotlightTarget> targets, this.semanticLabel})
    : assert(targets.isNotEmpty),
      targets = List.unmodifiable(targets);

  /// Creates a step containing exactly one [target].
  SpotlightStep.single(SpotlightTarget target, {this.semanticLabel})
    : targets = List.unmodifiable([target]);

  /// The immutable targets displayed during this step.
  final List<SpotlightTarget> targets;

  /// Describes this step to accessibility services.
  final String? semanticLabel;
}

/// Visual defaults for an entire spotlight tour.
@immutable
class SpotlightThemeData {
  /// Creates visual defaults for spotlight cutouts, cards, and navigation.
  const SpotlightThemeData({
    this.barrierColor = const Color(0xA60B1220),
    this.blurSigma = 2.5,
    this.highlightColor = Colors.white,
    this.highlightBorderColor = const Color(0xFF9ACBFF),
    this.highlightBorderWidth = 1.5,
    this.highlightElevation = 10,
    this.highlightShadowColor = const Color(0x73000000),
    this.cardColor = const Color(0xFFF8FAFD),
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(22)),
    this.cardBorderSide = BorderSide.none,
    this.cardPadding = const EdgeInsets.all(16),
    this.cardElevation = 10,
    this.titleStyle = const TextStyle(
      color: Color(0xFF101828),
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    this.descriptionStyle = const TextStyle(
      color: Color(0xFF101828),
      fontSize: 14,
      height: 1.25,
    ),
    this.progressStyle = const TextStyle(
      color: Color(0xFF7A8CA8),
      fontSize: 14,
    ),
    this.primaryColor = const Color(0xFF087BFF),
    this.primaryForegroundColor = Colors.white,
    this.secondaryForegroundColor = const Color(0xFF58708F),
    this.pointerColor = const Color(0xFFF8FAFD),
    this.pointerSize = const Size(18, 10),
    this.screenPadding = const EdgeInsets.all(18),
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOutCubic,
    this.nextLabel = 'Next',
    this.doneLabel = 'Done',
    this.backLabel = 'Back',
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.avoidKeyboard = true,
  });

  /// Color painted over content outside highlighted cutouts.
  final Color barrierColor;

  /// Gaussian blur strength applied behind the barrier.
  final double blurSigma;

  /// Color of the soft halo surrounding a highlighted target.
  final Color highlightColor;

  /// Color of the target cutout border.
  final Color highlightBorderColor;

  /// Width of the target cutout border.
  final double highlightBorderWidth;

  /// Elevation of the highlighted target above the barrier.
  final double highlightElevation;

  /// Shadow color used by the elevated target cutout.
  final Color highlightShadowColor;

  /// Background color of default content cards.
  final Color cardColor;

  /// Corner radii of default content cards.
  final BorderRadius cardBorderRadius;

  /// Border painted around default content cards.
  final BorderSide cardBorderSide;

  /// Inner padding of default content cards.
  final EdgeInsets cardPadding;

  /// Material elevation of default content cards.
  final double cardElevation;

  /// Text style used for default card titles.
  final TextStyle titleStyle;

  /// Text style used for default card descriptions.
  final TextStyle descriptionStyle;

  /// Text style used for the step progress label.
  final TextStyle progressStyle;

  /// Background color of the primary navigation button.
  final Color primaryColor;

  /// Foreground color of the primary navigation button.
  final Color primaryForegroundColor;

  /// Foreground color of the back button.
  final Color secondaryForegroundColor;

  /// Fill color of pointers connecting cards and targets.
  final Color pointerColor;

  /// Width and height of card pointers.
  final Size pointerSize;

  /// Minimum distance maintained between cards and screen edges.
  final EdgeInsets screenPadding;

  /// Duration of the overlay entrance and step transition animation.
  final Duration animationDuration;

  /// Curve of the overlay entrance and step transition animation.
  final Curve animationCurve;

  /// Default label used to advance to a later step.
  final String nextLabel;

  /// Default label used to complete the final step.
  final String doneLabel;

  /// Default label used to return to an earlier step.
  final String backLabel;

  /// Optional style applied to every default next or done button.
  final ButtonStyle? primaryButtonStyle;

  /// Optional style applied to every default back button.
  final ButtonStyle? secondaryButtonStyle;

  /// Whether cards avoid the visible software keyboard by default.
  final bool avoidKeyboard;

  /// Returns a copy with the supplied visual values replaced.
  SpotlightThemeData copyWith({
    Color? barrierColor,
    double? blurSigma,
    Color? highlightColor,
    Color? highlightBorderColor,
    double? highlightBorderWidth,
    double? highlightElevation,
    Color? highlightShadowColor,
    Color? cardColor,
    BorderRadius? cardBorderRadius,
    BorderSide? cardBorderSide,
    EdgeInsets? cardPadding,
    double? cardElevation,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    TextStyle? progressStyle,
    Color? primaryColor,
    Color? primaryForegroundColor,
    Color? secondaryForegroundColor,
    Color? pointerColor,
    Size? pointerSize,
    EdgeInsets? screenPadding,
    Duration? animationDuration,
    Curve? animationCurve,
    String? nextLabel,
    String? doneLabel,
    String? backLabel,
    ButtonStyle? primaryButtonStyle,
    ButtonStyle? secondaryButtonStyle,
    bool? avoidKeyboard,
  }) => SpotlightThemeData(
    barrierColor: barrierColor ?? this.barrierColor,
    blurSigma: blurSigma ?? this.blurSigma,
    highlightColor: highlightColor ?? this.highlightColor,
    highlightBorderColor: highlightBorderColor ?? this.highlightBorderColor,
    highlightBorderWidth: highlightBorderWidth ?? this.highlightBorderWidth,
    highlightElevation: highlightElevation ?? this.highlightElevation,
    highlightShadowColor: highlightShadowColor ?? this.highlightShadowColor,
    cardColor: cardColor ?? this.cardColor,
    cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
    cardBorderSide: cardBorderSide ?? this.cardBorderSide,
    cardPadding: cardPadding ?? this.cardPadding,
    cardElevation: cardElevation ?? this.cardElevation,
    titleStyle: titleStyle ?? this.titleStyle,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    progressStyle: progressStyle ?? this.progressStyle,
    primaryColor: primaryColor ?? this.primaryColor,
    primaryForegroundColor:
        primaryForegroundColor ?? this.primaryForegroundColor,
    secondaryForegroundColor:
        secondaryForegroundColor ?? this.secondaryForegroundColor,
    pointerColor: pointerColor ?? this.pointerColor,
    pointerSize: pointerSize ?? this.pointerSize,
    screenPadding: screenPadding ?? this.screenPadding,
    animationDuration: animationDuration ?? this.animationDuration,
    animationCurve: animationCurve ?? this.animationCurve,
    nextLabel: nextLabel ?? this.nextLabel,
    doneLabel: doneLabel ?? this.doneLabel,
    backLabel: backLabel ?? this.backLabel,
    primaryButtonStyle: primaryButtonStyle ?? this.primaryButtonStyle,
    secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
    avoidKeyboard: avoidKeyboard ?? this.avoidKeyboard,
  );
}
