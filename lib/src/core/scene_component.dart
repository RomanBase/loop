part of '../../loop.dart';

class SceneComponent with ObservableLoopComponent {
  final components = <Type, LoopComponent>{};

  final transform = TransformMatrix();

  Matrix4 get globalTransform => transform.of(parent);

  SceneComponent? parent;

  LoopScene? _loop;

  bool get isMounted => _loop != null;

  bool notifyOnTick = true;

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

  void attach(LoopComponent component, {dynamic socket}) {
    components[socket ?? component.runtimeType] = component;

    if (component is SceneComponent) {
      component.onAttach(this);
    }
  }

  void detach(LoopComponent component, {dynamic socket}) {
    components.remove(socket ?? component.runtimeType);

    if (component is SceneComponent) {
      component.onDetach();
    }
  }

  T? getComponent<T>() => components.containsKey(T) ? components[T] as T : null;

  @override
  void dispose() {
    if (_loop != null) {
      _loop?.remove(this);
    }

    super.dispose();
  }
}
