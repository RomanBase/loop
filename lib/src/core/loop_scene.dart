part of '../../loop.dart';

class LoopScene extends LoopActor with ObservableLoop, RenderComponent, RenderQueue, LoopLeaf, PointerDispatcher {
  final viewport = SceneViewport();
  final items = <LoopComponent>[];

  //TODO: custom struct
  /// We don't care about rotation during visibility test, so [framePadding] extends viewport bounds.
  final frame = ActionControl.broadcast<Rect>(Rect.zero);

  double get framePadding => 32.0;

  @override
  set size(Size value) {
    super.size = value;
    frame.value = Rect.fromLTRB(-framePadding, -framePadding, size.width + framePadding, size.height + framePadding);
  }

  void attach(SceneComponent component) {
    assert(!component.isMounted, 'Can\'t use one Component in multiple Scenes');

    items.add(component);
    component.onAttach(this);

    notify();
  }

  void detach(SceneComponent component) {
    if (component.isMounted && items.remove(component)) {
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
    if (!component.isVisible(frame.value)) {
      return;
    }

    super.pushRenderComponent(component);
  }

  T? findComponentByTag<T extends LoopComponent>(String tag) => ComponentLookup.findComponentByTag<T>(items, tag);

  T? findComponent<T extends LoopComponent>({bool Function(T object)? where}) => ComponentLookup.findComponent<T>(items, where);

  Iterable<T> findComponents<T extends LoopComponent>({bool Function(T object)? where}) => ComponentLookup.findComponents<T>(items, where);

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
