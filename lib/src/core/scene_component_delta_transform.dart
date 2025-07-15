part of '../../loop.dart';

extension SceneComponentDeltaTransform on SceneComponent {
  T applyTransform<T extends DeltaTransform>(T transform, {bool reset = false}) {
    final key = T == dynamic ? transform.runtimeType : T;

    syncAction(() {
      if (reset || !components.containsKey(key)) {
        getComponent<T>()?.destroy();
        components[key] = transform;
      } else {
        components[key] = (components[key] as DeltaTransform).chain(transform);
      }
    });

    return transform;
  }

  DeltaPosition applyTranslate(Offset location, {Offset? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaPosition(
        duration: duration,
        begin: begin ?? transform.position.offset,
        end: location,
      )..onValue = (value) => transform.position = Vector2(value.dx, value.dy),
      reset: reset,
    );
  }

  DeltaScale applyScale(Scale scale, {Scale? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaScale(
        duration: duration,
        begin: begin ?? transform.scale,
        end: scale,
      )..onValue = (value) => transform.scale = value,
      reset: reset,
    );
  }

  DeltaRotation applyRotate(double degree, {double? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaRotation(
        duration: duration,
        begin: begin != null ? begin * _toRadian : transform.rotation,
        end: degree * _toRadian,
      )..onValue = (value) => transform.rotation = value,
      reset: reset,
    );
  }

  DeltaCurve applyTranslateCurve(Offset location, Offset controlPoint, {Offset? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaCurve(
        duration: duration,
        begin: begin ?? transform.position.offset,
        end: location,
        cp: controlPoint,
      )..onValue = (value) => transform.position = Vector2(value.dx, value.dy),
      reset: reset,
    );
  }

  DeltaLifetime applyLifetime(Duration duration, {bool reset = false}) {
    return applyTransform(
      DeltaLifetime(
        duration: duration,
      )..onFinished = () => destroy(),
      reset: reset,
    );
  }

  void applyDeltaLoopBehavior(LoopBehavior loop) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setLoopBehavior(loop);
      }
    });
  }

  void applyDeltaLoopReversion(bool reverse) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setReverse(reverse);
      }
    });
  }
}

extension SceneComponentDeltaRenderer on SceneColorComponent {
  DeltaOpacity applyOpacity(double opacity, {double? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaOpacity(
        duration: duration,
        begin: begin ?? alpha,
        end: opacity,
      )..onValue = (value) => color = Color.from(alpha: value, red: color.r, green: color.g, blue: color.b),
      reset: reset,
    );
  }

  DeltaColor applyColor(Color color, {Color? begin, bool applyAlpha = true, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
      DeltaColor(
        duration: duration,
        begin: begin ?? color,
        end: color,
      )..onValue = (value) => this.color = applyAlpha ? value : Color.from(alpha: this.color.a, red: value.r, green: value.g, blue: value.b),
      reset: reset,
    );
  }
}
