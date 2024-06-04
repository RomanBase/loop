part of '../../loop.dart';

enum ComponentAction {
  none,
  create,
  attach,
  detach,
  destroy,
}

class _ComponentAction {
  final dynamic key;
  final ComponentAction action;
  final LoopComponent component;

  const _ComponentAction({
    this.key,
    this.action = ComponentAction.none,
    required this.component,
  });
}

mixin LoopComponent {
  late String tag = '$runtimeType';
  bool active = true;

  void tick(double dt);

  void destroy() {
    active = false;
  }
}

class Loop with LoopComponent, ObservableLoop, RenderComponent, RenderQueue, LoopLeaf, PointerDispatcher {
  final viewport = ViewportMatrix();
  final items = <LoopComponent>[];
  final _actions = <_ComponentAction>[];
  bool _tickActive = false;

  //TODO: custom struct
  /// We don't care about rotation during visibility test, so [framePadding] extends viewport bounds.
  final frame = ActionControl.broadcast<Rect>(Rect.zero);

  double get framePadding => 32.0;

  void updateViewportSize(Size canvasSize, {double? requiredWidth, double? requiredHeight, double? ratio}) {
    if (frame.internalData == canvasSize) {
      return;
    }

    frame.internalData = canvasSize;
    size = viewport.updateViewport(
      canvasSize,
      requiredWidth: requiredWidth,
      requiredHeight: requiredHeight,
      ratio: ratio,
    );
    frame.value = Rect.fromLTRB(
      -framePadding,
      -framePadding,
      (size.width * viewport.scale) + framePadding,
      (size.height * viewport.scale) + framePadding,
    );
  }

  @override
  Pointer transformPointer(PointerEvent event) => Pointer(
        event,
        (event.localPosition * viewport.reverseScale) + viewport.position,
      );

  void attach(LoopComponent component) {
    assert(component is! SceneComponent || !component.isMounted, 'Can\'t use one Component in multiple Scenes');

    _add(component);

    if (component is SceneComponent) {
      component.onAttach(this);
    }

    notify();
  }

  void detach(LoopComponent component) {
    if (_remove(component)) {
      if (component is SceneComponent) {
        component.onDetach();
      }

      notify();
    }
  }

  void _add(LoopComponent component) {
    if (_tickActive) {
      _actions.add(_ComponentAction(
        action: ComponentAction.attach,
        component: component,
      ));
      return;
    }

    items.add(component);
  }

  bool _remove(LoopComponent component) {
    if (_tickActive) {
      _actions.add(_ComponentAction(
        action: ComponentAction.detach,
        component: component,
      ));

      return true;
    }

    return items.remove(component);
  }

  void preTick(double dt) {
    if (_actions.isNotEmpty) {
      for (final element in _actions) {
        switch (element.action) {
          case ComponentAction.attach:
            items.add(element.component);
            break;
          case ComponentAction.detach:
            items.remove(element.component);
            break;
          default:
        }
      }

      _actions.clear();
    }
  }

  @override
  void tick(double dt) {
    if (!active) {
      return;
    }

    setValue(dt);
    dt = value;
    preTick(dt);

    _tickActive = true;
    for (final element in items) {
      if (element.active) {
        element.tick(dt);

        if (element is RenderComponent) {
          pushRenderComponent(element);
        }
      }
    }
    _tickActive = false;

    onTick(dt);
  }

  @override
  void onTick(double dt) {}

  @override
  void render(Canvas canvas, Rect rect) {
    if (!visible) {
      return;
    }

    renderQueue(canvas, rect);
  }

  @override
  void pushRenderComponent(RenderComponent component) {
    if (!component.isVisible(frame.value)) {
      return;
    }

    super.pushRenderComponent(component);
  }

  T? findComponentByTag<T extends LoopComponent>(String tag) => ComponentLookup.findComponentByTag<T>(items, tag);

  T? findComponent<T extends LoopComponent>({bool Function(T object)? where}) => ComponentLookup.findComponent<T>(items, where);

  Iterable<T> findComponents<T extends LoopComponent>({bool Function(T object)? where}) => ComponentLookup.findComponents<T>(items, where);

  T? getSubsystem<T>({bool main = true}) {
    if (main && _control is T) {
      return _control as T;
    }

    if (this is T) {
      return this as T;
    }

    printDebug('Subsystem not found: $T');

    return null;
  }

  @override
  void dispose() {
    super.dispose();

    for (final element in items) {
      if (element is SceneComponent) {
        element._loop = null;
        element.dispose();
      }
    }

    items.clear();
  }

  @override
  String toString() {
    return 'Scene [${size.width.toInt()}, ${size.height.toInt()}] (${_renderQueue.length})';
  }
}
