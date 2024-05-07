part of '../../loop.dart';

class SceneComponent with ObservableLoopComponent, RenderQueue {
  final components = <Type, LoopComponent>{};

  final transform = TransformMatrix();

  Matrix4 get globalTransform => transform.of(parent);

  LoopScene? _loop;

  LoopScene get loop => _loop!;

  bool get isMounted => _loop != null;

  Offset? get deltaOffset => getTransform<DeltaPosition>()?.value;

  Scale? get deltaScale => getTransform<DeltaScale>()?.value;

  double? get deltaRotation => getTransform<DeltaRotation>()?.value;

  Color? get deltaColor => getTransform<DeltaColor>()?.value;

  double? get deltaOpacity => getTransform<DeltaOpacity>()?.value;

  Offset? get deltaCurve => getTransform<DeltaCurve>()?.value;

  bool notifyOnTick = true;

  SceneComponent? parent;

  void onAttach(LoopComponent component) {
    if (component is SceneComponent) {
      assert(parent == null, 'Can\'t attach to multiple transform object');

      parent = component;
    }
  }

  void onDetach() {
    parent = null;
  }

  void onTick(double dt) {}

  @override
  void tick(double dt) {
    components.forEach((key, value) {
      if (value.active) {
        value.tick(dt);

        if (value is RenderComponent) {
          componentQueue.add(value);
        }
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

  DeltaScale scale(Scale scale, {Scale? begin, Duration duration = const Duration(seconds: 1), bool reset = false}) {
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
