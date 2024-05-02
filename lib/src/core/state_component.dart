part of '../../loop.dart';

abstract class StateCondition<T extends DeltaTransform> {
  static StateCondition<T> until<T extends DeltaTransform>(bool Function(T parent, double dt) condition) => _StateConditionCheck<T>(condition);

  bool check(T parent, double dt);

  void reset() {}
}

class _StateConditionCheck<T extends DeltaTransform> extends StateCondition<T> {
  final bool Function(T parent, double dt) condition;

  _StateConditionCheck(this.condition);

  @override
  bool check(T parent, double dt) => condition(parent, dt);
}

class StateComponent<T extends DeltaTransform> {
  String name = 'state';

  LoopBehavior loop = LoopBehavior.none;
  LoopBehavior loopHold = LoopBehavior.none;
  bool reverseHold = false;

  StateCondition<T>? postpone;
  StateCondition<T>? hold;

  bool tickPostpone(T parent, double dt) => postpone?.check(parent, dt) ?? false;

  bool tickHold(T parent, double dt) => hold?.check(parent, dt) ?? false;

  void clear() {
    postpone = null;
    hold = null;
  }

  void reset() {
    postpone?.reset();
    hold?.reset();
  }
}

class WaitCondition<T extends DeltaTransform> extends StateCondition<T> {
  final Duration duration;

  double _elapsed = 0.0;

  WaitCondition({
    required this.duration,
  });

  @override
  bool check(T parent, double dt) {
    _elapsed += dt * Duration.microsecondsPerSecond;

    return _elapsed < duration.inMicroseconds;
  }

  @override
  void reset() {
    _elapsed = 0.0;
  }
}

class CycleCondition<T extends DeltaTransform> extends StateCondition<T> {
  final int cycles;

  int _elapsed = 0;

  CycleCondition({
    required this.cycles,
  });

  @override
  bool check(T parent, double dt) {
    final loop = parent.state.loopHold;

    switch (loop) {
      case LoopBehavior.none:
        _elapsed++;
        break;
      case LoopBehavior.loop:
        if (parent.atEdge) {
          _elapsed++;
        }
        break;
      case LoopBehavior.reverseLoop:
        if (parent.atEdge && !parent.state.reverseHold) {
          _elapsed++;
        }
        break;
    }

    return _elapsed < cycles;
  }

  @override
  void reset() {
    _elapsed = 0;
  }
}

class TriggerCondition<T extends DeltaTransform> extends StateCondition<T> {
  final bool Function() trigger;

  bool _hold = true;

  TriggerCondition({
    required this.trigger,
  });

  @override
  bool check(T parent, double dt) {
    if (_hold) {
      _hold = trigger();
    }

    return _hold;
  }

  @override
  void reset() {
    _hold = true;
  }
}
