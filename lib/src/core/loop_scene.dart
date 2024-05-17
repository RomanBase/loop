part of '../../loop.dart';

class LoopScene extends LoopActor with ObservableLoop, RenderComponent, RenderQueue, LoopLeaf implements PointerListener {
  final viewport = SceneViewport();
  final items = <LoopComponent>[];

  /// We don't care about rotation during visibility test, so [_safePadding] extends viewport bounds.
  Rect _safeZone = Rect.zero;

  double get _safePadding => 32.0;

  @override
  set size(Size value) {
    super.size = value;
    _safeZone = Rect.fromLTRB(-_safePadding, -_safePadding, size.width + _safePadding, size.height + _safePadding);
  }

  void add(SceneComponent component) {
    assert(!component.isMounted, 'Can\'t use one Component in multiple Scenes');

    items.add(component);
    component._loop = this;
    component.onAttach(this);

    notify();
  }

  void remove(SceneComponent component) {
    if (component.isMounted && items.remove(component)) {
      component._loop = null;
      component.onDetach();

      notify();
    }
  }

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
  }

  @override
  void render(Canvas canvas, Rect rect) {
    if (!visible) {
      return;
    }

    renderQueue(canvas, rect);
  }

  @override
  void pushRenderComponent(RenderComponent component) {
    if (!component.isVisible(_safeZone)) {
      return;
    }

    super.pushRenderComponent(component);
  }

  @override
  bool onPointerDown(PointerEvent event) => PointerListener._proceed(items, event, (component) => component.onPointerDown(event));

  @override
  bool onPointerHover(PointerEvent event) => PointerListener._proceed(items, event, (component) => component.onPointerHover(event));

  @override
  bool onPointerUp(PointerEvent event) => PointerListener._proceed(items, event, (component) => component.onPointerUp(event));

  @override
  bool onPointerMove(PointerEvent event) => PointerListener._proceed(items, event, (component) => component.onPointerMove(event));

  @override
  bool onPointerCancel(PointerEvent event) => PointerListener._proceed(items, event, (component) => component.onPointerCancel(event));

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
}
