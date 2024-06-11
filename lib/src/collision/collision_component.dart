part of '../../loop.dart';

mixin LoopCollisionComponent on SceneComponent {
  final Set<LoopCollisionComponent> overlapComponents = <LoopCollisionComponent>{};
  final _collisionChild = <LoopCollisionComponent>{};
  dynamic _collisionParent;

  int collisionMask = 0x0001;

  Rect? _bounds;

  Rect get collisionBounds => _bounds ??= _bBox();

  Size? get collisionSize => this is RenderComponent ? (this as RenderComponent).size : null;

  bool get canCollide => collisionMask > 0;

  Function(LoopCollisionComponent other)? onCollision;
  Function(LoopCollisionComponent other)? onCollisionEnded;

  Rect _bBox() {
    late Rect rect;

    if (collisionSize != null) {
      rect = getBounds(collisionSize!);
    } else {
      final position = worldMatrix.position2D;
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
        final other = element.collisionBounds;
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
    if (collisionBounds.overlaps(other.collisionBounds)) {
      return _collisionChild.isEmpty || _collisionChild.any((element) => element.overlaps(other));
    }

    return false;
  }

  @override
  void onInit() {
    super.onInit();

    if (_collisionParent == null) {
      (_collisionParent = getSubsystem<LoopCollisionSubsystem>())?.addCollisionComponent(this);
    }
  }

  @override
  void attach(LoopComponent component, {slot}) {
    super.attach(component, slot: slot);

    if (component is LoopCollisionComponent) {
      _collisionChild.add(component);
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
  void removeFromParent() {
    if (_collisionParent is LoopCollisionSubsystem) {
      (_collisionParent as LoopCollisionSubsystem).removeCollisionComponent(this);
    }

    _collisionParent = null;

    super.removeFromParent();
  }

  @override
  void preTick(double dt) {
    super.preTick(dt);

    _bounds = null;
  }
}

class LoopCollisionActor extends SceneComponent with LoopCollisionComponent {}

class LoopColliderComponent extends LoopCollisionActor {
  Size? size;

  LoopColliderComponent({
    this.size,
  });

  @override
  Size? get collisionSize => size ?? (parent is RenderComponent ? (parent as RenderComponent).size : null);
}
