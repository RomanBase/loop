part of '../../loop.dart';

class BaseTransform {
  final _matrix = Matrix4.identity();

  Offset position = Offset.zero;
  Offset scale = Scale.one;
  double rotation = 0.0;

  Matrix4 get matrix {
    _matrix.setIdentity();

    if (rotation != 0.0) {
      _matrix.setRotationZ(rotation);
    }

    if (!scale.isOne) {
      _matrix.scale(scale.dx, scale.dy, 1.0);
    }

    if (!position.isZero) {
      _matrix.setTranslationRaw(position.dx, position.dy, 0.0);
    }

    return _matrix;
  }
}

class SceneComponent with ObservableLoopComponent {
  final components = <Type, LoopComponent>{};

  final transform = BaseTransform();

  LoopScene? _loop;

  LoopScene get loop => _loop!;

  bool get isMounted => _loop != null;

  Offset? get deltaOffset => getTransform<DeltaPosition>()?.value;

  Offset? get deltaScale => getTransform<DeltaScale>()?.value;

  double? get deltaRotation => getTransform<DeltaRotation>()?.value;

  Color? get deltaColor => getTransform<DeltaColor>()?.value;

  double? get deltaOpacity => getTransform<DeltaOpacity>()?.value;

  Offset? get deltaCurve => getTransform<DeltaCurve>()?.value;

  Offset? origin;

  bool notifyOnTick = true;

  void onAttach(LoopComponent component) {}

  void onDetach() {}

  void onTick(double dt) {}

  @override
  void tick(double dt) {
    components.forEach((key, value) {
      if (value.active) {
        value.tick(dt);
      }
    });

    if (deltaOffset != null) {
      transform.position = deltaOffset!;
    }

    if (deltaRotation != null) {
      transform.rotation = deltaRotation!;
    }

    if (deltaScale != null) {
      transform.scale = deltaScale!;
    }

    onTick(dt);

    if (notifyOnTick) {
      notify();
    }
  }

  void attach(LoopComponent component, {dynamic socket}) {
    components[socket ?? component.runtimeType] = component;

    if (component is SceneComponent) {
      component.onAttach(this);
    }
  }

  void detach(LoopComponent component, {dynamic socket}) {
    components.remove(socket ?? component.runtimeType);

    if (component is SceneComponent) {
      component.onDetach();
    }
  }

  T? getTransform<T extends DeltaTransform>() => components.containsKey(T) ? components[T] as T : null;

  T applyTransform<T extends DeltaTransform>(T transform, {bool reset = false}) {
    final key = T == dynamic ? transform.runtimeType : T;

    if (reset || !components.containsKey(key)) {
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
        ),
        reset: reset);
  }

  DeltaScale scale(Offset scale, {Offset? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
        DeltaScale(
          duration: duration,
          begin: begin ?? transform.scale,
          end: scale,
        ),
        reset: reset);
  }

  DeltaRotation rotate(double degree, {double? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
        DeltaRotation(
          duration: duration,
          begin: begin != null ? begin * _toRadian : transform.rotation,
          end: degree * _toRadian,
        ),
        reset: reset);
  }

  DeltaOpacity opacity(double opacity, {double begin = 1.0, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
        DeltaOpacity(
          duration: duration,
          begin: begin,
          end: opacity,
        ),
        reset: reset);
  }

  DeltaColor color(Color color, {Color begin = Colors.white, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
        DeltaColor(
          duration: duration,
          begin: begin,
          end: color,
        ),
        reset: reset);
  }

  DeltaCurve curve(Offset location, Offset controlPoint, {Offset begin = Offset.zero, Duration duration = const Duration(seconds: 1), bool reset = false}) {
    return applyTransform(
        DeltaCurve(
          duration: duration,
          begin: begin,
          end: location,
          cp: controlPoint,
        ),
        reset: reset);
  }

  void updateLoopBehavior(LoopBehavior loop) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setLoopBehavior(loop);
      }
    });
  }

  void updateLoopReversion(bool reverse) {
    components.forEach((key, value) {
      if (value is DeltaTransform) {
        value.setReverse(reverse);
      }
    });
  }

  @override
  void dispose() {
    if (_loop != null) {
      _loop?.remove(this);
    }

    super.dispose();
  }
}
