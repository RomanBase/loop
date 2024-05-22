part of '../../loop.dart';

mixin LoopCollision on SceneComponent {
  final Set<LoopCollision> overlapComponents = <LoopCollision>{};
  final _collisionChild = <LoopCollision>{};
  LoopComponent? _collisionParent;

  int collisionMask = 0x0001;

  Rect get bounds;

  Function(LoopCollision other)? onCollision;
  Function(LoopCollision other)? onCollisionEnded;

  void onBeginOverlap(LoopCollision other) {
    overlapComponents.add(other);
    onCollision?.call(other);
  }

  void onEndOverlap(LoopCollision other) {
    overlapComponents.remove(other);
    onCollisionEnded?.call(other);
  }

  bool overlaps(LoopCollision other) {
    if (bounds.overlaps(other.bounds)) {
      return _collisionChild.isEmpty || _collisionChild.any((element) => element.overlaps(other));
    }

    return false;
  }

  @override
  void attach(LoopComponent component, {slot}) {
    if (component is LoopCollision) {
      _collisionChild.add(component);
    }

    super.attach(component, slot: slot);
  }

  @override
  void onAttach(LoopComponent component) {
    super.onAttach(component);

    if (component is LoopCollision) {
      _collisionParent = component;
    } else {
      (_collisionParent = getLoop() as LoopCollisionSubsystem).addCollisionComponent(this);
    }
  }

  @override
  void onDetach() {
    super.onDetach();

    if (_collisionParent is LoopCollisionSubsystem) {
      (_collisionParent as LoopCollisionSubsystem).removeCollisionComponent(this);
    } else if (_collisionParent is LoopCollision) {}

    _collisionParent = null;
  }
}

mixin LoopCollisionSubsystem on LoopScene {
  final _collisionItems = <LoopCollision>[];

  void addCollisionComponent(LoopCollision component) => _collisionItems.add(component);

  bool removeCollisionComponent(LoopCollision component) => _collisionItems.remove(component);

  @override
  void onTick(double dt) {
    if (_collisionItems.length < 2) {
      return;
    }

    for (int i = 0; i < _collisionItems.length - 2; i++) {
      final item = _collisionItems[i];

      if (!item.active) {
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

class CollisionLoopScene extends LoopScene with LoopCollisionSubsystem {}
