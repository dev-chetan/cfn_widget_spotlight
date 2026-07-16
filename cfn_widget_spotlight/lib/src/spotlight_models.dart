import 'package:flutter/material.dart';

import 'spotlight_controller.dart';

/// Where a target's content card should be placed.
enum SpotlightPlacement { auto, above, below, left, right }

/// How a card is aligned along the edge of its target.
enum SpotlightAlignment { start, center, end }

/// The shape cut out around a highlighted widget.
enum SpotlightShape { roundedRectangle, rectangle, circle, oval }

/// Why a spotlight overlay was closed.
enum SpotlightDismissReason { completed, skipped, barrierTap, programmatic }

/// The result returned when a spotlight tour closes.
@immutable
class SpotlightResult {
  const SpotlightResult({required this.reason, required this.lastStepIndex});

  final SpotlightDismissReason reason;
  final int lastStepIndex;

  bool get completed => reason == SpotlightDismissReason.completed;
}

/// Information passed to a custom target content builder.
@immutable
class SpotlightContentDetails {
  const SpotlightContentDetails({
    required this.controller,
    required this.stepIndex,
    required this.stepCount,
    required this.targetIndex,
    required this.targetCount,
    required this.targetRect,
  });

  final SpotlightController controller;
  final int stepIndex;
  final int stepCount;
  final int targetIndex;
  final int targetCount;
  final Rect targetRect;

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex == stepCount - 1;
}

typedef SpotlightContentBuilder =
    Widget Function(BuildContext context, SpotlightContentDetails details);

/// A widget to highlight and the content associated with it.
@immutable
class SpotlightTarget {
  const SpotlightTarget({
    required this.key,
    this.title,
    this.description,
    this.contentBuilder,
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
  }) : assert(
         title != null || description != null || contentBuilder != null,
         'Provide title, description, or contentBuilder.',
       );

  /// The key of a mounted widget to spotlight.
  final GlobalKey key;
  final String? title;
  final String? description;

  /// Replaces the package's default card completely.
  final SpotlightContentBuilder? contentBuilder;
  final SpotlightPlacement placement;
  final SpotlightAlignment alignment;
  final SpotlightShape shape;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double gap;
  final Offset offset;
  final double maxContentWidth;
  final bool showPointer;

  /// Whether the default card includes progress and next/back controls.
  final bool showNavigation;

  /// Lets pointer events inside the cutout reach the highlighted widget.
  ///
  /// This is ignored when [onTargetTap] is supplied because the overlay handles
  /// the tap in that case.
  final bool allowTargetInteraction;
  final VoidCallback? onTargetTap;
  final String? nextLabel;
  final String? backLabel;
  final String? semanticLabel;
}

/// One page in a tour. A page can highlight one or many widgets at once.
@immutable
class SpotlightStep {
  SpotlightStep({required List<SpotlightTarget> targets, this.semanticLabel})
    : assert(targets.isNotEmpty),
      targets = List.unmodifiable(targets);

  SpotlightStep.single(SpotlightTarget target, {this.semanticLabel})
    : targets = List.unmodifiable([target]);

  final List<SpotlightTarget> targets;
  final String? semanticLabel;
}

/// Visual defaults for an entire spotlight tour.
@immutable
class SpotlightThemeData {
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
  });

  final Color barrierColor;
  final double blurSigma;
  final Color highlightColor;
  final Color highlightBorderColor;
  final double highlightBorderWidth;
  final double highlightElevation;
  final Color highlightShadowColor;
  final Color cardColor;
  final BorderRadius cardBorderRadius;
  final EdgeInsets cardPadding;
  final double cardElevation;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle progressStyle;
  final Color primaryColor;
  final Color primaryForegroundColor;
  final Color secondaryForegroundColor;
  final Color pointerColor;
  final Size pointerSize;
  final EdgeInsets screenPadding;
  final Duration animationDuration;
  final Curve animationCurve;
  final String nextLabel;
  final String doneLabel;
  final String backLabel;

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
  );
}
