part of '../../loop.dart';

const _pi2 = math.pi * 2.0;
const _toRadian = math.pi / 180.0;
const _toDegrees = 180.0 / math.pi;

enum LoopBehavior {
  none,
  loop,
  reverseLoop,
}

abstract class TransformComponent<T> {
  late T componentValue;

  Curve curve = Curves.linear;
  bool reverse = false;

  T transform(T a, T b, double t) {
    t = reverse ? (1.0 - t) : t;

    if (t <= 0.0) {
      return componentValue = a;
    }

    if (t >= 1.0) {
      return componentValue = b;
    }

    return componentValue = lerp(a, b, curve.transform(t));
  }

  T lerp(T a, T b, double t);
}

abstract class DeltaTransform<T, U> extends TransformComponent<T> with LoopComponent {
  final state = StateComponent<DeltaTransform<T, U>>();

  T begin;
  T end;

  bool _run = true;
  double _overflowDelta = 0.0;
  DeltaTransform<T, U>? _parent;

  bool get atEdge => componentValue == begin || componentValue == end;

  bool get _isParentActive => _parent?._run ?? false;

  T get value => reverse ? ((_run || _parent == null) ? componentValue : _parent!.value) : (_isParentActive ? _parent!.value : componentValue);

  @override
  bool get active => !isDone();

  DeltaTransform({
    required this.begin,
    required this.end,
  }) {
    componentValue = begin;
  }

  double deltaProgress(double dt);

  bool isDone() => !_run && (_parent?.isDone() ?? true);

  @override
  void tick(double dt) {
    _evaluateTick(dt);

    if (isDone()) {
      switch (state.loop) {
        case LoopBehavior.reverseLoop:
          setReverse(!reverse);
          reset();
          break;
        case LoopBehavior.loop:
          reset();
          break;
        default:
          break;
      }
    }
  }

  void _evaluateTick(double dt) {
    if (reverse) {
      if (_run) {
        // postpone/hold is not reversed, so it will tick on other edge then non reverse run.
        if (state.tickPostpone(this, dt)) {
          _overflowDelta = 0.0;
          return;
        }

        if (!_evaluateTickHold(dt)) {
          transform(begin, end, deltaProgress(dt));
          _run = componentValue != begin;
        }

        dt = _overflowDelta;
      }

      if (dt == 0.0) {
        return;
      }

      if (_parent != null) {
        _parent!._evaluateTick(dt);
      }
    } else {
      if (_parent != null && _parent!._run) {
        _parent!._evaluateTick(dt);

        dt = _parent!._overflowDelta;
      }

      if (dt == 0.0) {
        return;
      }

      if (state.tickPostpone(this, dt)) {
        _overflowDelta = 0.0;
        return;
      }

      if (!_evaluateTickHold(dt)) {
        transform(begin, end, deltaProgress(dt));
        _run = componentValue != end;
      }
    }
  }

  bool _evaluateTickHold(double dt) {
    if (state.tickHold(this, dt)) {
      transform(begin, end, state.reverseHold ? 1.0 - deltaProgress(dt) : deltaProgress(dt));
      _overflowDelta = 0.0;

      if (atEdge) {
        switch (state.loopHold) {
          case LoopBehavior.reverseLoop:
            state.reverseHold = !state.reverseHold;
            resetLoop();
            break;
          case LoopBehavior.loop:
            resetLoop();
            break;
          default:
            break;
        }
      }

      return true;
    }

    return false;
  }

  void setLoopBehavior(LoopBehavior loop, {bool local = false}) {
    state.loop = loop;

    if (!local) {
      _parent?.setLoopBehavior(loop, local: local);
    }
  }

  void setReverse(bool reverse, {bool local = false}) {
    this.reverse = reverse;

    if (!local) {
      _parent?.setReverse(reverse);
    }
  }

  void resetLoop() {
    _overflowDelta = 0.0;
    _run = true;
  }

  void reset({bool local = false}) {
    state.reset();
    _overflowDelta = 0.0;
    componentValue = reverse ? end : begin;
    _run = true;

    if (!local) {
      _parent?.reset();
    }
  }

  void until({StateCondition<DeltaTransform<T, U>>? postpone, StateCondition<DeltaTransform<T, U>>? hold, LoopBehavior loopHold = LoopBehavior.none}) {
    state.postpone = postpone;
    state.hold = hold;
    state.loopHold = loopHold;
  }

  DeltaTransform<T, U> chain(DeltaTransform<T, U> transform) {
    transform._parent = this;
    transform.begin = end;
    transform.componentValue = end;

    return transform;
  }
}

abstract class DeltaDuration<T> extends DeltaTransform<T, Duration> {
  Duration duration;
  double _elapsed = 0.0;

