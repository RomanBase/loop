part of '../../loop.dart';

mixin LoopCollisionSubsystem on ObservableLoop {
  final _collisionItems = <LoopCollisionComponent>[];

  void addCollisionComponent(LoopCollisionComponent component) => _collisionItems.add(component);

  bool removeCollisionComponent(LoopCollisionComponent component) => _collisionItems.remove(component);

  @override
  void onTick(double dt) {
    if (_collisionItems.length < 2) {
      return;
    }

    for (int i = 0; i < _collisionItems.length - 1; i++) {
      final item = _collisionItems[i];

      if (!item.canCollide || item.static) {
        continue;
      }

      for (int j = i + 1; j < _collisionItems.length; j++) {
        final other = _collisionItems[j];

        if (!other.canCollide) {
          continue;
        }

        if (item.collisionMask & other.collisionMask != 0) {
          if (item.overlaps(other)) {
            if (!item.overlapComponents.contains(other)) {
              item.onBeginOverlap(other);
            }

            if (!other.overlapComponents.contains(item)) {
              other.onBeginOverlap(item);
            }
          } else {
            if (item.overlapComponents.contains(other)) {
              item.onEndOverlap(other);
            }

            if (other.overlapComponents.contains(item)) {
              other.onEndOverlap(item);
            }
          }
        }
      }
    }
  }

  List<LoopCollisionComponent> getCollisionTree() {
    final items = <LoopCollisionComponent>[];

    for (final element in _collisionItems) {
      _fillCollisionTree(element, items);
    }

    return items;
  }

  void _fillCollisionTree(LoopCollisionComponent component, List<LoopCollisionComponent> out) {
    out.add(component);

    for (final element in component._collisionChild) {
      _fillCollisionTree(element, out);
    }
  }
}
