part of '../../loop.dart';

class _ToAttach<T> {
  final T component;
  final bool attach;

  const _ToAttach({
    required this.component,
    required this.attach,
  });

  void weakInit(ComponentEmitter emitter) {
    if (component is SceneComponent) {
      (component as SceneComponent)
        .._loop = emitter.getLoop()
        ..onInit();
    }
  }
}

class ComponentEmitter<T extends LoopComponent> extends SceneComponent {
  final emittedObjects = HashMap<dynamic, T>();
  final _toEmit = HashMap<dynamic, _ToAttach>();

  void emit(T component, {dynamic slot, bool attach = false}) {
    _toEmit[slot ?? component.hashCode] = _ToAttach(component: component, attach: attach);
  }

  @override
  void preTick(double dt) {
    super.preTick(dt);

    if (_toEmit.isNotEmpty) {
      _toEmit.forEach((key, value) {
        if (value.attach) {
          attach(value.component, slot: key);
        } else {
          emittedObjects[key] = value.component;
          value.weakInit(this);
        }
      });
      _toEmit.clear();
    }
  }

  @override
  void onTick(double dt) {
    super.onTick(dt);

    for (final key in emittedObjects.keys) {
      final object = emittedObjects[key]!;
      if (object.active) {
        object.tick(dt);
      } else {
        object.destroy();
      }
    }

    emittedObjects.removeWhere((key, value) => !value.active);
  }

  @override
  void destroy() {
    _toEmit.forEach((key, value) => value.component.destroy());
    _toEmit.clear();

    emittedObjects.forEach((key, value) => value.destroy());
    emittedObjects.clear();

    super.destroy();
  }
}