  DeltaDuration({
    required super.begin,
    required super.end,
    this.duration = const Duration(seconds: 1),
  });

  @override
  double deltaProgress(double dt) {
    _elapsed += dt * Duration.microsecondsPerSecond;

    if (_elapsed >= duration.inMicroseconds) {
      _overflowDelta = (_elapsed - duration.inMicroseconds) / Duration.microsecondsPerSecond;
      _elapsed = duration.inMicroseconds.toDouble();

      return 1.0;
    }

    return _elapsed / duration.inMicroseconds;
  }

  @override
  void resetLoop() {
    super.resetLoop();

    _elapsed = 0.0;
  }

  @override
  void reset({bool local = false}) {
    super.reset(local: local);

    _elapsed = 0.0;
  }
}

class DeltaValue<T> extends DeltaDuration {
  DeltaValue({
    required super.begin,
    required super.end,
    super.duration,
  });

  @override
  T lerp(dynamic a, dynamic b, double t) => (a + (a - b) * t) as T;
}

class DeltaOpacity extends DeltaDuration<double> {
  DeltaOpacity({
    super.begin = 0.0,
    super.end = 1.0,
    super.duration,
  });

  @override
  double lerp(double a, double b, double t) => (a + (b - a) * t).clamp(0.0, 1.0);
}

class DeltaColor extends DeltaDuration<Color> {
  DeltaColor({
    super.begin = Colors.white,
    super.end = Colors.black,
    super.duration,
  });

  @override
  Color lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;
}

class DeltaPosition extends DeltaDuration<Offset> {
  DeltaPosition({
    super.begin = Offset.zero,
    super.end = const Offset(1.0, 1.0),
    super.duration,
  });

  @override
  Offset lerp(Offset a, Offset b, double t) => Offset.lerp(a, b, t)!;
}

class DeltaScale extends DeltaDuration<Scale> {
  DeltaScale({
    super.begin = const Scale(1.0, 1.0),
    super.end = const Scale(2.0, 2.0),
    super.duration,
  });

  @override
  Scale lerp(Scale a, Scale b, double t) => Scale.lerp(a, b, t);
}

class DeltaRotation extends DeltaDuration<double> {
  DeltaRotation({
    super.begin = 0.0,
    super.end = _pi2,
    super.duration,
  });

  double get beginDegree => begin * _toDegrees;

  double get endDegree => end * _toDegrees;

  @override
  double lerp(double a, double b, double t) => (begin + (end - begin) * t) % _pi2;
}

class DeltaSize extends DeltaDuration<Size> {
  DeltaSize({
    super.begin = const Size(1.0, 1.0),
    super.end = const Size(100.0, 100.0),
    super.duration,
  });

  @override
  Size lerp(Size a, Size b, double t) => Size.lerp(a, b, t)!;
}

class DeltaCurve extends DeltaDuration<Offset> {
  Offset cp;

  DeltaCurve({
    super.begin = Offset.zero,
    super.end = const Offset(300.0, 0.0),
    this.cp = const Offset(150.0, 100.0),
    super.duration,
  });

  @override
  Offset lerp(Offset a, Offset b, double t) {
    final r = 1.0 - t;
    final tt = t * t;
    final rt2 = r * t * 2.0;
    final rr = r * r;

    return Offset(
      rr * a.dx + rt2 * b.dx + tt * cp.dx,
      rr * a.dy + rt2 * b.dy + tt * cp.dy,
    );
  }
}

class DeltaSequence extends DeltaDuration<int> {
  double blend = 0.0;

  DeltaSequence({
    super.begin = 0,
    super.end = 60,
    int framesPerSecond = 30,
  }) : super(
          duration: Duration(microseconds: ((end - begin).abs() * (1.0 / framesPerSecond) * Duration.microsecondsPerSecond).toInt()),
        );

  DeltaSequence.sub({
    int offset = 0,
    int count = 60,
    int framesPerSecond = 30,
  }) : super(
          begin: offset,
          end: offset + count,
          duration: Duration(microseconds: (count * (1.0 / framesPerSecond) * Duration.microsecondsPerSecond).toInt()),
        );

  @override
  int transform(int a, int b, double t) {
    t = reverse ? (1.0 - t) : t;

    if (t <= 0.0) {
      blend = 0.0;
      return componentValue = a;
    }

    if (t >= 1.0) {
      blend = 0.0;
      return componentValue = b;
    }

    return componentValue = lerp(a, b, t);
  }

  @override
  int lerp(int a, int b, double t) {
    final value = (a + (b - a) * t);
    final index = value.toInt();

    blend = curve.transform(value - index);
    return index;
  }
}
