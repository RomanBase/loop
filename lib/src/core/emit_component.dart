import 'dart:collection';
import 'dart:ui';

import 'package:loop/loop.dart';

abstract class ComponentEmitter<T extends LoopComponent> extends SceneComponent with RenderComponent {
  final emittedObjects = HashMap<dynamic, T>();
  final _toEmit = HashMap<dynamic, T>();

  void emit(T component, {dynamic slot}) => _toEmit[slot ?? component.hashCode] = component;

  @override
  void onTick(double dt) {
    if (_toEmit.isNotEmpty) {
      emittedObjects.addAll(_toEmit);
      _toEmit.clear();
    }

    for (final key in emittedObjects.keys) {
      final object = emittedObjects[key]!;
      if (object.active) {
        object.tick(dt);
      } else {
        emittedObjects.remove(key);
        object.destroy();
      }
    }
  }

  @override
  void destroy() {
    super.destroy();

    _toEmit.forEach((key, value) => value.destroy());
    _toEmit.clear();

    emittedObjects.forEach((key, value) => value.destroy());
    emittedObjects.clear();
  }
}
