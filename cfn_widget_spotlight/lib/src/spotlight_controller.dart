import 'package:flutter/foundation.dart';

import 'spotlight_models.dart';

typedef _MoveCallback = void Function(int index);
typedef _DismissCallback = void Function(SpotlightDismissReason reason);

/// Controls a visible spotlight tour.
class SpotlightController extends ChangeNotifier {
  /// Creates a controller that can be attached to one active tour at a time.
  SpotlightController();

  int _currentStep = 0;
  int _stepCount = 0;
  _MoveCallback? _onMove;
  _DismissCallback? _onDismiss;

  /// The zero-based index of the currently visible step.
  int get currentStep => _currentStep;

  /// The total number of steps in the attached tour.
  int get stepCount => _stepCount;

  /// Whether this controller is attached to a visible tour.
  bool get isShowing => _onDismiss != null;

  /// Whether [previous] can move to an earlier step.
  bool get canGoBack => isShowing && _currentStep > 0;

  /// Whether the currently visible step is the final step.
  bool get isLastStep => isShowing && _currentStep == _stepCount - 1;

  /// Advances one step, or completes the tour from its final step.
  void next() {
    if (!isShowing) return;
    if (isLastStep) {
      _onDismiss?.call(SpotlightDismissReason.completed);
    } else {
      goTo(_currentStep + 1);
    }
  }

  /// Returns to the previous step when [canGoBack] is true.
  void previous() {
    if (canGoBack) goTo(_currentStep - 1);
  }

  /// Displays the step at the given zero-based [index].
  ///
  /// Invalid indexes and calls made while no tour is visible are ignored.
  void goTo(int index) {
    if (!isShowing || index < 0 || index >= _stepCount) return;
    _onMove?.call(index);
  }

  /// Closes the active tour with [SpotlightDismissReason.skipped].
  void skip() => _onDismiss?.call(SpotlightDismissReason.skipped);

  /// Closes the active tour with [SpotlightDismissReason.programmatic].
  void dismiss() => _onDismiss?.call(SpotlightDismissReason.programmatic);

  void _attach({
    required int stepCount,
    required _MoveCallback onMove,
    required _DismissCallback onDismiss,
  }) {
    if (isShowing) {
      throw StateError('This SpotlightController already controls a tour.');
    }
    _currentStep = 0;
    _stepCount = stepCount;
    _onMove = onMove;
    _onDismiss = onDismiss;
    notifyListeners();
  }

  void _setStep(int index) {
    _currentStep = index;
    notifyListeners();
  }

  void _detach() {
    _onMove = null;
    _onDismiss = null;
    notifyListeners();
  }
}

/// Internal access used by the overlay session without exposing attachment
/// methods as part of the public controller API.
extension SpotlightControllerSession on SpotlightController {
  /// Attaches internal overlay session callbacks to this controller.
  void attachSession({
    required int stepCount,
    required void Function(int index) onMove,
    required void Function(SpotlightDismissReason reason) onDismiss,
  }) => _attach(stepCount: stepCount, onMove: onMove, onDismiss: onDismiss);

  /// Updates the step reported by this controller's active session.
  void setSessionStep(int index) => _setStep(index);

  /// Removes the active overlay session from this controller.
  void detachSession() => _detach();
}
