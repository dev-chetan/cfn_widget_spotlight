import 'package:flutter/foundation.dart';

import 'spotlight_models.dart';

typedef _MoveCallback = void Function(int index);
typedef _DismissCallback = void Function(SpotlightDismissReason reason);

/// Controls a visible spotlight tour.
class SpotlightController extends ChangeNotifier {
  int _currentStep = 0;
  int _stepCount = 0;
  _MoveCallback? _onMove;
  _DismissCallback? _onDismiss;

  int get currentStep => _currentStep;
  int get stepCount => _stepCount;
  bool get isShowing => _onDismiss != null;
  bool get canGoBack => isShowing && _currentStep > 0;
  bool get isLastStep => isShowing && _currentStep == _stepCount - 1;

  void next() {
    if (!isShowing) return;
    if (isLastStep) {
      _onDismiss?.call(SpotlightDismissReason.completed);
    } else {
      goTo(_currentStep + 1);
    }
  }

  void previous() {
    if (canGoBack) goTo(_currentStep - 1);
  }

  void goTo(int index) {
    if (!isShowing || index < 0 || index >= _stepCount) return;
    _onMove?.call(index);
  }

  void skip() => _onDismiss?.call(SpotlightDismissReason.skipped);

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
  void attachSession({
    required int stepCount,
    required void Function(int index) onMove,
    required void Function(SpotlightDismissReason reason) onDismiss,
  }) => _attach(stepCount: stepCount, onMove: onMove, onDismiss: onDismiss);

  void setSessionStep(int index) => _setStep(index);
  void detachSession() => _detach();
}
