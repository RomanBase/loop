part of '../../loop.dart';

class LoopScene extends BaseControl with ObservableLoop, LoopComponent, LoopLeaf {
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
  void dispose() {
    super.dispose();

    for (final element in _items) {
      element._loop = null;
      element.dispose();
    }

    _items.clear();
  }
}
