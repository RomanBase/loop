part of '../../loop.dart';

extension SceneComponentDelta on SceneComponent {
  Offset? get deltaOffset => getComponent<DeltaPosition>()?.value;

  Scale? get deltaScale => getComponent<DeltaScale>()?.value;

  double? get deltaRotation => getComponent<DeltaRotation>()?.value;

  Color? get deltaColor => getComponent<DeltaColor>()?.value;

  double? get deltaOpacity => getComponent<DeltaOpacity>()?.value;

  Offset? get deltaCurve => getComponent<DeltaCurve>()?.value;

  T applyTransform<T extends DeltaTransform>(T transform, {bool reset = false}) {
    final key = T == dynamic ? transform.runtimeType : T;

    if (reset || !components.containsKey(key)) {
      getComponent<T>()?.destroy();
      components[key] = transform;
    } else {
      components[key] = (components[key] as DeltaTransform).chain(transform);
    }

    return components[key] as T;
  }

  DeltaPosition translate(Offset location, {Offset? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaPosition(
        duration: duration,
        begin: begin ?? transform.position,
        end: location,
      )..onValue = (value) => transform.position = value,
      reset: reset,
    );
  }

  DeltaScale scale(Scale scale, {Scale? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaScale(
        duration: duration,
        begin: begin ?? transform.scale,
        end: scale,
      )..onValue = (value) => transform.scale = value,
      reset: reset,
    );
  }

  DeltaRotation rotate(double degree, {double? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaRotation(
        duration: duration,
        begin: begin != null ? begin * _toRadian : transform.rotation,
        end: degree * _toRadian,
      )..onValue = (value) => transform.rotation = value,
      reset: reset,
    );
  }

  DeltaOpacity opacity(double opacity, {double begin = 1.0, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaOpacity(
        duration: duration,
        begin: begin,
        end: opacity,
      ),
      reset: reset,
    );
  }

  DeltaColor color(Color color, {Color begin = Colors.white, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaColor(
        duration: duration,
        begin: begin,
        end: color,
      ),
      reset: reset,
    );
  }

  DeltaCurve curve(Offset location, Offset controlPoint, {Offset begin = Offset.zero, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaCurve(
        duration: duration,
        begin: begin,
        end: location,
        cp: controlPoint,
      ),
      reset: reset,
    );
  }

  DeltaLifetime lifetime(Duration duration, {bool reset = false}) {
    return applyTransform(
      DeltaLifetime(
        duration: duration,
      )..onFinished = () => destroy(),
      reset: reset,
    );
  }

  void updateDeltaLoopBehavior(LoopBehavior loop) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setLoopBehavior(loop);
      }
    });
  }

  void updateDeltaLoopReversion(bool reverse) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setReverse(reverse);
      }
    });
  }
}
