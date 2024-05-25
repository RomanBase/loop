part of '../../loop.dart';

class _ComponentAction {
  final bool attach;
  final dynamic key;
  final LoopComponent component;

  const _ComponentAction({
    required this.attach,
    required this.key,
    required this.component,
  });
}

class LoopScene extends LoopActor with ObservableLoop, RenderComponent, RenderQueue, LoopLeaf, PointerDispatcher {
  final viewport = ViewportMatrix();
  final items = <LoopComponent>[];

  //TODO: custom struct
  /// We don't care about rotation during visibility test, so [framePadding] extends viewport bounds.
  final frame = ActionControl.broadcast<Rect>(Rect.zero);

  double get framePadding => 32.0;

  void updateViewportSize(Size canvasSize, {double? requiredWidth, double? requiredHeight, double? ratio}) {
    if (frame.internalData == canvasSize) {
      return;
    }

    frame.internalData = canvasSize;
    size = viewport.updateViewport(canvasSize, requiredWidth: requiredWidth, requiredHeight: requiredHeight, ratio: ratio);
    frame.value = Rect.fromLTRB(-framePadding, -framePadding, (size.width * viewport.scale) + framePadding, (size.height * viewport.scale) + framePadding);
  }

  @override
  Pointer transformPointer(PointerEvent event) => Pointer(event, (event.localPosition * viewport.reverseScale) + viewport.position);

  void attach(SceneComponent component) {
    assert(!component.isMounted, 'Can\'t use one Component in multiple Scenes');

    add(component);
    component.onAttach(this);

    notify();
  }

  void detach(SceneComponent component) {
    if (component.isMounted && remove(component)) {
      component.onDetach();

      notify();
    }
  }

  void add(LoopComponent component) => items.add(component);

  bool remove(LoopComponent component) => items.remove(component);

  @override
  void tick(double dt) {
    if (!active) {
      return;
    }

    setValue(dt);
    dt = value;

    for (final element in items) {
      if (element.active) {
        element.tick(dt);

        if (element is RenderComponent) {
          pushRenderComponent(element);
        }
      }
    }

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
