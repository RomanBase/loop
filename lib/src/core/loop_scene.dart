part of '../../loop.dart';

class LoopScene extends BaseControl with ObservableLoop, LoopComponent, RenderComponent, LoopLeaf {
  final items = <SceneComponent>[];

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

    for (final element in items) {
      if (element.active) {
        element.tick(value);
      }
    }
  }

  @override
  void render(Canvas canvas, Rect rect) {
    if (!visible) {
      return;
    }

    for (final element in items) {
      if (element is RenderComponent) {
        final render = element as RenderComponent;

        if (render.visible && render.checkBounds(rect)) {
          render.render(canvas, rect);
        }
      }
    }
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
