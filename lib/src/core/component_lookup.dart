part of '../../loop.dart';

class ComponentLookup {
  const ComponentLookup._();

  static T? findComponentByTag<T extends LoopComponent>(Iterable<LoopComponent> items, String tag) => findComponent(items, (item) => item.tag == tag);

  static T? findComponent<T extends LoopComponent>(Iterable<LoopComponent> items, [bool Function(T object)? test]) {
    final children = <SceneComponent>[];

    for (var element in items) {
      if (element is T) {
        if (test == null || test.call(element)) {
          return element;
        }
      }

      if (element is SceneComponent) {
        children.add(element);
      }
    }

    for (final element in children) {
      final child = findComponent<T>(element.components.values, test);

      if (child != null) {
        return child;
      }
    }

    return null;
  }

  static Iterable<T> findComponents<T extends LoopComponent>(Iterable<LoopComponent> items, [bool Function(T object)? test]) {
    final output = <T>[];

    for (var element in items) {
      if (element is T) {
        if (test == null || test.call(element)) {
          output.add(element);
        }
      }

      if (element is SceneComponent) {
        output.addAll(findComponents<T>(element.components.values, test));
      }
    }

    return output;
  }

  static void proceedComponents<T extends LoopComponent>(Iterable<LoopComponent> items, void Function(T component) action, [bool Function(T object)? test]) {
    for (var element in items) {
      if (element is T) {
        if (test == null || test.call(element)) {
          action.call(element);
        }
      }

      if (element is SceneComponent) {
        proceedComponents<T>(element.components.values, action, test);
      }
    }
  }
}
