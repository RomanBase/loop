part of '../../loop.dart';

class SceneComponent with ObservableLoopComponent {
  final components = <dynamic, LoopComponent>{};

  final transform = TransformMatrix();

  Matrix4? _screenMatrix;
  Matrix4? _worldMatrix;

  Matrix4 get screenMatrix => _screenMatrix ??= _screenSpace();

  Matrix4 get worldMatrix => _worldMatrix ??= _worldSpace();

  SceneComponent? parent;

  LoopScene? _loop;

  bool get isMounted => _loop != null;

  bool notifyOnTick = true;

  Matrix4 _screenSpace() {
    if (parent == null) {
      return getLoop()?.viewport.multiply(transform.matrix) ?? transform.matrix;
    }

    return parent!.screenMatrix.multiplied2DTransform(transform.matrix);
  }

  Matrix4 _worldSpace() {
    if (parent == null) {
      return transform.matrix;
    }

    return parent!.screenMatrix.multiplied2DTransform(transform.matrix);
  }

  LoopScene? getLoop() {
    if (_loop != null) {
      return _loop;
    }

    if (parent is LoopScene) {
      return _loop = parent as LoopScene;
    }

    return _loop = parent?.getLoop();
  }

  void onAttach(LoopComponent component) {
    if (component is SceneComponent) {
      assert(parent == null, 'Can\'t attach to multiple transform objects');

      parent = component;
      _loop ??= getLoop();
    }
  }

  void onDetach() {
    _loop = null;
    parent = null;
  }

  void onTick(double dt) {}

  @override
  void tick(double dt) {
    _worldMatrix = null;
    _screenMatrix = null;

    components.forEach((key, value) {
      if (value.active) {
        value.tick(dt);

        if (value is RenderComponent) {
          getLoop()?.pushRenderComponent(value);
        }
      }
    });

    onTick(dt);

    if (notifyOnTick) {
      notify();
    }
  }

  void attach(LoopComponent component, {dynamic slot}) {
    components[slot ?? component.hashCode] = component;

    if (component is SceneComponent) {
      component.onAttach(this);
    }
  }

  void detach(LoopComponent component, {dynamic slot}) {
    components.remove(slot ?? component.hashCode);

    if (component is SceneComponent) {
      component.onDetach();
    }
  }

  void removeFromParent() => parent?.detach(this);

  T? getComponent<T>([dynamic slot]) {
    final key = slot ?? T;

    return components.containsKey(key) ? components[key] as T : null;
  }

  T? findComponentByTag<T extends LoopComponent>(String tag, {bool root = true}) => ComponentLookup.findComponentByTag<T>(root ? getLoop()!.items : components.values, tag);

  T? findComponent<T extends LoopComponent>({bool root = true, bool Function(T object)? where}) => ComponentLookup.findComponent<T>(root ? getLoop()!.items : components.values, where);

  Iterable<T> findComponents<T extends LoopComponent>({bool root = true, bool Function(T object)? where}) => ComponentLookup.findComponents<T>(root ? getLoop()!.items : components.values, where);

  @override
  void dispose() {
    if (_loop != null) {
      _loop?.remove(this);
    }

    super.dispose();
  }
}
