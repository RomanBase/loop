part of '../../loop.dart';

class SceneComponent with ObservableLoopComponent {
  final components = HashMap<dynamic, LoopComponent>();

  final transform = TransformMatrix();

  Matrix4? _screenMatrix;
  Matrix4? _worldMatrix;

  Matrix4 get screenMatrix => _screenMatrix ??= _screenSpace();

  Matrix4 get worldMatrix => _worldMatrix ??= _worldSpace();

  SceneComponent? parent;

  LoopScene? _loop;

  bool get isMounted => _loop != null;

  bool notifyOnTick = true;

  bool static = false;

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

  Rect getBounds(Size size) {
    final sx = worldMatrix.scaleX2D;
    final sy = worldMatrix.scaleY2D;

    final sSize = Size(size.width * sx, size.height * sy);
    final dstOrigin = Offset(transform.origin.dx * sSize.width, transform.origin.dy * sSize.height);

    return (worldMatrix.position2D - dstOrigin) & sSize;
  }

  T? getComponent<T>([dynamic slot]) {
    final key = slot ?? T;

    return components.containsKey(key) ? components[key] as T : null;
  }

  T? findComponentByTag<T extends LoopComponent>(String tag, {bool root = false}) => ComponentLookup.findComponentByTag<T>(root ? getLoop()!.items : components.values, tag);

  T? findComponent<T extends LoopComponent>({bool root = false, bool Function(T object)? where}) => ComponentLookup.findComponent<T>(root ? getLoop()!.items : components.values, where);

  Iterable<T> findComponents<T extends LoopComponent>({bool root = false, bool Function(T object)? where}) => ComponentLookup.findComponents<T>(root ? getLoop()!.items : components.values, where);

  T? getSubsystem<T>({bool main = true}) => getLoop()?.getSubsystem<T>(main: main);

  @override
  void destroy() {
    super.destroy();

    components.forEach((key, value) => value.destroy());
    dispose();
  }

  @override
  void dispose() {
    if (parent == null) {
      _loop?.detach(this);
    } else {
      parent?.detach(this);
    }

    super.dispose();
  }
}
