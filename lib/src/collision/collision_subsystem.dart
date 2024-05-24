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

      if (!item.active || item.static) {
        continue;
      }

      for (int j = i + 1; j < _collisionItems.length; j++) {
        final other = _collisionItems[j];

        if (!other.active) {
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
}
