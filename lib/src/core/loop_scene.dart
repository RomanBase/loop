part of '../../loop.dart';

class LoopScene extends BaseControl with ObservableLoop, LoopComponent, RenderComponent, RenderQueue, LoopLeaf {
  final viewport = SceneViewport();
  final items = <SceneComponent>[];
  final components = <Type, LoopComponent>{};

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

    for (final element in components.entries) {
      if (element.value.active) {
        element.value.tick(value);
      }
    }

    setValue(dt);

    for (final element in items) {
      if (element.active) {
        element.tick(value);

        if (element is RenderComponent) {
          pushRenderComponent(element as RenderComponent);
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
  void dispose() {
    super.dispose();

    for (final element in items) {
      element._loop = null;
      element.dispose();
    }

    items.clear();
  }
}
