import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'spotlight_controller.dart';
import 'spotlight_models.dart';

/// Entry point for displaying spotlight overlays.
abstract final class CfnWidgetSpotlight {
  /// Highlights one widget.
  static Future<SpotlightResult> show(
    BuildContext context, {
    required SpotlightTarget target,
    SpotlightController? controller,
    SpotlightThemeData theme = const SpotlightThemeData(),
    bool barrierDismissible = false,
    bool useRootOverlay = true,
    ValueChanged<int>? onStepChanged,
    ValueChanged<SpotlightResult>? onDismissed,
  }) => showTour(
    context,
    steps: [SpotlightStep.single(target)],
    controller: controller,
    theme: theme,
    barrierDismissible: barrierDismissible,
    useRootOverlay: useRootOverlay,
    onStepChanged: onStepChanged,
    onDismissed: onDismissed,
  );

  /// Highlights multiple widgets simultaneously.
  static Future<SpotlightResult> showMultiple(
    BuildContext context, {
    required List<SpotlightTarget> targets,
    SpotlightController? controller,
    SpotlightThemeData theme = const SpotlightThemeData(),
    bool barrierDismissible = false,
    bool useRootOverlay = true,
    ValueChanged<SpotlightResult>? onDismissed,
  }) => showTour(
    context,
    steps: [SpotlightStep(targets: targets)],
    controller: controller,
    theme: theme,
    barrierDismissible: barrierDismissible,
    useRootOverlay: useRootOverlay,
    onDismissed: onDismissed,
  );

  /// Displays a guided tour. Every step can contain one or many targets.
  static Future<SpotlightResult> showTour(
    BuildContext context, {
    required List<SpotlightStep> steps,
    SpotlightController? controller,
    SpotlightThemeData theme = const SpotlightThemeData(),
    bool barrierDismissible = false,
    bool useRootOverlay = true,
    ValueChanged<int>? onStepChanged,
    ValueChanged<SpotlightResult>? onDismissed,
  }) async {
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'steps', 'Must not be empty.');
    }

    final overlay = Overlay.of(context, rootOverlay: useRootOverlay);
    await WidgetsBinding.instance.endOfFrame;

    final sessionController = controller ?? SpotlightController();
    final completer = Completer<SpotlightResult>();
    OverlayEntry? entry;
    var closed = false;

    void close(SpotlightDismissReason reason) {
      if (closed) return;
      closed = true;
      final result = SpotlightResult(
        reason: reason,
        lastStepIndex: sessionController.currentStep,
      );
      entry?.remove();
      entry = null;
      sessionController.detachSession();
      onDismissed?.call(result);
      completer.complete(result);
    }

    void moveTo(int index) {
      if (closed || index == sessionController.currentStep) return;
      sessionController.setSessionStep(index);
      onStepChanged?.call(index);
    }

    sessionController.attachSession(
      stepCount: steps.length,
      onMove: moveTo,
      onDismiss: close,
    );

    entry = OverlayEntry(
      builder: (overlayContext) => _SpotlightOverlay(
        steps: steps,
        controller: sessionController,
        theme: theme,
        barrierDismissible: barrierDismissible,
        onBarrierTap: () => close(SpotlightDismissReason.barrierTap),
      ),
    );
    overlay.insert(entry!);
    onStepChanged?.call(0);

    return completer.future;
  }
}

class _SpotlightOverlay extends StatelessWidget {
  const _SpotlightOverlay({
    required this.steps,
    required this.controller,
    required this.theme,
    required this.barrierDismissible,
    required this.onBarrierTap,
  });

  final List<SpotlightStep> steps;
  final SpotlightController controller;
  final SpotlightThemeData theme;
  final bool barrierDismissible;
  final VoidCallback onBarrierTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final step = steps[controller.currentStep];
        return _SpotlightStepView(
          key: ValueKey(controller.currentStep),
          step: step,
          stepIndex: controller.currentStep,
          stepCount: steps.length,
          controller: controller,
          theme: theme,
          barrierDismissible: barrierDismissible,
          onBarrierTap: onBarrierTap,
        );
      },
    );
  }
}

class _SpotlightStepView extends StatelessWidget {
  const _SpotlightStepView({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.controller,
    required this.theme,
    required this.barrierDismissible,
    required this.onBarrierTap,
  });

  final SpotlightStep step;
  final int stepIndex;
  final int stepCount;
  final SpotlightController controller;
  final SpotlightThemeData theme;
  final bool barrierDismissible;
  final VoidCallback onBarrierTap;

