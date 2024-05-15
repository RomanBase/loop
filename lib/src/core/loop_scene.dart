part of '../../loop.dart';

/// Just fake reversion Matrix that mimics orthographic projection when multiplied with local matrix.
class SceneViewport {
  final _transform = TransformMatrix();

  Matrix4 get matrix => _transform.matrix;

  Offset get position => -_transform.position;

  set position(Offset value) => _transform.position = -value;

  double get rotation => _transform.rotation;

  set rotation(double value) => _transform.rotation = -value;

  double get scale => _transform.scale.width;

  set scale(double value) => _transform.scale = Scale.of(value);

  Matrix4 combine(Matrix4 local) => matrix.multiplied(local);
}

class LoopScene extends BaseControl with ObservableLoop, LoopComponent, RenderComponent, RenderQueue, LoopLeaf {
  final viewport = SceneViewport();
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
        pushRenderComponent(element as RenderComponent);
      }
    }

    super.render(canvas, rect);
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
