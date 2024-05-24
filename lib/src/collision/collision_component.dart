part of '../../loop.dart';

mixin LoopCollisionComponent on SceneComponent {
  final Set<LoopCollisionComponent> overlapComponents = <LoopCollisionComponent>{};
  final _collisionChild = <LoopCollisionComponent>{};
  dynamic _collisionParent;

  int collisionMask = 0x0001;

  Rect? _bounds;

  Rect get bounds => _bounds ??= _bBox();

  Function(LoopCollisionComponent other)? onCollision;
  Function(LoopCollisionComponent other)? onCollisionEnded;

  Rect _bBox() {
    final matrix = worldMatrix;
    final position = matrix.position2D;
    late Rect rect;

    if (this is RenderComponent) {
      rect = getBounds((this as RenderComponent).size);
    } else {
      rect = Rect.fromLTWH(position.dx, position.dy, 0.0, 0.0);
      final components = findComponents(where: (item) => item is SceneComponent && item is RenderComponent);

      if (components.isNotEmpty) {
        for (final element in components) {
          final other = (element as SceneComponent).getBounds((element as RenderComponent).size);

          rect = Rect.fromLTRB(
            math.min(rect.left, other.left),
            math.min(rect.top, other.top),
            math.max(rect.right, other.right),
            math.max(rect.bottom, other.bottom),
          );
        }
      }
    }

    if (_collisionChild.isNotEmpty) {
      for (final element in _collisionChild) {
        final other = element.bounds;
        rect = Rect.fromLTRB(
          math.min(rect.left, other.left),
          math.min(rect.top, other.top),
          math.max(rect.right, other.right),
          math.max(rect.bottom, other.bottom),
        );
      }
    }

    return rect;
  }

  void onBeginOverlap(LoopCollisionComponent other) {
    overlapComponents.add(other);
    onCollision?.call(other);
  }

  void onEndOverlap(LoopCollisionComponent other) {
    overlapComponents.remove(other);
    onCollisionEnded?.call(other);
  }

  bool overlaps(LoopCollisionComponent other) {
    if (bounds.overlaps(other.bounds)) {
      return _collisionChild.isEmpty || _collisionChild.any((element) => element.overlaps(other));
    }

    return false;
  }

  @override
  void attach(LoopComponent component, {slot}) {
    super.attach(component, slot: slot);

    if (component is LoopCollisionComponent) {
      _collisionChild.add(component);
    }
  }

  @override
  void onInit() {
    super.onInit();

    if (_collisionParent == null) {
      (_collisionParent = getSubsystem<LoopCollisionSubsystem>())?.addCollisionComponent(this);
    }
  }

  @override
  void onAttach(LoopComponent component) {
    super.onAttach(component);

    if (component is LoopCollisionComponent) {
      _collisionParent = component;
    }
  }

  @override
  void onDetach() {
    super.onDetach();

    if (_collisionParent is LoopCollisionSubsystem) {
      (_collisionParent as LoopCollisionSubsystem).removeCollisionComponent(this);
    }

    _collisionParent = null;
  }
}

class LoopCollisionActor extends SceneComponent with LoopCollisionComponent {}
