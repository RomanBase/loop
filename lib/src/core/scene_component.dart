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

  void onInit() {}

  LoopScene? _initLoop(LoopScene? scene) {
    assert(_loop == null, 'Can\'t attach to multiple loops');

    if (scene == null) {
      return null;
    }

    _loop = scene;
    onInit();
    _instantiate();

    return _loop;
  }

  void _instantiate() {
    components.forEach((key, value) {
      if (value is SceneComponent) {
        value.getLoop();
      }
    });
  }

  LoopScene? getLoop() {
    if (_loop != null) {
      return _loop;
    }

    return _initLoop(parent?.getLoop());
  }

  void onAttach(LoopComponent component) {
    assert(parent == null, 'Can\'t attach to multiple transform objects');

    if (component is LoopScene) {
      _initLoop(component);
      return;
    }

    if (component is SceneComponent) {
      parent = component;
    }
  }

  void onDetach() {
    _loop = null;
    parent = null;
  }

  void removeFromParent() {
    if (parent == null) {
      _loop?.detach(this);
    } else {
      parent?.detach(this);
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

  void onTick(double dt) {}

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
      _loop?.detach(this);
    }

    super.dispose();
  }
}