  @override
  Widget build(BuildContext context) {
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) (context as Element).markNeedsBuild();
      });
      return const SizedBox.expand();
    }

    final geometries = <_TargetGeometry>[];
    for (final target in step.targets) {
      final targetBox = target.key.currentContext?.findRenderObject();
      if (targetBox is! RenderBox ||
          !targetBox.attached ||
          !targetBox.hasSize) {
        continue;
      }
      final transformed = MatrixUtils.transformRect(
        targetBox.getTransformTo(overlayBox),
        Offset.zero & targetBox.size,
      );
      geometries.add(
        _TargetGeometry(
          target: target,
          rect: target.padding.inflateRect(transformed),
        ),
      );
    }

    final interactiveRects = geometries
        .where(
          (item) =>
              item.target.allowTargetInteraction &&
              item.target.onTargetTap == null,
        )
        .map((item) => item.rect)
        .toList(growable: false);

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: step.semanticLabel ?? 'Spotlight ${stepIndex + 1} of $stepCount',
      child: TweenAnimationBuilder<double>(
        duration: theme.animationDuration,
        curve: theme.animationCurve,
        tween: Tween(begin: 0, end: 1),
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: ClipPath(
                  clipper: _BackdropClipper(geometries),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: theme.blurSigma,
                      sigmaY: theme.blurSigma,
                    ),
                    child: ColoredBox(color: theme.barrierColor),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: _HighlightPainter(geometries, theme),
                ),
              ),
              _SpotlightBarrier(
                interactiveRects: interactiveRects,
                onTap: barrierDismissible ? onBarrierTap : null,
              ),
              for (final item in geometries)
                if (item.target.onTargetTap != null)
                  Positioned.fromRect(
                    rect: item.rect,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: item.target.onTargetTap,
                    ),
                  ),
              for (var index = 0; index < geometries.length; index++)
                _TargetContent(
                  geometry: geometries[index],
                  targetIndex: index,
                  targetCount: geometries.length,
                  stepIndex: stepIndex,
                  stepCount: stepCount,
                  controller: controller,
                  theme: theme,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetContent extends StatelessWidget {
  const _TargetContent({
    required this.geometry,
    required this.targetIndex,
    required this.targetCount,
    required this.stepIndex,
    required this.stepCount,
    required this.controller,
    required this.theme,
  });

  final _TargetGeometry geometry;
  final int targetIndex;
  final int targetCount;
  final int stepIndex;
  final int stepCount;
  final SpotlightController controller;
  final SpotlightThemeData theme;

  @override
  Widget build(BuildContext context) {
    final target = geometry.target;
    final details = SpotlightContentDetails(
      controller: controller,
      stepIndex: stepIndex,
      stepCount: stepCount,
      targetIndex: targetIndex,
      targetCount: targetCount,
      targetRect: geometry.rect,
    );
    final card =
        target.contentBuilder?.call(context, details) ??
        _DefaultCard(target: target, details: details, theme: theme);
    final mediaQuery = MediaQuery.of(context);
    final bottomObstruction = theme.avoidKeyboard
        ? math.max(mediaQuery.padding.bottom, mediaQuery.viewInsets.bottom)
        : mediaQuery.padding.bottom;
    final effectiveScreenPadding = EdgeInsets.fromLTRB(
      theme.screenPadding.left + mediaQuery.padding.left,
      theme.screenPadding.top + mediaQuery.padding.top,
      theme.screenPadding.right + mediaQuery.padding.right,
      theme.screenPadding.bottom + bottomObstruction,
    );
    return Positioned.fill(
      child: CustomMultiChildLayout(
        delegate: _TargetLayoutDelegate(
          targetRect: geometry.rect,
          requestedPlacement: target.placement,
          alignment: target.alignment,
          gap: target.gap,
          offset: target.offset,
          maxContentWidth: target.maxContentWidth,
          pointerSize: target.showPointer ? theme.pointerSize : Size.zero,
          pointerEdgeInset: theme.cardBorderRadius.topLeft.x,
          screenPadding: effectiveScreenPadding,
        ),
        children: [
          LayoutId(
            id: _LayoutPart.card,
            child: Semantics(
              container: true,
              label: target.semanticLabel,
              child: card,
            ),
          ),
          if (target.showPointer)
            for (final placement in const [
              SpotlightPlacement.above,
              SpotlightPlacement.below,
              SpotlightPlacement.left,
              SpotlightPlacement.right,
            ])
              LayoutId(
                id: _pointerPartFor(placement),
                child: CustomPaint(
                  size: theme.pointerSize,
                  painter: _PointerPainter(
                    placement: placement,
                    color: theme.pointerColor,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _DefaultCard extends StatelessWidget {
  const _DefaultCard({
    required this.target,
    required this.details,
    required this.theme,
  });

  final SpotlightTarget target;
  final SpotlightContentDetails details;
  final SpotlightThemeData theme;

  @override
  Widget build(BuildContext context) {
    final nextLabel =
        target.nextLabel ??
        (details.isLastStep ? theme.doneLabel : theme.nextLabel);
    final backLabel = target.backLabel ?? theme.backLabel;
    final navigationDetails = SpotlightNavigationDetails(
      controller: details.controller,
      stepIndex: details.stepIndex,
      stepCount: details.stepCount,
      nextLabel: nextLabel,
      backLabel: backLabel,
    );
    final body = target.bodyBuilder?.call(context, details);
    return Material(
      color: target.cardColor ?? theme.cardColor,
      elevation: target.cardElevation ?? theme.cardElevation,
      shadowColor: Colors.black38,
      borderRadius: target.cardBorderRadius ?? theme.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: target.cardPadding ?? theme.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (target.title case final title?)
              Text(title, style: target.titleStyle ?? theme.titleStyle),
            if (target.title != null && target.description != null)
              const SizedBox(height: 6),
            if (target.description case final description?)
              Text(
                description,
                style: target.descriptionStyle ?? theme.descriptionStyle,
              ),
            if (body != null) ...[
              if (target.title != null || target.description != null)
                const SizedBox(height: 12),
              body,
            ],
            if (target.showNavigation) ...[
              const SizedBox(height: 12),
              if (target.navigationBuilder case final builder?)
                builder(context, navigationDetails)
              else
                Row(
                  children: [
                    Text(
                      navigationDetails.progressLabel,
                      style: target.progressStyle ?? theme.progressStyle,
                    ),
                    const Spacer(),
                    if (navigationDetails.canGoBack) ...[
                      OutlinedButton(
                        onPressed: navigationDetails.back,
                        style:
                            target.secondaryButtonStyle ??
                            theme.secondaryButtonStyle ??
                            OutlinedButton.styleFrom(
                              foregroundColor: theme.secondaryForegroundColor,
                            ),
                        child: Text(backLabel),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton(
                      onPressed: navigationDetails.next,
                      style:
                          target.primaryButtonStyle ??
                          theme.primaryButtonStyle ??
                          FilledButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.primaryForegroundColor,
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(nextLabel),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetGeometry {
  const _TargetGeometry({required this.target, required this.rect});

  final SpotlightTarget target;
  final Rect rect;

  Path path() {
    return switch (target.shape) {
      SpotlightShape.roundedRectangle =>
        Path()..addRRect(target.borderRadius.toRRect(rect)),
      SpotlightShape.rectangle => Path()..addRect(rect),
      SpotlightShape.circle =>
        Path()..addOval(
          Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2),
        ),
      SpotlightShape.oval => Path()..addOval(rect),
    };
  }
}

class _BackdropClipper extends CustomClipper<Path> {
  const _BackdropClipper(this.targets);

  final List<_TargetGeometry> targets;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final target in targets) {
      path.addPath(target.path(), Offset.zero);
    }
    return path;
  }

  @override
  bool shouldReclip(_BackdropClipper oldClipper) => true;
}

class _HighlightPainter extends CustomPainter {
  const _HighlightPainter(this.targets, this.theme);

  final List<_TargetGeometry> targets;
  final SpotlightThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    for (final target in targets) {
      final path = target.path();
      if (theme.highlightElevation > 0) {
        // Draw elevation in an isolated layer, then remove everything inside
        // the cutout so the original target stays crisp and un-tinted.
        canvas.saveLayer(Offset.zero & size, Paint());
        canvas.drawShadow(
          path,
          theme.highlightShadowColor,
          theme.highlightElevation,
          false,
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.highlightBorderWidth + 4
            ..color = theme.highlightColor.withValues(alpha: 0.9)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.outer,
              theme.highlightElevation * 0.55,
            ),
        );
        canvas.drawPath(path, Paint()..blendMode = BlendMode.clear);
        canvas.restore();
      }
      if (theme.highlightBorderWidth > 0) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.highlightBorderWidth
            ..color = theme.highlightBorderColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) => true;
}

enum _LayoutPart { card, pointerAbove, pointerBelow, pointerLeft, pointerRight }

_LayoutPart _pointerPartFor(SpotlightPlacement placement) {
  return switch (placement) {
    SpotlightPlacement.above => _LayoutPart.pointerAbove,
    SpotlightPlacement.below => _LayoutPart.pointerBelow,
    SpotlightPlacement.left => _LayoutPart.pointerLeft,
    SpotlightPlacement.right => _LayoutPart.pointerRight,
    SpotlightPlacement.auto => _LayoutPart.pointerBelow,
  };
}

class _TargetLayoutDelegate extends MultiChildLayoutDelegate {
  _TargetLayoutDelegate({
    required this.targetRect,
    required this.requestedPlacement,
    required this.alignment,
    required this.gap,
    required this.offset,
    required this.maxContentWidth,
    required this.pointerSize,
    required this.pointerEdgeInset,
    required this.screenPadding,
  });

  final Rect targetRect;
  final SpotlightPlacement requestedPlacement;
  final SpotlightAlignment alignment;
  final double gap;
  final Offset offset;
  final double maxContentWidth;
  final Size pointerSize;
  final double pointerEdgeInset;
  final EdgeInsets screenPadding;

  @override
  void performLayout(Size size) {
    final availableWidth = (size.width - screenPadding.horizontal).clamp(
      0.0,
      size.width,
    );
    final cardSize = layoutChild(
      _LayoutPart.card,
      BoxConstraints(
        maxWidth: maxContentWidth.clamp(0.0, availableWidth),
        maxHeight: (size.height - screenPadding.vertical).clamp(
          0.0,
          size.height,
        ),
      ),
    );

    final pointerParts = <SpotlightPlacement, _LayoutPart>{
      SpotlightPlacement.above: _LayoutPart.pointerAbove,
      SpotlightPlacement.below: _LayoutPart.pointerBelow,
      SpotlightPlacement.left: _LayoutPart.pointerLeft,
      SpotlightPlacement.right: _LayoutPart.pointerRight,
    };
    for (final part in pointerParts.values) {
      if (hasChild(part)) {
        layoutChild(part, BoxConstraints.tight(pointerSize));
      }
    }

    final placement = _resolveFittingPlacement(size, cardSize);
    final pointerPart = pointerParts[placement]!;
    final pointer = hasChild(pointerPart) ? pointerSize : Size.zero;
    var cardOffset = _cardOffset(cardSize, pointer, placement);
    cardOffset = Offset(
      cardOffset.dx.clamp(
        screenPadding.left,
        size.width - screenPadding.right - cardSize.width,
      ),
      cardOffset.dy.clamp(
        screenPadding.top,
        size.height - screenPadding.bottom - cardSize.height,
      ),
    );
    positionChild(_LayoutPart.card, cardOffset + offset);

    for (final part in pointerParts.values) {
      if (hasChild(part)) positionChild(part, Offset(-size.width * 2, 0));
    }
    if (hasChild(pointerPart)) {
      positionChild(
        pointerPart,
        _pointerOffset(cardOffset, cardSize, pointer, placement) + offset,
      );
    }
  }

  SpotlightPlacement _resolveFittingPlacement(Size screen, Size card) {
    final available = <SpotlightPlacement, double>{
      SpotlightPlacement.above: targetRect.top - screenPadding.top,
      SpotlightPlacement.below:
          screen.height - screenPadding.bottom - targetRect.bottom,
      SpotlightPlacement.left: targetRect.left - screenPadding.left,
      SpotlightPlacement.right:
          screen.width - screenPadding.right - targetRect.right,
    };
    final required = <SpotlightPlacement, double>{
      SpotlightPlacement.above: card.height + gap + pointerSize.height,
      SpotlightPlacement.below: card.height + gap + pointerSize.height,
      SpotlightPlacement.left: card.width + gap + pointerSize.width,
      SpotlightPlacement.right: card.width + gap + pointerSize.width,
    };

    if (requestedPlacement != SpotlightPlacement.auto &&
        available[requestedPlacement]! >= required[requestedPlacement]!) {
      return requestedPlacement;
    }

    final candidates = available.keys.toList()
      ..sort(
        (a, b) => (available[b]! - required[b]!).compareTo(
          available[a]! - required[a]!,
        ),
      );
    return candidates.first;
  }

  Offset _cardOffset(Size card, Size pointer, SpotlightPlacement placement) {
    final alignedX = switch (alignment) {
      SpotlightAlignment.start => targetRect.left,
      SpotlightAlignment.center => targetRect.center.dx - card.width / 2,
      SpotlightAlignment.end => targetRect.right - card.width,
    };
    final alignedY = switch (alignment) {
      SpotlightAlignment.start => targetRect.top,
      SpotlightAlignment.center => targetRect.center.dy - card.height / 2,
      SpotlightAlignment.end => targetRect.bottom - card.height,
    };
    return switch (placement) {
      SpotlightPlacement.above => Offset(
        alignedX,
        targetRect.top - gap - pointer.height - card.height,
      ),
      SpotlightPlacement.below || SpotlightPlacement.auto => Offset(
        alignedX,
        targetRect.bottom + gap + pointer.height,
      ),
      SpotlightPlacement.left => Offset(
        targetRect.left - gap - pointer.width - card.width,
        alignedY,
      ),
      SpotlightPlacement.right => Offset(
        targetRect.right + gap + pointer.width,
        alignedY,
      ),
    };
  }

  Offset _pointerOffset(
    Offset cardOffset,
    Size card,
    Size pointer,
    SpotlightPlacement placement,
  ) {
    final x = _clampOrCenter(
      targetRect.center.dx,
      cardOffset.dx + pointer.width / 2 + pointerEdgeInset,
      cardOffset.dx + card.width - pointer.width / 2 - pointerEdgeInset,
    );
    final y = _clampOrCenter(
      targetRect.center.dy,
      cardOffset.dy + pointer.height / 2 + pointerEdgeInset,
      cardOffset.dy + card.height - pointer.height / 2 - pointerEdgeInset,
    );
    return switch (placement) {
      SpotlightPlacement.above => Offset(
        x - pointer.width / 2,
        cardOffset.dy + card.height,
      ),
      SpotlightPlacement.below || SpotlightPlacement.auto => Offset(
        x - pointer.width / 2,
        cardOffset.dy - pointer.height,
      ),
      SpotlightPlacement.left => Offset(
        cardOffset.dx + card.width,
        y - pointer.height / 2,
      ),
      SpotlightPlacement.right => Offset(
        cardOffset.dx - pointer.width,
        y - pointer.height / 2,
      ),
    };
  }

  @override
  bool shouldRelayout(_TargetLayoutDelegate oldDelegate) => true;
}

double _clampOrCenter(double value, double minimum, double maximum) {
  if (maximum < minimum) return (minimum + maximum) / 2;
  return value.clamp(minimum, maximum);
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({required this.placement, required this.color});

  final SpotlightPlacement placement;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = switch (placement) {
      SpotlightPlacement.above =>
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height),
      SpotlightPlacement.below || SpotlightPlacement.auto =>
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height),
      SpotlightPlacement.left =>
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(0, size.height),
      SpotlightPlacement.right =>
        Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height),
    };
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) =>
      placement != oldDelegate.placement || color != oldDelegate.color;
}

class _SpotlightBarrier extends LeafRenderObjectWidget {
  const _SpotlightBarrier({required this.interactiveRects, this.onTap});

  final List<Rect> interactiveRects;
  final VoidCallback? onTap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSpotlightBarrier(interactiveRects: interactiveRects, onTap: onTap);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSpotlightBarrier renderObject,
  ) {
    renderObject
      ..interactiveRects = interactiveRects
      ..onTap = onTap;
  }
}

class _RenderSpotlightBarrier extends RenderBox {
  _RenderSpotlightBarrier({
    required this._interactiveRects,
    VoidCallback? onTap,
    // The callback remains mutable because updateRenderObject replaces it.
    // ignore: prefer_initializing_formals
  }) : _onTap = onTap {
    _recognizer = TapGestureRecognizer()..onTap = _handleTap;
  }

  late final TapGestureRecognizer _recognizer;
  List<Rect> _interactiveRects;
  VoidCallback? _onTap;

  set interactiveRects(List<Rect> value) {
    if (identical(value, _interactiveRects)) return;
    _interactiveRects = value;
  }

  set onTap(VoidCallback? value) {
    _onTap = value;
  }

  void _handleTap() => _onTap?.call();

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  bool hitTestSelf(Offset position) =>
      !_interactiveRects.any((rect) => rect.contains(position));

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) _recognizer.addPointer(event);
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }
}
