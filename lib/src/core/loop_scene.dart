part of '../../loop.dart';

class LoopScene extends BaseControl with ObservableLoop, LoopComponent, RenderComponent, LoopLeaf {
  final _items = <SceneComponent>[];

  void add(SceneComponent component) {
    assert(!component.isMounted, 'Can\'t use one Component in multiple Scenes');

    _items.add(component);
    component._loop = this;
    component.onAttach();

    notify();
  }

  void remove(SceneComponent component) {
    if (component.isMounted && _items.remove(component)) {
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

    for (final element in _items) {
      if (element.active) {
        element.tick(dt);
      }
    }
  }

  @override
  void render(Canvas canvas, Rect rect) {
    if (!visible) {
      return;
    }

    for (final element in _items) {
      if (element is RenderComponent) {
        final render = element as RenderComponent;

        if (render.visible && render.checkBounds(rect)) {
          render.render(canvas, rect);
        }
      }
    }

    super.render(canvas, rect); //debug bounds
  }

  @override
  void dispose() {
    super.dispose();

    for (final element in _items) {
      element._loop = null;
      element.dispose();
    }

    _items.clear();
  }
}
