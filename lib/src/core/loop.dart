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
  final VoidCallback? callback;

  const _ComponentAction({
    this.key,
    this.action = ComponentAction.none,
    required this.component,
    this.callback,
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
  final items = <LoopComponent>[];
  final _actions = <_ComponentAction>[];
  bool _tickActive = false;

  Viewport2D? _viewport2d;

  Viewport2D get viewport => _viewport2d ??= Viewport2D();

  //This can be called every frame
  void prepareViewport(Size canvasSize, {double? requiredWidth, double? requiredHeight}) {
    viewport.updateViewportFrame(
      canvasSize,
      requiredWidth: requiredWidth,
      requiredHeight: requiredHeight,
      onChanged: (viewSize) => size = viewSize,
    );
  }

  void syncAction(LoopComponent component, VoidCallback callback) {
    if (_tickActive) {
      _actions.add(_ComponentAction(
        component: component,
        callback: callback,
      ));
      return;
    }

    callback();
  }

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

        if (element.callback != null) {
          element.callback!();
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
    if (!component.isVisible(viewport.screenFrame)) {
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
  Pointer transformPointerEvent(PointerEvent event) => Pointer(event, viewport.transformLocalPoint(event.localPosition));

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
